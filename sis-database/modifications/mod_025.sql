-- OBJECT: project_organisation and site_project
-- ISSUE: rename


ALTER TABLE IF EXISTS core.project_organisation RENAME TO organisation_project;
ALTER TABLE IF EXISTS core.organisation_project SET SCHEMA metadata;
ALTER TABLE metadata.organisation_project RENAME CONSTRAINT project_organisation_pkey TO organisation_project_pkey;

ALTER TABLE IF EXISTS core.site_project RENAME TO project_site;
ALTER TABLE core.project_site RENAME CONSTRAINT site_project_pkey TO project_site_pkey;
