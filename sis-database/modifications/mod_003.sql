-- OBJECT: multiple
-- ISSUE: 23 column without a COMMENT


-- SELECT
--     c.table_catalog,
--     c.table_schema,
--     c.table_name,
--     c.column_name,
--     d.description
-- FROM pg_catalog.pg_statio_all_tables st
-- LEFT JOIN information_schema.columns c
-- 	ON c.table_schema = st.schemaname
-- 	AND c.table_name = st.relname
-- LEFT JOIN pg_catalog.pg_description d
-- 	ON d.objoid = st.relid
-- 	AND d.objsubid = c.ordinal_position
-- WHERE table_catalog = 'iso28258'
--   AND c.table_schema IN ('metadata', 'core')
--   AND d.description IS NULL
-- ORDER BY 1,2,3,4;

-- https://stackoverflow.com/questions/48137309/postgresql-if-exists-comment-on-table

DO $$
BEGIN
  IF EXISTS (SELECT relname FROM pg_class WHERE relname='observation_desc_element') THEN
    COMMENT ON COLUMN core.observation_desc_element.procedure_desc_id IS 'Foreign key to the corresponding procedure.';
  END IF;

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='observation_desc_plot') THEN
    COMMENT ON COLUMN core.observation_desc_plot.procedure_desc_id IS 'Foreign key to the corresponding procedure.';
  END IF;

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='observation_desc_profile') THEN
    COMMENT ON COLUMN core.observation_desc_profile.procedure_desc_id IS 'Foreign key to the corresponding procedure.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='observation_desc_specimen') THEN
    COMMENT ON COLUMN core.observation_desc_specimen.procedure_desc_id IS 'Foreign key to the corresponding procedure.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='observation_desc_surface') THEN
    COMMENT ON COLUMN core.observation_desc_surface.procedure_desc_id IS 'Foreign key to the corresponding procedure.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='plot') THEN
    COMMENT ON COLUMN core.plot.positional_accuracy IS 'Accuracy in meters of the GPS position.';
    COMMENT ON COLUMN core.plot.site_id IS 'Foreign key to Site table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='project_organisation') THEN
    COMMENT ON COLUMN core.project_organisation.organisation_id IS 'Foreign key to Organisation table.';
    COMMENT ON COLUMN core.project_organisation.project_id IS 'Foreign key to Project table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_desc_element') THEN
    COMMENT ON COLUMN core.result_desc_element.property_desc_element_id IS 'Foreign key to property_desc_element table.';
    COMMENT ON COLUMN core.result_desc_element.thesaurus_desc_element_id IS 'Foreign key to thesaurus_desc_element table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_desc_plot') THEN
    COMMENT ON COLUMN core.result_desc_plot.property_desc_plot_id IS 'Foreign key to property_desc_plot table.';
    COMMENT ON COLUMN core.result_desc_plot.thesaurus_desc_plot_id IS 'Foreign key to thesaurus_desc_plot table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_desc_profile') THEN
    COMMENT ON COLUMN core.result_desc_profile.property_desc_profile_id IS 'Foreign key to property_desc_profile table.';
    COMMENT ON COLUMN core.result_desc_profile.thesaurus_desc_profile_id IS 'Foreign key to thesaurus_desc_profile table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_desc_surface') THEN
    COMMENT ON COLUMN core.result_desc_surface.property_desc_surface_id IS 'Foreign key to property_desc_surface table.';
    COMMENT ON COLUMN core.result_desc_surface.thesaurus_desc_surface_id IS 'Foreign key to thesaurus_desc_surface table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_phys_chem_element') THEN
    COMMENT ON COLUMN core.result_phys_chem_element.individual_id IS 'Foreign key to Individual table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='result_phys_chem_specimen') THEN
    COMMENT ON COLUMN core.result_phys_chem_specimen.organisation_id IS 'Foreign key to Organisation table.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='surface') THEN
    COMMENT ON COLUMN core.surface.super_surface_id IS 'Hierarchical relation between surfaces.';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='address') THEN
    COMMENT ON COLUMN metadata.address.country IS 'Equivalent to the country data property in VCard, e.g. "The Netherlands".';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='individual') THEN
    COMMENT ON COLUMN metadata.individual.telephone IS 'Equivalent to the telephone data property in VCard, e.g. "0031 961000789".';
  END IF;


  IF EXISTS (SELECT relname FROM pg_class WHERE relname='organisation') THEN
    COMMENT ON COLUMN metadata.organisation.telephone IS 'Equivalent to the telephone data property in VCard, e.g. "0031 961000787".';
  END IF;

END $$;
