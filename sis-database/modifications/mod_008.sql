-- OBJECT: core.project, result_numerical_specimen, result_phys_chem
-- ISSUE: double UNIQUE


ALTER TABLE IF EXISTS core.project DROP CONSTRAINT project_name_key;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen DROP CONSTRAINT result_numerical_specimen_unq_foi_obs;
