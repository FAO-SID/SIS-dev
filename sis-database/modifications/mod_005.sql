-- OBJECT: core.specimen.organisation_id
-- ISSUE: COMMENT does not coincide with the column name


ALTER TABLE IF EXISTS core.result_phys_chem_specimen RENAME COLUMN organisation_id TO individual_id;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen DROP CONSTRAINT fk_organisation;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen ADD FOREIGN KEY (individual_id) REFERENCES metadata.individual(individual_id);

ALTER TABLE IF EXISTS core.element ADD COLUMN organisation_id integer;
ALTER TABLE IF EXISTS core.element ADD FOREIGN KEY (organisation_id) REFERENCES metadata.organisation(organisation_id);

DO $$
BEGIN

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='element') THEN
    COMMENT ON COLUMN core.element.organisation_id IS 'Organisation that is responsible for, or carried out, the process that produced this result.';
  END IF;

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_phys_chem_element') THEN
    COMMENT ON COLUMN core.result_phys_chem_element.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';
  END IF;

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='specimen') THEN
    COMMENT ON COLUMN core.specimen.organisation_id IS 'Organisation that is responsible for, or carried out, the process that produced this result.';
  END IF;

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_phys_chem_specimen') THEN
    COMMENT ON COLUMN core.result_phys_chem_specimen.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';
  END IF;

END $$;
