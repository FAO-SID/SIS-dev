-- OBJECT: schemas
-- ISSUE: rename schemas


DROP SCHEMA soil_metadata CASCADE;
DROP TABLE soil_data.project_related;
DROP TABLE soil_data.project_site;


ALTER TABLE soil_data.project ALTER COLUMN project_id DROP IDENTITY;
ALTER TABLE soil_data.project ALTER COLUMN project_id TYPE text USING project_id::text;


CREATE TABLE soil_data.project_site (
	project_id text NOT NULL,
	site_id int4 NOT NULL,
	CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id),
	CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id),
	CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id)
);
ALTER TABLE IF EXISTS soil_data.project_site OWNER to sis;
GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


CREATE TABLE IF NOT EXISTS soil_data.organisation
(
    organisation_id text NOT NULL,
    url text,
    email text,
    country text,
    city text,
    postal_code text,
    delivery_point text,
    phone text,
    facsimile text,
    CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id)
);
ALTER TABLE IF EXISTS soil_data.organisation OWNER to sis;
GRANT SELECT ON TABLE soil_data.organisation TO sis_r;

CREATE TABLE IF NOT EXISTS soil_data.individual
(
    individual_id text NOT NULL,
    email text,
    CONSTRAINT individual_pkey PRIMARY KEY (individual_id)
);
ALTER TABLE IF EXISTS soil_data.individual OWNER to sis;
GRANT SELECT ON TABLE soil_data.individual TO sis_r;


CREATE TABLE IF NOT EXISTS soil_data.proj_x_org_x_ind
(
    project_id text NOT NULL,
    organisation_id text NOT NULL,
    individual_id text NOT NULL,
    "position" text NOT NULL,
    tag text NOT NULL,
    role text NOT NULL,
    CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role),
    CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES soil_data.project (project_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id)
        REFERENCES soil_data.individual (individual_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id)
        REFERENCES soil_data.organisation (organisation_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT proj_x_org_x_ind_role_check CHECK (role = ANY (ARRAY['author'::text, 'custodian'::text, 'distributor'::text, 'originator'::text, 'owner'::text, 'pointOfContact'::text, 'principalInvestigator'::text, 'processor'::text, 'publisher'::text, 'resourceProvider'::text, 'user'::text])),
    CONSTRAINT proj_x_org_x_ind_tag_check CHECK (tag = ANY (ARRAY['contact'::text, 'pointOfContact'::text]))
);
ALTER TABLE IF EXISTS soil_data.proj_x_org_x_ind OWNER to sis;
GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;
