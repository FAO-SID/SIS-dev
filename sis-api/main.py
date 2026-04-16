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
import os
import re
import psycopg2
from psycopg2.extras import RealDictCursor
import requests as http_requests

from shared import (
    DB_CONFIG, ACCESS_TOKEN_EXPIRE_MINUTES,
    get_db, log_audit,
    hash_password, verify_password, create_access_token,
    generate_api_key,
    UserLogin, Token, User, UserCreate, UserSelfUpdate, Layer, LayerCreate, PublishUpdate,
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

            if payload.new_password and payload.new_user_id:
                cur.execute(
                    "UPDATE api.user SET user_id = %s, password_hash = %s WHERE user_id = %s",
                    (payload.new_user_id, hash_password(payload.new_password), current_user['user_id']))
            elif payload.new_password:
                cur.execute(
                    "UPDATE api.user SET password_hash = %s WHERE user_id = %s",
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

# ==================== Metadata Sync ====================

PYCSW_URL = os.getenv("PYCSW_URL", "http://sis-metadata:8000")
MAPSERVER_WMS_URL = os.getenv("MAPSERVER_WMS_URL", "http://localhost:8004")


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
    # Strip the trailing " (...)..." segment, e.g. given
    # 'GSNMap - Potassium (K+) - exchangeable (Bhutan - 250 m - 2024) - SOIL+'
    # return 'GSNMap - Potassium (K+) - exchangeable'.
    if not title:
        return title
    return re.sub(r"\s*\([^()]*\)[^()]*$", "", title).strip()


@app.post("/api/sync/layers")
async def sync_layers_from_metadata(current_user: dict = Depends(get_current_admin_user)):
    """Sync api.layer with records from the sis-metadata (pyCSW) server.

    Preserves manually-curated fields (project_name, unit_of_measure_id) on existing rows.
    """
    try:
        resp = http_requests.get(
            f"{PYCSW_URL}/collections/metadata:main/items?f=json&limit=1000",
            timeout=30)
        resp.raise_for_status()
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY,
                            detail=f"Could not reach metadata server: {e}")

    features = resp.json().get("features", [])
    added, updated = 0, 0
    seen_layer_ids = set()

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
            download_url = _to_relative_path(next(
                (l["href"] for l in download_links if f"D-{stat}" in l.get("href", "")),
                None))
            get_map_url, get_legend_url, get_feature_info_url = _build_wms_urls(map_path, layer_id)

            with get_db() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT layer_id FROM api.layer WHERE layer_id = %s", (layer_id,))
                    exists = cur.fetchone()
                    if exists:
                        cur.execute("""
                            UPDATE api.layer SET
                                project_id = %s, property_name = %s, dimension = %s,
                                version = %s, metadata_url = %s, download_url = %s,
                                get_map_url = %s, get_legend_url = %s, get_feature_info_url = %s,
                                keywords = %s
                            WHERE layer_id = %s
                            """,
                            (project_id, property_name, dimension, version,
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
