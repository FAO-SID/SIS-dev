from typing import List, Optional
from pydantic import validator
from pydantic_settings import BaseSettings
import os
from pathlib import Path


class Settings(BaseSettings):
    # Database settings
    DATABASE_URL: str = "postgresql://sis:password@localhost:5432/sis_database"
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "sis_database"
    DB_USER: str = "sis"
    DB_PASSWORD: str = "password"
    
    # JWT settings
    SECRET_KEY: str = "your-super-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # API settings
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "SIS API"
    PROJECT_VERSION: str = "1.0.0"
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080"]
    
    # File upload settings
    MAX_FILE_SIZE_MB: int = 50
    UPLOAD_DIR: str = "./uploads"
    ALLOWED_EXTENSIONS: List[str] = [".xlsx", ".xls", ".csv"]
    
    # Redis settings
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Environment
    ENVIRONMENT: str = "development"
    
    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v):
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)
    
    @property
    def max_file_size_bytes(self) -> int:
        return self.MAX_FILE_SIZE_MB * 1024 * 1024
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create uploads directory if it doesn't exist
def create_upload_dir():
    settings = Settings()
    upload_path = Path(settings.UPLOAD_DIR)
    upload_path.mkdir(exist_ok=True)


settings = Settings() 