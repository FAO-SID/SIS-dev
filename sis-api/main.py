"""
FastAPI REST API for Soil Information System
Supports user authentication (JWT) and API client authentication (API keys)
"""

from fastapi import FastAPI, Depends, HTTPException, status, Header, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional, List, Annotated
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import RealDictCursor
from jose import jwt, JWTError
import bcrypt
import secrets
import os
from contextlib import contextmanager

# Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

DB_CONFIG = {
    "host": os.getenv("DB_HOST", os.getenv("POSTGRES_HOST", "sis-database")),
    "port": os.getenv("DB_PORT", "5432"),
    "database": os.getenv("DB_NAME", os.getenv("POSTGRES_DB", "sis")),
    "user": os.getenv("DB_USER", os.getenv("POSTGRES_USER", "sis")),
    "password": os.getenv("DB_PASSWORD", os.getenv("POSTGRES_PASSWORD", "sis"))
}

app = FastAPI(
    title="Global Soil Information System REST API",
    description="REST API for soil data and layer management",
    version="1.0.0"
)

# Add CORS middleware
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

security = HTTPBearer()

# ==================== Database Connection ====================

@contextmanager
def get_db():
    """Database connection context manager"""
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

# ==================== Pydantic Models ====================

class UserLogin(BaseModel):
    user_id: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class User(BaseModel):
    user_id: str
    is_active: bool
    is_admin: bool
    created_at: datetime
    last_login: Optional[datetime] = None

class Layer(BaseModel):
    project_id: Optional[str] = None
    project_name: Optional[str] = None
    layer_id: str
    publish: bool = True
    property_name: Optional[str] = None
    dimension: Optional[str] = None
    version: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    metadata_url: Optional[str] = None
    download_url: Optional[str] = None
    get_map_url: Optional[str] = None
    get_legend_url: Optional[str] = None
    get_feature_info_url: Optional[str] = None

class LayerCreate(BaseModel):
    project_id: Optional[str] = None
    project_name: Optional[str] = None
    layer_id: str
    publish: bool = True
    property_name: Optional[str] = None
    dimension: Optional[str] = None
    version: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    metadata_url: Optional[str] = None
    download_url: Optional[str] = None
    get_map_url: Optional[str] = None
    get_legend_url: Optional[str] = None
    get_feature_info_url: Optional[str] = None

class PublishUpdate(BaseModel):
    publish: bool

class Setting(BaseModel):
    key: str
    value: str

class SettingCreate(BaseModel):
    key: str
    value: str

class SettingUpdate(BaseModel):
    value: str

class APIClient(BaseModel):
    api_client_id: str
    is_active: bool
    created_at: datetime
    expires_at: Optional[datetime] = None
    description: str

class APIClientCreate(BaseModel):
    api_client_id: str
    description: str
    expires_at: Optional[datetime] = None

# ==================== Authentication Functions ====================

def hash_password(password: str) -> str:
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def generate_api_key() -> str:
    """Generate a secure random API key"""
    return secrets.token_urlsafe(32)

def log_audit(user_id: Optional[str], api_client_id: Optional[str], 
              action: str, details: Optional[dict], ip_address: Optional[str]):
    """Log action to audit table"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO api.audit (user_id, api_client_id, action, details, ip_address)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (user_id, api_client_id, action, 
                 psycopg2.extras.Json(details) if details else None, 
                 ip_address)
            )

# ==================== Dependencies ====================

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Dependency to get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        
        # Verify user still exists and is active
        with get_db() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(
                    "SELECT user_id, is_active, is_admin FROM api.user WHERE user_id = %s",
                    (user_id,)
                )
                user = cur.fetchone()
                if user is None or not user['is_active']:
                    raise credentials_exception
                return dict(user)
    except JWTError:
        raise credentials_exception

async def get_current_admin_user(current_user: dict = Depends(get_current_user)) -> dict:
    """Dependency to ensure user is admin"""
    if not current_user.get('is_admin'):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user

async def verify_api_key(
    request: Request,
    x_api_key: Annotated[str | None, Header()] = None
) -> dict:
    """Dependency to verify API key for all programmatic access"""
    if not x_api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key required. Include X-API-Key header in your request.",
            headers={"WWW-Authenticate": "ApiKey"}
        )
    
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT api_client_id, is_active, expires_at 
                FROM api.api_client 
                WHERE api_key = %s
                """,
                (x_api_key,)
            )
            client = cur.fetchone()
            
            if not client:
                log_audit(None, None, "api_key_invalid_attempt", 
                         {"api_key_prefix": x_api_key[:8] + "..."}, 
                         request.client.host)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid API key"
                )
            
            if not client['is_active']:
                log_audit(None, client['api_client_id'], "api_key_inactive_attempt", 
                         None, request.client.host)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="API key is inactive"
                )
            
            if client['expires_at'] and client['expires_at'] < datetime.now().date():
                log_audit(None, client['api_client_id'], "api_key_expired_attempt", 
                         None, request.client.host)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="API key has expired"
                )
            
            # Update last_login
            cur.execute(
                "UPDATE api.api_client SET last_login = %s WHERE api_client_id = %s",
                (datetime.now(), client['api_client_id'])
            )
            
            return dict(client)

# ==================== Authentication Endpoints ====================

@app.post("/api/auth/login", response_model=Token)
async def login(user_credentials: UserLogin, request: Request):
    """User login endpoint - returns JWT token for admin access"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT user_id, password_hash, is_active FROM api.user WHERE user_id = %s",
                (user_credentials.user_id,)
            )
            user = cur.fetchone()
            
            if not user or not verify_password(user_credentials.password, user['password_hash']):
                log_audit(user_credentials.user_id, None, "login_failed", 
                         None, request.client.host)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Incorrect username or password"
                )
            
            if not user['is_active']:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="User account is inactive"
                )
            
            # Update last_login
            cur.execute(
                "UPDATE api.user SET last_login = %s WHERE user_id = %s",
                (datetime.now(), user['user_id'])
            )
            
            log_audit(user['user_id'], None, "login_success", None, request.client.host)
            
            access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            access_token = create_access_token(
                data={"sub": user['user_id']}, 
                expires_delta=access_token_expires
            )
            
            return {"access_token": access_token, "token_type": "bearer"}

@app.get("/api/auth/verify")
async def verify_token(current_user: dict = Depends(get_current_user)):
    """Verify if JWT token is valid"""
    return {
        "user_id": current_user['user_id'], 
        "is_admin": current_user['is_admin'],
        "message": "Token is valid"
    }

# ==================== User Management Endpoints (Admin Only) ====================

@app.post("/api/users", status_code=status.HTTP_201_CREATED)
async def create_user(
    user_id: EmailStr,
    password: str,
    is_admin: bool = False,
    current_user: dict = Depends(get_current_admin_user)
):
    """Create a new user (admin only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                password_hash = hash_password(password)
                cur.execute(
                    """
                    INSERT INTO api.user (user_id, password_hash, is_admin)
                    VALUES (%s, %s, %s)
                    """,
                    (user_id, password_hash, is_admin)
                )
                log_audit(current_user['user_id'], None, "user_created", 
                         {"new_user": user_id}, None)
                return {"message": "User created successfully", "user_id": user_id}
            except psycopg2.IntegrityError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="User already exists"
                )

@app.get("/api/users", response_model=List[User])
async def list_users(current_user: dict = Depends(get_current_admin_user)):
    """List all users (admin only)"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT user_id, is_active, is_admin, created_at, last_login FROM api.user ORDER BY created_at DESC"
            )
            users = cur.fetchall()
            return [dict(user) for user in users]

@app.delete("/api/users/{user_id}")
async def delete_user(user_id: str, current_user: dict = Depends(get_current_admin_user)):
    """Delete a user (admin only)"""
    if user_id == current_user['user_id']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.user WHERE user_id = %s", (user_id,))
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            log_audit(current_user['user_id'], None, "user_deleted", 
                     {"deleted_user": user_id}, None)
            return {"message": "User deleted successfully"}

# ==================== API Client Management Endpoints (Admin Only) ====================

@app.post("/api/clients", status_code=status.HTTP_201_CREATED)
async def create_api_client(
    client: APIClientCreate,
    current_user: dict = Depends(get_current_admin_user)
):
    """Create a new API client (admin only) - Returns the API key once"""
    api_key = generate_api_key()
    
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    """
                    INSERT INTO api.api_client 
                    (api_client_id, api_key, description, expires_at)
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
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="API client already exists"
                )

@app.get("/api/clients", response_model=List[APIClient])
async def list_api_clients(current_user: dict = Depends(get_current_admin_user)):
    """List all API clients (admin only) - does not return API keys"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT api_client_id, is_active, created_at, expires_at, description, last_login
                FROM api.api_client
                ORDER BY created_at DESC
                """
            )
            clients = cur.fetchall()
            return [dict(client) for client in clients]

@app.patch("/api/clients/{api_client_id}/status")
async def update_api_client_status(
    api_client_id: str,
    is_active: bool,
    current_user: dict = Depends(get_current_admin_user)
):
    """Activate or deactivate an API client (admin only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE api.api_client SET is_active = %s WHERE api_client_id = %s",
                (is_active, api_client_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="API client not found"
                )
            log_audit(current_user['user_id'], None, "api_client_status_changed",
                     {"client_id": api_client_id, "is_active": is_active}, None)
            return {
                "message": f"API client {'activated' if is_active else 'deactivated'} successfully"
            }

@app.delete("/api/clients/{api_client_id}")
async def delete_api_client(
    api_client_id: str,
    current_user: dict = Depends(get_current_admin_user)
):
    """Delete an API client (admin only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM api.api_client WHERE api_client_id = %s",
                (api_client_id,)
            )
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="API client not found"
                )
            log_audit(current_user['user_id'], None, "api_client_deleted",
                     {"deleted_client": api_client_id}, None)
            return {"message": "API client deleted successfully"}

# ==================== Layer Management Endpoints (Admin/User) ====================

@app.post("/api/layer", status_code=status.HTTP_201_CREATED)
async def create_layer(layer: LayerCreate, current_user: dict = Depends(get_current_user)):
    """Create a new layer (authenticated users only)"""
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
                    (layer.project_id, layer.project_name, layer.layer_id, layer.publish,
                     layer.property_name, layer.dimension, layer.version,
                     layer.unit_of_measure_id, layer.metadata_url, layer.download_url,
                     layer.get_map_url, layer.get_legend_url, layer.get_feature_info_url)
                )
                log_audit(current_user['user_id'], None, "layer_created",
                         {"layer_id": layer.layer_id}, None)
                return {"message": "Layer created successfully", "layer_id": layer.layer_id}
            except psycopg2.IntegrityError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Layer already exists"
                )

@app.put("/api/layer/{layer_id}")
async def update_layer(
    layer_id: str,
    layer: Layer,
    current_user: dict = Depends(get_current_user)
):
    """Update a layer (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE api.layer SET
                    project_id = %s,
                    project_name = %s,
                    publish = %s,
                    property_name = %s,
                    dimension = %s,
                    version = %s,
                    unit_of_measure_id = %s,
                    metadata_url = %s,
                    download_url = %s,
                    get_map_url = %s,
                    get_legend_url = %s,
                    get_feature_info_url = %s
                WHERE layer_id = %s
                """,
                (layer.project_id, layer.project_name, layer.publish,
                 layer.property_name, layer.dimension, layer.version,
                 layer.unit_of_measure_id, layer.metadata_url, layer.download_url,
                 layer.get_map_url, layer.get_legend_url, layer.get_feature_info_url,
                 layer_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Layer not found"
                )
            log_audit(current_user['user_id'], None, "layer_updated",
                     {"layer_id": layer_id}, None)
            return {"message": "Layer updated successfully"}

@app.patch("/api/layer/{layer_id}/publish")
async def update_layer_publish(
    layer_id: str,
    publish_data: PublishUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Publish or unpublish a layer (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE api.layer SET publish = %s WHERE layer_id = %s",
                (publish_data.publish, layer_id)
            )
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Layer not found"
                )
            log_audit(current_user['user_id'], None, "layer_publish_changed",
                     {"layer_id": layer_id, "publish": publish_data.publish}, None)
            return {"message": "Layer publish status updated successfully"}

@app.delete("/api/layer/{layer_id}")
async def delete_layer(layer_id: str, current_user: dict = Depends(get_current_user)):
    """Delete a layer (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.layer WHERE layer_id = %s", (layer_id,))
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Layer not found"
                )
            log_audit(current_user['user_id'], None, "layer_deleted",
                     {"layer_id": layer_id}, None)
            return {"message": "Layer deleted successfully"}

@app.get("/api/layer/all", response_model=List[Layer])
async def get_all_layers(current_user: dict = Depends(get_current_user)):
    """Get all layers including unpublished (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.layer ORDER BY layer_id")
            layers = cur.fetchall()
            return [dict(layer) for layer in layers]

# ==================== Settings Management Endpoints (Admin/User) ====================

@app.post("/api/setting", status_code=status.HTTP_201_CREATED)
async def create_setting(setting: SettingCreate, current_user: dict = Depends(get_current_user)):
    """Create a new setting (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "INSERT INTO api.setting (key, value) VALUES (%s, %s)",
                    (setting.key, setting.value)
                )
                log_audit(current_user['user_id'], None, "setting_created",
                         {"key": setting.key}, None)
                return {"message": "Setting created successfully", "key": setting.key}
            except psycopg2.IntegrityError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Setting already exists"
                )

@app.put("/api/setting/{key}")
async def update_setting(
    key: str,
    setting_update: SettingUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update a setting value (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE api.setting SET value = %s WHERE key = %s",
                (setting_update.value, key)
            )
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Setting not found"
                )
            log_audit(current_user['user_id'], None, "setting_updated",
                     {"key": key}, None)
            return {"message": "Setting updated successfully"}

@app.delete("/api/setting/{key}")
async def delete_setting(key: str, current_user: dict = Depends(get_current_user)):
    """Delete a setting (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM api.setting WHERE key = %s", (key,))
            if cur.rowcount == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Setting not found"
                )
            log_audit(current_user['user_id'], None, "setting_deleted",
                     {"key": key}, None)
            return {"message": "Setting deleted successfully"}

@app.get("/api/setting/all", response_model=List[Setting])
async def get_all_settings(current_user: dict = Depends(get_current_user)):
    """Get all settings (authenticated users only)"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT key, value FROM api.setting ORDER BY key")
            settings = cur.fetchall()
            return [dict(setting) for setting in settings]

# ==================== Data Access Endpoints (API Key Required) ====================

@app.get("/api/manifest")
async def get_manifest(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get soil properties manifest (requires API key)"""
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
    """Get soil profiles (requires API key)"""
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
    """Get observational data (requires API key)"""
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

@app.get("/api/layer", response_model=List[Layer])
async def get_published_layers(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get only published layers (requires API key)"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.layer WHERE publish = TRUE ORDER BY layer_id")
            layers = cur.fetchall()
            
            log_audit(None, api_client['api_client_id'], "published_layers_accessed",
                     {"layer_count": len(layers)}, request.client.host)
            
            return [dict(layer) for layer in layers]

@app.get("/api/setting", response_model=List[Setting])
async def get_settings(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get all settings for application configuration (requires API key)"""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT key, value FROM api.setting ORDER BY key")
            settings = cur.fetchall()
            
            log_audit(None, api_client['api_client_id'], "settings_accessed",
                     {"setting_count": len(settings)}, request.client.host)
            
            return [dict(setting) for setting in settings]

# ==================== Health Check & Root ====================

@app.get("/")
async def root():
    """API root endpoint"""
    return {
        "message": "Soil Information System API",
        "version": "1.0.0",
        "docs": "/docs",
        "authentication": {
            "admin_access": "Use POST /api/auth/login to get JWT token for admin operations",
            "data_access": "Use X-API-Key header for all data endpoints"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint - no authentication required"""
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": "disconnected", "error": str(e)}