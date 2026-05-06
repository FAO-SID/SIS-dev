"""
SIS GloSIS API — federation read-only data API.

The DB connection uses the read-only `sis_glosis` Postgres role, which has
SELECT only on the federation views and api.setting (plus INSERT on api.audit
for logging). Even with a valid token, callers cannot read or write anything
beyond manifest, profile, and observation.

In addition to the DB-layer guard, every request requires a federation token
(api.api_client.description = 'glosis-federation') AND the admin must have
flipped the GLOSIS_FEDERATION_ENABLED setting on.
"""

from typing import Annotated, Optional
from datetime import datetime

from fastapi import FastAPI, Depends, Request, Header, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from psycopg2.extras import RealDictCursor

from shared import get_db, log_audit

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


async def verify_federation_token(
    request: Request,
    x_api_key: Annotated[Optional[str], Header()] = None
) -> dict:
    """Validate a GloSIS federation token.

    Two gates:
    1. api.setting GLOSIS_FEDERATION_ENABLED must be 'true' (admin opt-in).
    2. The provided X-API-Key must match an active, non-expired row in
       api.vw_glosis_federation_token (filtered to description='glosis-federation').
    """
    if not x_api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key required. Include X-API-Key header in your request.",
            headers={"WWW-Authenticate": "ApiKey"}
        )
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT value FROM api.setting WHERE key = 'GLOSIS_FEDERATION_ENABLED'"
            )
            row = cur.fetchone()
            enabled = bool(row and str(row["value"]).strip().lower() == "true")
            if not enabled:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="GloSIS federation is disabled on this node."
                )

            cur.execute(
                "SELECT api_client_id, is_active, expires_at "
                "FROM api.vw_glosis_federation_token WHERE api_key = %s",
                (x_api_key,)
            )
            client = cur.fetchone()
            if not client:
                log_audit(None, None, "glosis_token_invalid",
                          {"api_key_prefix": x_api_key[:8] + "..."},
                          request.client.host)
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                    detail="Invalid federation token")
            if not client["is_active"]:
                log_audit(None, client["api_client_id"], "glosis_token_inactive",
                          None, request.client.host)
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                    detail="Federation token is inactive")
            if client["expires_at"] and client["expires_at"] < datetime.now().date():
                log_audit(None, client["api_client_id"], "glosis_token_expired",
                          None, request.client.host)
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                    detail="Federation token has expired")
            return dict(client)


# ==================== GloSIS Federation Endpoints ====================

@app.get("/manifest")
async def get_manifest(
    request: Request,
    api_client: dict = Depends(verify_federation_token)
):
    """Aggregated soil-property manifest for this node."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_manifest")
            data = cur.fetchall()
            log_audit(None, api_client["api_client_id"], "glosis_manifest_accessed",
                      {"record_count": len(data)}, request.client.host)
            return [dict(row) for row in data]


@app.get("/profile")
async def get_profiles(
    request: Request,
    api_client: dict = Depends(verify_federation_token)
):
    """Soil profiles for this node."""
    with get_db() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM api.vw_api_profile")
            data = cur.fetchall()
            log_audit(None, api_client["api_client_id"], "glosis_profiles_accessed",
                      {"record_count": len(data)}, request.client.host)
            return [dict(row) for row in data]


@app.get("/observation")
async def get_observations(
    request: Request,
    profile_code: Optional[str] = None,
    api_client: dict = Depends(verify_federation_token)
):
    """Observational data, optionally filtered by profile_code."""
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
            log_audit(None, api_client["api_client_id"], "glosis_observations_accessed",
                      {"profile_code": profile_code, "record_count": len(data)},
                      request.client.host)
            return [dict(row) for row in data]


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
