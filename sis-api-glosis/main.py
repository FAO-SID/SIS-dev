"""
SIS GloSIS API — API key authentication (for applications)
Read-only data access for GloSIS federation: manifest, profiles, observations, layers, settings.
"""

from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from psycopg2.extras import RealDictCursor

from shared import get_db, log_audit, Layer, Setting, verify_api_key

app = FastAPI(
    title="SIS GloSIS API",
    description="API key-protected read-only API for GloSIS federation data access.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

# ==================== GloSIS Federation Endpoints ====================

@app.get("/manifest")
async def get_manifest(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get the soil properties manifest."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_manifest")
            data = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "manifest_accessed",
                     {"record_count": len(data)}, request.client.host)
            return [dict(row) for row in data]

@app.get("/profile")
async def get_profiles(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get soil profiles."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_profile")
            data = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "profiles_accessed",
                     {"record_count": len(data)}, request.client.host)
            return [dict(row) for row in data]

@app.get("/observation")
async def get_observations(
    request: Request,
    profile_code: Optional[str] = None,
    api_client: dict = Depends(verify_api_key)
):
    """Get observational data, optionally filtered by profile code."""
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
                     {"profile_code": profile_code, "record_count": len(data)}, request.client.host)
            return [dict(row) for row in data]

@app.get("/layer", response_model=List[Layer])
async def get_published_layers(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get published layers only."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.layer WHERE LOWER(publish) = 'true' ORDER BY layer_id")
            layers = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "published_layers_accessed",
                     {"layer_count": len(layers)}, request.client.host)
            return [dict(layer) for layer in layers]

@app.get("/setting", response_model=List[Setting])
async def get_settings(
    request: Request,
    api_client: dict = Depends(verify_api_key)
):
    """Get application settings."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT key, value FROM api.setting ORDER BY key")
            settings = cur.fetchall()
            log_audit(None, api_client['api_client_id'], "settings_accessed",
                     {"setting_count": len(settings)}, request.client.host)
            return [dict(s) for s in settings]

# ==================== Health Check & Root ====================

@app.get("/")
async def root():
    return {
        "message": "SIS GloSIS API",
        "version": "1.0.0",
        "docs": "/docs",
        "authentication": "Include X-API-Key header in all requests"
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
