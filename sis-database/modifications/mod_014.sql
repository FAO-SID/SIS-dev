-- OBJECT: core.observation_desc_specimen, observation_desc_element
-- ISSUE: redundancy between these two tables


ALTER TABLE IF EXISTS core.result_desc_specimen DROP CONSTRAINT result_desc_specimen_property_desc_specimen_id_thesaurus_d_fkey;
ALTER TABLE IF EXISTS core.result_desc_specimen RENAME COLUMN property_desc_specimen_id TO property_desc_element_id;
ALTER TABLE IF EXISTS core.result_desc_specimen RENAME COLUMN thesaurus_desc_specimen_id TO thesaurus_desc_element_id;

ALTER TABLE IF EXISTS core.result_desc_specimen ADD FOREIGN KEY (property_desc_element_id,thesaurus_desc_element_id) REFERENCES core.observation_desc_element(property_desc_element_id,thesaurus_desc_element_id);

DROP TABLE IF EXISTS core.observation_desc_specimen;
DROP TABLE IF EXISTS core.property_desc_specimen;
DROP TABLE IF EXISTS core.thesaurus_desc_specimen;
