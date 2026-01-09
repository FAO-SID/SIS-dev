-- ============================================================================
-- ISO 28258 - Soil quality — Digital exchange of soil-related data
-- PostgreSQL Database Schema
-- ============================================================================
-- This schema implements the conceptual model defined in ISO 28258:2013
-- for the digital exchange of soil-related data.
-- Requires: PostgreSQL 9.4+ with PostGIS extension
-- ============================================================================

-- ============================================================================
-- ROLES
-- ============================================================================

-- Admin role (owner of all objects)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sis_a') THEN
        CREATE ROLE sis_a WITH LOGIN;
    END IF;
END
$$;
COMMENT ON ROLE sis_a IS 'Soil Information System Administrator - owner of all objects, full privileges';

-- Editor role (INSERT, UPDATE, DELETE)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sis_e') THEN
        CREATE ROLE sis_e WITH LOGIN;
    END IF;
END
$$;
COMMENT ON ROLE sis_e IS 'Soil Information System Editor - can INSERT, UPDATE, DELETE data';

-- Reader role (SELECT only)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sis_r') THEN
        CREATE ROLE sis_r WITH LOGIN;
    END IF;
END
$$;
COMMENT ON ROLE sis_r IS 'Soil Information System Reader - read-only access (SELECT)';

-- ============================================================================
-- SCHEMA
-- ============================================================================

DROP SCHEMA IF EXISTS soil_data CASCADE;
CREATE SCHEMA soil_data AUTHORIZATION sis_a;
COMMENT ON SCHEMA soil_data IS 'ISO 28258:2013 Soil quality — Digital exchange of soil-related data';

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS postgis;

SET search_path TO soil_data, public;

-- ============================================================================
-- CORE FEATURE TYPES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Site: Geographic location where soil is observed
-- ----------------------------------------------------------------------------
CREATE TABLE site (
    site_id           TEXT PRIMARY KEY,
    name                TEXT,
    description         TEXT,
    geom                GEOMETRY(Point, 4326) NOT NULL,
    elevation_m         NUMERIC(8,2),
    positional_accuracy_m NUMERIC(10,2),
    country_code        CHAR(2),
    administrative_area TEXT,
    established_date    DATE,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    source              TEXT,
    remarks             TEXT
);

COMMENT ON TABLE site IS 'Geographic location where soil observations are made (ISO 28258 Site feature)';
COMMENT ON COLUMN site.site_id IS 'Unique identifier for the site (natural key)';
COMMENT ON COLUMN site.name IS 'Human-readable name of the site';
COMMENT ON COLUMN site.description IS 'Detailed description of the site';
COMMENT ON COLUMN site.geom IS 'Point geometry of the site location (EPSG:4326)';
COMMENT ON COLUMN site.elevation_m IS 'Elevation above sea level in meters';
COMMENT ON COLUMN site.positional_accuracy_m IS 'Positional accuracy of the location in meters';
COMMENT ON COLUMN site.country_code IS 'ISO 3166-1 alpha-2 country code';
COMMENT ON COLUMN site.administrative_area IS 'Administrative area (province, state, region)';
COMMENT ON COLUMN site.established_date IS 'Date when the site was established';
COMMENT ON COLUMN site.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN site.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN site.source IS 'Source of the site information';
COMMENT ON COLUMN site.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_site_geom ON site USING GIST (geom);
COMMENT ON INDEX idx_site_geom IS 'Spatial index on site geometry';

CREATE INDEX idx_site_country ON site (country_code);
COMMENT ON INDEX idx_site_country IS 'Index on country code for filtering by country';

-- ----------------------------------------------------------------------------
-- Plot: Specific area within a site for observation
-- ----------------------------------------------------------------------------
CREATE TABLE plot (
    plot_id           TEXT PRIMARY KEY,
    site_id           TEXT NOT NULL REFERENCES site(site_id) ON DELETE CASCADE,
    name                TEXT,
    description         TEXT,
    geom                GEOMETRY(Geometry, 4326),
    area_m2             NUMERIC(12,2),
    slope_gradient_pct  NUMERIC(5,2),
    slope_aspect_deg    NUMERIC(5,2),
    land_use            TEXT,
    land_cover          TEXT,
    vegetation          TEXT,
    observation_date    DATE,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE plot IS 'Specific area within a site for observation (ISO 28258 Plot feature)';
COMMENT ON COLUMN plot.plot_id IS 'Unique identifier for the plot (natural key)';
COMMENT ON COLUMN plot.site_id IS 'Reference to the parent site';
COMMENT ON COLUMN plot.name IS 'Human-readable name of the plot';
COMMENT ON COLUMN plot.description IS 'Detailed description of the plot';
COMMENT ON COLUMN plot.geom IS 'Geometry of the plot - point or polygon (EPSG:4326)';
COMMENT ON COLUMN plot.area_m2 IS 'Area of the plot in square meters';
COMMENT ON COLUMN plot.slope_gradient_pct IS 'Slope gradient as percentage';
COMMENT ON COLUMN plot.slope_aspect_deg IS 'Slope aspect in degrees from north';
COMMENT ON COLUMN plot.land_use IS 'Current land use classification';
COMMENT ON COLUMN plot.land_cover IS 'Land cover type';
COMMENT ON COLUMN plot.vegetation IS 'Description of vegetation';
COMMENT ON COLUMN plot.observation_date IS 'Date of plot observation';
COMMENT ON COLUMN plot.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN plot.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN plot.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_plot_site ON plot (site_id);
COMMENT ON INDEX idx_plot_site IS 'Index on site code for joining with site table';

CREATE INDEX idx_plot_geom ON plot USING GIST (geom);
COMMENT ON INDEX idx_plot_geom IS 'Spatial index on plot geometry';

-- ----------------------------------------------------------------------------
-- Profile: Vertical section of soil (pit, borehole, auger hole)
-- ----------------------------------------------------------------------------
CREATE TABLE profile (
    profile_id        TEXT PRIMARY KEY,
    plot_id           TEXT NOT NULL REFERENCES plot(plot_id) ON DELETE CASCADE,
    name                TEXT,
    description         TEXT,
    geom                GEOMETRY(Point, 4326),
    profile_type        TEXT,
    total_depth_cm      NUMERIC(6,2),
    excavation_date     DATE,
    excavation_method   TEXT,
    wrb_classification  TEXT,
    local_classification TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    described_by        TEXT,
    remarks             TEXT
);

COMMENT ON TABLE profile IS 'Vertical section of soil - pit, borehole, or auger hole (ISO 28258 Profile feature)';
COMMENT ON COLUMN profile.profile_id IS 'Unique identifier for the profile (natural key)';
COMMENT ON COLUMN profile.plot_id IS 'Reference to the parent plot';
COMMENT ON COLUMN profile.name IS 'Human-readable name of the profile';
COMMENT ON COLUMN profile.description IS 'Detailed description of the profile';
COMMENT ON COLUMN profile.geom IS 'Point geometry of the profile location (EPSG:4326)';
COMMENT ON COLUMN profile.profile_type IS 'Type of profile: pit, borehole, auger, etc.';
COMMENT ON COLUMN profile.total_depth_cm IS 'Total depth of the profile in centimeters';
COMMENT ON COLUMN profile.excavation_date IS 'Date when the profile was excavated';
COMMENT ON COLUMN profile.excavation_method IS 'Method used for excavation';
COMMENT ON COLUMN profile.wrb_classification IS 'World Reference Base soil classification';
COMMENT ON COLUMN profile.local_classification IS 'Local or national soil classification';
COMMENT ON COLUMN profile.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN profile.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN profile.described_by IS 'Person who described the profile';
COMMENT ON COLUMN profile.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_profile_plot ON profile (plot_id);
COMMENT ON INDEX idx_profile_plot IS 'Index on plot code for joining with plot table';

CREATE INDEX idx_profile_geom ON profile USING GIST (geom);
COMMENT ON INDEX idx_profile_geom IS 'Spatial index on profile geometry';

-- ----------------------------------------------------------------------------
-- ProfileElement: Horizon or Layer within a profile
-- ----------------------------------------------------------------------------
CREATE TABLE profile_element (
    element_id        TEXT PRIMARY KEY,
    profile_id        TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
    element_type        TEXT NOT NULL,
    designation         TEXT,
    name                TEXT,
    upper_depth_cm      NUMERIC(6,2) NOT NULL,
    lower_depth_cm      NUMERIC(6,2) NOT NULL,
    boundary_distinctness TEXT,
    boundary_topography TEXT,
    sequence_number     INTEGER,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_element_type CHECK (element_type IN ('Horizon', 'Layer')),
    CONSTRAINT chk_depth_order CHECK (lower_depth_cm >= upper_depth_cm)
);

COMMENT ON TABLE profile_element IS 'Horizon or Layer within a soil profile (ISO 28258 ProfileElement feature)';
COMMENT ON COLUMN profile_element.element_id IS 'Unique identifier for the profile element (natural key)';
COMMENT ON COLUMN profile_element.profile_id IS 'Reference to the parent profile';
COMMENT ON COLUMN profile_element.element_type IS 'Type: Horizon (pedogenic) or Layer (non-pedogenic)';
COMMENT ON COLUMN profile_element.designation IS 'Horizon/layer designation (e.g., Ap, Bt1, C)';
COMMENT ON COLUMN profile_element.name IS 'Human-readable name of the element';
COMMENT ON COLUMN profile_element.upper_depth_cm IS 'Upper boundary depth in centimeters';
COMMENT ON COLUMN profile_element.lower_depth_cm IS 'Lower boundary depth in centimeters';
COMMENT ON COLUMN profile_element.boundary_distinctness IS 'Distinctness of lower boundary: abrupt, clear, gradual, diffuse';
COMMENT ON COLUMN profile_element.boundary_topography IS 'Topography of lower boundary: smooth, wavy, irregular, broken';
COMMENT ON COLUMN profile_element.sequence_number IS 'Order of elements from top to bottom';
COMMENT ON COLUMN profile_element.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN profile_element.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN profile_element.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_element_profile ON profile_element (profile_id);
COMMENT ON INDEX idx_element_profile IS 'Index on profile code for joining with profile table';

CREATE INDEX idx_element_depth ON profile_element (upper_depth_cm, lower_depth_cm);
COMMENT ON INDEX idx_element_depth IS 'Index on depth boundaries for depth-based queries';

-- ----------------------------------------------------------------------------
-- Specimen: Physical sample taken from a profile element
-- ----------------------------------------------------------------------------
CREATE TABLE specimen (
    specimen_id       TEXT PRIMARY KEY,
    element_id        TEXT NOT NULL REFERENCES profile_element(element_id) ON DELETE CASCADE,
    name                TEXT,
    sampling_date       DATE,
    sampling_method     TEXT,
    sampled_by          TEXT,
    upper_depth_cm      NUMERIC(6,2),
    lower_depth_cm      NUMERIC(6,2),
    mass_g              NUMERIC(10,2),
    volume_cm3          NUMERIC(10,2),
    storage_location    TEXT,
    preparation_method  TEXT,
    preparation_date    DATE,
    is_archived         BOOLEAN DEFAULT FALSE,
    is_exhausted        BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE specimen IS 'Physical soil sample taken from a profile element (ISO 28258 Specimen feature)';
COMMENT ON COLUMN specimen.specimen_id IS 'Unique identifier for the specimen (natural key)';
COMMENT ON COLUMN specimen.element_id IS 'Reference to the parent profile element';
COMMENT ON COLUMN specimen.name IS 'Human-readable name of the specimen';
COMMENT ON COLUMN specimen.sampling_date IS 'Date when the specimen was collected';
COMMENT ON COLUMN specimen.sampling_method IS 'Method used for sampling';
COMMENT ON COLUMN specimen.sampled_by IS 'Person who collected the specimen';
COMMENT ON COLUMN specimen.upper_depth_cm IS 'Upper depth of sampling in centimeters';
COMMENT ON COLUMN specimen.lower_depth_cm IS 'Lower depth of sampling in centimeters';
COMMENT ON COLUMN specimen.mass_g IS 'Mass of the specimen in grams';
COMMENT ON COLUMN specimen.volume_cm3 IS 'Volume of the specimen in cubic centimeters';
COMMENT ON COLUMN specimen.storage_location IS 'Current storage location of the specimen';
COMMENT ON COLUMN specimen.preparation_method IS 'Method used to prepare the specimen';
COMMENT ON COLUMN specimen.preparation_date IS 'Date when the specimen was prepared';
COMMENT ON COLUMN specimen.is_archived IS 'Whether the specimen is archived';
COMMENT ON COLUMN specimen.is_exhausted IS 'Whether the specimen has been exhausted';
COMMENT ON COLUMN specimen.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN specimen.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN specimen.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_specimen_element ON specimen (element_id);
COMMENT ON INDEX idx_specimen_element IS 'Index on element code for joining with profile_element table';

-- ============================================================================
-- SOIL MAPPING FEATURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SoilMap: A soil map (collection of mapping units)
-- ----------------------------------------------------------------------------
CREATE TABLE soil_map (
    soil_map_id       TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    geom                GEOMETRY(Polygon, 4326),
    scale_denominator   INTEGER,
    spatial_resolution_m NUMERIC(10,2),
    publication_date    DATE,
    survey_start_date   DATE,
    survey_end_date     DATE,
    classification_system TEXT,
    source_organization TEXT,
    source_citation     TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE soil_map IS 'A soil map containing delineated mapping units (ISO 28258 SoilMap feature)';
COMMENT ON COLUMN soil_map.soil_map_id IS 'Unique identifier for the soil map (natural key)';
COMMENT ON COLUMN soil_map.name IS 'Name of the soil map';
COMMENT ON COLUMN soil_map.description IS 'Detailed description of the soil map';
COMMENT ON COLUMN soil_map.geom IS 'Polygon geometry representing the map extent (EPSG:4326)';
COMMENT ON COLUMN soil_map.scale_denominator IS 'Map scale denominator (e.g., 50000 for 1:50,000)';
COMMENT ON COLUMN soil_map.spatial_resolution_m IS 'Spatial resolution in meters';
COMMENT ON COLUMN soil_map.publication_date IS 'Date when the map was published';
COMMENT ON COLUMN soil_map.survey_start_date IS 'Start date of the soil survey';
COMMENT ON COLUMN soil_map.survey_end_date IS 'End date of the soil survey';
COMMENT ON COLUMN soil_map.classification_system IS 'Soil classification system used (e.g., WRB 2022, Soil Taxonomy)';
COMMENT ON COLUMN soil_map.source_organization IS 'Organization that produced the map';
COMMENT ON COLUMN soil_map.source_citation IS 'Full citation for the map source';
COMMENT ON COLUMN soil_map.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN soil_map.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN soil_map.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_soil_map_geom ON soil_map USING GIST (geom);
COMMENT ON INDEX idx_soil_map_geom IS 'Spatial index on soil map extent geometry';

-- ----------------------------------------------------------------------------
-- SoilMappingUnitCategory: Legend category describing soil types
-- ----------------------------------------------------------------------------
CREATE TABLE soil_mapping_unit_category (
    category_id       TEXT PRIMARY KEY,
    soil_map_id       TEXT NOT NULL REFERENCES soil_map(soil_map_id) ON DELETE CASCADE,
    name                TEXT NOT NULL,
    description         TEXT,
    wrb_classification  TEXT,
    local_classification TEXT,
    dominant_soil_type  TEXT,
    parent_material     TEXT,
    landform            TEXT,
    is_compound         BOOLEAN DEFAULT FALSE,
    legend_order        INTEGER,
    symbol              TEXT,
    colour_rgb          TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    UNIQUE (soil_map_id, category_id)
);

COMMENT ON TABLE soil_mapping_unit_category IS 'Legend category describing soil types in a map (ISO 28258 SoilMappingUnitCategory feature)';
COMMENT ON COLUMN soil_mapping_unit_category.category_id IS 'Unique identifier for the category (natural key)';
COMMENT ON COLUMN soil_mapping_unit_category.soil_map_id IS 'Reference to the parent soil map';
COMMENT ON COLUMN soil_mapping_unit_category.name IS 'Name of the mapping unit category';
COMMENT ON COLUMN soil_mapping_unit_category.description IS 'Detailed description of the category';
COMMENT ON COLUMN soil_mapping_unit_category.wrb_classification IS 'World Reference Base classification';
COMMENT ON COLUMN soil_mapping_unit_category.local_classification IS 'Local or national classification';
COMMENT ON COLUMN soil_mapping_unit_category.dominant_soil_type IS 'Dominant soil type in this category';
COMMENT ON COLUMN soil_mapping_unit_category.parent_material IS 'Parent material description';
COMMENT ON COLUMN soil_mapping_unit_category.landform IS 'Associated landform';
COMMENT ON COLUMN soil_mapping_unit_category.is_compound IS 'Whether this is a compound unit with multiple soil types';
COMMENT ON COLUMN soil_mapping_unit_category.legend_order IS 'Order in the map legend';
COMMENT ON COLUMN soil_mapping_unit_category.symbol IS 'Symbol used in the map legend';
COMMENT ON COLUMN soil_mapping_unit_category.colour_rgb IS 'RGB colour code for map display (e.g., #A52A2A)';
COMMENT ON COLUMN soil_mapping_unit_category.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN soil_mapping_unit_category.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_category_map ON soil_mapping_unit_category (soil_map_id);
COMMENT ON INDEX idx_category_map IS 'Index on soil map code for joining with soil_map table';

-- ----------------------------------------------------------------------------
-- SoilMappingUnitCategoryComponent: Components of compound categories
-- ----------------------------------------------------------------------------
CREATE TABLE soil_mapping_unit_category_component (
    component_id      TEXT PRIMARY KEY,
    category_id       TEXT NOT NULL REFERENCES soil_mapping_unit_category(category_id) ON DELETE CASCADE,
    component_name      TEXT NOT NULL,
    component_classification TEXT,
    proportion_pct      NUMERIC(5,2),
    sequence_order      INTEGER,
    remarks             TEXT
);

COMMENT ON TABLE soil_mapping_unit_category_component IS 'Components of compound mapping unit categories';
COMMENT ON COLUMN soil_mapping_unit_category_component.component_id IS 'Unique identifier for the component (natural key)';
COMMENT ON COLUMN soil_mapping_unit_category_component.category_id IS 'Reference to the parent category';
COMMENT ON COLUMN soil_mapping_unit_category_component.component_name IS 'Name of the soil component';
COMMENT ON COLUMN soil_mapping_unit_category_component.component_classification IS 'Classification of the component';
COMMENT ON COLUMN soil_mapping_unit_category_component.proportion_pct IS 'Percentage of the compound unit occupied by this component';
COMMENT ON COLUMN soil_mapping_unit_category_component.sequence_order IS 'Order of components within the category';
COMMENT ON COLUMN soil_mapping_unit_category_component.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_component_category ON soil_mapping_unit_category_component (category_id);
COMMENT ON INDEX idx_component_category IS 'Index on category code for joining with category table';

-- ----------------------------------------------------------------------------
-- SoilMappingUnit: Delineated polygon on a soil map
-- ----------------------------------------------------------------------------
CREATE TABLE soil_mapping_unit (
    mapping_unit_id   TEXT PRIMARY KEY,
    category_id       TEXT NOT NULL REFERENCES soil_mapping_unit_category(category_id) ON DELETE CASCADE,
    geom                GEOMETRY(MultiPolygon, 4326) NOT NULL,
    name                TEXT,
    area_ha             NUMERIC(12,2),
    perimeter_m         NUMERIC(12,2),
    slope_class         TEXT,
    drainage_class      TEXT,
    erosion_class       TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE soil_mapping_unit IS 'Delineated polygon on a soil map (ISO 28258 SoilMappingUnit feature)';
COMMENT ON COLUMN soil_mapping_unit.mapping_unit_id IS 'Unique identifier for the mapping unit (natural key)';
COMMENT ON COLUMN soil_mapping_unit.category_id IS 'Reference to the mapping unit category';
COMMENT ON COLUMN soil_mapping_unit.geom IS 'MultiPolygon geometry of the mapping unit (EPSG:4326)';
COMMENT ON COLUMN soil_mapping_unit.name IS 'Name of the mapping unit';
COMMENT ON COLUMN soil_mapping_unit.area_ha IS 'Area of the mapping unit in hectares';
COMMENT ON COLUMN soil_mapping_unit.perimeter_m IS 'Perimeter of the mapping unit in meters';
COMMENT ON COLUMN soil_mapping_unit.slope_class IS 'Slope class within this unit';
COMMENT ON COLUMN soil_mapping_unit.drainage_class IS 'Drainage class within this unit';
COMMENT ON COLUMN soil_mapping_unit.erosion_class IS 'Erosion class within this unit';
COMMENT ON COLUMN soil_mapping_unit.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN soil_mapping_unit.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_mapping_unit_category ON soil_mapping_unit (category_id);
COMMENT ON INDEX idx_mapping_unit_category IS 'Index on category code for joining with category table';

CREATE INDEX idx_mapping_unit_geom ON soil_mapping_unit USING GIST (geom);
COMMENT ON INDEX idx_mapping_unit_geom IS 'Spatial index on mapping unit geometry';

-- ----------------------------------------------------------------------------
-- Link profiles to mapping units (representative profiles)
-- ----------------------------------------------------------------------------
CREATE TABLE soil_mapping_unit_profile (
    mapping_unit_id   TEXT REFERENCES soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE,
    profile_id        TEXT REFERENCES profile(profile_id) ON DELETE CASCADE,
    is_representative   BOOLEAN DEFAULT FALSE,
    remarks             TEXT,
    PRIMARY KEY (mapping_unit_id, profile_id)
);

COMMENT ON TABLE soil_mapping_unit_profile IS 'Links profiles to mapping units as representative or supporting profiles';
COMMENT ON COLUMN soil_mapping_unit_profile.mapping_unit_id IS 'Reference to the mapping unit';
COMMENT ON COLUMN soil_mapping_unit_profile.profile_id IS 'Reference to the profile';
COMMENT ON COLUMN soil_mapping_unit_profile.is_representative IS 'Whether this is the representative (type) profile for the unit';
COMMENT ON COLUMN soil_mapping_unit_profile.remarks IS 'Additional remarks or notes';

-- ============================================================================
-- OBSERVATION MODEL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Property: Catalogue of observable properties
-- ----------------------------------------------------------------------------
CREATE TABLE property (
    property_id       TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    property_group      TEXT,
    uom_symbol          TEXT,
    uom_name            TEXT,
    value_type          TEXT,
    min_value           NUMERIC,
    max_value           NUMERIC,
    external_uri        TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE property IS 'Catalogue of observable soil properties';
COMMENT ON COLUMN property.property_id IS 'Unique identifier for the property (natural key)';
COMMENT ON COLUMN property.name IS 'Human-readable name of the property';
COMMENT ON COLUMN property.description IS 'Detailed description of the property';
COMMENT ON COLUMN property.property_group IS 'Property group: physical, chemical, biological, descriptive';
COMMENT ON COLUMN property.uom_symbol IS 'Unit of measure symbol (e.g., %, g/cm³)';
COMMENT ON COLUMN property.uom_name IS 'Full name of the unit of measure';
COMMENT ON COLUMN property.value_type IS 'Data type: numeric, text, codelist, boolean';
COMMENT ON COLUMN property.min_value IS 'Minimum valid value for numeric properties';
COMMENT ON COLUMN property.max_value IS 'Maximum valid value for numeric properties';
COMMENT ON COLUMN property.external_uri IS 'URI to external property definition';
COMMENT ON COLUMN property.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN property.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_property_group ON property (property_group);
COMMENT ON INDEX idx_property_group IS 'Index on property group for filtering';

-- ----------------------------------------------------------------------------
-- Procedure: Methods used for observations
-- ----------------------------------------------------------------------------
CREATE TABLE procedure (
    procedure_id      TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    observation_type    TEXT NOT NULL,
    external_uri        TEXT,
    reference_document  TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_observation_type CHECK (observation_type IN ('field', 'laboratory'))
);

COMMENT ON TABLE procedure IS 'Methods and procedures used for soil observations';
COMMENT ON COLUMN procedure.procedure_id IS 'Unique identifier for the procedure (natural key)';
COMMENT ON COLUMN procedure.name IS 'Human-readable name of the procedure';
COMMENT ON COLUMN procedure.description IS 'Detailed description of the procedure';
COMMENT ON COLUMN procedure.observation_type IS 'Type of observation: field (in-situ) or laboratory';
COMMENT ON COLUMN procedure.external_uri IS 'URI to external procedure definition';
COMMENT ON COLUMN procedure.reference_document IS 'Reference document (e.g., ISO standard number)';
COMMENT ON COLUMN procedure.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN procedure.remarks IS 'Additional remarks or notes';

-- ----------------------------------------------------------------------------
-- Observations on Site
-- ----------------------------------------------------------------------------
CREATE TABLE observation_site (
    observation_id    TEXT PRIMARY KEY,
    site_id           TEXT NOT NULL REFERENCES site(site_id) ON DELETE CASCADE,
    property_id       TEXT NOT NULL REFERENCES property(property_id),
    procedure_id      TEXT REFERENCES procedure(procedure_id),
    observation_date    TIMESTAMPTZ,
    result_numeric      NUMERIC,
    result_text         TEXT,
    result_boolean      BOOLEAN,
    result_uom          TEXT,
    result_quality      TEXT DEFAULT 'valid',
    uncertainty         NUMERIC,
    observer            TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_result_quality_site CHECK (result_quality IN ('valid', 'estimated', 'below_detection_limit', 'above_detection_limit', 'missing', 'suspect'))
);

COMMENT ON TABLE observation_site IS 'Observations made at the site level';
COMMENT ON COLUMN observation_site.observation_id IS 'Unique identifier for the observation (natural key)';
COMMENT ON COLUMN observation_site.site_id IS 'Reference to the observed site';
COMMENT ON COLUMN observation_site.property_id IS 'Reference to the observed property';
COMMENT ON COLUMN observation_site.procedure_id IS 'Reference to the procedure used';
COMMENT ON COLUMN observation_site.observation_date IS 'Date and time of the observation';
COMMENT ON COLUMN observation_site.result_numeric IS 'Numeric result value';
COMMENT ON COLUMN observation_site.result_text IS 'Text result value';
COMMENT ON COLUMN observation_site.result_boolean IS 'Boolean result value';
COMMENT ON COLUMN observation_site.result_uom IS 'Unit of measure for the result';
COMMENT ON COLUMN observation_site.result_quality IS 'Quality indicator: valid, estimated, below/above detection limit, missing, suspect';
COMMENT ON COLUMN observation_site.uncertainty IS 'Measurement uncertainty';
COMMENT ON COLUMN observation_site.observer IS 'Person who made the observation';
COMMENT ON COLUMN observation_site.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN observation_site.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_obs_site_site ON observation_site (site_id);
COMMENT ON INDEX idx_obs_site_site IS 'Index on site code for joining with site table';

CREATE INDEX idx_obs_site_property ON observation_site (property_id);
COMMENT ON INDEX idx_obs_site_property IS 'Index on property code for filtering by property';

CREATE INDEX idx_obs_site_date ON observation_site (observation_date);
COMMENT ON INDEX idx_obs_site_date IS 'Index on observation date for temporal queries';

-- ----------------------------------------------------------------------------
-- Observations on Plot
-- ----------------------------------------------------------------------------
CREATE TABLE observation_plot (
    observation_id    TEXT PRIMARY KEY,
    plot_id           TEXT NOT NULL REFERENCES plot(plot_id) ON DELETE CASCADE,
    property_id       TEXT NOT NULL REFERENCES property(property_id),
    procedure_id      TEXT REFERENCES procedure(procedure_id),
    observation_date    TIMESTAMPTZ,
    result_numeric      NUMERIC,
    result_text         TEXT,
    result_boolean      BOOLEAN,
    result_uom          TEXT,
    result_quality      TEXT DEFAULT 'valid',
    uncertainty         NUMERIC,
    observer            TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_result_quality_plot CHECK (result_quality IN ('valid', 'estimated', 'below_detection_limit', 'above_detection_limit', 'missing', 'suspect'))
);

COMMENT ON TABLE observation_plot IS 'Observations made at the plot level';
COMMENT ON COLUMN observation_plot.observation_id IS 'Unique identifier for the observation (natural key)';
COMMENT ON COLUMN observation_plot.plot_id IS 'Reference to the observed plot';
COMMENT ON COLUMN observation_plot.property_id IS 'Reference to the observed property';
COMMENT ON COLUMN observation_plot.procedure_id IS 'Reference to the procedure used';
COMMENT ON COLUMN observation_plot.observation_date IS 'Date and time of the observation';
COMMENT ON COLUMN observation_plot.result_numeric IS 'Numeric result value';
COMMENT ON COLUMN observation_plot.result_text IS 'Text result value';
COMMENT ON COLUMN observation_plot.result_boolean IS 'Boolean result value';
COMMENT ON COLUMN observation_plot.result_uom IS 'Unit of measure for the result';
COMMENT ON COLUMN observation_plot.result_quality IS 'Quality indicator: valid, estimated, below/above detection limit, missing, suspect';
COMMENT ON COLUMN observation_plot.uncertainty IS 'Measurement uncertainty';
COMMENT ON COLUMN observation_plot.observer IS 'Person who made the observation';
COMMENT ON COLUMN observation_plot.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN observation_plot.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_obs_plot_plot ON observation_plot (plot_id);
COMMENT ON INDEX idx_obs_plot_plot IS 'Index on plot code for joining with plot table';

CREATE INDEX idx_obs_plot_property ON observation_plot (property_id);
COMMENT ON INDEX idx_obs_plot_property IS 'Index on property code for filtering by property';

-- ----------------------------------------------------------------------------
-- Observations on Profile
-- ----------------------------------------------------------------------------
CREATE TABLE observation_profile (
    observation_id    TEXT PRIMARY KEY,
    profile_id        TEXT NOT NULL REFERENCES profile(profile_id) ON DELETE CASCADE,
    property_id       TEXT NOT NULL REFERENCES property(property_id),
    procedure_id      TEXT REFERENCES procedure(procedure_id),
    observation_date    TIMESTAMPTZ,
    result_numeric      NUMERIC,
    result_text         TEXT,
    result_boolean      BOOLEAN,
    result_uom          TEXT,
    result_quality      TEXT DEFAULT 'valid',
    uncertainty         NUMERIC,
    observer            TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_result_quality_profile CHECK (result_quality IN ('valid', 'estimated', 'below_detection_limit', 'above_detection_limit', 'missing', 'suspect'))
);

COMMENT ON TABLE observation_profile IS 'Observations made at the profile level';
COMMENT ON COLUMN observation_profile.observation_id IS 'Unique identifier for the observation (natural key)';
COMMENT ON COLUMN observation_profile.profile_id IS 'Reference to the observed profile';
COMMENT ON COLUMN observation_profile.property_id IS 'Reference to the observed property';
COMMENT ON COLUMN observation_profile.procedure_id IS 'Reference to the procedure used';
COMMENT ON COLUMN observation_profile.observation_date IS 'Date and time of the observation';
COMMENT ON COLUMN observation_profile.result_numeric IS 'Numeric result value';
COMMENT ON COLUMN observation_profile.result_text IS 'Text result value';
COMMENT ON COLUMN observation_profile.result_boolean IS 'Boolean result value';
COMMENT ON COLUMN observation_profile.result_uom IS 'Unit of measure for the result';
COMMENT ON COLUMN observation_profile.result_quality IS 'Quality indicator: valid, estimated, below/above detection limit, missing, suspect';
COMMENT ON COLUMN observation_profile.uncertainty IS 'Measurement uncertainty';
COMMENT ON COLUMN observation_profile.observer IS 'Person who made the observation';
COMMENT ON COLUMN observation_profile.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN observation_profile.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_obs_profile_profile ON observation_profile (profile_id);
COMMENT ON INDEX idx_obs_profile_profile IS 'Index on profile code for joining with profile table';

CREATE INDEX idx_obs_profile_property ON observation_profile (property_id);
COMMENT ON INDEX idx_obs_profile_property IS 'Index on property code for filtering by property';

-- ----------------------------------------------------------------------------
-- Observations on ProfileElement (Horizon/Layer)
-- ----------------------------------------------------------------------------
CREATE TABLE observation_element (
    observation_id    TEXT PRIMARY KEY,
    element_id        TEXT NOT NULL REFERENCES profile_element(element_id) ON DELETE CASCADE,
    property_id       TEXT NOT NULL REFERENCES property(property_id),
    procedure_id      TEXT REFERENCES procedure(procedure_id),
    observation_date    TIMESTAMPTZ,
    result_numeric      NUMERIC,
    result_text         TEXT,
    result_boolean      BOOLEAN,
    result_uom          TEXT,
    result_quality      TEXT DEFAULT 'valid',
    uncertainty         NUMERIC,
    observer            TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_result_quality_element CHECK (result_quality IN ('valid', 'estimated', 'below_detection_limit', 'above_detection_limit', 'missing', 'suspect'))
);

COMMENT ON TABLE observation_element IS 'Observations made at the profile element (horizon/layer) level';
COMMENT ON COLUMN observation_element.observation_id IS 'Unique identifier for the observation (natural key)';
COMMENT ON COLUMN observation_element.element_id IS 'Reference to the observed profile element';
COMMENT ON COLUMN observation_element.property_id IS 'Reference to the observed property';
COMMENT ON COLUMN observation_element.procedure_id IS 'Reference to the procedure used';
COMMENT ON COLUMN observation_element.observation_date IS 'Date and time of the observation';
COMMENT ON COLUMN observation_element.result_numeric IS 'Numeric result value';
COMMENT ON COLUMN observation_element.result_text IS 'Text result value';
COMMENT ON COLUMN observation_element.result_boolean IS 'Boolean result value';
COMMENT ON COLUMN observation_element.result_uom IS 'Unit of measure for the result';
COMMENT ON COLUMN observation_element.result_quality IS 'Quality indicator: valid, estimated, below/above detection limit, missing, suspect';
COMMENT ON COLUMN observation_element.uncertainty IS 'Measurement uncertainty';
COMMENT ON COLUMN observation_element.observer IS 'Person who made the observation';
COMMENT ON COLUMN observation_element.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN observation_element.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_obs_element_element ON observation_element (element_id);
COMMENT ON INDEX idx_obs_element_element IS 'Index on element code for joining with profile_element table';

CREATE INDEX idx_obs_element_property ON observation_element (property_id);
COMMENT ON INDEX idx_obs_element_property IS 'Index on property code for filtering by property';

-- ----------------------------------------------------------------------------
-- Observations on Specimen (typically laboratory results)
-- ----------------------------------------------------------------------------
CREATE TABLE observation_specimen (
    observation_id    TEXT PRIMARY KEY,
    specimen_id       TEXT NOT NULL REFERENCES specimen(specimen_id) ON DELETE CASCADE,
    property_id       TEXT NOT NULL REFERENCES property(property_id),
    procedure_id      TEXT REFERENCES procedure(procedure_id),
    observation_date    TIMESTAMPTZ,
    result_numeric      NUMERIC,
    result_text         TEXT,
    result_boolean      BOOLEAN,
    result_uom          TEXT,
    result_quality      TEXT DEFAULT 'valid',
    uncertainty         NUMERIC,
    analyst             TEXT,
    laboratory          TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT,
    
    CONSTRAINT chk_result_quality_specimen CHECK (result_quality IN ('valid', 'estimated', 'below_detection_limit', 'above_detection_limit', 'missing', 'suspect'))
);

COMMENT ON TABLE observation_specimen IS 'Observations made on specimens, typically laboratory analyses';
COMMENT ON COLUMN observation_specimen.observation_id IS 'Unique identifier for the observation (natural key)';
COMMENT ON COLUMN observation_specimen.specimen_id IS 'Reference to the observed specimen';
COMMENT ON COLUMN observation_specimen.property_id IS 'Reference to the observed property';
COMMENT ON COLUMN observation_specimen.procedure_id IS 'Reference to the procedure used';
COMMENT ON COLUMN observation_specimen.observation_date IS 'Date and time of the observation';
COMMENT ON COLUMN observation_specimen.result_numeric IS 'Numeric result value';
COMMENT ON COLUMN observation_specimen.result_text IS 'Text result value';
COMMENT ON COLUMN observation_specimen.result_boolean IS 'Boolean result value';
COMMENT ON COLUMN observation_specimen.result_uom IS 'Unit of measure for the result';
COMMENT ON COLUMN observation_specimen.result_quality IS 'Quality indicator: valid, estimated, below/above detection limit, missing, suspect';
COMMENT ON COLUMN observation_specimen.uncertainty IS 'Measurement uncertainty';
COMMENT ON COLUMN observation_specimen.analyst IS 'Person who performed the analysis';
COMMENT ON COLUMN observation_specimen.laboratory IS 'Laboratory where the analysis was performed';
COMMENT ON COLUMN observation_specimen.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN observation_specimen.remarks IS 'Additional remarks or notes';

CREATE INDEX idx_obs_specimen_specimen ON observation_specimen (specimen_id);
COMMENT ON INDEX idx_obs_specimen_specimen IS 'Index on specimen code for joining with specimen table';

CREATE INDEX idx_obs_specimen_property ON observation_specimen (property_id);
COMMENT ON INDEX idx_obs_specimen_property IS 'Index on property code for filtering by property';

-- ============================================================================
-- SUPPORTING TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Document: Related documents (photos, reports, etc.)
-- ----------------------------------------------------------------------------
CREATE TABLE document (
    document_id       TEXT PRIMARY KEY,
    title               TEXT,
    description         TEXT,
    document_type       TEXT,
    file_path           TEXT,
    file_url            TEXT,
    mime_type           TEXT,
    file_size_bytes     BIGINT,
    document_date       DATE,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE document IS 'Related documents such as photos, reports, and maps';
COMMENT ON COLUMN document.document_id IS 'Unique identifier for the document (natural key)';
COMMENT ON COLUMN document.title IS 'Title of the document';
COMMENT ON COLUMN document.description IS 'Description of the document';
COMMENT ON COLUMN document.document_type IS 'Type of document: photo, report, map, etc.';
COMMENT ON COLUMN document.file_path IS 'File system path to the document';
COMMENT ON COLUMN document.file_url IS 'URL to access the document';
COMMENT ON COLUMN document.mime_type IS 'MIME type of the document';
COMMENT ON COLUMN document.file_size_bytes IS 'File size in bytes';
COMMENT ON COLUMN document.document_date IS 'Date of the document';
COMMENT ON COLUMN document.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN document.remarks IS 'Additional remarks or notes';

-- Link documents to features (many-to-many)
CREATE TABLE site_document (
    site_id           TEXT REFERENCES site(site_id) ON DELETE CASCADE,
    document_id       TEXT REFERENCES document(document_id) ON DELETE CASCADE,
    PRIMARY KEY (site_id, document_id)
);
COMMENT ON TABLE site_document IS 'Links documents to sites (many-to-many relationship)';
COMMENT ON COLUMN site_document.site_id IS 'Reference to the site';
COMMENT ON COLUMN site_document.document_id IS 'Reference to the document';

CREATE TABLE plot_document (
    plot_id           TEXT REFERENCES plot(plot_id) ON DELETE CASCADE,
    document_id       TEXT REFERENCES document(document_id) ON DELETE CASCADE,
    PRIMARY KEY (plot_id, document_id)
);
COMMENT ON TABLE plot_document IS 'Links documents to plots (many-to-many relationship)';
COMMENT ON COLUMN plot_document.plot_id IS 'Reference to the plot';
COMMENT ON COLUMN plot_document.document_id IS 'Reference to the document';

CREATE TABLE profile_document (
    profile_id        TEXT REFERENCES profile(profile_id) ON DELETE CASCADE,
    document_id       TEXT REFERENCES document(document_id) ON DELETE CASCADE,
    PRIMARY KEY (profile_id, document_id)
);
COMMENT ON TABLE profile_document IS 'Links documents to profiles (many-to-many relationship)';
COMMENT ON COLUMN profile_document.profile_id IS 'Reference to the profile';
COMMENT ON COLUMN profile_document.document_id IS 'Reference to the document';

CREATE TABLE element_document (
    element_id        TEXT REFERENCES profile_element(element_id) ON DELETE CASCADE,
    document_id       TEXT REFERENCES document(document_id) ON DELETE CASCADE,
    PRIMARY KEY (element_id, document_id)
);
COMMENT ON TABLE element_document IS 'Links documents to profile elements (many-to-many relationship)';
COMMENT ON COLUMN element_document.element_id IS 'Reference to the profile element';
COMMENT ON COLUMN element_document.document_id IS 'Reference to the document';

-- ----------------------------------------------------------------------------
-- Project: Grouping of sites/data collection campaigns
-- ----------------------------------------------------------------------------
CREATE TABLE project (
    project_id        TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    start_date          DATE,
    end_date            DATE,
    organization        TEXT,
    contact_person      TEXT,
    contact_email       TEXT,
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    remarks             TEXT
);

COMMENT ON TABLE project IS 'Projects or data collection campaigns that group sites';
COMMENT ON COLUMN project.project_id IS 'Unique identifier for the project (natural key)';
COMMENT ON COLUMN project.name IS 'Name of the project';
COMMENT ON COLUMN project.description IS 'Description of the project';
COMMENT ON COLUMN project.start_date IS 'Project start date';
COMMENT ON COLUMN project.end_date IS 'Project end date';
COMMENT ON COLUMN project.organization IS 'Organization responsible for the project';
COMMENT ON COLUMN project.contact_person IS 'Contact person for the project';
COMMENT ON COLUMN project.contact_email IS 'Contact email address';
COMMENT ON COLUMN project.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN project.remarks IS 'Additional remarks or notes';

CREATE TABLE project_site (
    project_id        TEXT REFERENCES project(project_id) ON DELETE CASCADE,
    site_id           TEXT REFERENCES site(site_id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, site_id)
);
COMMENT ON TABLE project_site IS 'Links sites to projects (many-to-many relationship)';
COMMENT ON COLUMN project_site.project_id IS 'Reference to the project';
COMMENT ON COLUMN project_site.site_id IS 'Reference to the site';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Full hierarchy view: Site -> Plot -> Profile -> Element
CREATE VIEW v_profile_hierarchy AS
SELECT 
    s.site_id,
    s.name AS site_name,
    s.geom AS site_geom,
    s.country_code,
    pl.plot_id,
    pl.name AS plot_name,
    pr.profile_id,
    pr.name AS profile_name,
    pr.wrb_classification,
    pe.element_id,
    pe.element_type,
    pe.designation,
    pe.upper_depth_cm,
    pe.lower_depth_cm
FROM site s
LEFT JOIN plot pl ON pl.site_id = s.site_id
LEFT JOIN profile pr ON pr.plot_id = pl.plot_id
LEFT JOIN profile_element pe ON pe.profile_id = pr.profile_id
ORDER BY s.site_id, pl.plot_id, pr.profile_id, pe.upper_depth_cm;

COMMENT ON VIEW v_profile_hierarchy IS 'Hierarchical view of sites, plots, profiles, and profile elements';

-- Specimen with full context
CREATE VIEW v_specimen_context AS
SELECT 
    sp.specimen_id,
    sp.sampling_date,
    pe.element_id,
    pe.designation AS element_designation,
    pe.upper_depth_cm AS element_upper_depth,
    pe.lower_depth_cm AS element_lower_depth,
    pr.profile_id,
    pr.name AS profile_name,
    pl.plot_id,
    s.site_id,
    s.name AS site_name,
    s.geom AS site_geom
FROM specimen sp
JOIN profile_element pe ON pe.element_id = sp.element_id
JOIN profile pr ON pr.profile_id = pe.profile_id
JOIN plot pl ON pl.plot_id = pr.plot_id
JOIN site s ON s.site_id = pl.site_id;

COMMENT ON VIEW v_specimen_context IS 'Specimens with full hierarchical context from site to profile element';

-- Soil map with mapping units
CREATE VIEW v_soil_map_units AS
SELECT 
    sm.soil_map_id,
    sm.name AS map_name,
    sm.scale_denominator,
    sm.classification_system,
    smc.category_id,
    smc.name AS category_name,
    smc.wrb_classification,
    smu.mapping_unit_id,
    smu.geom,
    smu.area_ha
FROM soil_map sm
JOIN soil_mapping_unit_category smc ON smc.soil_map_id = sm.soil_map_id
JOIN soil_mapping_unit smu ON smu.category_id = smc.category_id;

COMMENT ON VIEW v_soil_map_units IS 'Soil mapping units with their map and category context';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_timestamp() IS 'Trigger function to automatically update the updated_at timestamp';

-- Apply trigger to tables with updated_at
CREATE TRIGGER trg_site_updated BEFORE UPDATE ON site
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_site_updated ON site IS 'Automatically updates updated_at timestamp on site modification';

CREATE TRIGGER trg_plot_updated BEFORE UPDATE ON plot
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_plot_updated ON plot IS 'Automatically updates updated_at timestamp on plot modification';

CREATE TRIGGER trg_profile_updated BEFORE UPDATE ON profile
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_profile_updated ON profile IS 'Automatically updates updated_at timestamp on profile modification';

CREATE TRIGGER trg_element_updated BEFORE UPDATE ON profile_element
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_element_updated ON profile_element IS 'Automatically updates updated_at timestamp on profile_element modification';

CREATE TRIGGER trg_specimen_updated BEFORE UPDATE ON specimen
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_specimen_updated ON specimen IS 'Automatically updates updated_at timestamp on specimen modification';

CREATE TRIGGER trg_soil_map_updated BEFORE UPDATE ON soil_map
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
COMMENT ON TRIGGER trg_soil_map_updated ON soil_map IS 'Automatically updates updated_at timestamp on soil_map modification';

-- ============================================================================
-- SAMPLE PROPERTIES (Common soil properties from ISO 28258)
-- ============================================================================

INSERT INTO property (property_id, name, property_group, uom_symbol, value_type, min_value, max_value, description) VALUES
-- Physical properties
('clay_content', 'Clay content', 'physical', '%', 'numeric', 0, 100, 'Mass fraction of clay particles (<2 µm)'),
('silt_content', 'Silt content', 'physical', '%', 'numeric', 0, 100, 'Mass fraction of silt particles (2-50 µm)'),
('sand_content', 'Sand content', 'physical', '%', 'numeric', 0, 100, 'Mass fraction of sand particles (50-2000 µm)'),
('bulk_density', 'Bulk density', 'physical', 'g/cm³', 'numeric', 0.1, 2.5, 'Dry bulk density of undisturbed soil'),
('particle_density', 'Particle density', 'physical', 'g/cm³', 'numeric', 2.0, 3.0, 'Density of solid soil particles'),
('porosity', 'Porosity', 'physical', '%', 'numeric', 0, 100, 'Volume fraction of pore space'),
('water_content', 'Water content', 'physical', '%', 'numeric', 0, 100, 'Gravimetric water content'),
('field_capacity', 'Field capacity', 'physical', '%', 'numeric', 0, 100, 'Water content at field capacity'),
('wilting_point', 'Permanent wilting point', 'physical', '%', 'numeric', 0, 100, 'Water content at permanent wilting point'),
('hydraulic_conductivity', 'Saturated hydraulic conductivity', 'physical', 'cm/day', 'numeric', 0, NULL, 'Saturated hydraulic conductivity (Ksat)'),

-- Chemical properties
('ph_h2o', 'pH in water', 'chemical', NULL, 'numeric', 0, 14, 'Soil pH measured in water suspension'),
('ph_kcl', 'pH in KCl', 'chemical', NULL, 'numeric', 0, 14, 'Soil pH measured in KCl solution'),
('ph_cacl2', 'pH in CaCl2', 'chemical', NULL, 'numeric', 0, 14, 'Soil pH measured in CaCl2 solution'),
('ec', 'Electrical conductivity', 'chemical', 'dS/m', 'numeric', 0, NULL, 'Electrical conductivity of soil extract'),
('organic_carbon', 'Organic carbon content', 'chemical', '%', 'numeric', 0, 100, 'Mass fraction of organic carbon'),
('total_nitrogen', 'Total nitrogen', 'chemical', '%', 'numeric', 0, 100, 'Mass fraction of total nitrogen'),
('c_n_ratio', 'Carbon to nitrogen ratio', 'chemical', NULL, 'numeric', 0, NULL, 'Ratio of organic carbon to total nitrogen'),
('cec', 'Cation exchange capacity', 'chemical', 'cmol(+)/kg', 'numeric', 0, NULL, 'Cation exchange capacity at soil pH'),
('base_saturation', 'Base saturation', 'chemical', '%', 'numeric', 0, 100, 'Percentage of CEC occupied by base cations'),
('calcium_exch', 'Exchangeable calcium', 'chemical', 'cmol(+)/kg', 'numeric', 0, NULL, 'Exchangeable calcium content'),
('magnesium_exch', 'Exchangeable magnesium', 'chemical', 'cmol(+)/kg', 'numeric', 0, NULL, 'Exchangeable magnesium content'),
('potassium_exch', 'Exchangeable potassium', 'chemical', 'cmol(+)/kg', 'numeric', 0, NULL, 'Exchangeable potassium content'),
('sodium_exch', 'Exchangeable sodium', 'chemical', 'cmol(+)/kg', 'numeric', 0, NULL, 'Exchangeable sodium content'),
('phosphorus_avail', 'Available phosphorus', 'chemical', 'mg/kg', 'numeric', 0, NULL, 'Plant-available phosphorus'),
('caco3', 'Calcium carbonate content', 'chemical', '%', 'numeric', 0, 100, 'Mass fraction of calcium carbonate equivalent'),

-- Descriptive properties (field observations)
('soil_colour_moist', 'Soil colour (moist)', 'descriptive', NULL, 'text', NULL, NULL, 'Munsell colour notation for moist soil'),
('soil_colour_dry', 'Soil colour (dry)', 'descriptive', NULL, 'text', NULL, NULL, 'Munsell colour notation for dry soil'),
('structure_type', 'Structure type', 'descriptive', NULL, 'text', NULL, NULL, 'Type of soil structure (granular, blocky, prismatic, etc.)'),
('structure_grade', 'Structure grade', 'descriptive', NULL, 'text', NULL, NULL, 'Grade of soil structure development'),
('consistence_moist', 'Consistence (moist)', 'descriptive', NULL, 'text', NULL, NULL, 'Soil consistence when moist'),
('root_abundance', 'Root abundance', 'descriptive', NULL, 'text', NULL, NULL, 'Abundance of roots'),
('mottling', 'Mottling description', 'descriptive', NULL, 'text', NULL, NULL, 'Description of soil mottling'),
('coarse_fragments', 'Coarse fragments', 'descriptive', '%', 'numeric', 0, 100, 'Volume fraction of coarse fragments (>2mm)');

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA soil_data TO sis_e, sis_r;

-- Grant permissions on all tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA soil_data TO sis_e;
GRANT SELECT ON ALL TABLES IN SCHEMA soil_data TO sis_r;

-- Grant permissions on sequences (if any are created)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA soil_data TO sis_e;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA soil_data TO sis_r;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA soil_data
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sis_e;

ALTER DEFAULT PRIVILEGES IN SCHEMA soil_data
    GRANT SELECT ON TABLES TO sis_r;

ALTER DEFAULT PRIVILEGES IN SCHEMA soil_data
    GRANT USAGE, SELECT ON SEQUENCES TO sis_e;

ALTER DEFAULT PRIVILEGES IN SCHEMA soil_data
    GRANT SELECT ON SEQUENCES TO sis_r;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================