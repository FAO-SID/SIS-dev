-- OBJECT: core.observation_phys_chem_element, observation_phys_chem_specimen
-- ISSUE: redundancy between these two tables


ALTER TABLE IF EXISTS core.result_phys_chem_element DROP CONSTRAINT fk_observation_phys_chem;
ALTER TABLE IF EXISTS core.observation_phys_chem_element RENAME TO observation_phys_chem;
ALTER TABLE IF EXISTS core.observation_phys_chem RENAME COLUMN observation_phys_chem_element_id TO observation_phys_chem_id;
ALTER TABLE IF EXISTS core.result_phys_chem_element RENAME COLUMN observation_phys_chem_element_id TO observation_phys_chem_id;
ALTER TABLE IF EXISTS core.result_phys_chem_element ADD FOREIGN KEY (observation_phys_chem_id)
    REFERENCES core.observation_phys_chem (observation_phys_chem_id);

ALTER TABLE IF EXISTS core.result_phys_chem_specimen DROP CONSTRAINT fk_observation_numerical_specimen;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen DROP CONSTRAINT result_numerical_specimen_unq;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen RENAME COLUMN observation_phys_chem_specimen_id TO observation_phys_chem_id;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen ADD UNIQUE (observation_phys_chem_id, specimen_id);
ALTER TABLE IF EXISTS core.result_phys_chem_specimen ADD FOREIGN KEY (observation_phys_chem_id) REFERENCES core.observation_phys_chem(observation_phys_chem_id);
DROP TABLE IF EXISTS core.observation_phys_chem_specimen;
