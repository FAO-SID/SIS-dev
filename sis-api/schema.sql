-- Schemas for API
CREATE SCHEMA IF NOT EXISTS api AUTHORIZATION sis;
COMMENT ON SCHEMA api IS 'API tables';
ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;

CREATE SCHEMA IF NOT EXISTS soil_data_upload AUTHORIZATION sis;
COMMENT ON SCHEMA soil_data_upload IS 'Schema to upload soil data';
ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;

-- Users and Authentication
CREATE TABLE IF NOT EXISTS api.user (
    individual_id TEXT PRIMARY KEY,
    organisation_id TEXT,
    password_hash TEXT NOT NULL,
    created_at DATE DEFAULT CURRENT_DATE,
    last_login DATE,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    CONSTRAINT user_organisation_id_fkey FOREIGN KEY (organisation_id)
        REFERENCES soil_data.organisation (organisation_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT user_individual_id_fkey FOREIGN KEY (individual_id)
        REFERENCES soil_data.individual (individual_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS api.user OWNER to sis;
GRANT SELECT ON TABLE api.user TO sis_r;


-- Settings System
CREATE TABLE IF NOT EXISTS api.setting (
    key TEXT PRIMARY KEY,
    value TEXT,
    display_order SMALLINT
);
ALTER TABLE IF EXISTS api.setting OWNER to sis;
GRANT SELECT ON TABLE api.setting TO sis_r;


-- User Preferences
CREATE TABLE IF NOT EXISTS api.user_layer (
    individual_id TEXT,
    project_id TEXT,
    PRIMARY KEY (individual_id, project_id),
    CONSTRAINT user_layer_individual_id_fkey FOREIGN KEY (individual_id)
        REFERENCES api.user (individual_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT user_layer_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES soil_data.project (project_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS api.user_layer OWNER to sis;
GRANT SELECT ON TABLE api.user_layer TO sis_r;


-- Project and Layer Management
CREATE TABLE IF NOT EXISTS api.layer (
    individual_id TEXT,
    project_id TEXT,
    layer_id TEXT PRIMARY KEY,
    publish BOOLEAN DEFAULT TRUE,
    property_id TEXT,
    property_name TEXT,
    version TEXT,
    unit_of_measure_id TEXT REFERENCES soil_data.unit_of_measure(unit_of_measure_id),
    dimension_des TEXT,
    metadata_url TEXT,
    download_url TEXT,
    get_map_url TEXT,
    get_legend_url TEXT,
    get_feature_info_url TEXT,
    CONSTRAINT layer_individual_project_id_fkey FOREIGN KEY (individual_id, project_id)
        REFERENCES api.user_layer (individual_id, project_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS api.layer OWNER to sis;
GRANT SELECT ON TABLE api.layer TO sis_r;


-- Data Upload Tracking
CREATE TABLE IF NOT EXISTS api.uploaded_dataset (
    individual_id text,
    project_id text,
    table_name text PRIMARY KEY,
    file_name TEXT NOT NULL UNIQUE,
    upload_date DATE DEFAULT CURRENT_DATE,
    ingestion_date date,
    status text,
    depth_if_topsoil smallint,
    n_rows integer,
    n_col smallint,
    has_cords boolean,
    cords_epsg integer,
    cords_check boolean DEFAULT false,
    note text,
    CONSTRAINT uploaded_dataset_status_check CHECK (status = ANY (ARRAY['Uploaded', 'Ingested', 'Removed'])),
    CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES soil_data.project (project_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT uploaded_dataset_individual_id_fkey FOREIGN KEY (individual_id)
        REFERENCES api.user (individual_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS api.uploaded_dataset OWNER to sis;
GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


CREATE TABLE IF NOT EXISTS api.uploaded_dataset_column
(
    table_name text NOT NULL,
    column_name text NOT NULL,
    property_phys_chem_id text,
    procedure_phys_chem_id text,
    unit_of_measure_id text,
    ignore_column boolean DEFAULT false,
    note text,
    CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name),
    CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name)
        REFERENCES api.uploaded_dataset (table_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT uploaded_dataset_column_property_phys_chem_id_fkey FOREIGN KEY (property_phys_chem_id)
        REFERENCES soil_data.property_phys_chem (property_phys_chem_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT uploaded_dataset_column_procedure_phys_chem_id_fkey FOREIGN KEY (procedure_phys_chem_id)
        REFERENCES soil_data.procedure_phys_chem (procedure_phys_chem_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id)
        REFERENCES soil_data.unit_of_measure (unit_of_measure_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS api.uploaded_dataset_column OWNER to sis;
GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;

