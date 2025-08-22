# requirements.txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
asyncpg==0.29.0
psycopg2-binary==2.9.9
alembic==1.12.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
pandas==2.1.3
openpyxl==3.1.2
xlrd==2.0.1
pydantic[email]==2.5.0
python-dotenv==1.0.0
slowapi==0.1.9
geoalchemy2==0.14.2
shapely==2.0.2
geojson==3.1.0

# .env
DATABASE_URL=postgresql+asyncpg://sis:your_password@localhost:5432/your_database
SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
MAX_FILE_SIZE_MB=50
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]

# app/main.py
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv

from .database import engine, get_db
from .auth import router as auth_router
from .api import api_router
from .soil_data import soil_data_router
from .upload import upload_router
from .middleware import add_rate_limiting

load_dotenv()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting up Soil Data API...")
    yield
    # Shutdown
    print("Shutting down Soil Data API...")

app = FastAPI(
    title="Soil Data Management API",
    description="REST API for soil data web mapping application",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add rate limiting middleware
add_rate_limiting(app)

# Include routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(api_router, prefix="/api", tags=["API Schema"])
app.include_router(soil_data_router, prefix="/soil-data", tags=["Soil Data"])
app.include_router(upload_router, prefix="/upload", tags=["File Upload"])

@app.get("/")
async def root():
    return {"message": "Soil Data Management API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# app/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy.pool import NullPool
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_async_engine(
    DATABASE_URL,
    poolclass=NullPool,  # Use NullPool for async
    echo=False,  # Set to True for SQL debugging
)

async_session = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

Base = declarative_base()

async def get_db():
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()

# app/models.py
from sqlalchemy import Column, Integer, String, Boolean, Date, Text, SmallInteger, Real, ForeignKey, CheckConstraint
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
import uuid

Base = declarative_base()

# API Schema Models
class User(Base):
    __tablename__ = "user"
    __table_args__ = {"schema": "api"}
    
    individual_id = Column(String, primary_key=True)
    organisation_id = Column(String, ForeignKey("soil_data.organisation.organisation_id"))
    password_hash = Column(String, nullable=False)
    created_at = Column(Date)
    last_login = Column(Date)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)

class Setting(Base):
    __tablename__ = "setting"
    __table_args__ = {"schema": "api"}
    
    key = Column(String, primary_key=True)
    value = Column(String)
    display_order = Column(SmallInteger)

class Layer(Base):
    __tablename__ = "layer"
    __table_args__ = {"schema": "api"}
    
    layer_id = Column(String, primary_key=True)
    individual_id = Column(String)
    project_id = Column(String)
    publish = Column(Boolean, default=True)
    property_id = Column(String)
    property_name = Column(String)
    version = Column(String)
    unit_of_measure_id = Column(String)
    dimension_des = Column(String)
    metadata_url = Column(String)
    download_url = Column(String)
    get_map_url = Column(String)
    get_legend_url = Column(String)
    get_feature_info_url = Column(String)

class UploadedDataset(Base):
    __tablename__ = "uploaded_dataset"
    __table_args__ = {"schema": "api"}
    
    table_name = Column(String, primary_key=True)
    individual_id = Column(String)
    project_id = Column(String)
    file_name = Column(String, nullable=False, unique=True)
    upload_date = Column(Date)
    ingestion_date = Column(Date)
    status = Column(String, CheckConstraint("status IN ('Uploaded', 'Ingested', 'Removed')"))
    depth_if_topsoil = Column(SmallInteger)
    n_rows = Column(Integer)
    n_col = Column(SmallInteger)
    has_cords = Column(Boolean)
    cords_epsg = Column(Integer)
    cords_check = Column(Boolean, default=False)
    note = Column(String)

class UploadedDatasetColumn(Base):
    __tablename__ = "uploaded_dataset_column"
    __table_args__ = {"schema": "api"}
    
    table_name = Column(String, ForeignKey("api.uploaded_dataset.table_name"), primary_key=True)
    column_name = Column(String, primary_key=True)
    property_phys_chem_id = Column(String)
    procedure_phys_chem_id = Column(String)
    unit_of_measure_id = Column(String)
    ignore_column = Column(Boolean, default=False)
    note = Column(String)

class UserLayer(Base):
    __tablename__ = "user_layer"
    __table_args__ = {"schema": "api"}
    
    individual_id = Column(String, primary_key=True)
    project_id = Column(String, primary_key=True)

# Soil Data Schema Models
class Individual(Base):
    __tablename__ = "individual"
    __table_args__ = {"schema": "soil_data"}
    
    individual_id = Column(String, primary_key=True)
    email = Column(String)

class Organisation(Base):
    __tablename__ = "organisation"
    __table_args__ = {"schema": "soil_data"}
    
    organisation_id = Column(String, primary_key=True)
    url = Column(String)
    email = Column(String)
    country = Column(String)
    city = Column(String)
    postal_code = Column(String)
    delivery_point = Column(String)
    phone = Column(String)
    facsimile = Column(String)

class Project(Base):
    __tablename__ = "project"
    __table_args__ = {"schema": "soil_data"}
    
    project_id = Column(String, primary_key=True)
    name = Column(String, nullable=False, unique=True)

class ProjXOrgXInd(Base):
    __tablename__ = "proj_x_org_x_ind"
    __table_args__ = {"schema": "soil_data"}
    
    project_id = Column(String, primary_key=True)
    organisation_id = Column(String, primary_key=True)
    individual_id = Column(String, primary_key=True)
    position = Column(String, primary_key=True)
    tag = Column(String, primary_key=True)
    role = Column(String, primary_key=True)

# app/schemas.py
from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import date
from enum import Enum

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str

class TokenData(BaseModel):
    individual_id: Optional[str] = None

class UserLogin(BaseModel):
    individual_id: str
    password: str

class UserCreate(BaseModel):
    individual_id: str
    email: EmailStr
    password: str
    organisation_id: Optional[str] = None
    is_admin: bool = False

class UserResponse(BaseModel):
    individual_id: str
    organisation_id: Optional[str]
    created_at: Optional[date]
    last_login: Optional[date]
    is_active: bool
    is_admin: bool

    class Config:
        from_attributes = True

class SettingCreate(BaseModel):
    key: str
    value: Optional[str]
    display_order: Optional[int]

class SettingResponse(BaseModel):
    key: str
    value: Optional[str]
    display_order: Optional[int]

    class Config:
        from_attributes = True

class LayerCreate(BaseModel):
    layer_id: str
    individual_id: Optional[str]
    project_id: Optional[str]
    publish: bool = True
    property_id: Optional[str]
    property_name: Optional[str]
    version: Optional[str]
    unit_of_measure_id: Optional[str]
    dimension_des: Optional[str]
    metadata_url: Optional[str]
    download_url: Optional[str]
    get_map_url: Optional[str]
    get_legend_url: Optional[str]
    get_feature_info_url: Optional[str]

class LayerResponse(BaseModel):
    layer_id: str
    individual_id: Optional[str]
    project_id: Optional[str]
    publish: bool
    property_id: Optional[str]
    property_name: Optional[str]
    version: Optional[str]
    unit_of_measure_id: Optional[str]
    dimension_des: Optional[str]
    metadata_url: Optional[str]
    download_url: Optional[str]
    get_map_url: Optional[str]
    get_legend_url: Optional[str]
    get_feature_info_url: Optional[str]

    class Config:
        from_attributes = True

class IndividualCreate(BaseModel):
    individual_id: str
    email: Optional[EmailStr]

class IndividualResponse(BaseModel):
    individual_id: str
    email: Optional[str]

    class Config:
        from_attributes = True

class OrganisationCreate(BaseModel):
    organisation_id: str
    url: Optional[str]
    email: Optional[EmailStr]
    country: Optional[str]
    city: Optional[str]
    postal_code: Optional[str]
    delivery_point: Optional[str]
    phone: Optional[str]
    facsimile: Optional[str]

class OrganisationResponse(BaseModel):
    organisation_id: str
    url: Optional[str]
    email: Optional[str]
    country: Optional[str]
    city: Optional[str]
    postal_code: Optional[str]
    delivery_point: Optional[str]
    phone: Optional[str]
    facsimile: Optional[str]

    class Config:
        from_attributes = True

class ProjectCreate(BaseModel):
    project_id: str
    name: str

class ProjectResponse(BaseModel):
    project_id: str
    name: str

    class Config:
        from_attributes = True

class ProjXOrgXIndCreate(BaseModel):
    project_id: str
    organisation_id: str
    individual_id: str
    position: str
    tag: str
    role: str

    @validator('role')
    def validate_role(cls, v):
        allowed_roles = ['author', 'custodian', 'distributor', 'originator', 'owner', 
                        'pointOfContact', 'principalInvestigator', 'processor', 'publisher', 
                        'resourceProvider', 'user']
        if v not in allowed_roles:
            raise ValueError(f'Role must be one of: {", ".join(allowed_roles)}')
        return v

    @validator('tag')
    def validate_tag(cls, v):
        allowed_tags = ['contact', 'pointOfContact']
        if v not in allowed_tags:
            raise ValueError(f'Tag must be one of: {", ".join(allowed_tags)}')
        return v

class ProjXOrgXIndResponse(BaseModel):
    project_id: str
    organisation_id: str
    individual_id: str
    position: str
    tag: str
    role: str

    class Config:
        from_attributes = True

class ProfileResponse(BaseModel):
    gid: int
    project_name: Optional[str]
    site_id: Optional[int]
    profile_id: Optional[int]
    specimen_id: Optional[int]
    upper_depth: Optional[int]
    lower_depth: Optional[int]
    property_phys_chem_id: Optional[str]
    procedure_phys_chem_id: Optional[str]
    value: Optional[float]
    unit_of_measure_id: Optional[str]

    class Config:
        from_attributes = True

# Upload related schemas
class DatasetStatus(str, Enum):
    uploaded = "Uploaded"
    ingested = "Ingested"
    removed = "Removed"

class UploadedDatasetResponse(BaseModel):
    table_name: str
    individual_id: Optional[str]
    project_id: Optional[str]
    file_name: str
    upload_date: Optional[date]
    ingestion_date: Optional[date]
    status: Optional[str]
    depth_if_topsoil: Optional[int]
    n_rows: Optional[int]
    n_col: Optional[int]
    has_cords: Optional[bool]
    cords_epsg: Optional[int]
    cords_check: Optional[bool]
    note: Optional[str]

    class Config:
        from_attributes = True

# app/auth.py
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import os

from .database import get_db
from .models import User, Individual
from .schemas import Token, UserLogin, UserCreate, UserResponse, TokenData

router = APIRouter()

# Security configuration
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def authenticate_user(db: AsyncSession, individual_id: str, password: str):
    result = await db.execute(select(User).where(User.individual_id == individual_id))
    user = result.scalar_one_or_none()
    if not user:
        return False
    if not verify_password(password, user.password_hash):
        return False
    return user

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: AsyncSession = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        individual_id: str = payload.get("sub")
        if individual_id is None:
            raise credentials_exception
        token_data = TokenData(individual_id=individual_id)
    except JWTError:
        raise credentials_exception
    
    result = await db.execute(select(User).where(User.individual_id == token_data.individual_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

async def get_admin_user(current_user: User = Depends(get_current_active_user)):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    return current_user

@router.post("/login", response_model=Token)
async def login_for_access_token(user_login: UserLogin, db: AsyncSession = Depends(get_db)):
    user = await authenticate_user(db, user_login.individual_id, user_login.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect individual_id or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Update last login
    user.last_login = datetime.utcnow().date()
    await db.commit()
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.individual_id}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token(data={"sub": user.individual_id})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh", response_model=Token)
async def refresh_access_token(credentials: HTTPAuthorizationCredentials = Depends(security), db: AsyncSession = Depends(get_db)):
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        individual_id: str = payload.get("sub")
        if individual_id is None:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    result = await db.execute(select(User).where(User.individual_id == individual_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.individual_id}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token(data={"sub": user.individual_id})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/register", response_model=UserResponse)
async def register_user(user_create: UserCreate, db: AsyncSession = Depends(get_db), admin_user: User = Depends(get_admin_user)):
    # Check if individual exists in soil_data schema
    result = await db.execute(select(Individual).where(Individual.individual_id == user_create.individual_id))
    individual = result.scalar_one_or_none()
    
    if not individual:
        # Create individual if doesn't exist
        new_individual = Individual(individual_id=user_create.individual_id, email=user_create.email)
        db.add(new_individual)
    
    # Check if user already exists in api schema
    result = await db.execute(select(User).where(User.individual_id == user_create.individual_id))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(status_code=400, detail="User already registered")
    
    # Create new user
    hashed_password = get_password_hash(user_create.password)
    db_user = User(
        individual_id=user_create.individual_id,
        organisation_id=user_create.organisation_id,
        password_hash=hashed_password,
        created_at=datetime.utcnow().date(),
        is_admin=user_create.is_admin
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    
    return db_user

@router.get("/me", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@router.post("/logout")
async def logout(current_user: User = Depends(get_current_active_user)):
    # In a production system, you might want to blacklist the token
    return {"message": "Successfully logged out"}

# app/api.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, insert, update, delete
from typing import List

from .database import get_db
from .auth import get_current_active_user, get_admin_user
from .models import User, Setting, Layer, UploadedDataset, UploadedDatasetColumn, UserLayer
from .schemas import (
    UserResponse, SettingCreate, SettingResponse, LayerCreate, LayerResponse,
    UploadedDatasetResponse
)

api_router = APIRouter()

# Settings endpoints
@api_router.get("/settings", response_model=List[SettingResponse])
async def get_settings(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Setting).order_by(Setting.display_order))
    settings = result.scalars().all()
    return settings

@api_router.post("/settings", response_model=SettingResponse)
async def create_setting(setting: SettingCreate, db: AsyncSession = Depends(get_db), admin_user: User = Depends(get_admin_user)):
    db_setting = Setting(**setting.dict())
    db.add(db_setting)
    await db.commit()
    await db.refresh(db_setting)
    return db_setting

@api_router.put("/settings/{key}", response_model=SettingResponse)
async def update_setting(key: str, setting: SettingCreate, db: AsyncSession = Depends(get_db), admin_user: User = Depends(get_admin_user)):
    result = await db.execute(select(Setting).where(Setting.key == key))
    db_setting = result.scalar_one_or_none()
    if not db_setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    
    for field, value in setting.dict(exclude_unset=True).items():
        setattr(db_setting, field, value)
    
    await db.commit()
    await db.refresh(db_setting)
    return db_setting

# Layers endpoints
@api_router.get("/layers", response_model=List[LayerResponse])
async def get_layers(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Get layers accessible to current user
    result = await db.execute(
        select(Layer).where(
            (Layer.individual_id == current_user.individual_id) | 
            (Layer.publish == True)
        )
    )
    layers = result.scalars().all()
    return layers

@api_router.post("/layers", response_model=LayerResponse)
async def create_layer(layer: LayerCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Set the current user as the owner if not specified
    if not layer.individual_id:
        layer.individual_id = current_user.individual_id
    
    db_layer = Layer(**layer.dict())
    db.add(db_layer)
    await db.commit()
    await db.refresh(db_layer)
    return db_layer

@api_router.put("/layers/{layer_id}", response_model=LayerResponse)
async def update_layer(layer_id: str, layer: LayerCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Layer).where(Layer.layer_id == layer_id))
    db_layer = result.scalar_one_or_none()
    if not db_layer:
        raise HTTPException(status_code=404, detail="Layer not found")
    
    # Check if user owns the layer or is admin
    if db_layer.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    for field, value in layer.dict(exclude_unset=True).items():
        setattr(db_layer, field, value)
    
    await db.commit()
    await db.refresh(db_layer)
    return db_layer

@api_router.delete("/layers/{layer_id}")
async def delete_layer(layer_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Layer).where(Layer.layer_id == layer_id))
    db_layer = result.scalar_one_or_none()
    if not db_layer:
        raise HTTPException(status_code=404, detail="Layer not found")
    
    # Check if user owns the layer or is admin
    if db_layer.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    await db.delete(db_layer)
    await db.commit()
    return {"message": "Layer deleted successfully"}

# Users endpoints
@api_router.get("/users", response_model=List[UserResponse])
async def get_users(db: AsyncSession = Depends(get_db), admin_user: User = Depends(get_admin_user)):
    result = await db.execute(select(User))
    users = result.scalars().all()
    return users

@api_router.put("/users/{individual_id}", response_model=UserResponse)
async def update_user(individual_id: str, user_update: dict, db: AsyncSession = Depends(get_db), admin_user: User = Depends(get_admin_user)):
    result = await db.execute(select(User).where(User.individual_id == individual_id))
    db_user = result.scalar_one_or_none()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Don't allow password updates through this endpoint
    user_update.pop('password', None)
    user_update.pop('password_hash', None)
    
    for field, value in user_update.items():
        if hasattr(db_user, field):
            setattr(db_user, field, value)
    
    await db.commit()
    await db.refresh(db_user)
    return db_user

# User layers endpoints
@api_router.get("/user-layers")
async def get_user_layers(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(UserLayer).where(UserLayer.individual_id == current_user.individual_id))
    user_layers = result.scalars().all()
    return user_layers

@api_router.post("/user-layers")
async def create_user_layer(project_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Check if association already exists
    result = await db.execute(
        select(UserLayer).where(
            (UserLayer.individual_id == current_user.individual_id) & 
            (UserLayer.project_id == project_id)
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="User layer association already exists")
    
    user_layer = UserLayer(individual_id=current_user.individual_id, project_id=project_id)
    db.add(user_layer)
    await db.commit()
    return {"message": "User layer association created successfully"}

# Uploaded datasets endpoints
@api_router.get("/uploaded-datasets", response_model=List[UploadedDatasetResponse])
async def get_uploaded_datasets(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    if current_user.is_admin:
        result = await db.execute(select(UploadedDataset))
    else:
        result = await db.execute(select(UploadedDataset).where(UploadedDataset.individual_id == current_user.individual_id))
    datasets = result.scalars().all()
    return datasets

@api_router.get("/uploaded-datasets/{table_name}", response_model=UploadedDatasetResponse)
async def get_uploaded_dataset(table_name: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(UploadedDataset).where(UploadedDataset.table_name == table_name))
    dataset = result.scalar_one_or_none()
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    # Check permissions
    if dataset.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    return dataset

# app/soil_data.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from typing import List, Optional

from .database import get_db
from .auth import get_current_active_user
from .models import Individual, Organisation, Project, ProjXOrgXInd, User
from .schemas import (
    IndividualCreate, IndividualResponse, OrganisationCreate, OrganisationResponse,
    ProjectCreate, ProjectResponse, ProjXOrgXIndCreate, ProjXOrgXIndResponse,
    ProfileResponse
)

soil_data_router = APIRouter()

# Individual endpoints
@soil_data_router.get("/individuals", response_model=List[IndividualResponse])
async def get_individuals(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Individual))
    individuals = result.scalars().all()
    return individuals

@soil_data_router.post("/individuals", response_model=IndividualResponse)
async def create_individual(individual: IndividualCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Check if individual already exists
    result = await db.execute(select(Individual).where(Individual.individual_id == individual.individual_id))
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Individual already exists")
    
    db_individual = Individual(**individual.dict())
    db.add(db_individual)
    await db.commit()
    await db.refresh(db_individual)
    return db_individual

@soil_data_router.get("/individuals/{individual_id}", response_model=IndividualResponse)
async def get_individual(individual_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Individual).where(Individual.individual_id == individual_id))
    individual = result.scalar_one_or_none()
    if not individual:
        raise HTTPException(status_code=404, detail="Individual not found")
    return individual

# Organisation endpoints
@soil_data_router.get("/organisations", response_model=List[OrganisationResponse])
async def get_organisations(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Organisation))
    organisations = result.scalars().all()
    return organisations

@soil_data_router.post("/organisations", response_model=OrganisationResponse)
async def create_organisation(organisation: OrganisationCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Check if organisation already exists
    result = await db.execute(select(Organisation).where(Organisation.organisation_id == organisation.organisation_id))
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Organisation already exists")
    
    db_organisation = Organisation(**organisation.dict())
    db.add(db_organisation)
    await db.commit()
    await db.refresh(db_organisation)
    return db_organisation

@soil_data_router.get("/organisations/{organisation_id}", response_model=OrganisationResponse)
async def get_organisation(organisation_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Organisation).where(Organisation.organisation_id == organisation_id))
    organisation = result.scalar_one_or_none()
    if not organisation:
        raise HTTPException(status_code=404, detail="Organisation not found")
    return organisation

# Project endpoints
@soil_data_router.get("/projects", response_model=List[ProjectResponse])
async def get_projects(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Project))
    projects = result.scalars().all()
    return projects

@soil_data_router.post("/projects", response_model=ProjectResponse)
async def create_project(project: ProjectCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Check if project already exists
    result = await db.execute(select(Project).where(Project.project_id == project.project_id))
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Project already exists")
    
    db_project = Project(**project.dict())
    db.add(db_project)
    await db.commit()
    await db.refresh(db_project)
    return db_project

@soil_data_router.get("/projects/{project_id}", response_model=ProjectResponse)
async def get_project(project_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(Project).where(Project.project_id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project

# Project-Organisation-Individual relationships
@soil_data_router.get("/project-relationships", response_model=List[ProjXOrgXIndResponse])
async def get_project_relationships(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    result = await db.execute(select(ProjXOrgXInd))
    relationships = result.scalars().all()
    return relationships

@soil_data_router.post("/project-relationships", response_model=ProjXOrgXIndResponse)
async def create_project_relationship(relationship: ProjXOrgXIndCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    # Check if relationship already exists
    result = await db.execute(
        select(ProjXOrgXInd).where(
            (ProjXOrgXInd.project_id == relationship.project_id) &
            (ProjXOrgXInd.organisation_id == relationship.organisation_id) &
            (ProjXOrgXInd.individual_id == relationship.individual_id) &
            (ProjXOrgXInd.position == relationship.position) &
            (ProjXOrgXInd.tag == relationship.tag) &
            (ProjXOrgXInd.role == relationship.role)
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Relationship already exists")
    
    db_relationship = ProjXOrgXInd(**relationship.dict())
    db.add(db_relationship)
    await db.commit()
    await db.refresh(db_relationship)
    return db_relationship

# Profiles view endpoint
@soil_data_router.get("/profiles", response_model=List[ProfileResponse])
async def get_profiles(
    project_name: Optional[str] = None,
    site_id: Optional[int] = None,
    profile_id: Optional[int] = None,
    property_phys_chem_id: Optional[str] = None,
    limit: int = 1000,
    offset: int = 0,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    query = "SELECT * FROM soil_data.profiles WHERE 1=1"
    params = {}
    
    if project_name:
        query += " AND project_name ILIKE :project_name"
        params["project_name"] = f"%{project_name}%"
    
    if site_id:
        query += " AND site_id = :site_id"
        params["site_id"] = site_id
    
    if profile_id:
        query += " AND profile_id = :profile_id"
        params["profile_id"] = profile_id
    
    if property_phys_chem_id:
        query += " AND property_phys_chem_id = :property_phys_chem_id"
        params["property_phys_chem_id"] = property_phys_chem_id
    
    query += " ORDER BY project_name, site_id, profile_id, upper_depth, property_phys_chem_id"
    query += " LIMIT :limit OFFSET :offset"
    params["limit"] = limit
    params["offset"] = offset
    
    result = await db.execute(text(query), params)
    profiles = result.fetchall()
    
    # Convert to response format
    response_data = []
    for profile in profiles:
        response_data.append({
            "gid": profile.gid,
            "project_name": profile.project_name,
            "site_id": profile.site_id,
            "profile_id": profile.profile_id,
            "specimen_id": profile.specimen_id,
            "upper_depth": profile.upper_depth,
            "lower_depth": profile.lower_depth,
            "property_phys_chem_id": profile.property_phys_chem_id,
            "procedure_phys_chem_id": profile.procedure_phys_chem_id,
            "value": profile.value,
            "unit_of_measure_id": profile.unit_of_measure_id
        })
    
    return response_data

@soil_data_router.get("/profiles/geojson")
async def get_profiles_geojson(
    project_name: Optional[str] = None,
    site_id: Optional[int] = None,
    property_phys_chem_id: Optional[str] = None,
    limit: int = 1000,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get profile data as GeoJSON for mapping applications"""
    query = """
    SELECT 
        p.gid,
        p.project_name,
        p.site_id,
        p.profile_id,
        p.property_phys_chem_id,
        p.value,
        p.unit_of_measure_id,
        ST_AsGeoJSON(p.geom) as geometry
    FROM soil_data.profiles p 
    WHERE p.geom IS NOT NULL
    """
    params = {}
    
    if project_name:
        query += " AND p.project_name ILIKE :project_name"
        params["project_name"] = f"%{project_name}%"
    
    if site_id:
        query += " AND p.site_id = :site_id"
        params["site_id"] = site_id
    
    if property_phys_chem_id:
        query += " AND p.property_phys_chem_id = :property_phys_chem_id"
        params["property_phys_chem_id"] = property_phys_chem_id
    
    query += " LIMIT :limit"
    params["limit"] = limit
    
    result = await db.execute(text(query), params)
    profiles = result.fetchall()
    
    # Build GeoJSON
    features = []
    for profile in profiles:
        if profile.geometry:
            import json
            geometry = json.loads(profile.geometry)
            feature = {
                "type": "Feature",
                "geometry": geometry,
                "properties": {
                    "gid": profile.gid,
                    "project_name": profile.project_name,
                    "site_id": profile.site_id,
                    "profile_id": profile.profile_id,
                    "property_phys_chem_id": profile.property_phys_chem_id,
                    "value": profile.value,
                    "unit_of_measure_id": profile.unit_of_measure_id
                }
            }
            features.append(feature)
    
    return {
        "type": "FeatureCollection",
        "features": features
    }

# app/upload.py
import os
import uuid
import pandas as pd
from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text, create_engine
from sqlalchemy.dialects.postgresql import insert

from .database import get_db, DATABASE_URL
from .auth import get_current_active_user
from .models import User, UploadedDataset, UploadedDatasetColumn
from .schemas import UploadedDatasetResponse

upload_router = APIRouter()

MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE_MB", "50")) * 1024 * 1024  # Convert MB to bytes

def detect_coordinate_columns(df):
    """Detect potential coordinate columns in the dataframe"""
    coord_patterns = {
        'lat': ['lat', 'latitude', 'y', 'coord_y', 'northing'],
        'lon': ['lon', 'lng', 'longitude', 'x', 'coord_x', 'easting']
    }
    
    detected_coords = {}
    columns_lower = [col.lower() for col in df.columns]
    
    for coord_type, patterns in coord_patterns.items():
        for pattern in patterns:
            for i, col in enumerate(columns_lower):
                if pattern in col:
                    detected_coords[coord_type] = df.columns[i]
                    break
            if coord_type in detected_coords:
                break
    
    return detected_coords

def infer_data_types(df):
    """Infer PostgreSQL data types from pandas dataframe"""
    type_mapping = {}
    
    for column in df.columns:
        dtype = df[column].dtype
        
        if pd.api.types.is_integer_dtype(dtype):
            type_mapping[column] = 'INTEGER'
        elif pd.api.types.is_float_dtype(dtype):
            type_mapping[column] = 'REAL'
        elif pd.api.types.is_bool_dtype(dtype):
            type_mapping[column] = 'BOOLEAN'
        elif pd.api.types.is_datetime64_any_dtype(dtype):
            type_mapping[column] = 'TIMESTAMP'
        else:
            # For text columns, analyze max length
            max_length = df[column].astype(str).str.len().max()
            if max_length > 255:
                type_mapping[column] = 'TEXT'
            else:
                type_mapping[column] = f'VARCHAR({min(max_length + 50, 255)})'
    
    return type_mapping

def validate_coordinates(df, lat_col, lon_col):
    """Validate coordinate values"""
    if lat_col not in df.columns or lon_col not in df.columns:
        return False, "Coordinate columns not found"
    
    try:
        lat_values = pd.to_numeric(df[lat_col], errors='coerce')
        lon_values = pd.to_numeric(df[lon_col], errors='coerce')
        
        # Check for valid coordinate ranges
        valid_lat = (lat_values >= -90) & (lat_values <= 90)
        valid_lon = (lon_values >= -180) & (lon_values <= 180)
        
        invalid_count = (~(valid_lat & valid_lon)).sum()
        
        if invalid_count > 0:
            return False, f"{invalid_count} rows have invalid coordinates"
        
        return True, "Coordinates are valid"
    except Exception as e:
        return False, f"Error validating coordinates: {str(e)}"

async def create_table_in_upload_schema(df, table_name, type_mapping):
    """Create table in soil_data_upload schema"""
    # Create synchronous connection for table creation
    sync_url = DATABASE_URL.replace('+asyncpg', '')
    engine = create_engine(sync_url)
    
    try:
        # Create table schema
        columns_def = []
        for column, pg_type in type_mapping.items():
            # Sanitize column name
            safe_column = column.replace(' ', '_').replace('-', '_').replace('.', '_')
            columns_def.append(f'"{safe_column}" {pg_type}')
        
        create_table_sql = f"""
        CREATE TABLE IF NOT EXISTS soil_data_upload."{table_name}" (
            id SERIAL PRIMARY KEY,
            {', '.join(columns_def)}
        )
        """
        
        with engine.connect() as conn:
            conn.execute(text(create_table_sql))
            conn.commit()
            
            # Insert data
            df_clean = df.copy()
            df_clean.columns = [col.replace(' ', '_').replace('-', '_').replace('.', '_') for col in df_clean.columns]
            df_clean.to_sql(table_name, conn, schema='soil_data_upload', if_exists='append', index=False, method='multi')
        
        return True, "Table created and data inserted successfully"
    except Exception as e:
        return False, f"Error creating table: {str(e)}"
    finally:
        engine.dispose()

@upload_router.post("/upload-file", response_model=UploadedDatasetResponse)
async def upload_file(
    file: UploadFile = File(...),
    project_id: Optional[str] = Form(None),
    depth_if_topsoil: Optional[int] = Form(None),
    note: Optional[str] = Form(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Validate file size
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum size is {MAX_FILE_SIZE // (1024*1024)}MB"
        )
    
    # Validate file type
    allowed_extensions = ['.xlsx', '.xls', '.csv']
    file_extension = os.path.splitext(file.filename)[1].lower()
    if file_extension not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail=f"File type not supported. Allowed types: {', '.join(allowed_extensions)}"
        )
    
    try:
        # Read file content
        contents = await file.read()
        
        # Parse file based on extension
        if file_extension in ['.xlsx', '.xls']:
            df = pd.read_excel(contents, engine='openpyxl' if file_extension == '.xlsx' else 'xlrd')
        else:  # CSV
            df = pd.read_csv(contents)
        
        # Basic validation
        if df.empty:
            raise HTTPException(status_code=400, detail="File is empty")
        
        if len(df.columns) == 0:
            raise HTTPException(status_code=400, detail="No columns found in file")
        
        # Generate unique table name
        table_name = f"upload_{uuid.uuid4().hex[:8]}_{int(date.today().strftime('%Y%m%d'))}"
        
        # Detect coordinates
        coord_cols = detect_coordinate_columns(df)
        has_coords = len(coord_cols) >= 2
        coords_valid = False
        cords_epsg = 4326  # Default to WGS84
        
        if has_coords:
            coords_valid, coord_msg = validate_coordinates(df, coord_cols.get('lat'), coord_cols.get('lon'))
            if not coords_valid:
                print(f"Coordinate validation warning: {coord_msg}")
        
        # Infer data types
        type_mapping = infer_data_types(df)
        
        # Create table in upload schema
        success, message = await create_table_in_upload_schema(df, table_name, type_mapping)
        if not success:
            raise HTTPException(status_code=500, detail=message)
        
        # Create uploaded dataset record
        uploaded_dataset = UploadedDataset(
            table_name=table_name,
            individual_id=current_user.individual_id,
            project_id=project_id,
            file_name=file.filename,
            upload_date=date.today(),
            status="Uploaded",
            depth_if_topsoil=depth_if_topsoil,
            n_rows=len(df),
            n_col=len(df.columns),
            has_cords=has_coords,
            cords_epsg=cords_epsg if has_coords else None,
            cords_check=coords_valid,
            note=note
        )
        
        db.add(uploaded_dataset)
        await db.commit()
        await db.refresh(uploaded_dataset)
        
        # Create column metadata records
        for column, pg_type in type_mapping.items():
            safe_column = column.replace(' ', '_').replace('-', '_').replace('.', '_')
            column_record = UploadedDatasetColumn(
                table_name=table_name,
                column_name=safe_column,
                ignore_column=False
            )
            db.add(column_record)
        
        await db.commit()
        
        return uploaded_dataset
        
    except pd.errors.EmptyDataError:
        raise HTTPException(status_code=400, detail="File is empty or corrupted")
    except pd.errors.ParserError as e:
        raise HTTPException(status_code=400, detail=f"Error parsing file: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")

@upload_router.get("/uploaded-datasets/{table_name}/preview")
async def preview_uploaded_dataset(
    table_name: str,
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check if dataset exists and user has permission
    result = await db.execute(select(UploadedDataset).where(UploadedDataset.table_name == table_name))
    dataset = result.scalar_one_or_none()
    
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    if dataset.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    try:
        # Get sample data from uploaded table
        query = f'SELECT * FROM soil_data_upload."{table_name}" LIMIT :limit'
        result = await db.execute(text(query), {"limit": limit})
        rows = result.fetchall()
        columns = result.keys()
        
        # Convert to list of dictionaries
        data = []
        for row in rows:
            data.append(dict(zip(columns, row)))
        
        return {
            "columns": list(columns),
            "data": data,
            "total_rows": dataset.n_rows,
            "preview_rows": len(data)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error previewing data: {str(e)}")

@upload_router.post("/uploaded-datasets/{table_name}/ingest")
async def ingest_uploaded_dataset(
    table_name: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check if dataset exists and user has permission
    result = await db.execute(select(UploadedDataset).where(UploadedDataset.table_name == table_name))
    dataset = result.scalar_one_or_none()
    
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    if dataset.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    if dataset.status == "Ingested":
        raise HTTPException(status_code=400, detail="Dataset already ingested")
    
    try:
        # This is where you would implement your data ingestion logic
        # For now, we'll just mark it as ingested
        dataset.status = "Ingested"
        dataset.ingestion_date = date.today()
        
        await db.commit()
        await db.refresh(dataset)
        
        return {"message": "Dataset ingested successfully", "dataset": dataset}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error ingesting dataset: {str(e)}")

@upload_router.delete("/uploaded-datasets/{table_name}")
async def delete_uploaded_dataset(
    table_name: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check if dataset exists and user has permission
    result = await db.execute(select(UploadedDataset).where(UploadedDataset.table_name == table_name))
    dataset = result.scalar_one_or_none()
    
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    if dataset.individual_id != current_user.individual_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    try:
        # Drop the table from upload schema
        sync_url = DATABASE_URL.replace('+asyncpg', '')
        engine = create_engine(sync_url)
        
        with engine.connect() as conn:
            conn.execute(text(f'DROP TABLE IF EXISTS soil_data_upload."{table_name}"'))
            conn.commit()
        
        engine.dispose()
        
        # Update status
        dataset.status = "Removed"
        await db.commit()
        
        return {"message": "Dataset deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting dataset: {str(e)}")

# app/middleware.py
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi import FastAPI, Request
import redis
import os

# Rate limiting configuration
limiter = Limiter(
    key_func=get_remote_address,
    storage_uri=os.getenv("REDIS_URL", "memory://"),  # Use in-memory if Redis not available
    default_limits=["100/minute"]
)

def add_rate_limiting(app: FastAPI):
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# app/utils.py
import re
from typing import Dict, Any
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def validate_email(email: str) -> bool:
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
    return re.match(pattern, email) is not None

def sanitize_table_name(name: str) -> str:
    """Sanitize table name for PostgreSQL"""
    # Remove special characters and replace with underscore
    sanitized = re.sub(r'[^a-zA-Z0-9_]', '_', name)
    # Ensure it starts with a letter
    if not sanitized[0].isalpha():
        sanitized = 'table_' + sanitized
    return sanitized.lower()

def sanitize_column_name(name: str) -> str:
    """Sanitize column name for PostgreSQL"""
    # Remove special characters and replace with underscore
    sanitized = re.sub(r'[^a-zA-Z0-9_]', '_', name)
    # Ensure it starts with a letter or underscore
    if sanitized and not (sanitized[0].isalpha() or sanitized[0] == '_'):
        sanitized = 'col_' + sanitized
    return sanitized.lower()

def hash_password(password: str) -> str:
    """Hash password using bcrypt"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against hash"""
    return pwd_context.verify(plain_password, hashed_password)

# docker-compose.yml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://sis:your_password@postgres:5432/your_database
      - SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random
      - ALGORITHM=HS256
      - ACCESS_TOKEN_EXPIRE_MINUTES=30
      - REFRESH_TOKEN_EXPIRE_DAYS=7
      - MAX_FILE_SIZE_MB=50
      - CORS_ORIGINS=http://localhost:3000,http://localhost:8080
    depends_on:
      - postgres
      - redis
    volumes:
      - ./app:/app
    restart: unless-stopped

  postgres:
    image: postgis/postgis:15-3.3
    environment:
      - POSTGRES_DB=your_database
      - POSTGRES_USER=sis
      - POSTGRES_PASSWORD=your_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sis-database_latest_only_schema.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379