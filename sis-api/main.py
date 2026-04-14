"""
SIS Admin API — JWT authentication (for humans)
Manages users, API clients, layers, and settings.
"""

from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import EmailStr
from typing import List, Optional
from datetime import datetime, timedelta
from urllib.parse import urlparse, parse_qs
import psycopg2
from psycopg2.extras import RealDictCursor
import requests as http_requests

from shared import (
    DB_CONFIG, ACCESS_TOKEN_EXPIRE_MINUTES,
    get_db, log_audit,
    hash_password, verify_password, create_access_token,
    generate_api_key,
    UserLogin, Token, User, Layer, LayerCreate, PublishUpdate,
    Setting, SettingCreate, SettingUpdate, APIClient, APIClientCreate,
    get_current_user, get_current_admin_user, verify_api_key,
)

app = FastAPI(
    title="SIS Admin API",
    description="JWT-protected API for managing users, API clients, layers, and settings.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:80",
        "http://localhost:8001",
        "*"  # For development - remove in production!
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== Authentication ====================

@app.post("/api/auth/login", response_model=Token)
async def login(user_credentials: UserLogin, request: Request):
    """Login with email/password — returns a JWT token."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT user_id, password_hash, is_active FROM api.user WHERE user_id = %s",
                (user_credentials.user_id,)
            )
            user = cur.fetchone()
            if not user or not verify_password(user_credentials.password, user['password_hash']):
                log_audit(user_credentials.user_id, None, "login_failed", None, request.client.host)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Incorrect username or password"
                )
            if not user['is_active']:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="User account is inactive"
                )
            cur.execute(
                "UPDATE api.user SET last_login = %s WHERE user_id = %s",
                (datetime.now(), user['user_id'])
            )
            log_audit(user['user_id'], None, "login_success", None, request.client.host)
            access_token = create_access_token(
                data={"sub": user['user_id']},
                expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            )
            return {"access_token": access_token, "token_type": "bearer"}

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
    user_id: EmailStr,
    password: str,
    is_admin: bool = False,
    current_user: dict = Depends(get_current_admin_user)
):
    """Create a new user (admin only)."""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "INSERT INTO api.user (user_id, password_hash, is_admin) VALUES (%s, %s, %s)",
                    (user_id, hash_password(password), is_admin)
                )
                log_audit(current_user['user_id'], None, "user_created", {"new_user": user_id}, None)
                return {"message": "User created successfully", "user_id": user_id}
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
    """Publish or unpublish a layer."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE api.layer SET publish = %s WHERE layer_id = %s",
                (str(publish_data.publish).lower(), layer_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Layer not found")
            log_audit(current_user['user_id'], None, "layer_publish_changed",
                     {"layer_id": layer_id, "publish": publish_data.publish}, None)
            return {"message": "Layer publish status updated successfully"}

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
async def create_setting(setting: SettingCreate, current_user: dict = Depends(get_current_user)):
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
    current_user: dict = Depends(get_current_user)
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
async def delete_setting(key: str, current_user: dict = Depends(get_current_user)):
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
                     {"layer_count": len(layers)}, request.client.host)
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
                     {"setting_count": len(settings)}, request.client.host)
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
                     {"record_count": len(data)}, request.client.host)
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
                     {"record_count": len(data)}, request.client.host)
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
                     request.client.host)
            return [dict(row) for row in data]

# ==================== Health Check & Root ====================

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
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": "disconnected", "error": str(e)}
