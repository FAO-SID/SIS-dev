from pydantic import BaseModel
from typing import Optional, List
from datetime import date


# Setting schemas
class SettingBase(BaseModel):
    key: str
    value: Optional[str] = None
    display_order: Optional[int] = None


class SettingCreate(SettingBase):
    pass


class SettingUpdate(BaseModel):
    value: Optional[str] = None
    display_order: Optional[int] = None


class SettingResponse(SettingBase):
    class Config:
        from_attributes = True


# Layer schemas
class LayerBase(BaseModel):
    layer_id: str
    individual_id: Optional[str] = None
    project_id: Optional[str] = None
    publish: bool = True
    property_id: Optional[str] = None
    property_name: Optional[str] = None
    version: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    dimension_des: Optional[str] = None
    metadata_url: Optional[str] = None
    download_url: Optional[str] = None
    get_map_url: Optional[str] = None
    get_legend_url: Optional[str] = None
    get_feature_info_url: Optional[str] = None


class LayerCreate(LayerBase):
    pass


class LayerUpdate(BaseModel):
    individual_id: Optional[str] = None
    project_id: Optional[str] = None
    publish: Optional[bool] = None
    property_id: Optional[str] = None
    property_name: Optional[str] = None
    version: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    dimension_des: Optional[str] = None
    metadata_url: Optional[str] = None
    download_url: Optional[str] = None
    get_map_url: Optional[str] = None
    get_legend_url: Optional[str] = None
    get_feature_info_url: Optional[str] = None


class LayerResponse(LayerBase):
    class Config:
        from_attributes = True


# UserLayer schemas
class UserLayerBase(BaseModel):
    individual_id: str
    project_id: str


class UserLayerCreate(UserLayerBase):
    pass


class UserLayerResponse(UserLayerBase):
    class Config:
        from_attributes = True


# UploadedDataset schemas
class UploadedDatasetBase(BaseModel):
    table_name: str
    individual_id: Optional[str] = None
    project_id: Optional[str] = None
    file_name: str
    upload_date: Optional[date] = None
    ingestion_date: Optional[date] = None
    status: Optional[str] = None
    depth_if_topsoil: Optional[int] = None
    n_rows: Optional[int] = None
    n_col: Optional[int] = None
    has_cords: Optional[bool] = None
    cords_epsg: Optional[int] = None
    cords_check: bool = False
    note: Optional[str] = None


class UploadedDatasetCreate(UploadedDatasetBase):
    pass


class UploadedDatasetUpdate(BaseModel):
    individual_id: Optional[str] = None
    project_id: Optional[str] = None
    ingestion_date: Optional[date] = None
    status: Optional[str] = None
    depth_if_topsoil: Optional[int] = None
    n_rows: Optional[int] = None
    n_col: Optional[int] = None
    has_cords: Optional[bool] = None
    cords_epsg: Optional[int] = None
    cords_check: Optional[bool] = None
    note: Optional[str] = None


class UploadedDatasetResponse(UploadedDatasetBase):
    columns: Optional[List["UploadedDatasetColumnResponse"]] = []
    
    class Config:
        from_attributes = True


# UploadedDatasetColumn schemas
class UploadedDatasetColumnBase(BaseModel):
    table_name: str
    column_name: str
    property_phys_chem_id: Optional[str] = None
    procedure_phys_chem_id: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    ignore_column: bool = False
    note: Optional[str] = None


class UploadedDatasetColumnCreate(UploadedDatasetColumnBase):
    pass


class UploadedDatasetColumnUpdate(BaseModel):
    property_phys_chem_id: Optional[str] = None
    procedure_phys_chem_id: Optional[str] = None
    unit_of_measure_id: Optional[str] = None
    ignore_column: Optional[bool] = None
    note: Optional[str] = None


class UploadedDatasetColumnResponse(UploadedDatasetColumnBase):
    class Config:
        from_attributes = True


# File upload response
class FileUploadResponse(BaseModel):
    message: str
    table_name: str
    file_name: str
    n_rows: int
    n_cols: int
    columns: List[str]
    data_types: dict
    sample_data: List[dict]


# Update forward references
UploadedDatasetResponse.model_rebuild() 