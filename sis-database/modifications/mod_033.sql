-- OBJECT: soil_data.procedure_phys_chem, observation_phys_chem, property_phys_chem and result_phys_chem
-- ISSUE: rename phys_chem to num (numerical)


ALTER TABLE IF EXISTS soil_data.property_phys_chem RENAME COLUMN property_phys_chem_id TO property_num_id;
ALTER TABLE IF EXISTS soil_data.property_phys_chem RENAME CONSTRAINT property_phys_chem_pkey TO property_num_pkey;
ALTER TABLE IF EXISTS soil_data.property_phys_chem RENAME CONSTRAINT unq_property_phys_chem_uri TO unq_property_num_uri;
ALTER TABLE IF EXISTS soil_data.property_phys_chem RENAME TO property_num;

ALTER TABLE IF EXISTS soil_data.procedure_phys_chem RENAME COLUMN procedure_phys_chem_id TO procedure_num_id;
ALTER TABLE IF EXISTS soil_data.procedure_phys_chem RENAME CONSTRAINT procedure_phys_chem_pkey TO procedure_num_pkey;
ALTER TABLE IF EXISTS soil_data.procedure_phys_chem RENAME CONSTRAINT unq_procedure_phys_chem_uri TO unq_procedure_num_uri;
ALTER TABLE IF EXISTS soil_data.procedure_phys_chem RENAME CONSTRAINT procedure_phys_chem_broader_id_fkey TO procedure_num_broader_id_fkey;
ALTER TABLE IF EXISTS soil_data.procedure_phys_chem RENAME TO procedure_num;

ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME COLUMN observation_phys_chem_id TO observation_num_id;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME COLUMN property_phys_chem_id TO property_num_id;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME COLUMN procedure_phys_chem_id TO procedure_num_id;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME CONSTRAINT observation_phys_chem_pkey TO observation_num_pkey;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME CONSTRAINT observation_phys_chem_property_phys_chem_id_procedure_phys__key TO observation_num_property_num_id_procedure_num_key;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME CONSTRAINT observation_phys_chem_procedure_phys_chem_id_fkey TO observation_num_procedure_num_id_fkey;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME CONSTRAINT observation_phys_chem_property_phys_chem_id_fkey TO observation_num_property_num_id_fkey;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME CONSTRAINT observation_phys_chem_unit_of_measure_id_fkey TO observation_bum_unit_of_measure_id_fkey;
ALTER TABLE IF EXISTS soil_data.observation_phys_chem RENAME TO observation_num;

ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME COLUMN result_phys_chem_id TO result_num_id;
ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME COLUMN observation_phys_chem_id TO observation_num_id;
ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME CONSTRAINT result_numerical_specimen_pkey TO result_num_specimen_pkey;
ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME CONSTRAINT result_phys_chem_specimen_observation_phys_chem_id_specimen_key TO result_num_observation_num_id_specimen_id_key;
ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME CONSTRAINT result_phys_chem_specimen_observation_phys_chem_id_fkey TO result_num_observation_num_id_fkey;
ALTER TABLE IF EXISTS soil_data.result_phys_chem RENAME TO result_num;

-- ALTER TABLE IF EXISTS soil_data.specimen DROP COLUMN individual_id;
ALTER TABLE IF EXISTS soil_data.specimen DROP COLUMN organisation_id;

-- DROP VIEW IF EXISTS api.vw_api_observation;
-- CREATE OR REPLACE VIEW api.vw_api_observation
--  AS
--  SELECT p2.profile_code,
--     e.upper_depth,
--     e.lower_depth,
--     o.property_num_id,
--     o.procedure_num_id,
--     o.unit_of_measure_id,
--     r.value
--    FROM soil_data.project p
--      LEFT JOIN soil_data.project_site ps ON ps.project_id = p.project_id
--      LEFT JOIN soil_data.site s ON s.site_id = ps.site_id
--      LEFT JOIN soil_data.profile p2 ON p2.site_id = ps.site_id
--      LEFT JOIN soil_data.element e ON e.profile_id = p2.profile_id
--      LEFT JOIN soil_data.specimen s2 ON s2.element_id = e.element_id
--      LEFT JOIN soil_data.result_num r ON r.specimen_id = s2.specimen_id
--      LEFT JOIN soil_data.observation_num o ON o.observation_num_id = r.observation_num_id
--   ORDER BY p2.profile_code, e.upper_depth, o.property_num_id;
-- ALTER TABLE api.vw_api_observation OWNER TO sis;
-- COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';
-- GRANT ALL ON TABLE api.vw_api_observation TO sis;
-- GRANT SELECT ON TABLE api.vw_api_observation TO sis_r;
