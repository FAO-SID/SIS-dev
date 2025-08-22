-- OBJECT: observation_phys_chem
-- ISSUE: add min and max values

UPDATE core.observation_phys_chem SET value_min = 1.5, value_max = 13 WHERE unit_of_measure_id = 'pH';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 60 WHERE unit_of_measure_id = 'dS/m';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE unit_of_measure_id = '%';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE unit_of_measure_id = 'cm/h';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE unit_of_measure_id = 'g/hg';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE unit_of_measure_id = 'm³/100 m³';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 1000 WHERE unit_of_measure_id = 'g/kg';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 1000 WHERE unit_of_measure_id = 'cmol/L';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 1000 WHERE unit_of_measure_id = 'cmol/kg';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE property_phys_chem_id ILIKE '%exchangeable%' AND unit_of_measure_id = 'cmol/kg';
UPDATE core.observation_phys_chem SET value_min = 0, value_max = 100 WHERE property_phys_chem_id = 'effectiveCecProperty';
UPDATE core.observation_phys_chem SET value_min = 0.01, value_max = 2.65 WHERE property_phys_chem_id = 'bulkDensityFineEarthProperty';
UPDATE core.observation_phys_chem SET value_min = 0.01, value_max = 3.60 WHERE property_phys_chem_id = 'bulkDensityWholeSoilProperty';
