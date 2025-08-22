from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.api.deps import get_db, get_current_user
from app.models.api_models import User
from app.models.soil_data_models import (
    Individual, Organisation, Project, ProjXOrgXInd
)
from app.schemas.soil_data_schemas import (
    IndividualCreate, IndividualUpdate, IndividualResponse,
    OrganisationCreate, OrganisationUpdate, OrganisationResponse,
    ProjectCreate, ProjectUpdate, ProjectResponse,
    ProjXOrgXIndCreate, ProjXOrgXIndUpdate, ProjXOrgXIndResponse,
    ProfileView, ProfilesQueryParams, GeospatialResponse
)
from app.core.config import settings

router = APIRouter()

# Individual endpoints
@router.get("/individuals", response_model=List[IndividualResponse])
def get_individuals(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all individuals"""
    individuals = db.query(Individual).offset(skip).limit(limit).all()
    return individuals


@router.get("/individuals/{individual_id}", response_model=IndividualResponse)
def get_individual(
    individual_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get individual by ID"""
    individual = db.query(Individual).filter(Individual.individual_id == individual_id).first()
    if not individual:
        raise HTTPException(status_code=404, detail="Individual not found")
    return individual


@router.post("/individuals", response_model=IndividualResponse)
def create_individual(
    individual: IndividualCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new individual"""
    # Check if individual already exists
    existing = db.query(Individual).filter(Individual.individual_id == individual.individual_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Individual already exists")
    
    db_individual = Individual(**individual.dict())
    db.add(db_individual)
    db.commit()
    db.refresh(db_individual)
    return db_individual


# Organisation endpoints
@router.get("/organisations", response_model=List[OrganisationResponse])
def get_organisations(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all organisations"""
    organisations = db.query(Organisation).offset(skip).limit(limit).all()
    return organisations


@router.get("/organisations/{organisation_id}", response_model=OrganisationResponse)
def get_organisation(
    organisation_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get organisation by ID"""
    organisation = db.query(Organisation).filter(Organisation.organisation_id == organisation_id).first()
    if not organisation:
        raise HTTPException(status_code=404, detail="Organisation not found")
    return organisation


@router.post("/organisations", response_model=OrganisationResponse)
def create_organisation(
    organisation: OrganisationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new organisation"""
    # Check if organisation already exists
    existing = db.query(Organisation).filter(Organisation.organisation_id == organisation.organisation_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Organisation already exists")
    
    db_organisation = Organisation(**organisation.dict())
    db.add(db_organisation)
    db.commit()
    db.refresh(db_organisation)
    return db_organisation


# Project endpoints
@router.get("/projects", response_model=List[ProjectResponse])
def get_projects(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all projects"""
    projects = db.query(Project).offset(skip).limit(limit).all()
    return projects


@router.get("/projects/{project_id}", response_model=ProjectResponse)
def get_project(
    project_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get project by ID"""
    project = db.query(Project).filter(Project.project_id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.post("/projects", response_model=ProjectResponse)
def create_project(
    project: ProjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new project"""
    # Check if project already exists
    existing = db.query(Project).filter(Project.project_id == project.project_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Project already exists")
    
    db_project = Project(**project.dict())
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project


# ProjXOrgXInd endpoints
@router.get("/proj-org-ind", response_model=List[ProjXOrgXIndResponse])
def get_proj_org_inds(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    project_id: Optional[str] = Query(None),
    organisation_id: Optional[str] = Query(None),
    individual_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get project-organisation-individual associations with optional filtering"""
    query = db.query(ProjXOrgXInd)
    
    if project_id:
        query = query.filter(ProjXOrgXInd.project_id == project_id)
    
    if organisation_id:
        query = query.filter(ProjXOrgXInd.organisation_id == organisation_id)
    
    if individual_id:
        query = query.filter(ProjXOrgXInd.individual_id == individual_id)
    
    associations = query.offset(skip).limit(limit).all()
    return associations


@router.post("/proj-org-ind", response_model=ProjXOrgXIndResponse)
def create_proj_org_ind(
    association: ProjXOrgXIndCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create new project-organisation-individual association"""
    # Check if association already exists
    existing = db.query(ProjXOrgXInd).filter(
        ProjXOrgXInd.project_id == association.project_id,
        ProjXOrgXInd.organisation_id == association.organisation_id,
        ProjXOrgXInd.individual_id == association.individual_id,
        ProjXOrgXInd.position == association.position,
        ProjXOrgXInd.tag == association.tag,
        ProjXOrgXInd.role == association.role
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Association already exists")
    
    db_association = ProjXOrgXInd(**association.dict())
    db.add(db_association)
    db.commit()
    db.refresh(db_association)
    return db_association


@router.delete("/proj-org-ind/{project_id}/{organisation_id}/{individual_id}/{position}/{tag}/{role}")
def delete_proj_org_ind(
    project_id: str,
    organisation_id: str,
    individual_id: str,
    position: str,
    tag: str,
    role: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete project-organisation-individual association"""
    association = db.query(ProjXOrgXInd).filter(
        ProjXOrgXInd.project_id == project_id,
        ProjXOrgXInd.organisation_id == organisation_id,
        ProjXOrgXInd.individual_id == individual_id,
        ProjXOrgXInd.position == position,
        ProjXOrgXInd.tag == tag,
        ProjXOrgXInd.role == role
    ).first()
    
    if not association:
        raise HTTPException(status_code=404, detail="Association not found")
    
    db.delete(association)
    db.commit()
    return {"message": "Association deleted"}


# Profiles view endpoint (read-only)
@router.get("/profiles", response_model=List[ProfileView])
def get_profiles(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    project_name: Optional[str] = Query(None),
    site_id: Optional[int] = Query(None),
    profile_id: Optional[int] = Query(None),
    property_phys_chem_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get profiles view data with optional filtering"""
    
    # Build the query with filters
    base_query = """
    SELECT 
        gid, project_name, site_id, profile_id, specimen_id,
        upper_depth, lower_depth, property_phys_chem_id,
        procedure_phys_chem_id, value, unit_of_measure_id,
        ST_AsGeoJSON(geom) as geom
    FROM soil_data.profiles
    WHERE 1=1
    """
    
    conditions = []
    params = {}
    
    if project_name:
        conditions.append("AND project_name ILIKE :project_name")
        params["project_name"] = f"%{project_name}%"
    
    if site_id:
        conditions.append("AND site_id = :site_id")
        params["site_id"] = site_id
    
    if profile_id:
        conditions.append("AND profile_id = :profile_id")
        params["profile_id"] = profile_id
    
    if property_phys_chem_id:
        conditions.append("AND property_phys_chem_id = :property_phys_chem_id")
        params["property_phys_chem_id"] = property_phys_chem_id
    
    query = base_query + " ".join(conditions)
    query += f" ORDER BY gid LIMIT :limit OFFSET :skip"
    
    params.update({"limit": limit, "skip": skip})
    
    try:
        result = db.execute(text(query), params)
        profiles = []
        for row in result:
            profile_dict = dict(row._mapping)
            profiles.append(profile_dict)
        
        return profiles
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error querying profiles view: {str(e)}"
        )


@router.get("/profiles/geojson", response_model=GeospatialResponse)
def get_profiles_geojson(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    project_name: Optional[str] = Query(None),
    site_id: Optional[int] = Query(None),
    profile_id: Optional[int] = Query(None),
    property_phys_chem_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get profiles as GeoJSON FeatureCollection"""
    
    # Build the query for GeoJSON output
    base_query = """
    SELECT 
        jsonb_build_object(
            'type', 'Feature',
            'id', gid,
            'geometry', ST_AsGeoJSON(geom)::jsonb,
            'properties', jsonb_build_object(
                'gid', gid,
                'project_name', project_name,
                'site_id', site_id,
                'profile_id', profile_id,
                'specimen_id', specimen_id,
                'upper_depth', upper_depth,
                'lower_depth', lower_depth,
                'property_phys_chem_id', property_phys_chem_id,
                'procedure_phys_chem_id', procedure_phys_chem_id,
                'value', value,
                'unit_of_measure_id', unit_of_measure_id
            )
        ) as feature
    FROM soil_data.profiles
    WHERE geom IS NOT NULL
    """
    
    conditions = []
    params = {}
    
    if project_name:
        conditions.append("AND project_name ILIKE :project_name")
        params["project_name"] = f"%{project_name}%"
    
    if site_id:
        conditions.append("AND site_id = :site_id")
        params["site_id"] = site_id
    
    if profile_id:
        conditions.append("AND profile_id = :profile_id")
        params["profile_id"] = profile_id
    
    if property_phys_chem_id:
        conditions.append("AND property_phys_chem_id = :property_phys_chem_id")
        params["property_phys_chem_id"] = property_phys_chem_id
    
    query = base_query + " ".join(conditions)
    query += f" ORDER BY gid LIMIT :limit OFFSET :skip"
    
    params.update({"limit": limit, "skip": skip})
    
    try:
        result = db.execute(text(query), params)
        features = []
        for row in result:
            features.append(row.feature)
        
        return {
            "type": "FeatureCollection",
            "features": features
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generating GeoJSON: {str(e)}"
        ) 