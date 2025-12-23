-- OBJECT: soil_data.plot and surface
-- ISSUE: drop tables plot and surface

ALTER TABLE IF EXISTS soil_data.observation_desc_plot RENAME TO observation_desc_site;
ALTER TABLE IF EXISTS soil_data.result_desc_plot RENAME TO result_desc_site;
ALTER TABLE IF EXISTS soil_data.result_desc_site DROP CONSTRAINT fk_plot;
ALTER TABLE IF EXISTS soil_data.result_desc_site RENAME COLUMN plot_id TO site_id;
ALTER TABLE IF EXISTS soil_data.result_desc_site ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE IF EXISTS soil_data.profile DROP CONSTRAINT fk_plot;
ALTER TABLE IF EXISTS soil_data.profile RENAME COLUMN plot_id TO site_id;
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE IF EXISTS soil_data.profile DROP COLUMN surface_id;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN altitude smallint;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN time_stamp date;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN map_sheet_code text;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN positional_accuracy smallint;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN geom geometry(Point,4326);
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN type text;
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_altitude_check CHECK (altitude::numeric > '-100'::integer::numeric);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_altitude_check1 CHECK (altitude::numeric < 8000::numeric);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_time_stamp_check CHECK (time_stamp > '1900-01-01'::date);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_type_check CHECK (type = ANY (ARRAY['TrialPit'::text, 'Borehole'::text]));

DROP TABLE IF EXISTS soil_data.result_desc_surface;
DROP TABLE IF EXISTS soil_data.surface_individual;
DROP TABLE IF EXISTS soil_data.plot_individual;
DROP TABLE IF EXISTS soil_data.surface;

DROP VIEW api.vw_api_manifest;
CREATE OR REPLACE VIEW api.vw_api_manifest
 AS
 SELECT opc.property_phys_chem_id AS property,
    count(DISTINCT p.profile_id) AS profiles,
    count(rpc.result_phys_chem_id) AS observations,
    st_envelope(st_collect(p.geom)) AS geom
   FROM soil_data.observation_phys_chem opc
     JOIN soil_data.result_phys_chem rpc ON opc.observation_phys_chem_id = rpc.observation_phys_chem_id
     JOIN soil_data.specimen s ON rpc.specimen_id = s.specimen_id
     JOIN soil_data.element e ON s.element_id = e.element_id
     JOIN soil_data.profile p ON e.profile_id = p.profile_id
  GROUP BY opc.property_phys_chem_id
  ORDER BY opc.property_phys_chem_id;
ALTER TABLE api.vw_api_manifest OWNER TO sis;
COMMENT ON VIEW api.vw_api_manifest IS 'View to expose the list of soil properties and geographical extent';
GRANT ALL ON TABLE api.vw_api_manifest TO sis;
GRANT SELECT ON TABLE api.vw_api_manifest TO sis_r;

DROP VIEW api.vw_api_observation;
CREATE OR REPLACE VIEW api.vw_api_observation
 AS
 SELECT p2.profile_code,
    e.upper_depth,
    e.lower_depth,
    o.property_phys_chem_id,
    o.procedure_phys_chem_id,
    o.unit_of_measure_id,
    r.value
   FROM soil_data.project p
     LEFT JOIN soil_data.project_site ps ON ps.project_id = p.project_id
     LEFT JOIN soil_data.site s ON s.site_id = ps.site_id
     LEFT JOIN soil_data.profile p2 ON p2.site_id = ps.site_id
     LEFT JOIN soil_data.element e ON e.profile_id = p2.profile_id
     LEFT JOIN soil_data.specimen s2 ON s2.element_id = e.element_id
     LEFT JOIN soil_data.result_phys_chem r ON r.specimen_id = s2.specimen_id
     LEFT JOIN soil_data.observation_phys_chem o ON o.observation_phys_chem_id = r.observation_phys_chem_id
  ORDER BY p2.profile_code, e.upper_depth, o.property_phys_chem_id;
ALTER TABLE api.vw_api_observation OWNER TO sis;
COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';
GRANT ALL ON TABLE api.vw_api_observation TO sis;
GRANT SELECT ON TABLE api.vw_api_observation TO sis_r;

DROP VIEW api.vw_api_profile;
CREATE OR REPLACE VIEW api.vw_api_profile
 AS
 SELECT p.profile_id AS gid,
    p.profile_code,
    proj.name AS project_name,
    p.altitude,
    p.time_stamp AS date,
    p.geom
   FROM soil_data.profile p
     JOIN soil_data.site s ON p.site_id = s.site_id
     LEFT JOIN soil_data.project_site ps ON s.site_id = ps.site_id
     LEFT JOIN soil_data.project proj ON ps.project_id = proj.project_id
  WHERE p.geom IS NOT NULL
  ORDER BY p.profile_id;
ALTER TABLE api.vw_api_profile OWNER TO sis;
COMMENT ON VIEW api.vw_api_profile IS 'View to expose the list of profiles';
GRANT ALL ON TABLE api.vw_api_profile TO sis;
GRANT SELECT ON TABLE api.vw_api_profile TO sis_r;

DROP TABLE IF EXISTS soil_data.plot;

ALTER TABLE IF EXISTS soil_data.site DROP COLUMN "position";
ALTER TABLE IF EXISTS soil_data.site RENAME COLUMN extent TO geom;
