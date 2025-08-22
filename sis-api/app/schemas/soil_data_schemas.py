from pydantic import BaseModel, EmailStr
from typing import Optional, List, Any
from datetime import date


# Individual schemas
class IndividualBase(BaseModel):
    individual_id: str
    email: Optional[str] = None


class IndividualCreate(IndividualBase):
    pass


class IndividualUpdate(BaseModel):
    email: Optional[str] = None


class IndividualResponse(IndividualBase):
    class Config:
        from_attributes = True


# Organisation schemas
class OrganisationBase(BaseModel):
    organisation_id: str
    url: Optional[str] = None
    email: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = None
    delivery_point: Optional[str] = None
    phone: Optional[str] = None
    facsimile: Optional[str] = None


class OrganisationCreate(OrganisationBase):
    pass


class OrganisationUpdate(BaseModel):
    url: Optional[str] = None
    email: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    postal_code: Optional[str] = None
    delivery_point: Optional[str] = None
    phone: Optional[str] = None
    facsimile: Optional[str] = None


class OrganisationResponse(OrganisationBase):
    class Config:
        from_attributes = True


# Project schemas
class ProjectBase(BaseModel):
    project_id: str
    name: str


class ProjectCreate(ProjectBase):
    pass


class ProjectUpdate(BaseModel):
    name: Optional[str] = None


class ProjectResponse(ProjectBase):
    class Config:
        from_attributes = True


# ProjXOrgXInd schemas
class ProjXOrgXIndBase(BaseModel):
    project_id: str
    organisation_id: str
    individual_id: str
    position: str
    tag: str
    role: str


class ProjXOrgXIndCreate(ProjXOrgXIndBase):
    pass


class ProjXOrgXIndUpdate(BaseModel):
    position: Optional[str] = None
    tag: Optional[str] = None
    role: Optional[str] = None


class ProjXOrgXIndResponse(ProjXOrgXIndBase):
    class Config:
        from_attributes = True


# Profile view schema (for GET on soil_data.profiles view)
class ProfileView(BaseModel):
    gid: int
    project_name: Optional[str] = None
    site_id: Optional[int] = None
    profile_id: Optional[int] = None
    specimen_id: Optional[int] = None
    upper_depth: Optional[int] = None
    lower_depth: Optional[int] = None
    property_phys_chem_id: Optional[str] = None
    procedure_phys_chem_id: Optional[str] = None
    value: Optional[float] = None
    unit_of_measure_id: Optional[str] = None
    geom: Optional[Any] = None  # Geometry field
    
    class Config:
        from_attributes = True


# PropertyPhysChem schemas
class PropertyPhysChemBase(BaseModel):
    property_phys_chem_id: str
    uri: str


class PropertyPhysChemCreate(PropertyPhysChemBase):
    pass


class PropertyPhysChemUpdate(BaseModel):
    uri: Optional[str] = None


class PropertyPhysChemResponse(PropertyPhysChemBase):
    class Config:
        from_attributes = True


# ProcedurePhysChem schemas
class ProcedurePhysChemBase(BaseModel):
    procedure_phys_chem_id: str
    broader_id: Optional[str] = None
    uri: str
    definition: Optional[str] = None
    reference: Optional[str] = None
    citation: Optional[str] = None


class ProcedurePhysChemCreate(ProcedurePhysChemBase):
    pass


class ProcedurePhysChemUpdate(BaseModel):
    broader_id: Optional[str] = None
    uri: Optional[str] = None
    definition: Optional[str] = None
    reference: Optional[str] = None
    citation: Optional[str] = None


class ProcedurePhysChemResponse(ProcedurePhysChemBase):
    class Config:
        from_attributes = True


# UnitOfMeasure schemas
class UnitOfMeasureBase(BaseModel):
    unit_of_measure_id: str
    label: str
    uri: str


class UnitOfMeasureCreate(UnitOfMeasureBase):
    pass


class UnitOfMeasureUpdate(BaseModel):
    label: Optional[str] = None
    uri: Optional[str] = None


class UnitOfMeasureResponse(UnitOfMeasureBase):
    class Config:
        from_attributes = True


# Geospatial data response
class GeospatialResponse(BaseModel):
    type: str = "FeatureCollection"
    features: List[dict]
    
    
# Query parameters for profiles view
class ProfilesQueryParams(BaseModel):
    project_name: Optional[str] = None
    site_id: Optional[int] = None
    profile_id: Optional[int] = None
    property_phys_chem_id: Optional[str] = None
    limit: Optional[int] = 100
    offset: Optional[int] = 0 