from sqlalchemy import Column, String, Integer, Boolean, Date, SmallInteger, Text, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base


class User(Base):
    __tablename__ = "user"
    __table_args__ = {"schema": "api"}
    
    individual_id = Column(String, primary_key=True)
    organisation_id = Column(String, ForeignKey("soil_data.organisation.organisation_id"))
    password_hash = Column(String, nullable=False)
    created_at = Column(Date, default="CURRENT_DATE")
    last_login = Column(Date)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    
    # Relationships
    user_layers = relationship("UserLayer", back_populates="user")
    uploaded_datasets = relationship("UploadedDataset", back_populates="user")


class UserLayer(Base):
    __tablename__ = "user_layer"
    __table_args__ = {"schema": "api"}
    
    individual_id = Column(String, ForeignKey("api.user.individual_id"), primary_key=True)
    project_id = Column(String, ForeignKey("soil_data.project.project_id"), primary_key=True)
    
    # Relationships
    user = relationship("User", back_populates="user_layers")


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
    unit_of_measure_id = Column(String, ForeignKey("soil_data.unit_of_measure.unit_of_measure_id"))
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
    individual_id = Column(String, ForeignKey("api.user.individual_id"))
    project_id = Column(String, ForeignKey("soil_data.project.project_id"))
    file_name = Column(String, nullable=False, unique=True)
    upload_date = Column(Date, default="CURRENT_DATE")
    ingestion_date = Column(Date)
    status = Column(String)  # 'Uploaded', 'Ingested', 'Removed'
    depth_if_topsoil = Column(SmallInteger)
    n_rows = Column(Integer)
    n_col = Column(SmallInteger)
    has_cords = Column(Boolean)
    cords_epsg = Column(Integer)
    cords_check = Column(Boolean, default=False)
    note = Column(Text)
    
    # Relationships
    user = relationship("User", back_populates="uploaded_datasets")
    columns = relationship("UploadedDatasetColumn", back_populates="dataset")


class UploadedDatasetColumn(Base):
    __tablename__ = "uploaded_dataset_column"
    __table_args__ = {"schema": "api"}
    
    table_name = Column(String, ForeignKey("api.uploaded_dataset.table_name"), primary_key=True)
    column_name = Column(String, primary_key=True)
    property_phys_chem_id = Column(String, ForeignKey("soil_data.property_phys_chem.property_phys_chem_id"))
    procedure_phys_chem_id = Column(String, ForeignKey("soil_data.procedure_phys_chem.procedure_phys_chem_id"))
    unit_of_measure_id = Column(String, ForeignKey("soil_data.unit_of_measure.unit_of_measure_id"))
    ignore_column = Column(Boolean, default=False)
    note = Column(Text)
    
    # Relationships
    dataset = relationship("UploadedDataset", back_populates="columns") 