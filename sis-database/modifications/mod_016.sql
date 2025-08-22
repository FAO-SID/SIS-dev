-- OBJECT: multiple
-- ISSUE: Enable update and delete cascade and convert artificial keys to natural keys


-- property_desc_xxxx_id
ALTER TABLE IF EXISTS core.observation_desc_element DROP CONSTRAINT fk_property_desc_element;
ALTER TABLE IF EXISTS core.observation_desc_plot DROP CONSTRAINT fk_property_desc_plot;
ALTER TABLE IF EXISTS core.observation_desc_profile DROP CONSTRAINT fk_property_desc_profile;
ALTER TABLE IF EXISTS core.result_desc_specimen DROP CONSTRAINT result_desc_specimen_property_desc_element_id_thesaurus_de_fkey;
ALTER TABLE IF EXISTS core.result_desc_element DROP CONSTRAINT result_desc_element_property_desc_element_id_thesaurus_des_fkey;
ALTER TABLE IF EXISTS core.result_desc_plot DROP CONSTRAINT result_desc_plot_property_desc_plot_id_thesaurus_desc_plot_fkey;
ALTER TABLE IF EXISTS core.result_desc_surface DROP CONSTRAINT result_desc_surface_property_desc_plot_id_thesaurus_desc_p_fkey;
ALTER TABLE IF EXISTS core.result_desc_profile DROP CONSTRAINT result_desc_profile_property_desc_profile_id_thesaurus_des_fkey;
ALTER TABLE IF EXISTS core.property_desc_element ALTER COLUMN property_desc_element_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.property_desc_plot ALTER COLUMN property_desc_plot_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.property_desc_profile ALTER COLUMN property_desc_profile_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.property_desc_element ALTER COLUMN property_desc_element_id TYPE text USING property_desc_element_id::text;
ALTER TABLE IF EXISTS core.property_desc_plot ALTER COLUMN property_desc_plot_id TYPE text USING property_desc_plot_id::text;
ALTER TABLE IF EXISTS core.property_desc_profile ALTER COLUMN property_desc_profile_id TYPE text USING property_desc_profile_id::text;
ALTER TABLE IF EXISTS core.observation_desc_element ALTER COLUMN property_desc_element_id TYPE text USING property_desc_element_id::text;
ALTER TABLE IF EXISTS core.observation_desc_plot ALTER COLUMN property_desc_plot_id TYPE text USING property_desc_plot_id::text;
ALTER TABLE IF EXISTS core.observation_desc_profile ALTER COLUMN property_desc_profile_id TYPE text USING property_desc_profile_id::text;
ALTER TABLE IF EXISTS core.result_desc_specimen ALTER COLUMN property_desc_element_id TYPE text USING property_desc_element_id::text;
ALTER TABLE IF EXISTS core.result_desc_element ALTER COLUMN property_desc_element_id TYPE text USING property_desc_element_id::text;
ALTER TABLE IF EXISTS core.result_desc_plot ALTER COLUMN property_desc_plot_id TYPE text USING property_desc_plot_id::text;
ALTER TABLE IF EXISTS core.result_desc_surface ALTER COLUMN property_desc_plot_id TYPE text USING property_desc_plot_id::text;
ALTER TABLE IF EXISTS core.result_desc_profile ALTER COLUMN property_desc_profile_id TYPE text USING property_desc_profile_id::text;
ALTER TABLE IF EXISTS core.observation_desc_element ADD FOREIGN KEY (property_desc_element_id) REFERENCES core.property_desc_element(property_desc_element_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.observation_desc_plot ADD FOREIGN KEY (property_desc_plot_id) REFERENCES core.property_desc_plot(property_desc_plot_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.observation_desc_profile ADD FOREIGN KEY (property_desc_profile_id) REFERENCES core.property_desc_profile(property_desc_profile_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.result_desc_specimen ADD FOREIGN KEY (property_desc_element_id,thesaurus_desc_element_id) REFERENCES core.observation_desc_element(property_desc_element_id,thesaurus_desc_element_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.result_desc_element ADD FOREIGN KEY (property_desc_element_id,thesaurus_desc_element_id) REFERENCES core.observation_desc_element(property_desc_element_id,thesaurus_desc_element_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.result_desc_plot ADD FOREIGN KEY (property_desc_plot_id,thesaurus_desc_plot_id) REFERENCES core.observation_desc_plot(property_desc_plot_id,thesaurus_desc_plot_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.result_desc_surface ADD FOREIGN KEY (property_desc_plot_id,thesaurus_desc_plot_id) REFERENCES core.observation_desc_plot(property_desc_plot_id,thesaurus_desc_plot_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS core.result_desc_profile ADD FOREIGN KEY (property_desc_profile_id,thesaurus_desc_profile_id) REFERENCES core.observation_desc_profile(property_desc_profile_id,thesaurus_desc_profile_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
UPDATE core.property_desc_element SET property_desc_element_id = "label";
UPDATE core.property_desc_plot SET property_desc_plot_id = "label";
UPDATE core.property_desc_profile SET property_desc_profile_id = "label";
ALTER TABLE IF EXISTS core.property_desc_element DROP COLUMN IF EXISTS "label";
ALTER TABLE IF EXISTS core.property_desc_plot DROP COLUMN IF EXISTS "label";
ALTER TABLE IF EXISTS core.property_desc_profile DROP COLUMN IF EXISTS "label";


-- procedure_desc_id
ALTER TABLE IF EXISTS core.observation_desc_element DROP CONSTRAINT fk_procedure_desc;
ALTER TABLE IF EXISTS core.observation_desc_plot DROP CONSTRAINT fk_procedure_desc;
ALTER TABLE IF EXISTS core.observation_desc_profile DROP CONSTRAINT fk_procedure_desc;
ALTER TABLE IF EXISTS core.procedure_desc ALTER COLUMN procedure_desc_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.procedure_desc ALTER COLUMN procedure_desc_id TYPE text USING procedure_desc_id::text;
ALTER TABLE IF EXISTS core.observation_desc_element ALTER COLUMN procedure_desc_id TYPE text USING procedure_desc_id::text;
ALTER TABLE IF EXISTS core.observation_desc_plot ALTER COLUMN procedure_desc_id TYPE text USING procedure_desc_id::text;
ALTER TABLE IF EXISTS core.observation_desc_profile ALTER COLUMN procedure_desc_id TYPE text USING procedure_desc_id::text;
ALTER TABLE IF EXISTS core.observation_desc_element ADD FOREIGN KEY (procedure_desc_id) REFERENCES core.procedure_desc(procedure_desc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS core.observation_desc_plot ADD FOREIGN KEY (procedure_desc_id) REFERENCES core.procedure_desc(procedure_desc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS core.observation_desc_profile ADD FOREIGN KEY (procedure_desc_id) REFERENCES core.procedure_desc(procedure_desc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
UPDATE core.procedure_desc SET procedure_desc_id = "label";
ALTER TABLE IF EXISTS core.procedure_desc DROP COLUMN IF EXISTS "label";


-- unit_of_measure_id
ALTER TABLE IF EXISTS core.observation_phys_chem DROP CONSTRAINT fk_unit_of_measure;
ALTER TABLE IF EXISTS core.unit_of_measure ALTER COLUMN unit_of_measure_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.unit_of_measure ALTER COLUMN unit_of_measure_id TYPE text USING unit_of_measure_id::text;
ALTER TABLE IF EXISTS core.observation_phys_chem ALTER COLUMN unit_of_measure_id TYPE text USING unit_of_measure_id::text;
ALTER TABLE IF EXISTS core.observation_phys_chem ADD FOREIGN KEY (unit_of_measure_id) REFERENCES core.unit_of_measure(unit_of_measure_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
UPDATE core.unit_of_measure SET "label" = 'Centimetre per hour' WHERE "label" = 'Centimetre Per Hour';
UPDATE core.unit_of_measure SET "label" = 'Decisiemens per metre' WHERE "label" = 'decisiemens per metre';
UPDATE core.unit_of_measure SET "label" = 'Gram per kilogram' WHERE "label" = 'Gram Per Kilogram';
UPDATE core.unit_of_measure SET "label" = 'Kilogram per cubic decimetre' WHERE "label" = 'Kilogram Per Cubic Decimetre';
UPDATE core.unit_of_measure SET "label" = 'Centimol per litre' WHERE "label" = 'Centimol Per Litre';
UPDATE core.unit_of_measure SET "label" = 'Gram per hectogram' WHERE "label" = 'Gram Per Hectogram';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'cm/h' WHERE "label" = 'Centimetre per hour';
UPDATE core.unit_of_measure SET unit_of_measure_id = '%' WHERE "label" = 'Percent';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'cmol/kg' WHERE "label" = 'Centimole per kilogram';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'dS/m' WHERE "label" = 'Decisiemens per metre';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'g/kg' WHERE "label" = 'Gram per kilogram';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'kg/dm³' WHERE "label" = 'Kilogram per cubic decimetre';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'pH' WHERE "label" = 'Acidity';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'cmol/L' WHERE "label" = 'Centimol per litre';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'g/hg' WHERE "label" = 'Gram per hectogram';
UPDATE core.unit_of_measure SET unit_of_measure_id = 'm³/100 m³' WHERE "label" = 'Cubic metre per one hundred cubic metre';


-- property_phys_chem_id
ALTER TABLE IF EXISTS core.observation_phys_chem DROP CONSTRAINT fk_property_phys_chem;
ALTER TABLE IF EXISTS core.property_phys_chem ALTER COLUMN property_phys_chem_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.property_phys_chem ALTER COLUMN property_phys_chem_id TYPE text USING property_phys_chem_id::text;
ALTER TABLE IF EXISTS core.observation_phys_chem ALTER COLUMN property_phys_chem_id TYPE text USING property_phys_chem_id::text;
ALTER TABLE IF EXISTS core.observation_phys_chem ADD FOREIGN KEY (property_phys_chem_id) REFERENCES core.property_phys_chem(property_phys_chem_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
UPDATE core.property_phys_chem SET property_phys_chem_id = "label";
ALTER TABLE IF EXISTS core.property_phys_chem DROP COLUMN IF EXISTS "label";


-- procedure_phys_chem_id
ALTER TABLE IF EXISTS core.observation_phys_chem DROP CONSTRAINT fk_procedure_phys_chem;
ALTER TABLE IF EXISTS core.procedure_phys_chem DROP CONSTRAINT fk_broader;
ALTER TABLE IF EXISTS core.procedure_phys_chem ALTER COLUMN procedure_phys_chem_id DROP IDENTITY;
ALTER TABLE IF EXISTS core.procedure_phys_chem ALTER COLUMN procedure_phys_chem_id TYPE text USING procedure_phys_chem_id::text;
ALTER TABLE IF EXISTS core.procedure_phys_chem ALTER COLUMN broader_id TYPE text USING broader_id::text;
ALTER TABLE IF EXISTS core.procedure_phys_chem ADD FOREIGN KEY (broader_id) REFERENCES core.procedure_phys_chem(procedure_phys_chem_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS core.observation_phys_chem ALTER COLUMN procedure_phys_chem_id TYPE text USING procedure_phys_chem_id::text;
ALTER TABLE IF EXISTS core.observation_phys_chem ADD FOREIGN KEY (procedure_phys_chem_id) REFERENCES core.procedure_phys_chem(procedure_phys_chem_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
UPDATE core.procedure_phys_chem SET procedure_phys_chem_id = "label";
ALTER TABLE IF EXISTS core.procedure_phys_chem DROP COLUMN IF EXISTS "label";
