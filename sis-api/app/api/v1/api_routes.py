from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user, get_current_admin_user
from app.models.api_models import User, Setting, Layer, UserLayer, UploadedDataset, UploadedDatasetColumn
from app.schemas.api_schemas import (
    SettingCreate, SettingUpdate, SettingResponse,
    LayerCreate, LayerUpdate, LayerResponse,
    UserLayerCreate, UserLayerResponse,
    UploadedDatasetCreate, UploadedDatasetUpdate, UploadedDatasetResponse,
    UploadedDatasetColumnCreate, UploadedDatasetColumnUpdate, UploadedDatasetColumnResponse,
    FileUploadResponse
)
from app.services.file_upload_service import FileUploadService

router = APIRouter()

# Settings endpoints
@router.get("/settings", response_model=List[SettingResponse])
def get_settings(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all settings"""
    settings = db.query(Setting).order_by(Setting.display_order).offset(skip).limit(limit).all()
    return settings


@router.get("/settings/{key}", response_model=SettingResponse)
def get_setting(
    key: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get setting by key"""
    setting = db.query(Setting).filter(Setting.key == key).first()
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    return setting


@router.post("/settings", response_model=SettingResponse)
def create_setting(
    setting: SettingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Create new setting (admin only)"""
    # Check if setting already exists
    existing = db.query(Setting).filter(Setting.key == setting.key).first()
    if existing:
        raise HTTPException(status_code=400, detail="Setting already exists")
    
    db_setting = Setting(**setting.dict())
    db.add(db_setting)
    db.commit()
    db.refresh(db_setting)
    return db_setting


@router.put("/settings/{key}", response_model=SettingResponse)
def update_setting(
    key: str,
    setting_update: SettingUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Update setting (admin only)"""
    setting = db.query(Setting).filter(Setting.key == key).first()
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    
    for field, value in setting_update.dict(exclude_unset=True).items():
        setattr(setting, field, value)
    
    db.commit()
    db.refresh(setting)
    return setting


@router.delete("/settings/{key}")
def delete_setting(
    key: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Delete setting (admin only)"""
    setting = db.query(Setting).filter(Setting.key == key).first()
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    
    db.delete(setting)
    db.commit()
    return {"message": "Setting deleted"}


# Layer endpoints
@router.get("/layers", response_model=List[LayerResponse])
def get_layers(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    publish: Optional[bool] = Query(None),
    project_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get layers with optional filtering"""
    query = db.query(Layer)
    
    if publish is not None:
        query = query.filter(Layer.publish == publish)
    
    if project_id:
        query = query.filter(Layer.project_id == project_id)
    
    layers = query.offset(skip).limit(limit).all()
    return layers


@router.get("/layers/{layer_id}", response_model=LayerResponse)
def get_layer(
    layer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get layer by ID"""
    layer = db.query(Layer).filter(Layer.layer_id == layer_id).first()
    if not layer:
        raise HTTPException(status_code=404, detail="Layer not found")
    return layer


@router.post("/layers", response_model=LayerResponse)
def create_layer(
    layer: LayerCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new layer"""
    # Check if layer already exists
    existing = db.query(Layer).filter(Layer.layer_id == layer.layer_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Layer already exists")
    
    db_layer = Layer(**layer.dict())
    db.add(db_layer)
    db.commit()
    db.refresh(db_layer)
    return db_layer


@router.put("/layers/{layer_id}", response_model=LayerResponse)
def update_layer(
    layer_id: str,
    layer_update: LayerUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update layer"""
    layer = db.query(Layer).filter(Layer.layer_id == layer_id).first()
    if not layer:
        raise HTTPException(status_code=404, detail="Layer not found")
    
    for field, value in layer_update.dict(exclude_unset=True).items():
        setattr(layer, field, value)
    
    db.commit()
    db.refresh(layer)
    return layer


@router.delete("/layers/{layer_id}")
def delete_layer(
    layer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete layer"""
    layer = db.query(Layer).filter(Layer.layer_id == layer_id).first()
    if not layer:
        raise HTTPException(status_code=404, detail="Layer not found")
    
    db.delete(layer)
    db.commit()
    return {"message": "Layer deleted"}


# UserLayer endpoints
@router.get("/user-layers", response_model=List[UserLayerResponse])
def get_user_layers(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user layers for current user"""
    user_layers = (
        db.query(UserLayer)
        .filter(UserLayer.individual_id == current_user.individual_id)
        .offset(skip)
        .limit(limit)
        .all()
    )
    return user_layers


@router.post("/user-layers", response_model=UserLayerResponse)
def create_user_layer(
    user_layer: UserLayerCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create user layer association"""
    # Ensure user can only create associations for themselves (unless admin)
    if not current_user.is_admin and user_layer.individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Check if association already exists
    existing = db.query(UserLayer).filter(
        UserLayer.individual_id == user_layer.individual_id,
        UserLayer.project_id == user_layer.project_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="User layer association already exists")
    
    db_user_layer = UserLayer(**user_layer.dict())
    db.add(db_user_layer)
    db.commit()
    db.refresh(db_user_layer)
    return db_user_layer


@router.delete("/user-layers/{individual_id}/{project_id}")
def delete_user_layer(
    individual_id: str,
    project_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete user layer association"""
    # Ensure user can only delete their own associations (unless admin)
    if not current_user.is_admin and individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    user_layer = db.query(UserLayer).filter(
        UserLayer.individual_id == individual_id,
        UserLayer.project_id == project_id
    ).first()
    
    if not user_layer:
        raise HTTPException(status_code=404, detail="User layer association not found")
    
    db.delete(user_layer)
    db.commit()
    return {"message": "User layer association deleted"}


# File upload endpoints
@router.post("/upload", response_model=FileUploadResponse)
async def upload_file(
    file: UploadFile = File(...),
    project_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload Excel or CSV file"""
    upload_service = FileUploadService(db)
    result = await upload_service.process_uploaded_file(
        file=file,
        user_id=current_user.individual_id,
        project_id=project_id
    )
    return result


# UploadedDataset endpoints
@router.get("/uploaded-datasets", response_model=List[UploadedDatasetResponse])
def get_uploaded_datasets(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get uploaded datasets"""
    query = db.query(UploadedDataset)
    
    # Non-admin users can only see their own uploads
    if not current_user.is_admin:
        query = query.filter(UploadedDataset.individual_id == current_user.individual_id)
    
    if status:
        query = query.filter(UploadedDataset.status == status)
    
    datasets = query.offset(skip).limit(limit).all()
    return datasets


@router.get("/uploaded-datasets/{table_name}", response_model=UploadedDatasetResponse)
def get_uploaded_dataset(
    table_name: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get uploaded dataset by table name"""
    dataset = db.query(UploadedDataset).filter(UploadedDataset.table_name == table_name).first()
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    # Check permissions
    if not current_user.is_admin and dataset.individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    return dataset


@router.put("/uploaded-datasets/{table_name}", response_model=UploadedDatasetResponse)
def update_uploaded_dataset(
    table_name: str,
    dataset_update: UploadedDatasetUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update uploaded dataset"""
    dataset = db.query(UploadedDataset).filter(UploadedDataset.table_name == table_name).first()
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    # Check permissions
    if not current_user.is_admin and dataset.individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    for field, value in dataset_update.dict(exclude_unset=True).items():
        setattr(dataset, field, value)
    
    db.commit()
    db.refresh(dataset)
    return dataset


@router.delete("/uploaded-datasets/{table_name}")
def delete_uploaded_dataset(
    table_name: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete uploaded dataset and its table"""
    dataset = db.query(UploadedDataset).filter(UploadedDataset.table_name == table_name).first()
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    # Check permissions
    if not current_user.is_admin and dataset.individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    upload_service = FileUploadService(db)
    return upload_service.delete_uploaded_table(table_name)


@router.get("/uploaded-datasets/{table_name}/data")
def get_uploaded_dataset_data(
    table_name: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get data from uploaded dataset table"""
    dataset = db.query(UploadedDataset).filter(UploadedDataset.table_name == table_name).first()
    if not dataset:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    # Check permissions
    if not current_user.is_admin and dataset.individual_id != current_user.individual_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    upload_service = FileUploadService(db)
    return upload_service.get_table_data(table_name, limit, offset) 