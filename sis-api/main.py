"""
SIS Admin API — JWT authentication (for humans)
Manages users, API clients, layers, and settings.
"""

from fastapi import FastAPI, Depends, HTTPException, status, Request, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime, timedelta
from urllib.parse import urlparse, parse_qs
import os
import re
import csv
import io
import secrets
import psycopg2
from psycopg2 import sql as pgsql
from psycopg2.extras import RealDictCursor
import requests as http_requests

from shared import (
    DB_CONFIG, ACCESS_TOKEN_EXPIRE_MINUTES,
    get_db, log_audit, get_client_ip,
    hash_password, verify_password, create_access_token,
    generate_api_key,
    UserLogin, Token, User, UserCreate, UserSelfUpdate, Layer, LayerCreate, PublishUpdate,
    Setting, SettingCreate, SettingUpdate, APIClient, APIClientCreate,
    get_current_user, get_current_admin_user, verify_api_key,
)

# /docs, /redoc, /openapi.json reveal the full API surface. Off by default;
# set ENABLE_DOCS=true in the env to re-enable for local development.
_docs_on = os.getenv("ENABLE_DOCS", "false").strip().lower() == "true"
app = FastAPI(
    title="SIS Admin API",
    description="JWT-protected API for managing users, API clients, layers, and settings.",
    version="1.0.0",
    docs_url="/docs" if _docs_on else None,
    redoc_url="/redoc" if _docs_on else None,
    openapi_url="/openapi.json" if _docs_on else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:80",
        "http://localhost:8001",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== Authentication ====================

LOGIN_MAX_ATTEMPTS = 5
LOGIN_LOCKOUT_MINUTES = 15

@app.post("/api/auth/login", response_model=Token)
async def login(user_credentials: UserLogin, request: Request):
    """Login with email/password — returns a JWT token.

    After LOGIN_MAX_ATTEMPTS consecutive failures the account is locked for
    LOGIN_LOCKOUT_MINUTES. A successful login resets the counter.
    """
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT user_id, password_hash, is_active, "
                "       failed_login_attempts, locked_until "
                "FROM api.user WHERE user_id = %s",
                (user_credentials.user_id,)
            )
            user = cur.fetchone()

            # Generic auth-error response — same message for unknown user / bad
            # password / locked account so we don't leak which one it was.
            generic_unauthorized = HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )

            if not user:
                log_audit(user_credentials.user_id, None, "login_failed",
                          {"reason": "unknown_user"}, get_client_ip(request))
                raise generic_unauthorized

            # Lockout window still active?
            if user.get("locked_until") and user["locked_until"] > datetime.now(user["locked_until"].tzinfo):
                log_audit(user["user_id"], None, "login_locked",
                          {"locked_until": user["locked_until"].isoformat()},
                          get_client_ip(request))
                raise generic_unauthorized

            if not verify_password(user_credentials.password, user['password_hash']):
                # Increment failed counter; lock if threshold reached
                attempts = (user.get("failed_login_attempts") or 0) + 1
                if attempts >= LOGIN_MAX_ATTEMPTS:
                    cur.execute(
                        "UPDATE api.user SET failed_login_attempts = %s, "
                        "       locked_until = now() + (%s || ' minutes')::interval "
                        "WHERE user_id = %s",
                        (attempts, LOGIN_LOCKOUT_MINUTES, user["user_id"])
                    )
                    log_audit(user["user_id"], None, "login_account_locked",
                              {"attempts": attempts}, get_client_ip(request))
                else:
                    cur.execute(
                        "UPDATE api.user SET failed_login_attempts = %s "
                        "WHERE user_id = %s",
                        (attempts, user["user_id"])
                    )
                    log_audit(user["user_id"], None, "login_failed",
                              {"attempts": attempts}, get_client_ip(request))
                raise generic_unauthorized

            if not user['is_active']:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="User account is inactive"
                )

            # Successful login — reset lockout state
            cur.execute(
                "UPDATE api.user SET last_login = %s, "
                "       failed_login_attempts = 0, locked_until = NULL "
                "WHERE user_id = %s",
                (datetime.now(), user['user_id'])
            )
            log_audit(user['user_id'], None, "login_success", None, get_client_ip(request))
            access_token = create_access_token(
                data={"sub": user['user_id']},
                expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            )
            return {"access_token": access_token, "token_type": "bearer"}

@app.patch("/api/users/me")
async def update_own_account(
    payload: UserSelfUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update the logged-in user's own email and/or password. Requires current password."""
    if payload.new_user_id is None and payload.new_password is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                            detail="Nothing to update")

    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT password_hash FROM api.user WHERE user_id = %s",
                (current_user['user_id'],))
            row = cur.fetchone()
            if not row or not verify_password(payload.current_password, row['password_hash']):
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                    detail="Current password is incorrect")

            new_user_id = payload.new_user_id or current_user['user_id']

            if payload.new_user_id and payload.new_user_id != current_user['user_id']:
                cur.execute("SELECT 1 FROM api.user WHERE user_id = %s",
                            (payload.new_user_id,))
                if cur.fetchone():
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                                        detail="Email already in use")

            # Bump password_changed_at on every password change so old JWTs
            # for this user are rejected by get_current_user (see shared.py).
            if payload.new_password and payload.new_user_id:
                cur.execute(
                    "UPDATE api.user SET user_id = %s, password_hash = %s, "
                    "password_changed_at = now() WHERE user_id = %s",
                    (payload.new_user_id, hash_password(payload.new_password), current_user['user_id']))
            elif payload.new_password:
                cur.execute(
                    "UPDATE api.user SET password_hash = %s, password_changed_at = now() "
                    "WHERE user_id = %s",
                    (hash_password(payload.new_password), current_user['user_id']))
            elif payload.new_user_id:
                cur.execute(
                    "UPDATE api.user SET user_id = %s WHERE user_id = %s",
                    (payload.new_user_id, current_user['user_id']))

            log_audit(current_user['user_id'], None, "user_self_updated",
                     {"new_user_id": payload.new_user_id,
                      "password_changed": payload.new_password is not None}, None)

            result = {"message": "Account updated successfully"}
            if payload.new_user_id and payload.new_user_id != current_user['user_id']:
                new_token = create_access_token(
                    data={"sub": new_user_id},
                    expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
                result["access_token"] = new_token
                result["token_type"] = "bearer"
            return result

@app.get("/api/auth/verify")
async def verify_token(current_user: dict = Depends(get_current_user)):
    """Verify that a JWT token is valid."""
    return {
        "user_id": current_user['user_id'],
        "is_admin": current_user['is_admin'],
        "message": "Token is valid"
    }

# ==================== User Management (Admin Only) ====================

@app.post("/api/users", status_code=status.HTTP_201_CREATED)
async def create_user(
    user: UserCreate,
    current_user: dict = Depends(get_current_admin_user)
):
    """Create a new user (admin only)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "INSERT INTO api.user (user_id, password_hash, is_admin) VALUES (%s, %s, %s)",
                    (user.user_id, hash_password(user.password), user.is_admin)
                )
                log_audit(current_user['user_id'], None, "user_created", {"new_user": user.user_id}, None)
                return {"message": "User created successfully", "user_id": user.user_id}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User already exists")

@app.get("/api/users", response_model=List[User])
async def list_users(current_user: dict = Depends(get_current_admin_user)):
    """List all users (admin only)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT user_id, is_active, is_admin, created_at, last_login FROM api.user ORDER BY created_at DESC"
            )
            return [dict(u) for u in cur.fetchall()]

@app.patch("/api/users/{user_id}/active")
async def toggle_user_active(user_id: str, is_active: bool, current_user: dict = Depends(get_current_admin_user)):
    """Activate or deactivate a user (admin only)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("UPDATE api.\"user\" SET is_active = %s WHERE user_id = %s", (is_active, user_id))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
            log_audit(current_user['user_id'], None, "user_active_toggled",
                     {"user": user_id, "is_active": is_active}, None)
            return {"message": f"User {'activated' if is_active else 'deactivated'} successfully"}

@app.delete("/api/users/{user_id}")
async def delete_user(user_id: str, current_user: dict = Depends(get_current_admin_user)):
    """Delete a user (admin only)."""
    if user_id == current_user['user_id']:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot delete your own account")
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.user WHERE user_id = %s", (user_id,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
            log_audit(current_user['user_id'], None, "user_deleted", {"deleted_user": user_id}, None)
            return {"message": "User deleted successfully"}

# ==================== API Client Management (Admin Only) ====================

@app.post("/api/clients", status_code=status.HTTP_201_CREATED)
async def create_api_client(
    client: APIClientCreate,
    current_user: dict = Depends(get_current_admin_user)
):
    """Create a new API client and return its key once (admin only)."""
    api_key = generate_api_key()
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    """
                    INSERT INTO api.api_client (api_client_id, api_key, description, expires_at)
                    VALUES (%s, %s, %s, %s)
                    """,
                    (client.api_client_id, api_key, client.description, client.expires_at)
                )
                log_audit(current_user['user_id'], None, "api_client_created",
                         {"client_id": client.api_client_id}, None)
                return {
                    "message": "API client created successfully",
                    "api_client_id": client.api_client_id,
                    "api_key": api_key,
                    "warning": "Save this API key now. You won't be able to see it again!"
                }
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="API client already exists")

@app.get("/api/clients", response_model=List[APIClient])
async def list_api_clients(current_user: dict = Depends(get_current_admin_user)):
    """List all API clients without their keys (admin only)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT api_client_id, is_active, created_at, expires_at, description, last_login
                FROM api.api_client ORDER BY created_at DESC
                """
            )
            return [dict(c) for c in cur.fetchall()]

@app.patch("/api/clients/{api_client_id}/status")
async def update_api_client_status(
    api_client_id: str,
    is_active: bool,
    current_user: dict = Depends(get_current_admin_user)
):
    """Activate or deactivate an API client (admin only)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE api.api_client SET is_active = %s WHERE api_client_id = %s",
                (is_active, api_client_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="API client not found")
            log_audit(current_user['user_id'], None, "api_client_status_changed",
                     {"client_id": api_client_id, "is_active": is_active}, None)
            return {"message": f"API client {'activated' if is_active else 'deactivated'} successfully"}

@app.delete("/api/clients/{api_client_id}")
async def delete_api_client(
    api_client_id: str,
    current_user: dict = Depends(get_current_admin_user)
):
    """Delete an API client (admin only)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.api_client WHERE api_client_id = %s", (api_client_id,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="API client not found")
            log_audit(current_user['user_id'], None, "api_client_deleted",
                     {"deleted_client": api_client_id}, None)
            return {"message": "API client deleted successfully"}

# ==================== Layer Management ====================

@app.post("/api/layer", status_code=status.HTTP_201_CREATED)
async def create_layer(layer: LayerCreate, current_user: dict = Depends(get_current_user)):
    """Create a new layer."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    """
                    INSERT INTO api.layer
                    (project_id, project_name, layer_id, publish, property_name,
                     dimension, version, unit_of_measure_id, metadata_url,
                     download_url, get_map_url, get_legend_url, get_feature_info_url)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (layer.project_id, layer.project_name, layer.layer_id,
                     str(layer.publish).lower(),
                     layer.property_name, layer.dimension, layer.version,
                     layer.unit_of_measure_id, layer.metadata_url, layer.download_url,
                     layer.get_map_url, layer.get_legend_url, layer.get_feature_info_url)
                )
                log_audit(current_user['user_id'], None, "layer_created", {"layer_id": layer.layer_id}, None)
                return {"message": "Layer created successfully", "layer_id": layer.layer_id}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Layer already exists")

@app.put("/api/layer/{layer_id}")
async def update_layer(layer_id: str, layer: Layer, current_user: dict = Depends(get_current_user)):
    """Update a layer."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE api.layer SET
                    project_id = %s, project_name = %s, publish = %s,
                    property_name = %s, dimension = %s, version = %s,
                    unit_of_measure_id = %s, metadata_url = %s, download_url = %s,
                    get_map_url = %s, get_legend_url = %s, get_feature_info_url = %s
                WHERE layer_id = %s
                """,
                (layer.project_id, layer.project_name, str(layer.publish).lower(),
                 layer.property_name, layer.dimension, layer.version,
                 layer.unit_of_measure_id, layer.metadata_url, layer.download_url,
                 layer.get_map_url, layer.get_legend_url, layer.get_feature_info_url,
                 layer_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Layer not found")
            log_audit(current_user['user_id'], None, "layer_updated", {"layer_id": layer_id}, None)
            return {"message": "Layer updated successfully"}

@app.patch("/api/layer/{layer_id}/publish")
async def update_layer_publish(
    layer_id: str,
    publish_data: PublishUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Publish or unpublish a layer. Unpublishing clears is_default."""
    with get_db() as conn:
        with conn.cursor() as cur:
            if publish_data.publish:
                cur.execute(
                    "UPDATE api.layer SET publish = 'true' WHERE layer_id = %s",
                    (layer_id,))
            else:
                cur.execute(
                    "UPDATE api.layer SET publish = 'false', is_default = FALSE WHERE layer_id = %s",
                    (layer_id,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Layer not found")
            log_audit(current_user['user_id'], None, "layer_publish_changed",
                     {"layer_id": layer_id, "publish": publish_data.publish}, None)
            return {"message": "Layer publish status updated successfully"}

@app.patch("/api/layer/{layer_id}/default")
async def set_default_layer(
    layer_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Mark a layer as the default (clears previous default). Layer must be published."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT publish FROM api.layer WHERE layer_id = %s", (layer_id,))
            row = cur.fetchone()
            if not row:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Layer not found")
            if str(row[0]).lower() != 'true':
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Only a published layer can be set as default")
            cur.execute("UPDATE api.layer SET is_default = FALSE WHERE is_default = TRUE")
            cur.execute("UPDATE api.layer SET is_default = TRUE WHERE layer_id = %s", (layer_id,))
            log_audit(current_user['user_id'], None, "layer_default_set",
                     {"layer_id": layer_id}, None)
            return {"message": "Default layer updated successfully"}

@app.post("/api/default-layer/clear")
async def clear_default_layer(current_user: dict = Depends(get_current_user)):
    """Clear the default layer (no layer will be default)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("UPDATE api.layer SET is_default = FALSE WHERE is_default = TRUE")
            log_audit(current_user['user_id'], None, "layer_default_cleared", None, None)
            return {"message": "Default layer cleared"}

@app.delete("/api/layer/{layer_id}")
async def delete_layer(layer_id: str, current_user: dict = Depends(get_current_user)):
    """Delete a layer."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.layer WHERE layer_id = %s", (layer_id,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Layer not found")
            log_audit(current_user['user_id'], None, "layer_deleted", {"layer_id": layer_id}, None)
            return {"message": "Layer deleted successfully"}

@app.get("/api/layer/all", response_model=List[Layer])
async def get_all_layers(current_user: dict = Depends(get_current_user)):
    """Get all layers including unpublished ones."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.layer ORDER BY layer_id")
            return [dict(l) for l in cur.fetchall()]

# ==================== Settings Management ====================

@app.post("/api/setting", status_code=status.HTTP_201_CREATED)
async def create_setting(setting: SettingCreate, current_user: dict = Depends(get_current_admin_user)):
    """Create a new setting."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "INSERT INTO api.setting (key, value) VALUES (%s, %s)",
                    (setting.key, setting.value)
                )
                log_audit(current_user['user_id'], None, "setting_created", {"key": setting.key}, None)
                return {"message": "Setting created successfully", "key": setting.key}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Setting already exists")

@app.put("/api/setting/{key}")
async def update_setting(
    key: str,
    setting_update: SettingUpdate,
    current_user: dict = Depends(get_current_admin_user)
):
    """Update a setting value."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("UPDATE api.setting SET value = %s WHERE key = %s", (setting_update.value, key))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Setting not found")
            log_audit(current_user['user_id'], None, "setting_updated", {"key": key}, None)
            return {"message": "Setting updated successfully"}

@app.delete("/api/setting/{key}")
async def delete_setting(key: str, current_user: dict = Depends(get_current_admin_user)):
    """Delete a setting."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.setting WHERE key = %s", (key,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Setting not found")
            log_audit(current_user['user_id'], None, "setting_deleted", {"key": key}, None)
            return {"message": "Setting deleted successfully"}

@app.get("/api/setting/all", response_model=List[Setting])
async def get_all_settings(current_user: dict = Depends(get_current_user)):
    """Get all settings."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT key, value FROM api.setting ORDER BY key")
            return [dict(s) for s in cur.fetchall()]

# ==================== Data Read Endpoints (API Key) ====================
# Used by the web mapping app. These are separate from the GloSIS federation
# endpoints in sis-api-glosis, which are optional.

@app.get("/api/layer", response_model=List[Layer])
async def get_published_layers(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get published layers only (requires API key). Used by the web mapping app."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.layer WHERE LOWER(publish) = 'true' ORDER BY layer_id")
            layers = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "published_layers_accessed",
                     {"layer_count": len(layers)}, get_client_ip(request))
            return [dict(layer) for layer in layers]

@app.get("/api/setting", response_model=List[Setting])
async def get_settings(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get all settings (requires API key). Used by the web mapping app."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT key, value FROM api.setting ORDER BY key")
            settings = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "settings_accessed",
                     {"setting_count": len(settings)}, get_client_ip(request))
            return [dict(s) for s in settings]

@app.get("/api/manifest")
async def get_manifest(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get soil properties manifest (requires API key)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_manifest")
            data = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "manifest_accessed",
                     {"record_count": len(data)}, get_client_ip(request))
            return [dict(row) for row in data]

@app.get("/api/profile")
async def get_profiles(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get soil profiles (requires API key)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_profile")
            data = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "profiles_accessed",
                     {"record_count": len(data)}, get_client_ip(request))
            return [dict(row) for row in data]

@app.get("/api/observation")
async def get_observations(
    request: Request,
    profile_code: Optional[str] = None,
    api_client: dict = Depends(verify_api_key)
):
    """Get observational data, optionally filtered by profile code (requires API key)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            if profile_code:
                cur.execute(
                    "SELECT * FROM api.vw_api_observation WHERE profile_code = %s",
                    (profile_code,)
                )
            else:
                cur.execute("SELECT * FROM api.vw_api_observation")
            data = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "observations_accessed",
                     {"profile_code": profile_code, "record_count": len(data)},
                     get_client_ip(request))
            return [dict(row) for row in data]

# ==================== Metadata Sync ====================

PYCSW_URL = os.getenv("PYCSW_URL", "http://sis-metadata:8000")
MAPSERVER_WMS_URL = os.getenv("MAPSERVER_WMS_URL", "http://localhost:8004")

def _validate_pycsw_url(url: str) -> str:
    """Reject anything that isn't an http(s) URL pointing at our metadata
    container. Hardcoding the parser stops a future bug from turning
    PYCSW_URL into a user-controlled SSRF vector."""
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https"):
        raise HTTPException(status_code=500, detail="PYCSW_URL must be http(s)")
    # Allow only the docker hostname or explicit operator-trusted hosts.
    allowed_hosts = {"sis-metadata", "localhost", "127.0.0.1"}
    if parsed.hostname not in allowed_hosts:
        raise HTTPException(
            status_code=500,
            detail=f"PYCSW_URL host '{parsed.hostname}' is not in the allowlist"
        )
    return url


def _parse_layer_id(info_href: str):
    params = parse_qs(urlparse(info_href).query)
    map_path = params.get("map", [None])[0]
    if not map_path:
        return None, None
    layer_id = map_path.split("/")[-1].replace(".map", "")
    return layer_id, map_path


def _build_wms_urls(map_path: str, layer_id: str):
    base = MAPSERVER_WMS_URL
    get_map = (f"{base}/?map={map_path}&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap"
               f"&LAYERS={layer_id}&STYLES=&FORMAT=image%2Fpng&TRANSPARENT=TRUE")
    get_legend = (f"{base}/?map={map_path}&SERVICE=WMS&VERSION=1.1.1"
                  f"&LAYER={layer_id}&REQUEST=getlegendgraphic&FORMAT=image/png")
    get_feature_info = (f"{base}/?map={map_path}&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo"
                        f"&LAYERS={layer_id}&QUERY_LAYERS={layer_id}&INFO_FORMAT=text%2Fhtml")
    return get_map, get_legend, get_feature_info


def _to_relative_path(href: Optional[str]) -> Optional[str]:
    """Strip scheme/host from a pyCSW link so it becomes same-origin."""
    if not href:
        return None
    parsed = urlparse(href)
    if not parsed.netloc:
        return href
    rel = parsed.path
    if parsed.query:
        rel += "?" + parsed.query
    return rel


def _parse_property_name(title: str) -> str:
    return title.strip() if title else title


@app.post("/api/sync/layers")
async def sync_layers_from_metadata(current_user: dict = Depends(get_current_user)):
    """Sync api.layer with records from the sis-metadata (pyCSW) server.

    Preserves manually-curated fields (project_name, unit_of_measure_id) on existing rows.
    """
    try:
        _validate_pycsw_url(PYCSW_URL)
        resp = http_requests.get(
            f"{PYCSW_URL}/collections/metadata:main/items?f=json&limit=1000",
            timeout=30, allow_redirects=False)
        resp.raise_for_status()
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY,
                            detail=f"Could not reach metadata server: {e}")

    features = resp.json().get("features", [])
    added, updated = 0, 0
    seen_layer_ids = set()

    # Resolve local download base URL from the Settings table so that a change
    # in DOWNLOAD_BASE_URL takes effect on the next Sync.
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT value FROM api.setting WHERE key = 'DOWNLOAD_BASE_URL'")
            row = cur.fetchone()
    download_base = (row[0] if row else "/downloads/") or "/downloads/"
    if not download_base.endswith("/"):
        download_base += "/"

    for feature in features:
        props = feature.get("properties", {})
        links = feature.get("links", [])
        title = props.get("title", "")
        version = props.get("updated", "")
        property_name = _parse_property_name(title)
        # pyCSW mixes all keywords in `properties.keywords` and groups the
        # thesaurus-backed ones (discipline, place, topic category) under
        # `themes[].concepts[].id`. The ones we want (ISO keyword type=theme)
        # are the ones present in `keywords` but NOT in any theme concept.
        all_keywords = [str(k).strip() for k in (props.get("keywords") or []) if str(k).strip()]
        themed_ids = set()
        for theme in props.get("themes") or []:
            for concept in theme.get("concepts") or []:
                cid = concept.get("id")
                if cid:
                    themed_ids.add(str(cid).strip())
        seen_kw = set()
        keywords = []
        for k in all_keywords:
            if k in themed_ids or k in seen_kw:
                continue
            seen_kw.add(k)
            keywords.append(k)
        metadata_url = _to_relative_path(
            next((l["href"] for l in links if l.get("rel") == "self"), None))
        download_links = [l for l in links if l.get("rel") == "download"]
        info_links = [l for l in links
                      if l.get("rel") == "information" and "map=" in l.get("href", "")]

        for info_link in info_links:
            layer_id, map_path = _parse_layer_id(info_link["href"])
            if not layer_id or not map_path:
                continue
            parts = layer_id.split("-")
            if len(parts) < 7:
                continue
            seen_layer_ids.add(layer_id)
            project_id = parts[1]
            stat = parts[-1]
            dimension = f"{parts[-3]}-{parts[-2]}-{parts[-1]}"
            # Always point download_url at the local raster served by sis-nginx,
            # regardless of what the upstream metadata record advertises.
            download_url = f"{download_base}{layer_id}.tif"
            get_map_url, get_legend_url, get_feature_info_url = _build_wms_urls(map_path, layer_id)

            with get_db() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT layer_id FROM api.layer WHERE layer_id = %s", (layer_id,))
                    exists = cur.fetchone()
                    if exists:
                        # Preserve manually-curated property_name on existing rows
                        cur.execute("""
                            UPDATE api.layer SET
                                project_id = %s, dimension = %s,
                                version = %s, metadata_url = %s, download_url = %s,
                                get_map_url = %s, get_legend_url = %s, get_feature_info_url = %s,
                                keywords = %s
                            WHERE layer_id = %s
                            """,
                            (project_id, dimension, version,
                             metadata_url, download_url, get_map_url,
                             get_legend_url, get_feature_info_url, keywords, layer_id))
                        updated += 1
                    else:
                        cur.execute("""
                            INSERT INTO api.layer
                                (layer_id, project_id, property_name, dimension, version,
                                 publish, metadata_url, download_url,
                                 get_map_url, get_legend_url, get_feature_info_url, keywords)
                            VALUES (%s, %s, %s, %s, %s, 'true', %s, %s, %s, %s, %s, %s)
                            """,
                            (layer_id, project_id, property_name, dimension, version,
                             metadata_url, download_url, get_map_url,
                             get_legend_url, get_feature_info_url, keywords))
                        added += 1

    deleted = 0
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT layer_id FROM api.layer")
            existing_ids = {row[0] for row in cur.fetchall()}
            orphans = existing_ids - seen_layer_ids
            if orphans:
                cur.execute(
                    "DELETE FROM api.layer WHERE layer_id = ANY(%s)",
                    (list(orphans),))
                deleted = cur.rowcount

    log_audit(current_user['user_id'], None, "layers_synced_from_metadata",
              {"added": added, "updated": updated, "deleted": deleted}, None)
    return {
        "message": "Sync complete",
        "added": added,
        "updated": updated,
        "deleted": deleted,
        "total_metadata_records": len(features)
    }

# ==================== Codelists (any authenticated user) ====================

@app.get("/api/codelist/organisations")
async def get_organisations(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT organisation_id, country, city FROM soil_data.organisation ORDER BY organisation_id")
            return cur.fetchall()

@app.get("/api/codelist/individuals")
async def get_individuals(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT individual_id, email FROM soil_data.individual ORDER BY individual_id")
            return cur.fetchall()

@app.get("/api/codelist/projects")
async def get_projects(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT project_id, name, abstract, license FROM soil_data.project ORDER BY project_id")
            return cur.fetchall()

@app.get("/api/codelist/properties")
async def get_properties(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT property_num_id, property_name, uri FROM soil_data.property_num ORDER BY property_name")
            return cur.fetchall()

@app.get("/api/codelist/procedures")
async def get_procedures(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT procedure_num_id, procedure_name, uri FROM soil_data.procedure_num ORDER BY procedure_name")
            return cur.fetchall()

@app.get("/api/codelist/units")
async def get_units(current_user: dict = Depends(get_current_user)):
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT unit_of_measure_id, unit_name FROM soil_data.unit_of_measure ORDER BY unit_name")
            return cur.fetchall()

@app.get("/api/codelist/procedures_for_property/{property_num_id}")
async def get_procedures_for_property(property_num_id: str, current_user: dict = Depends(get_current_user)):
    """Get procedure_num entries available for a given property, based on observation_num."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DISTINCT o.procedure_num_id, p.procedure_name, p.uri
                FROM soil_data.observation_num o
                JOIN soil_data.procedure_num p ON p.procedure_num_id = o.procedure_num_id
                WHERE o.property_num_id = %s
                ORDER BY p.procedure_name
            """, (property_num_id,))
            return cur.fetchall()

@app.get("/api/codelist/units_for_property/{property_num_id}")
async def get_units_for_property(property_num_id: str, current_user: dict = Depends(get_current_user)):
    """Get unit_of_measure entries available for a given property, based on observation_num."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DISTINCT o.unit_of_measure_id
                FROM soil_data.observation_num o
                WHERE o.property_num_id = %s
                ORDER BY o.unit_of_measure_id
            """, (property_num_id,))
            return cur.fetchall()

@app.get("/api/codelist/source_units/{property_num_id}/{procedure_num_id}")
async def get_source_units(
    property_num_id: str,
    procedure_num_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Source-unit options for an observation (canonical unit + any conversions to it).

    The canonical unit comes from observation_num.unit_of_measure_id.
    Other entries are sourced from soil_data.unit_conversion where unit_to = canonical.
    """
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT unit_of_measure_id
                FROM soil_data.observation_num
                WHERE property_num_id = %s AND procedure_num_id = %s
            """, (property_num_id, procedure_num_id))
            row = cur.fetchone()
            if not row or not row["unit_of_measure_id"]:
                return []
            canonical = row["unit_of_measure_id"]

            cur.execute("""
                SELECT c.unit_from, c.operation, c.value, c.unit_to,
                       uf.uri AS unit_from_uri, ut.uri AS unit_to_uri
                FROM soil_data.unit_conversion c
                LEFT JOIN soil_data.unit_of_measure uf ON uf.unit_of_measure_id = c.unit_from
                LEFT JOIN soil_data.unit_of_measure ut ON ut.unit_of_measure_id = c.unit_to
                WHERE c.unit_to = %s
                ORDER BY c.unit_from
            """, (canonical,))
            convs = cur.fetchall()

            cur.execute("SELECT uri FROM soil_data.unit_of_measure WHERE unit_of_measure_id = %s", (canonical,))
            canonical_uri_row = cur.fetchone()
            canonical_uri = canonical_uri_row["uri"] if canonical_uri_row else None

            options = [{
                "unit_of_measure_id": canonical,
                "operation": None,
                "value": None,
                "unit_to": canonical,
                "is_canonical": True,
                "uri": canonical_uri,
            }]
            for c in convs:
                options.append({
                    "unit_of_measure_id": c["unit_from"],
                    "operation": c["operation"],
                    "value": float(c["value"]) if c["value"] is not None else None,
                    "unit_to": c["unit_to"],
                    "is_canonical": False,
                    "uri": c["unit_from_uri"],
                })
            return options

@app.post("/api/codelist/projects", status_code=status.HTTP_201_CREATED)
async def create_project(payload: dict, current_user: dict = Depends(get_current_user)):
    pid = payload.get("project_id", "").strip()
    name = payload.get("name", "").strip()
    if not pid or not name:
        raise HTTPException(status_code=400, detail="project_id and name are required")
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("INSERT INTO soil_data.project (project_id, name) VALUES (%s, %s)", (pid, name))
                return {"project_id": pid, "name": name}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=400, detail="Project already exists")

@app.patch("/api/codelist/projects/{project_id}")
async def update_project(project_id: str, payload: dict, current_user: dict = Depends(get_current_user)):
    abstract = payload.get("abstract")
    license_val = payload.get("license")
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                UPDATE soil_data.project SET abstract = %s, license = %s
                WHERE project_id = %s
            """, (abstract, license_val, project_id))
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Project not found")
            return {"message": "Project updated"}

@app.post("/api/codelist/organisations", status_code=status.HTTP_201_CREATED)
async def create_organisation(payload: dict, current_user: dict = Depends(get_current_user)):
    oid = payload.get("organisation_id", "").strip()
    if not oid:
        raise HTTPException(status_code=400, detail="organisation_id is required")
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("""
                    INSERT INTO soil_data.organisation (organisation_id, country, city)
                    VALUES (%s, %s, %s)
                """, (oid, payload.get("country"), payload.get("city")))
                return {"organisation_id": oid, "country": payload.get("country"), "city": payload.get("city")}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=400, detail="Organisation already exists")

@app.post("/api/codelist/individuals", status_code=status.HTTP_201_CREATED)
async def create_individual(payload: dict, current_user: dict = Depends(get_current_user)):
    iid = payload.get("individual_id", "").strip()
    if not iid:
        raise HTTPException(status_code=400, detail="individual_id is required")
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("INSERT INTO soil_data.individual (individual_id, email) VALUES (%s, %s)",
                           (iid, payload.get("email")))
                return {"individual_id": iid, "email": payload.get("email")}
            except psycopg2.IntegrityError:
                raise HTTPException(status_code=400, detail="Individual already exists")

# ==================== ETL (any authenticated user) ====================

@app.put("/api/etl/metadata")
async def save_etl_metadata(
    payload: dict,
    current_user: dict = Depends(get_current_user)
):
    """Replace all authors for a project in soil_data.proj_x_org_x_ind."""
    project_id = payload.get("project_id")
    authors = payload.get("authors", [])
    if not project_id:
        raise HTTPException(status_code=400, detail="project_id is required")
    with get_db() as conn:
        with conn.cursor() as cur:
            # Delete existing authors for this project
            cur.execute("DELETE FROM soil_data.proj_x_org_x_ind WHERE project_id = %s", (project_id,))
            # Insert the current set
            for a in authors:
                org = a.get("organisation_id")
                ind = a.get("individual_id")
                if not org or not ind:
                    continue
                cur.execute("""
                    INSERT INTO soil_data.proj_x_org_x_ind
                        (project_id, organisation_id, individual_id, position, tag, role)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                """, (project_id, org, ind, a.get("position"), a.get("tag"), a.get("role")))
            log_audit(current_user['user_id'], None, "etl_metadata_saved",
                     {"project_id": project_id, "count": len(authors)}, None)
            return {"message": f"{len(authors)} author(s) saved"}

@app.get("/api/etl/project/{project_id}/authors")
async def get_project_authors(project_id: str, current_user: dict = Depends(get_current_user)):
    """Get existing authors linked to a project from soil_data.proj_x_org_x_ind."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT organisation_id, individual_id, position, tag, role
                FROM soil_data.proj_x_org_x_ind
                WHERE project_id = %s
                ORDER BY organisation_id, individual_id
            """, (project_id,))
            return cur.fetchall()

CSV_UPLOAD_MAX_BYTES = 50 * 1024 * 1024   # 50 MB
CSV_UPLOAD_MAX_ROWS  = 200_000

@app.post("/api/etl/upload")
async def upload_csv(
    file: UploadFile = File(...),
    project_id: str = Form(None),
    current_user: dict = Depends(get_current_user)
):
    """Upload a CSV file: create staging table, register in api.uploaded_dataset."""
    if not file.filename or not file.filename.lower().endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are accepted")

    # Read with a hard byte cap so a malicious or runaway upload can't OOM us.
    contents = await file.read(CSV_UPLOAD_MAX_BYTES + 1)
    if len(contents) > CSV_UPLOAD_MAX_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"CSV exceeds {CSV_UPLOAD_MAX_BYTES // (1024 * 1024)} MB limit"
        )
    text = contents.decode('utf-8-sig')
    reader = csv.reader(io.StringIO(text))
    rows = list(reader)
    if len(rows) < 2:
        raise HTTPException(status_code=400, detail="CSV must have a header row and at least one data row")
    if len(rows) - 1 > CSV_UPLOAD_MAX_ROWS:
        raise HTTPException(
            status_code=413,
            detail=f"CSV exceeds {CSV_UPLOAD_MAX_ROWS} data-row limit"
        )

    raw_headers = [h.strip() for h in rows[0]]
    data_rows = rows[1:]

    # Sanitize column names: replace chars that break psycopg2's parameter substitution
    # Keep a map from sanitized → original for display
    def sanitize_col(name):
        return name.replace('%', 'pct')

    headers = [sanitize_col(h) for h in raw_headers]

    # Build a safe table name. Postgres truncates identifiers at 63 chars, so
    # if two long filenames sanitize to the same prefix the second upload's
    # CREATE TABLE silently collides with the first. Cap the base at 40 chars
    # (timestamp suffix is 16 chars + an underscore = 57, well under 63).
    base_name = re.sub(r'[^a-zA-Z0-9_]', '_', file.filename.rsplit('.', 1)[0]).lower()[:40]
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    table_name = f"{base_name}_{ts}"

    # Protect _row_id reserved name
    if any(h == '_row_id' for h in headers):
        raise HTTPException(status_code=400, detail="Column name '_row_id' is reserved; please rename in your CSV.")

    with get_db() as conn:
        with conn.cursor() as cur:
            # Create staging table with _row_id surrogate key + all TEXT columns
            col_defs = pgsql.SQL(', ').join(
                [pgsql.SQL("_row_id SERIAL PRIMARY KEY")] +
                [pgsql.SQL("{} TEXT").format(pgsql.Identifier(h)) for h in headers]
            )
            cur.execute(pgsql.SQL("CREATE TABLE {}.{} ({})").format(
                pgsql.Identifier('soil_data_upload'),
                pgsql.Identifier(table_name),
                col_defs
            ))

            # Insert data
            if data_rows:
                placeholders = pgsql.SQL(', ').join([pgsql.Placeholder()] * len(headers))
                insert_sql = pgsql.SQL("INSERT INTO {}.{} ({}) VALUES ({})").format(
                    pgsql.Identifier('soil_data_upload'),
                    pgsql.Identifier(table_name),
                    pgsql.SQL(', ').join(pgsql.Identifier(h) for h in headers),
                    placeholders
                )
                for row in data_rows:
                    # Pad or truncate row to match headers
                    padded = (row + [''] * len(headers))[:len(headers)]
                    cur.execute(insert_sql, padded)

            # Register in api.uploaded_dataset
            cur.execute("""
                INSERT INTO api.uploaded_dataset (table_name, file_name, user_id, status, n_rows, n_col, project_id)
                VALUES (%s, %s, %s, 'Uploaded', %s, %s, %s)
            """, (table_name, file.filename, current_user['user_id'], len(data_rows), len(headers), project_id))

            # Initialize column entries in api.uploaded_dataset_column
            for i, h in enumerate(headers):
                note = raw_headers[i] if raw_headers[i] != h else None
                cur.execute("""
                    INSERT INTO api.uploaded_dataset_column (table_name, column_name, ignore_column, note)
                    VALUES (%s, %s, true, %s)
                """, (table_name, h, note))

            log_audit(current_user['user_id'], None, "etl_csv_uploaded",
                     {"table_name": table_name, "rows": len(data_rows), "cols": len(headers)}, None)

    # Return preview (first 20 rows)
    preview = data_rows[:20]
    return {
        "table_name": table_name,
        "columns": headers,
        "n_rows": len(data_rows),
        "n_col": len(headers),
        "preview": preview
    }

@app.get("/api/etl/datasets")
async def list_datasets(current_user: dict = Depends(get_current_user)):
    """List all uploaded datasets."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.uploaded_dataset ORDER BY table_name DESC")
            return cur.fetchall()

@app.get("/api/etl/datasets/{table_name}/preview")
async def get_dataset_preview(table_name: str, current_user: dict = Depends(get_current_user)):
    """Get first 100 rows from a staging table."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT 1 FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Dataset not found")
            cur.execute(pgsql.SQL("SELECT * FROM {}.{} ORDER BY _row_id LIMIT 100").format(
                pgsql.Identifier('soil_data_upload'),
                pgsql.Identifier(table_name)
            ))
            rows = cur.fetchall()
            all_cols = [desc[0] for desc in cur.description] if cur.description else []
            # Hide _row_id from the column list (keep it in each row for PATCH targeting)
            columns = [c for c in all_cols if c != '_row_id']
            return {"columns": columns, "rows": [dict(r) for r in rows]}

@app.get("/api/etl/datasets/{table_name}/columns")
async def get_dataset_columns(table_name: str, current_user: dict = Depends(get_current_user)):
    """Get column mappings for a dataset."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT column_name, property_num_id, procedure_num_id, unit_of_measure_id,
                       ignore_column, note, destination_table, destination_column,
                       validation
                FROM api.uploaded_dataset_column
                WHERE table_name = %s ORDER BY column_name
            """, (table_name,))
            return cur.fetchall()

@app.put("/api/etl/datasets/{table_name}/columns")
async def save_dataset_columns(
    table_name: str,
    payload: dict,
    current_user: dict = Depends(get_current_user)
):
    """Save column mappings for a dataset. Payload: {columns: [...], epsg: "4326"}."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Dataset not found")

            columns = payload.get("columns", [])
            epsg = payload.get("epsg")
            project_id = payload.get("project_id")

            for col in columns:
                cur.execute("""
                    UPDATE api.uploaded_dataset_column
                    SET destination_table = %s,
                        destination_column = %s,
                        property_num_id = %s,
                        procedure_num_id = %s,
                        unit_of_measure_id = %s,
                        ignore_column = %s,
                        note = %s
                    WHERE table_name = %s AND column_name = %s
                """, (
                    col.get("destination_table"),
                    col.get("destination_column"),
                    col.get("property_num_id"),
                    col.get("procedure_num_id"),
                    col.get("unit_of_measure_id"),
                    col.get("ignore_column", True),
                    col.get("note"),
                    table_name,
                    col["column_name"]
                ))

            if epsg:
                cur.execute("""
                    UPDATE api.uploaded_dataset SET cords_epsg = %s WHERE table_name = %s
                """, (epsg, table_name))

            if project_id:
                cur.execute("""
                    UPDATE api.uploaded_dataset SET project_id = %s WHERE table_name = %s
                """, (project_id, table_name))

            log_audit(current_user['user_id'], None, "etl_columns_saved",
                     {"table_name": table_name, "columns": len(columns)}, None)
            return {"message": "Column mappings saved successfully"}

@app.post("/api/etl/datasets/{table_name}/ingest")
async def ingest_dataset(
    table_name: str,
    current_user: dict = Depends(get_current_user)
):
    """Ingest staged CSV data into soil_data tables based on column mappings."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Get dataset metadata
            cur.execute("SELECT * FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            dataset = cur.fetchone()
            if not dataset:
                raise HTTPException(status_code=404, detail="Dataset not found")

            project_id = dataset.get("project_id")
            epsg = dataset.get("cords_epsg") or "4326"

            # Get column mappings (non-ignored)
            cur.execute("""
                SELECT column_name, destination_table, destination_column,
                       property_num_id, procedure_num_id, unit_of_measure_id
                FROM api.uploaded_dataset_column
                WHERE table_name = %s AND (ignore_column = false OR destination_table IS NOT NULL)
            """, (table_name,))
            mappings = cur.fetchall()

            if not mappings:
                raise HTTPException(status_code=400, detail="No column mappings defined")

            # Build lookup: destination_table.destination_column → csv_column_name (and extras)
            # For result_num, use csv column name as key since multiple columns map to "value"
            col_map = {}  # {dest_table: {key: {csv_col, prop, proc, unit}}}
            for m in mappings:
                dt = m["destination_table"]
                if not dt:
                    continue
                if dt not in col_map:
                    col_map[dt] = {}
                key = m["column_name"] if dt == "result_num" else (m["destination_column"] or "value")
                col_map[dt][key] = {
                    "csv_col": m["column_name"],
                    "property_num_id": m.get("property_num_id"),
                    "procedure_num_id": m.get("procedure_num_id"),
                    "unit_of_measure_id": m.get("unit_of_measure_id"),
                }

            # Read all rows from staging table (stable order by _row_id)
            cur.execute(pgsql.SQL("SELECT * FROM {}.{} ORDER BY _row_id").format(
                pgsql.Identifier("soil_data_upload"),
                pgsql.Identifier(table_name)
            ))
            rows = cur.fetchall()

            if not rows:
                raise HTTPException(status_code=400, detail="No data rows in staging table")

            # Helper to get a value from a row via mapping
            def get_val(row, table, col):
                info = col_map.get(table, {}).get(col)
                if not info:
                    return None
                v = row.get(info["csv_col"])
                if v is None or v == "":
                    return None
                return v

            # Caches to avoid duplicate inserts
            sites_inserted = set()
            project_sites_inserted = set()
            plots_cache = {}       # (site_id, plot_code) → plot_id
            profiles_cache = {}    # profile_code → profile_id
            elements_cache = {}    # (profile_id, upper, lower) → element_id
            specimens_cache = {}   # element_id → specimen_id
            obs_num_cache = {}     # (prop, proc) → (observation_num_id, canonical_unit)
            unit_conv_cache = {}   # (source_unit, canonical_unit) → {operation, value} or None

            ingested = 0
            result_num_count = 0
            errors = []

            if not project_id:
                raise HTTPException(status_code=400, detail="Project is required for ingest")

            # Ensure the site for this project exists (site_id = project_id)
            site_id = project_id
            cur.execute("""
                INSERT INTO soil_data.site (site_id) VALUES (%s)
                ON CONFLICT (site_id) DO NOTHING
            """, (site_id,))
            cur.execute("""
                INSERT INTO soil_data.project_site (project_id, site_id)
                VALUES (%s, %s) ON CONFLICT DO NOTHING
            """, (project_id, site_id))
            sites_inserted.add(site_id)
            project_sites_inserted.add((project_id, site_id))

            for i, row in enumerate(rows):
                row_num = i + 2  # 1-based + header
                try:
                    # --- plot ---
                    plot_id = None
                    plot_code = None
                    if "plot" in col_map:
                        plot_code = get_val(row, "plot", "plot_code")
                        lon = get_val(row, "plot", "geom (longitude)")
                        lat = get_val(row, "plot", "geom (latitude)")
                        plot_type = get_val(row, "plot", "type")
                        altitude = get_val(row, "plot", "altitude")
                        sampling_date = get_val(row, "plot", "sampling_date")
                        pos_accuracy = get_val(row, "plot", "positional_accuracy")

                        cache_key = plot_code or f"_row{i}"
                        if plot_code and cache_key in plots_cache:
                            plot_id = plots_cache[cache_key]
                        else:
                            geom_expr = None
                            geom_params = []
                            if lon and lat:
                                geom_expr = "ST_Transform(ST_SetSRID(ST_MakePoint(%s, %s), %s), 4326)"
                                geom_params = [float(lon), float(lat), int(epsg)]

                            if geom_expr:
                                cur.execute(f"""
                                    INSERT INTO soil_data.plot
                                        (site_id, plot_code, geom, type, altitude, sampling_date, positional_accuracy, csv)
                                    VALUES (%s, %s, {geom_expr}, %s, %s, %s, %s, %s)
                                    ON CONFLICT (plot_code) DO UPDATE SET
                                        geom = EXCLUDED.geom,
                                        type = COALESCE(EXCLUDED.type, soil_data.plot.type),
                                        altitude = COALESCE(EXCLUDED.altitude, soil_data.plot.altitude),
                                        sampling_date = COALESCE(EXCLUDED.sampling_date, soil_data.plot.sampling_date),
                                        positional_accuracy = COALESCE(EXCLUDED.positional_accuracy, soil_data.plot.positional_accuracy),
                                        csv = COALESCE(soil_data.plot.csv, EXCLUDED.csv)
                                    RETURNING plot_id
                                """, (site_id, plot_code, *geom_params, plot_type,
                                      int(altitude) if altitude else None,
                                      sampling_date or None,
                                      int(pos_accuracy) if pos_accuracy else None,
                                      table_name))
                            else:
                                cur.execute("""
                                    INSERT INTO soil_data.plot
                                        (site_id, plot_code, type, altitude, sampling_date, positional_accuracy, csv)
                                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                                    ON CONFLICT (plot_code) DO UPDATE SET
                                        type = COALESCE(EXCLUDED.type, soil_data.plot.type),
                                        altitude = COALESCE(EXCLUDED.altitude, soil_data.plot.altitude),
                                        sampling_date = COALESCE(EXCLUDED.sampling_date, soil_data.plot.sampling_date),
                                        positional_accuracy = COALESCE(EXCLUDED.positional_accuracy, soil_data.plot.positional_accuracy),
                                        csv = COALESCE(soil_data.plot.csv, EXCLUDED.csv)
                                    RETURNING plot_id
                                """, (site_id, plot_code, plot_type,
                                      int(altitude) if altitude else None,
                                      sampling_date or None,
                                      int(pos_accuracy) if pos_accuracy else None,
                                      table_name))
                            plot_id = cur.fetchone()["plot_id"]
                            if plot_code:
                                plots_cache[cache_key] = plot_id

                    # --- profile (profile_code = plot_code) ---
                    profile_id = None
                    if plot_id and plot_code:
                        if plot_code in profiles_cache:
                            profile_id = profiles_cache[plot_code]
                        else:
                            cur.execute("""
                                INSERT INTO soil_data.profile (plot_id, profile_code)
                                VALUES (%s, %s)
                                ON CONFLICT (profile_code) DO UPDATE SET plot_id = EXCLUDED.plot_id
                                RETURNING profile_id
                            """, (plot_id, plot_code))
                            profile_id = cur.fetchone()["profile_id"]
                            profiles_cache[plot_code] = profile_id

                    # --- element ---
                    element_id = None
                    if "element" in col_map and profile_id:
                        upper = get_val(row, "element", "upper_depth")
                        lower = get_val(row, "element", "lower_depth")
                        elem_type = get_val(row, "element", "type") or "Layer"
                        horizon = get_val(row, "element", "horizon")
                        if upper is not None and lower is not None:
                            upper_i = int(float(upper))
                            lower_i = int(float(lower))
                            elem_key = (profile_id, upper_i, lower_i)
                            if elem_key in elements_cache:
                                element_id = elements_cache[elem_key]
                            else:
                                cur.execute("""
                                    INSERT INTO soil_data.element (profile_id, upper_depth, lower_depth, type, horizon)
                                    VALUES (%s, %s, %s, %s, %s)
                                    RETURNING element_id
                                """, (profile_id, upper_i, lower_i, elem_type, horizon))
                                element_id = cur.fetchone()["element_id"]
                                elements_cache[elem_key] = element_id

                    # --- specimen (auto-create per element) ---
                    specimen_id = None
                    if element_id:
                        if element_id in specimens_cache:
                            specimen_id = specimens_cache[element_id]
                        else:
                            cur.execute("""
                                INSERT INTO soil_data.specimen (element_id)
                                VALUES (%s) RETURNING specimen_id
                            """, (element_id,))
                            specimen_id = cur.fetchone()["specimen_id"]
                            specimens_cache[element_id] = specimen_id

                    # --- result_num (one per result_num-mapped column) ---
                    if "result_num" in col_map and specimen_id:
                        for dest_col, info in col_map["result_num"].items():
                            prop_id = info.get("property_num_id")
                            proc_id = info.get("procedure_num_id")
                            source_unit = info.get("unit_of_measure_id")
                            if not prop_id or not proc_id:
                                continue

                            # Get observation_num_id and its canonical unit
                            obs_key = (prop_id, proc_id)
                            if obs_key in obs_num_cache:
                                obs_num_id, canonical_unit = obs_num_cache[obs_key]
                            else:
                                cur.execute("""
                                    SELECT observation_num_id, unit_of_measure_id
                                    FROM soil_data.observation_num
                                    WHERE property_num_id = %s AND procedure_num_id = %s
                                """, (prop_id, proc_id))
                                obs_row = cur.fetchone()
                                if not obs_row:
                                    # No observation_num exists — fall back to the source unit as canonical
                                    cur.execute("""
                                        INSERT INTO soil_data.observation_num
                                            (property_num_id, procedure_num_id, unit_of_measure_id)
                                        VALUES (%s, %s, %s)
                                        RETURNING observation_num_id, unit_of_measure_id
                                    """, (prop_id, proc_id, source_unit or "Unknown"))
                                    obs_row = cur.fetchone()
                                obs_num_id = obs_row["observation_num_id"]
                                canonical_unit = obs_row["unit_of_measure_id"]
                                obs_num_cache[obs_key] = (obs_num_id, canonical_unit)

                            # Resolve conversion (source -> canonical) once per pair
                            if source_unit and canonical_unit and source_unit != canonical_unit:
                                conv_key = (source_unit, canonical_unit)
                                if conv_key in unit_conv_cache:
                                    conv = unit_conv_cache[conv_key]
                                else:
                                    cur.execute("""
                                        SELECT operation, value FROM soil_data.unit_conversion
                                        WHERE unit_from = %s AND unit_to = %s
                                    """, (source_unit, canonical_unit))
                                    conv = cur.fetchone()
                                    unit_conv_cache[conv_key] = conv
                            else:
                                conv = None  # no conversion needed

                            raw_val = row.get(info["csv_col"])
                            if raw_val is None or raw_val == "":
                                continue
                            try:
                                val = float(raw_val)
                            except (ValueError, TypeError):
                                continue
                            if conv:
                                cv = float(conv["value"])
                                if conv["operation"] == "*":
                                    val = val * cv
                                elif conv["operation"] == "/":
                                    val = val / cv

                            cur.execute("""
                                INSERT INTO soil_data.result_num (observation_num_id, specimen_id, value)
                                VALUES (%s, %s, %s)
                                ON CONFLICT (observation_num_id, specimen_id)
                                DO UPDATE SET value = EXCLUDED.value
                            """, (obs_num_id, specimen_id, val))
                            result_num_count += 1

                    ingested += 1

                except Exception as e:
                    errors.append(f"Row {row_num}: {str(e)}")
                    if len(errors) > 50:
                        errors.append("... too many errors, stopping")
                        break

            # Update dataset status and note
            status = "Ingested" if not errors else "Partial"
            note = f"Ingested {ingested}/{len(rows)} rows, {result_num_count} results"
            if errors:
                note += f", {len(errors)} errors"
            cur.execute("""
                UPDATE api.uploaded_dataset
                SET status = %s, note = %s, ingestion_date = CURRENT_DATE
                WHERE table_name = %s
            """, (status, note, table_name))

            log_audit(current_user['user_id'], None, "etl_ingested",
                     {"table_name": table_name, "ingested": ingested, "errors": len(errors)}, None)

            return {
                "message": note,
                "ingested": ingested,
                "total": len(rows),
                "result_num_count": result_num_count,
                "errors": errors
            }


class CellEdit(BaseModel):
    row_id: int
    column: str
    value: Optional[str] = None

class CellEditBatch(BaseModel):
    edits: List[CellEdit]


@app.patch("/api/etl/datasets/{table_name}/cells")
async def edit_dataset_cells(
    table_name: str,
    batch: CellEditBatch,
    current_user: dict = Depends(get_current_user)
):
    """Edit one or more cells in a staging table. Writes to api.uploaded_dataset_edit for audit."""
    if not batch.edits:
        return {"updated": 0, "errors": []}

    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Validate dataset exists
            cur.execute("SELECT 1 FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Dataset not found")

            # Load valid column names for this dataset (prevents injection via column param)
            cur.execute(
                "SELECT column_name FROM api.uploaded_dataset_column WHERE table_name = %s",
                (table_name,)
            )
            valid_cols = {r["column_name"] for r in cur.fetchall()}

            updated = 0
            errors = []
            for edit in batch.edits:
                if edit.column not in valid_cols:
                    errors.append(f"row {edit.row_id}: unknown column '{edit.column}'")
                    continue
                # Capture old value for audit
                cur.execute(
                    pgsql.SQL("SELECT {} AS v FROM {}.{} WHERE _row_id = %s").format(
                        pgsql.Identifier(edit.column),
                        pgsql.Identifier("soil_data_upload"),
                        pgsql.Identifier(table_name),
                    ),
                    (edit.row_id,)
                )
                old = cur.fetchone()
                if not old:
                    errors.append(f"row {edit.row_id}: not found")
                    continue
                old_value = old["v"]

                cur.execute(
                    pgsql.SQL("UPDATE {}.{} SET {} = %s WHERE _row_id = %s").format(
                        pgsql.Identifier("soil_data_upload"),
                        pgsql.Identifier(table_name),
                        pgsql.Identifier(edit.column),
                    ),
                    (edit.value, edit.row_id)
                )
                if cur.rowcount:
                    updated += 1
                    cur.execute("""
                        INSERT INTO api.uploaded_dataset_edit
                            (table_name, row_id, column_name, old_value, new_value, user_id)
                        VALUES (%s, %s, %s, %s, %s, %s)
                    """, (table_name, edit.row_id, edit.column, old_value, edit.value,
                          current_user['user_id']))

            log_audit(current_user['user_id'], None, "etl_cells_edited",
                     {"table_name": table_name, "updated": updated, "errors": len(errors)}, None)

            return {"updated": updated, "errors": errors}


@app.post("/api/etl/datasets/{table_name}/validate")
async def validate_dataset(
    table_name: str,
    current_user: dict = Depends(get_current_user)
):
    """Validate CSV values against destination column datatypes and check constraints.
    Saves per-column result in api.uploaded_dataset_column.validation.
    """
    # Datatype + constraint rules per (dest_table, dest_column)
    # kind: int | smallint | real | date | enum | text
    RULES = {
        ("plot", "type"):                {"kind": "enum", "values": ["TrialPit", "Borehole"]},
        ("plot", "altitude"):            {"kind": "smallint"},
        ("plot", "positional_accuracy"): {"kind": "smallint"},
        ("plot", "sampling_date"):       {"kind": "date"},
        ("plot", "geom (longitude)"):    {"kind": "real", "min": -180, "max": 180},
        ("plot", "geom (latitude)"):     {"kind": "real", "min": -90, "max": 90},
        ("element", "upper_depth"):      {"kind": "int", "min": 0, "max": 1000},
        ("element", "lower_depth"):      {"kind": "int", "min": 0},
        ("element", "type"):             {"kind": "enum", "values": ["Horizon", "Layer"]},
    }
    # Destinations that must be mapped at least once (label, table, column)
    REQUIRED_DESTINATIONS = [
        ("Profile code",   "plot",       "plot_code"),
        ("Longitude",      "plot",       "geom (longitude)"),
        ("Latitude",       "plot",       "geom (latitude)"),
        ("Sampling date",  "plot",       "sampling_date"),
        ("Upper depth",    "element",    "upper_depth"),
        ("Lower depth",    "element",    "lower_depth"),
        ("Soil property",  "result_num", "value"),
    ]
    SMALLINT_MIN, SMALLINT_MAX = -32768, 32767

    def check_value(v, rule):
        """Return None if valid, else error description."""
        if v is None or v == "":
            return None  # empty cells are allowed at validation stage
        kind = rule["kind"]
        if kind in ("int", "smallint"):
            try:
                n = int(float(v))
            except (ValueError, TypeError):
                return f"'{v}' not an integer"
            if kind == "smallint" and not (SMALLINT_MIN <= n <= SMALLINT_MAX):
                return f"{n} out of smallint range"
            if "min" in rule and n < rule["min"]:
                return f"{n} < {rule['min']}"
            if "max" in rule and n > rule["max"]:
                return f"{n} > {rule['max']}"
            return None
        if kind == "real":
            try:
                n = float(v)
            except (ValueError, TypeError):
                return f"'{v}' not a number"
            if "min" in rule and n < rule["min"]:
                return f"{n} < {rule['min']}"
            if "max" in rule and n > rule["max"]:
                return f"{n} > {rule['max']}"
            return None
        if kind == "date":
            try:
                datetime.strptime(str(v), "%Y-%m-%d")
            except (ValueError, TypeError):
                return f"'{v}' not a date (YYYY-MM-DD)"
            return None
        if kind == "enum":
            if v not in rule["values"]:
                return f"'{v}' not in {rule['values']}"
            return None
        return None

    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Dataset exists?
            cur.execute("SELECT table_name FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Dataset not found")

            # Load mappings
            cur.execute("""
                SELECT column_name, destination_table, destination_column,
                       property_num_id, procedure_num_id, unit_of_measure_id
                FROM api.uploaded_dataset_column
                WHERE table_name = %s AND destination_table IS NOT NULL
            """, (table_name,))
            mappings = cur.fetchall()

            if not mappings:
                raise HTTPException(status_code=400, detail="No column mappings defined")

            # Load staging rows (ordered by _row_id for stable row numbers)
            cur.execute(pgsql.SQL("SELECT * FROM {}.{} ORDER BY _row_id").format(
                pgsql.Identifier("soil_data_upload"),
                pgsql.Identifier(table_name)
            ))
            rows = cur.fetchall()

            # Preload value_min/max + canonical unit for result_num mappings
            obs_bounds = {}  # (prop_id, proc_id) -> (min, max, canonical_unit)
            for m in mappings:
                if m["destination_table"] == "result_num" and m["property_num_id"] and m["procedure_num_id"]:
                    key = (m["property_num_id"], m["procedure_num_id"])
                    if key not in obs_bounds:
                        cur.execute("""
                            SELECT value_min, value_max, unit_of_measure_id
                            FROM soil_data.observation_num
                            WHERE property_num_id = %s AND procedure_num_id = %s
                        """, key)
                        r = cur.fetchone()
                        obs_bounds[key] = (
                            (r["value_min"], r["value_max"], r["unit_of_measure_id"]) if r else (None, None, None)
                        )

            # Conversion lookup cache: (source_unit, canonical_unit) -> {operation, value} or None
            unit_conv_cache = {}
            def get_conversion(source, canonical):
                if not source or not canonical or source == canonical:
                    return None
                k = (source, canonical)
                if k in unit_conv_cache:
                    return unit_conv_cache[k]
                cur.execute("""
                    SELECT operation, value FROM soil_data.unit_conversion
                    WHERE unit_from = %s AND unit_to = %s
                """, (source, canonical))
                conv = cur.fetchone()
                unit_conv_cache[k] = conv
                return conv

            def convert_value(n, conv):
                if not conv:
                    return n
                cv = float(conv["value"])
                if conv["operation"] == "*":
                    return n * cv
                if conv["operation"] == "/":
                    return n / cv
                return n

            # Validate each mapped column
            col_results = {}  # csv_col -> {"status", "errors", "error_rows"}
            upper_col = None
            lower_col = None

            MAX_DISPLAY = 10

            for m in mappings:
                csv_col = m["column_name"]
                dt = m["destination_table"]
                dc = m["destination_column"]
                errors = []
                error_rows = set()
                truncated = False

                if dt == "element" and dc == "upper_depth":
                    upper_col = csv_col
                if dt == "element" and dc == "lower_depth":
                    lower_col = csv_col

                rule = RULES.get((dt, dc))
                if rule:
                    for row in rows:
                        rid = row["_row_id"]
                        err = check_value(row.get(csv_col), rule)
                        if err:
                            error_rows.add(rid)
                            if len(errors) < MAX_DISPLAY:
                                errors.append(f"row {rid}: {err}")
                            else:
                                truncated = True

                if dt == "result_num":
                    missing_meta = []
                    if not m.get("property_num_id"):    missing_meta.append("property")
                    if not m.get("procedure_num_id"):   missing_meta.append("procedure")
                    if not m.get("unit_of_measure_id"): missing_meta.append("unit")
                    if missing_meta:
                        errors.append("missing " + ", ".join(missing_meta))
                        # mark every populated row so the user can see this column failed overall
                        for row in rows:
                            v = row.get(csv_col)
                            if v is not None and v != "":
                                error_rows.add(row["_row_id"])
                    bounds = obs_bounds.get((m["property_num_id"], m["procedure_num_id"]), (None, None, None))
                    vmin, vmax, canonical_unit = bounds
                    source_unit = m.get("unit_of_measure_id")
                    conv = get_conversion(source_unit, canonical_unit)
                    for row in rows:
                        rid = row["_row_id"]
                        v = row.get(csv_col)
                        if v is None or v == "":
                            continue
                        try:
                            n = float(v)
                        except (ValueError, TypeError):
                            error_rows.add(rid)
                            if len(errors) < MAX_DISPLAY:
                                errors.append(f"row {rid}: '{v}' not a number")
                            else:
                                truncated = True
                            continue
                        n = convert_value(n, conv)
                        if vmin is not None and n < vmin:
                            error_rows.add(rid)
                            if len(errors) < MAX_DISPLAY:
                                errors.append(f"row {rid}: {n} < {vmin}")
                            else:
                                truncated = True
                        elif vmax is not None and n > vmax:
                            error_rows.add(rid)
                            if len(errors) < MAX_DISPLAY:
                                errors.append(f"row {rid}: {n} > {vmax}")
                            else:
                                truncated = True

                if truncated:
                    errors.append("...")

                col_results[csv_col] = {
                    "status": "OK" if not error_rows else "ERROR",
                    "errors": errors,
                    "error_rows": sorted(error_rows),
                }

            # Cross-column: upper_depth < lower_depth
            if upper_col and lower_col:
                depth_errors = []
                depth_rows = set()
                truncated = False
                for row in rows:
                    rid = row["_row_id"]
                    u = row.get(upper_col)
                    l = row.get(lower_col)
                    if u in (None, "") or l in (None, ""):
                        continue
                    try:
                        ui = int(float(u)); li = int(float(l))
                    except (ValueError, TypeError):
                        continue
                    if ui >= li:
                        depth_rows.add(rid)
                        if len(depth_errors) < MAX_DISPLAY:
                            depth_errors.append(f"row {rid}: upper {ui} >= lower {li}")
                        else:
                            truncated = True
                if truncated:
                    depth_errors.append("...")
                if depth_rows:
                    for c in (upper_col, lower_col):
                        r = col_results.setdefault(c, {"status": "OK", "errors": [], "error_rows": []})
                        r["errors"].extend(depth_errors)
                        merged = set(r["error_rows"]) | depth_rows
                        r["error_rows"] = sorted(merged)
                        r["status"] = "ERROR"

            # Persist per-column validation
            total_errors = 0
            for csv_col, r in col_results.items():
                text = "OK" if r["status"] == "OK" else "; ".join(r["errors"])
                cur.execute("""
                    UPDATE api.uploaded_dataset_column
                    SET validation = %s
                    WHERE table_name = %s AND column_name = %s
                """, (text, table_name, csv_col))
                if r["status"] != "OK":
                    total_errors += len([e for e in r["errors"] if e != "..."])

            # Required destinations: every entry in REQUIRED_DESTINATIONS must be mapped
            mapped_targets = {(m["destination_table"], m["destination_column"]) for m in mappings}
            missing_required = [
                lbl for (lbl, t, c) in REQUIRED_DESTINATIONS if (t, c) not in mapped_targets
            ]

            # Dataset-level note
            n_cols_err = sum(1 for r in col_results.values() if r["status"] != "OK")
            parts = []
            if missing_required:
                parts.append("missing required: " + ", ".join(missing_required))
            if n_cols_err:
                parts.append(f"{n_cols_err} column(s) with errors")
            note = "Validation OK" if not parts else "Validation: " + "; ".join(parts)
            cur.execute("UPDATE api.uploaded_dataset SET note = %s WHERE table_name = %s",
                        (note, table_name))

            log_audit(current_user['user_id'], None, "etl_validated",
                     {"table_name": table_name, "columns_with_errors": n_cols_err,
                      "missing_required": missing_required}, None)

            return {
                "message": note,
                "columns": col_results,
                "total_rows": len(rows),
                "missing_required": missing_required,
            }


@app.post("/api/etl/datasets/{table_name}/prune")
async def prune_dataset(
    table_name: str,
    current_user: dict = Depends(get_current_user)
):
    """Delete all soil_data rows associated with a dataset's project, reversing an ingest."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Get dataset metadata
            cur.execute("SELECT * FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            dataset = cur.fetchone()
            if not dataset:
                raise HTTPException(status_code=404, detail="Dataset not found")

            project_id = dataset.get("project_id")
            if not project_id:
                raise HTTPException(status_code=400, detail="No project associated with this dataset")

            # Collect IDs top-down: plots tagged with this CSV → profiles → elements → specimens
            cur.execute("SELECT site_id FROM soil_data.project_site WHERE project_id = %s", (project_id,))
            site_ids = [r["site_id"] for r in cur.fetchall()]

            cur.execute("SELECT plot_id FROM soil_data.plot WHERE csv = %s", (table_name,))
            plot_ids = [r["plot_id"] for r in cur.fetchall()]

            if not plot_ids:
                return {"message": "No data found for this dataset", "deleted": {}}

            profile_ids = []
            if plot_ids:
                cur.execute("SELECT profile_id FROM soil_data.profile WHERE plot_id = ANY(%s)", (plot_ids,))
                profile_ids = [r["profile_id"] for r in cur.fetchall()]

            element_ids = []
            if profile_ids:
                cur.execute("SELECT element_id FROM soil_data.element WHERE profile_id = ANY(%s)", (profile_ids,))
                element_ids = [r["element_id"] for r in cur.fetchall()]

            specimen_ids = []
            if element_ids:
                cur.execute("SELECT specimen_id FROM soil_data.specimen WHERE element_id = ANY(%s)", (element_ids,))
                specimen_ids = [r["specimen_id"] for r in cur.fetchall()]

            # Delete bottom-up
            deleted = {}

            if specimen_ids:
                cur.execute("DELETE FROM soil_data.result_num WHERE specimen_id = ANY(%s)", (specimen_ids,))
                deleted["result_num"] = cur.rowcount
                cur.execute("DELETE FROM soil_data.specimen WHERE specimen_id = ANY(%s)", (specimen_ids,))
                deleted["specimen"] = cur.rowcount

            if element_ids:
                cur.execute("DELETE FROM soil_data.element WHERE element_id = ANY(%s)", (element_ids,))
                deleted["element"] = cur.rowcount

            if profile_ids:
                cur.execute("DELETE FROM soil_data.profile WHERE profile_id = ANY(%s)", (profile_ids,))
                deleted["profile"] = cur.rowcount

            if plot_ids:
                cur.execute("DELETE FROM soil_data.plot WHERE plot_id = ANY(%s)", (plot_ids,))
                deleted["plot"] = cur.rowcount

            # Delete sites only if no plots remain AND no other project references them
            deleted["project_site"] = 0
            deleted["site"] = 0
            for site_id in site_ids:
                cur.execute("SELECT 1 FROM soil_data.plot WHERE site_id = %s LIMIT 1", (site_id,))
                if cur.fetchone():
                    continue  # plots still exist (from other CSVs) — keep site
                cur.execute("DELETE FROM soil_data.project_site WHERE project_id = %s AND site_id = %s",
                            (project_id, site_id))
                deleted["project_site"] += cur.rowcount
                cur.execute("SELECT COUNT(*) AS cnt FROM soil_data.project_site WHERE site_id = %s", (site_id,))
                if cur.fetchone()["cnt"] == 0:
                    cur.execute("DELETE FROM soil_data.site WHERE site_id = %s", (site_id,))
                    deleted["site"] += cur.rowcount

            # Reset dataset status and save note
            parts = [f"{k}: {v}" for k, v in deleted.items() if v > 0]
            note = "Pruned" + (" (" + ", ".join(parts) + ")" if parts else "")
            cur.execute("UPDATE api.uploaded_dataset SET status = %s, note = %s WHERE table_name = %s",
                        ("Removed", note, table_name))

            log_audit(current_user['user_id'], None, "etl_pruned",
                     {"table_name": table_name, "project_id": project_id, "deleted": deleted}, None)

            return {"message": note, "project_id": project_id, "deleted": deleted}


@app.delete("/api/etl/datasets/{table_name}")
async def delete_dataset(
    table_name: str,
    current_user: dict = Depends(get_current_admin_user)
):
    """Drop the staging table and remove all related rows from api.uploaded_dataset(_column)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Dataset not found")

            cur.execute(pgsql.SQL("DROP TABLE IF EXISTS {}.{}").format(
                pgsql.Identifier('soil_data_upload'),
                pgsql.Identifier(table_name)
            ))
            cur.execute("DELETE FROM api.uploaded_dataset_column WHERE table_name = %s", (table_name,))
            cur.execute("DELETE FROM api.uploaded_dataset WHERE table_name = %s", (table_name,))

            log_audit(current_user['user_id'], None, "etl_dataset_deleted",
                     {"table_name": table_name}, None)

            return {"message": f"Deleted dataset {table_name}"}


# ==================== Health Check & Root ====================

@app.get("/api/layer/soil_profiles")
async def list_soil_profile_layers(current_user: dict = Depends(get_current_user)):
    """List all soil-data projects as profile layers with total vs. published counts."""
    sql = """
        WITH profile_ranked AS (
          SELECT ps.project_id,
                 pr.profile_id,
                 row_number() OVER (PARTITION BY ps.project_id ORDER BY pr.profile_id) AS rn
          FROM soil_data.project_site ps
          JOIN soil_data.plot pl ON pl.site_id = ps.site_id
          JOIN soil_data.profile pr ON pr.plot_id = pl.plot_id
        ),
        profile_totals AS (
          SELECT project_id, count(DISTINCT profile_id) AS total_profiles
          FROM profile_ranked
          GROUP BY project_id
        ),
        published_profiles AS (
          SELECT pr.project_id, pr.profile_id
          FROM profile_ranked pr
          JOIN soil_data.project p ON p.project_id = pr.project_id
          WHERE p.is_published = TRUE
            AND (p.profile_limit IS NULL OR pr.rn <= p.profile_limit)
        ),
        published_profile_counts AS (
          SELECT project_id, count(DISTINCT profile_id) AS published_profiles
          FROM published_profiles
          GROUP BY project_id
        ),
        total_obs AS (
          SELECT ps.project_id, count(r.observation_num_id) AS total_observations
          FROM soil_data.project_site ps
          JOIN soil_data.plot pl ON pl.site_id = ps.site_id
          JOIN soil_data.profile pr ON pr.plot_id = pl.plot_id
          JOIN soil_data.element e ON e.profile_id = pr.profile_id
          JOIN soil_data.specimen s ON s.element_id = e.element_id
          JOIN soil_data.result_num r ON r.specimen_id = s.specimen_id
          GROUP BY ps.project_id
        ),
        published_obs AS (
          SELECT pp.project_id, count(r.observation_num_id) AS published_observations
          FROM published_profiles pp
          JOIN soil_data.element e ON e.profile_id = pp.profile_id
          JOIN soil_data.specimen s ON s.element_id = e.element_id
          JOIN soil_data.result_num r ON r.specimen_id = s.specimen_id
          GROUP BY pp.project_id
        )
        SELECT
          p.project_id,
          p.name AS project_name,
          p.is_published,
          p.profile_limit,
          p.spatial_blur_m,
          COALESCE(pt.total_profiles, 0) AS total_profile_count,
          COALESCE(ppc.published_profiles, 0) AS published_profile_count,
          COALESCE(tobs.total_observations, 0) AS total_observation_count,
          COALESCE(pobs.published_observations, 0) AS published_observation_count
        FROM soil_data.project p
        LEFT JOIN profile_totals pt ON pt.project_id = p.project_id
        LEFT JOIN published_profile_counts ppc ON ppc.project_id = p.project_id
        LEFT JOIN total_obs tobs ON tobs.project_id = p.project_id
        LEFT JOIN published_obs pobs ON pobs.project_id = p.project_id
        ORDER BY p.name;
    """
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql)
            return cur.fetchall()


class SoilProfilePublishUpdate(BaseModel):
    is_published: bool


@app.patch("/api/layer/soil_profiles/{project_id}/publish")
async def set_soil_profile_publish(
    project_id: str,
    body: SoilProfilePublishUpdate,
    current_user: dict = Depends(get_current_user),
):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE soil_data.project SET is_published = %s WHERE project_id = %s",
                (body.is_published, project_id),
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Project not found")
            conn.commit()
    return {"project_id": project_id, "is_published": body.is_published}


class SoilProfileLimitUpdate(BaseModel):
    profile_limit: Optional[int] = None


@app.patch("/api/layer/soil_profiles/{project_id}/limit")
async def set_soil_profile_limit(
    project_id: str,
    body: SoilProfileLimitUpdate,
    current_user: dict = Depends(get_current_user),
):
    if body.profile_limit is not None and body.profile_limit <= 0:
        raise HTTPException(status_code=400, detail="profile_limit must be > 0 or null")
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE soil_data.project SET profile_limit = %s WHERE project_id = %s",
                (body.profile_limit, project_id),
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Project not found")
            conn.commit()
    return {"project_id": project_id, "profile_limit": body.profile_limit}


class SoilProfileBlurUpdate(BaseModel):
    spatial_blur_m: Optional[int] = None


@app.patch("/api/layer/soil_profiles/{project_id}/blur")
async def set_soil_profile_blur(
    project_id: str,
    body: SoilProfileBlurUpdate,
    current_user: dict = Depends(get_current_user),
):
    if body.spatial_blur_m is not None and body.spatial_blur_m < 0:
        raise HTTPException(status_code=400, detail="spatial_blur_m must be >= 0 or null")
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE soil_data.project SET spatial_blur_m = %s WHERE project_id = %s",
                (body.spatial_blur_m, project_id),
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Project not found")
            conn.commit()
    return {"project_id": project_id, "spatial_blur_m": body.spatial_blur_m}


@app.get("/api/stats/dashboard")
async def dashboard_stats(current_user: dict = Depends(get_current_user)):
    """Aggregated stats across soil_data for the dashboard tab."""
    out = {}
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Top-line cards
            cur.execute("""
                SELECT
                  (SELECT count(*) FROM soil_data.profile) AS profile_count,
                  (SELECT count(*) FROM soil_data.result_num) AS observation_count,
                  (SELECT count(*) FROM soil_data.project) AS project_count,
                  (SELECT count(DISTINCT property_num_id) FROM soil_data.observation_num) AS property_count,
                  (SELECT count(*) FROM soil_data.site) AS site_count;
            """)
            out["totals"] = cur.fetchone()

            # Profiles per project
            cur.execute("""
                SELECT p.name AS project_name,
                       count(DISTINCT pr.profile_id) AS profile_count
                FROM soil_data.project p
                LEFT JOIN soil_data.project_site ps ON ps.project_id = p.project_id
                LEFT JOIN soil_data.plot pl ON pl.site_id = ps.site_id
                LEFT JOIN soil_data.profile pr ON pr.plot_id = pl.plot_id
                GROUP BY p.name
                ORDER BY profile_count DESC;
            """)
            out["profiles_per_project"] = cur.fetchall()

            # Top 10 measured properties
            cur.execute("""
                SELECT o.property_num_id AS property,
                       count(*) AS observation_count
                FROM soil_data.result_num r
                JOIN soil_data.observation_num o ON o.observation_num_id = r.observation_num_id
                GROUP BY o.property_num_id
                ORDER BY observation_count DESC
                LIMIT 10;
            """)
            out["top_properties"] = cur.fetchall()

            # Profiles sampled per year
            cur.execute("""
                SELECT extract(year FROM pl.sampling_date)::int AS year,
                       count(DISTINCT pr.profile_id) AS profile_count
                FROM soil_data.plot pl
                JOIN soil_data.profile pr ON pr.plot_id = pl.plot_id
                WHERE pl.sampling_date IS NOT NULL
                GROUP BY year
                ORDER BY year;
            """)
            out["profiles_per_year"] = cur.fetchall()

            # Depth distribution (bins of 25cm up to 2m, then >200)
            cur.execute("""
                WITH depths AS (
                  SELECT CASE
                           WHEN lower_depth IS NULL THEN NULL
                           WHEN lower_depth <= 25 THEN '0-25'
                           WHEN lower_depth <= 50 THEN '25-50'
                           WHEN lower_depth <= 75 THEN '50-75'
                           WHEN lower_depth <= 100 THEN '75-100'
                           WHEN lower_depth <= 150 THEN '100-150'
                           WHEN lower_depth <= 200 THEN '150-200'
                           ELSE '>200'
                         END AS bucket,
                         CASE
                           WHEN lower_depth IS NULL THEN 999
                           WHEN lower_depth <= 25 THEN 0
                           WHEN lower_depth <= 50 THEN 1
                           WHEN lower_depth <= 75 THEN 2
                           WHEN lower_depth <= 100 THEN 3
                           WHEN lower_depth <= 150 THEN 4
                           WHEN lower_depth <= 200 THEN 5
                           ELSE 6
                         END AS sort_idx
                  FROM soil_data.element
                  WHERE lower_depth IS NOT NULL
                )
                SELECT bucket AS depth_range, count(*) AS element_count
                FROM depths
                GROUP BY bucket, sort_idx
                ORDER BY sort_idx;
            """)
            out["depth_distribution"] = cur.fetchall()

            # Value summary per top property (min, q1, median, q3, max)
            cur.execute("""
                WITH top_props AS (
                  SELECT o.property_num_id
                  FROM soil_data.result_num r
                  JOIN soil_data.observation_num o ON o.observation_num_id = r.observation_num_id
                  GROUP BY o.property_num_id
                  ORDER BY count(*) DESC
                  LIMIT 8
                )
                SELECT o.property_num_id AS property,
                       count(r.value)::int AS n,
                       min(r.value)::float AS vmin,
                       percentile_cont(0.25) WITHIN GROUP (ORDER BY r.value)::float AS q1,
                       percentile_cont(0.5)  WITHIN GROUP (ORDER BY r.value)::float AS median,
                       percentile_cont(0.75) WITHIN GROUP (ORDER BY r.value)::float AS q3,
                       max(r.value)::float AS vmax
                FROM soil_data.result_num r
                JOIN soil_data.observation_num o ON o.observation_num_id = r.observation_num_id
                JOIN top_props tp ON tp.property_num_id = o.property_num_id
                WHERE r.value IS NOT NULL
                GROUP BY o.property_num_id
                ORDER BY n DESC;
            """)
            out["value_summary"] = cur.fetchall()

    return out


# ==================== GloSIS Federation (admin) ====================

GLOSIS_FED_DESCRIPTION = "glosis-federation"
GLOSIS_FED_SETTING = "GLOSIS_FEDERATION_ENABLED"


def _glosis_get_enabled(cur) -> bool:
    cur.execute("SELECT value FROM api.setting WHERE key = %s", (GLOSIS_FED_SETTING,))
    row = cur.fetchone()
    return bool(row and str(row["value"]).strip().lower() == "true")


def _glosis_get_token(cur):
    """Return the singleton federation token row (with plaintext api_key) or None.

    Stored plaintext per design — admin needs to be able to copy it back to
    the Discovery Hub at any time, not just once at generation.
    """
    cur.execute("""
        SELECT api_client_id, api_key, is_active, created_at, last_login
        FROM api.api_client
        WHERE description = %s
        ORDER BY created_at NULLS LAST
        LIMIT 1
    """, (GLOSIS_FED_DESCRIPTION,))
    return cur.fetchone()


@app.get("/api/glosis/status")
async def glosis_status(current_user: dict = Depends(get_current_admin_user)):
    """Return federation enabled flag and the singleton token metadata (no plaintext)."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            enabled = _glosis_get_enabled(cur)
            token = _glosis_get_token(cur)
            return {"enabled": enabled, "token": token}


@app.post("/api/glosis/enable")
async def glosis_enable(current_user: dict = Depends(get_current_admin_user)):
    """Enable federation. Creates the singleton token if missing (returns plaintext once),
    or re-activates the existing one if currently inactive (no plaintext returned)."""
    new_api_key = None
    new_api_client_id = None
    audit_action = "glosis_federation_enabled"
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO api.setting (key, value) VALUES (%s, 'true')
                ON CONFLICT (key) DO UPDATE SET value = 'true'
            """, (GLOSIS_FED_SETTING,))
            existing = _glosis_get_token(cur)
            if not existing:
                new_api_key = generate_api_key()
                new_api_client_id = f"glosis-{secrets.token_urlsafe(8)}"
                cur.execute("""
                    INSERT INTO api.api_client (api_client_id, api_key, description, is_active)
                    VALUES (%s, %s, %s, true)
                """, (new_api_client_id, new_api_key, GLOSIS_FED_DESCRIPTION))
                audit_action = "glosis_federation_enabled_token_created"
            elif not existing["is_active"]:
                cur.execute("""
                    UPDATE api.api_client SET is_active = true
                    WHERE api_client_id = %s
                """, (existing["api_client_id"],))
    # log_audit uses its own connection; call after the parent transaction commits
    log_audit(current_user["user_id"], new_api_client_id,
              audit_action, None, None)
    return {
        "message": "GloSIS federation enabled",
        "api_key": new_api_key,  # only set on first-ever enable
        "api_client_id": new_api_client_id,
    }


@app.post("/api/glosis/disable")
async def glosis_disable(current_user: dict = Depends(get_current_admin_user)):
    """Disable federation. The token row is kept intact so re-enabling reuses it."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO api.setting (key, value) VALUES (%s, 'false')
                ON CONFLICT (key) DO UPDATE SET value = 'false'
            """, (GLOSIS_FED_SETTING,))
    log_audit(current_user["user_id"], None, "glosis_federation_disabled", None, None)
    return {"message": "GloSIS federation disabled"}


@app.post("/api/glosis/disable_and_delete")
async def glosis_disable_and_delete(current_user: dict = Depends(get_current_admin_user)):
    """Disable federation AND delete the token. Re-enabling later mints a fresh key.

    Audit rows referencing the deleted token have their api_client_id nulled
    out (rather than cascading the delete) so the audit trail is preserved.
    """
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO api.setting (key, value) VALUES (%s, 'false')
                ON CONFLICT (key) DO UPDATE SET value = 'false'
            """, (GLOSIS_FED_SETTING,))
            cur.execute("""
                UPDATE api.audit SET api_client_id = NULL
                WHERE api_client_id IN (
                    SELECT api_client_id FROM api.api_client WHERE description = %s
                )
            """, (GLOSIS_FED_DESCRIPTION,))
            cur.execute("""
                DELETE FROM api.api_client WHERE description = %s
            """, (GLOSIS_FED_DESCRIPTION,))
    log_audit(current_user["user_id"], None,
              "glosis_federation_disabled_and_deleted", None, None)
    return {"message": "GloSIS federation disabled and token deleted"}


@app.get("/")
async def root():
    return {
        "message": "SIS Admin API",
        "version": "1.0.0",
        "docs": "/docs",
        "authentication": "POST /api/auth/login to get a JWT token"
    }

@app.get("/health")
async def health_check():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        return {"status": "healthy"}
    except Exception:
        # Don't leak DB error strings (may include creds/hostnames) to anonymous callers.
        return {"status": "unhealthy"}
