-- OBJECT: multiple
-- ISSUE: data type numeric is used with no precision specified. Use smallint (-32768 to +32767) instead


ALTER TABLE IF EXISTS core.plot ALTER COLUMN altitude TYPE smallint;
ALTER TABLE IF EXISTS core.plot ALTER COLUMN positional_accuracy TYPE smallint;
ALTER TABLE IF EXISTS core.result_phys_chem_element ALTER COLUMN value TYPE real;
ALTER TABLE IF EXISTS core.result_phys_chem_specimen ALTER COLUMN value TYPE real;
ALTER TABLE IF EXISTS core.observation_phys_chem_element ALTER COLUMN value_min TYPE real;
ALTER TABLE IF EXISTS core.observation_phys_chem_element ALTER COLUMN value_max TYPE real;
ALTER TABLE IF EXISTS core.observation_phys_chem_specimen ALTER COLUMN value_min TYPE real;
ALTER TABLE IF EXISTS core.observation_phys_chem_specimen ALTER COLUMN value_max TYPE real;
