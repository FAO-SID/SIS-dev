from fastapi import APIRouter
from app.api.v1 import auth, api_routes, soil_data_routes

api_router = APIRouter()

# Include authentication routes
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])

# Include API schema routes (settings, layers, user_layers, uploaded_datasets)
api_router.include_router(api_routes.router, prefix="/api", tags=["api-resources"])

# Include soil_data schema routes (individuals, organisations, projects, profiles)
api_router.include_router(soil_data_routes.router, prefix="/soil-data", tags=["soil-data"]) 