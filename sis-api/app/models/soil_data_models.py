from sqlalchemy import Column, String, Integer, Boolean, Date, SmallInteger, Text, ForeignKey, Real
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
from app.db.database import Base


class Individual(Base):
    __tablename__ = "individual"
    __table_args__ = {"schema": "soil_data"}
    
    individual_id = Column(String, primary_key=True)
    email = Column(String)
    
    # Relationships
    proj_x_org_x_inds = relationship("ProjXOrgXInd", back_populates="individual")


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
    
    # Relationships
    proj_x_org_x_inds = relationship("ProjXOrgXInd", back_populates="organisation")


class Project(Base):
    __tablename__ = "project"
    __table_args__ = {"schema": "soil_data"}
    
    project_id = Column(String, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    
    # Relationships
    proj_x_org_x_inds = relationship("ProjXOrgXInd", back_populates="project")
    project_sites = relationship("ProjectSite", back_populates="project")


class ProjXOrgXInd(Base):
    __tablename__ = "proj_x_org_x_ind"
    __table_args__ = {"schema": "soil_data"}
    
    project_id = Column(String, ForeignKey("soil_data.project.project_id"), primary_key=True)
    organisation_id = Column(String, ForeignKey("soil_data.organisation.organisation_id"), primary_key=True)
    individual_id = Column(String, ForeignKey("soil_data.individual.individual_id"), primary_key=True)
    position = Column(String, primary_key=True)
    tag = Column(String, primary_key=True)
    role = Column(String, primary_key=True)
    
    # Relationships
    project = relationship("Project", back_populates="proj_x_org_x_inds")
    organisation = relationship("Organisation", back_populates="proj_x_org_x_inds")
    individual = relationship("Individual", back_populates="proj_x_org_x_inds")


class Site(Base):
    __tablename__ = "site"
    __table_args__ = {"schema": "soil_data"}
    
    site_id = Column(Integer, primary_key=True, autoincrement=True)
    site_code = Column(String, unique=True)
    typical_profile = Column(Integer, ForeignKey("soil_data.profile.profile_id"))
    position = Column(Geometry("POINT", srid=4326))
    extent = Column(Geometry("POLYGON", srid=4326))
    
    # Relationships
    project_sites = relationship("ProjectSite", back_populates="site")
    plots = relationship("Plot", back_populates="site")
    surfaces = relationship("Surface", back_populates="site")


class ProjectSite(Base):
    __tablename__ = "project_site"
    __table_args__ = {"schema": "soil_data"}
    
    project_id = Column(String, ForeignKey("soil_data.project.project_id"), primary_key=True)
    site_id = Column(Integer, ForeignKey("soil_data.site.site_id"), primary_key=True)
    
    # Relationships
    project = relationship("Project", back_populates="project_sites")
    site = relationship("Site", back_populates="project_sites")


class Plot(Base):
    __tablename__ = "plot"
    __table_args__ = {"schema": "soil_data"}
    
    plot_id = Column(Integer, primary_key=True, autoincrement=True)
    site_id = Column(Integer, ForeignKey("soil_data.site.site_id"), nullable=False)
    plot_code = Column(String, unique=True)
    altitude = Column(SmallInteger)
    time_stamp = Column(Date)
    map_sheet_code = Column(String)
    positional_accuracy = Column(SmallInteger)
    position = Column(Geometry("POINT", srid=4326))
    type = Column(String)  # 'TrialPit' or 'Borehole'
    
    # Relationships
    site = relationship("Site", back_populates="plots")
    profiles = relationship("Profile", back_populates="plot")


class Surface(Base):
    __tablename__ = "surface"
    __table_args__ = {"schema": "soil_data"}
    
    surface_id = Column(Integer, primary_key=True, autoincrement=True)
    super_surface_id = Column(Integer, ForeignKey("soil_data.surface.surface_id"))
    site_id = Column(Integer, ForeignKey("soil_data.site.site_id"), nullable=False)
    shape = Column(Geometry("POLYGON", srid=4326))
    time_stamp = Column(Date)
    
    # Relationships
    site = relationship("Site", back_populates="surfaces")
    profiles = relationship("Profile", back_populates="surface")


class Profile(Base):
    __tablename__ = "profile"
    __table_args__ = {"schema": "soil_data"}
    
    profile_id = Column(Integer, primary_key=True, autoincrement=True)
    plot_id = Column(Integer, ForeignKey("soil_data.plot.plot_id"))
    surface_id = Column(Integer, ForeignKey("soil_data.surface.surface_id"))
    profile_code = Column(String, unique=True)
    
    # Relationships
    plot = relationship("Plot", back_populates="profiles")
    surface = relationship("Surface", back_populates="profiles")
    elements = relationship("Element", back_populates="profile")


class Element(Base):
    __tablename__ = "element"
    __table_args__ = {"schema": "soil_data"}
    
    element_id = Column(Integer, primary_key=True, autoincrement=True)
    profile_id = Column(Integer, ForeignKey("soil_data.profile.profile_id"), nullable=False)
    order_element = Column(Integer)
    upper_depth = Column(Integer, nullable=False)
    lower_depth = Column(Integer, nullable=False)
    type = Column(String, nullable=False)  # 'Horizon' or 'Layer'
    
    # Relationships
    profile = relationship("Profile", back_populates="elements")
    specimens = relationship("Specimen", back_populates="element")


class Specimen(Base):
    __tablename__ = "specimen"
    __table_args__ = {"schema": "soil_data"}
    
    specimen_id = Column(Integer, primary_key=True, autoincrement=True)
    element_id = Column(Integer, ForeignKey("soil_data.element.element_id"), nullable=False)
    specimen_prep_process_id = Column(Integer)
    organisation_id = Column(Integer)
    code = Column(String, unique=True)
    
    # Relationships
    element = relationship("Element", back_populates="specimens")
    results_phys_chem = relationship("ResultPhysChem", back_populates="specimen")


class PropertyPhysChem(Base):
    __tablename__ = "property_phys_chem"
    __table_args__ = {"schema": "soil_data"}
    
    property_phys_chem_id = Column(String, primary_key=True)
    uri = Column(String, nullable=False, unique=True)
    
    # Relationships
    observations = relationship("ObservationPhysChem", back_populates="property")


class ProcedurePhysChem(Base):
    __tablename__ = "procedure_phys_chem"
    __table_args__ = {"schema": "soil_data"}
    
    procedure_phys_chem_id = Column(String, primary_key=True)
    broader_id = Column(String, ForeignKey("soil_data.procedure_phys_chem.procedure_phys_chem_id"))
    uri = Column(String, nullable=False, unique=True)
    definition = Column(Text)
    reference = Column(Text)
    citation = Column(Text)
    
    # Relationships
    observations = relationship("ObservationPhysChem", back_populates="procedure")


class UnitOfMeasure(Base):
    __tablename__ = "unit_of_measure"
    __table_args__ = {"schema": "soil_data"}
    
    unit_of_measure_id = Column(String, primary_key=True)
    label = Column(String, nullable=False)
    uri = Column(String, nullable=False, unique=True)
    
    # Relationships
    observations = relationship("ObservationPhysChem", back_populates="unit_of_measure")


class ObservationPhysChem(Base):
    __tablename__ = "observation_phys_chem"
    __table_args__ = {"schema": "soil_data"}
    
    observation_phys_chem_id = Column(Integer, primary_key=True, autoincrement=True)
    property_phys_chem_id = Column(String, ForeignKey("soil_data.property_phys_chem.property_phys_chem_id"), nullable=False)
    procedure_phys_chem_id = Column(String, ForeignKey("soil_data.procedure_phys_chem.procedure_phys_chem_id"), nullable=False)
    unit_of_measure_id = Column(String, ForeignKey("soil_data.unit_of_measure.unit_of_measure_id"), nullable=False)
    value_min = Column(Real)
    value_max = Column(Real)
    
    # Relationships
    property = relationship("PropertyPhysChem", back_populates="observations")
    procedure = relationship("ProcedurePhysChem", back_populates="observations")
    unit_of_measure = relationship("UnitOfMeasure", back_populates="observations")
    results = relationship("ResultPhysChem", back_populates="observation")


class ResultPhysChem(Base):
    __tablename__ = "result_phys_chem"
    __table_args__ = {"schema": "soil_data"}
    
    result_phys_chem_id = Column(Integer, primary_key=True, autoincrement=True)
    observation_phys_chem_id = Column(Integer, ForeignKey("soil_data.observation_phys_chem.observation_phys_chem_id"), nullable=False)
    specimen_id = Column(Integer, ForeignKey("soil_data.specimen.specimen_id"), nullable=False)
    individual_id = Column(Integer)
    value = Column(Real, nullable=False)
    
    # Relationships
    observation = relationship("ObservationPhysChem", back_populates="results")
    specimen = relationship("Specimen", back_populates="results_phys_chem") 