-- OBJECT: core.element and specimen
-- ISSUE: specimen is child of element and not of plot


ALTER TABLE IF EXISTS core.specimen DROP CONSTRAINT fk_plot;
ALTER TABLE IF EXISTS core.specimen RENAME COLUMN plot_id TO element_id;
ALTER TABLE IF EXISTS core.specimen ADD FOREIGN KEY (element_id) REFERENCES core.element(element_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.element DROP COLUMN organisation_id;
DROP TABLE core.result_desc_specimen;
DROP TABLE core.result_phys_chem_element;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen RENAME TO result_phys_chem;
ALTER TABLE IF EXISTS core.result_phys_chem RENAME COLUMN result_phys_chem_specimen_id TO result_phys_chem_id;
