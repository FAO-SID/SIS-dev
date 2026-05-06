-- Issue https://github.com/glosis-ld/glosis/issues/200
INSERT INTO soil_data.property_num (property_num_id, property_name, uri) VALUES ('TEXTCLAY','Clay texture fraction', 'http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textclay') ON CONFLICT DO NOTHING;
INSERT INTO soil_data.property_num (property_num_id, property_name, uri) VALUES ('TEXTSAND','Sand texture fraction', 'http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textsand') ON CONFLICT DO NOTHING;
INSERT INTO soil_data.property_num (property_num_id, property_name, uri) VALUES ('TEXTSILT','Silt texture fraction', 'http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textsilt') ON CONFLICT DO NOTHING;
INSERT INTO soil_data.observation_num (property_num_id, unit_of_measure_id, procedure_num_id)
    SELECT pn.property_num_id, um.unit_of_measure_id, proc.procedure_num_id
        FROM soil_data.property_num pn
        CROSS JOIN soil_data.procedure_num proc
        JOIN soil_data.unit_of_measure um ON um.uri = 'http://qudt.org/vocab/unit/PERCENT'
        WHERE pn.uri LIKE 'http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Text%'
          AND proc.uri LIKE 'http://w3id.org/glosis/model/procedure/pSAProcedure%'
           ON CONFLICT DO NOTHING;

-- Issue https://github.com/glosis-ld/glosis/issues/216
INSERT INTO soil_data.property_num (property_num_id, property_name, uri) VALUES ('BULDWHOLE','Bulk Density whole soil', 'http://w3id.org/glosis/model/layerhorizon/bulkDensityWholeSoilProperty') ON CONFLICT DO NOTHING;
UPDATE soil_data.observation_num SET property_num_id = 'BULDWHOLE' WHERE procedure_num_id ILIKE 'BlkDensW%';

-- Issue https://github.com/glosis-ld/glosis/issues/215
UPDATE soil_data.property_num SET property_name = 'Coarse Fragments' WHERE property_num_id = 'COAFRA';

-- Pretifying property names, camel case to space
UPDATE soil_data.property_desc SET property_name = regexp_replace(property_name, '([a-z])([A-Z])', '\1 \2', 'g');

-- Fix uri
UPDATE soil_data.unit_of_measure SET uri = 'https://qudt.org/vocab/unit/CentiMOL-PER-L.html' WHERE uri = 'https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/centimolePerLitre';
UPDATE soil_data.unit_of_measure SET uri = 'http://qudt.org/vocab/unit/GM-PER-HectoGM' WHERE uri = 'https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/gramPerHectogram';

-- Pretifying unit names
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cm/h',       unit_name = 'Centimetre per hour',                      unit_type = 'Rate'              WHERE uri = 'http://qudt.org/vocab/unit/CentiM-PER-HR';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = '%',          unit_name = 'Percent',                                  unit_type = 'Dimensionless'     WHERE uri = 'http://qudt.org/vocab/unit/PERCENT';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cmol(c)/kg', unit_name = 'Centimole per kilogram',                   unit_type = 'Charge per mass'   WHERE uri = 'http://qudt.org/vocab/unit/CentiMOL-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'dS/m',       unit_name = 'Decisiemens per metre',                    unit_type = 'Conductivity'      WHERE uri = 'http://qudt.org/vocab/unit/DeciS-PER-M';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'g/kg',       unit_name = 'Gram per kilogram',                        unit_type = 'Mass fraction'     WHERE uri = 'http://qudt.org/vocab/unit/GM-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'kg/dm³',     unit_name = 'Kilogram per cubic decimetre',             unit_type = 'Density'           WHERE uri = 'http://qudt.org/vocab/unit/KiloGM-PER-DeciM3';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'pH',         unit_name = 'Acidity',                                  unit_type = 'Dimensionless'     WHERE uri = 'http://qudt.org/vocab/unit/PH';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'm³/100m³',   unit_name = 'Cubic metre per one hundred cubic metre',  unit_type = 'Volume fraction'   WHERE uri = 'http://w3id.org/glosis/model/unit/M3-PER-HundredM3';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'mg/kg',      unit_name = 'Miligram per kilogram (also ppm)',         unit_type = 'Mass fraction'     WHERE uri = 'http://qudt.org/vocab/unit/MilliGM-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cmol(c)/L',  unit_name = 'Centimole per litre',                      unit_type = 'Charge per volume' WHERE uri = 'https://qudt.org/vocab/unit/CentiMOL-PER-L.html';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'g/100g',     unit_name = 'Gram per hundred grams',                   unit_type = 'Mass fraction'     WHERE uri = 'http://qudt.org/vocab/unit/GM-PER-HectoGM';

-- Add units
INSERT INTO soil_data.unit_of_measure (unit_of_measure_id, unit_name, unit_type, uri) VALUES
  ('t/(ha·a)',     'Tonne per hectare per year',              'Areal mass rate',   'https://qudt.org/vocab/unit/TONNE-PER-HA-YR'),
  ('class',        'Categorical',                             'Dimensionless',     'https://qudt.org/vocab/unit/class'),
  ('dimensionless','No dimension',                            'Dimensionless',     'https://qudt.org/vocab/unit/dimensionless'),
  ('cm',           'Centimetre',                              'Length',            'http://qudt.org/vocab/unit/CentiM'),
  ('m',            'Metre',                                   'Length',            'http://qudt.org/vocab/unit/M'),
  ('in',           'Inch',                                    'Length',            'http://qudt.org/vocab/unit/IN'),
  ('ft',           'Foot',                                    'Length',            'http://qudt.org/vocab/unit/FT'),
  ('mg/100g',      'Milligram per hundred grams',             'Mass fraction',     'http://qudt.org/vocab/unit/MilliGM-PER-HectoGM'),
  ('ppm',          'Parts per million',                       'Mass fraction',     'http://qudt.org/vocab/unit/PPM'),
  ('cm³/100cm³',   'Cubic centimetre per hundred cubic centimetre', 'Volume fraction', 'http://w3id.org/glosis/model/unit/CentiM3-PER-HundredCentiM3'),
  ('cm³/cm³',      'Cubic centimetre per cubic centimetre',   'Volume fraction',   'http://qudt.org/vocab/unit/CentiM3-PER-CentiM3'),
  ('m³/m³',        'Cubic metre per cubic metre',             'Volume fraction',   'http://qudt.org/vocab/unit/M3-PER-M3'),
  ('mmol(c)/kg',   'Millimole of charge per kilogram',        'Charge per mass',   'http://w3id.org/glosis/model/unit/MilliMOL-C-PER-KiloGM'),
  ('meq/100g',     'Milliequivalent per hundred grams',       'Charge per mass',   'http://w3id.org/glosis/model/unit/MilliEQ-PER-HectoGM'),
  ('mmol(c)/100g', 'Millimole of charge per hundred grams',   'Charge per mass',   'http://w3id.org/glosis/model/unit/MilliMOL-C-PER-HectoGM'),
  ('mS/cm',        'Millisiemens per centimetre',             'Conductivity',      'http://qudt.org/vocab/unit/MilliS-PER-CentiM'),
  ('S/m',          'Siemens per metre',                       'Conductivity',      'http://qudt.org/vocab/unit/S-PER-M'),
  ('µS/cm',        'Microsiemens per centimetre',             'Conductivity',      'http://qudt.org/vocab/unit/MicroS-PER-CentiM'),
  ('g/cm³',        'Gram per cubic centimetre',               'Density',           'http://qudt.org/vocab/unit/GM-PER-CentiM3'),
  ('g/dm³',        'Gram per cubic decimetre',                'Density',           'http://qudt.org/vocab/unit/GM-PER-DeciM3'),
  ('mmol(c)/L',    'Millimole of charge per litre',           'Charge per volume', 'http://w3id.org/glosis/model/unit/MilliMOL-C-PER-L'),
  ('mol(c)/L',     'Mole of charge per litre',                'Charge per volume', 'http://w3id.org/glosis/model/unit/MOL-C-PER-L'),
  ('meq/L',        'Milliequivalent per litre',               'Charge per volume', 'http://w3id.org/glosis/model/unit/MilliEQ-PER-L'),
  ('µmol(c)/L',    'Micromole of charge per litre',           'Charge per volume', 'http://w3id.org/glosis/model/unit/MicroMOL-C-PER-L'),
  ('mm/h',         'Millimetre per hour',                     'Rate',              'http://qudt.org/vocab/unit/MilliM-PER-HR'),
  ('mm/day',       'Millimetre per day',                      'Rate',              'http://qudt.org/vocab/unit/MilliM-PER-DAY'),
  ('cm/day',       'Centimetre per day',                      'Rate',              'http://qudt.org/vocab/unit/CentiM-PER-DAY'),
  ('m/day',        'Metre per day',                           'Rate',              'http://qudt.org/vocab/unit/M-PER-DAY'),
  ('in/h',         'Inch per hour',                           'Rate',              'http://qudt.org/vocab/unit/IN-PER-HR');

-- Trace element extractables: % → mg/kg
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'BOREXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'COPEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'IROEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'MANEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'MOL'    AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'ZINEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'SULEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'CAD'    AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'mg/kg' WHERE property_num_id = 'PHOEXT' AND unit_of_measure_id = '%';
-- Major cation extractables: % → cmol(c)/kg
UPDATE soil_data.observation_num SET unit_of_measure_id = 'cmol(c)/kg' WHERE property_num_id = 'CALEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'cmol(c)/kg' WHERE property_num_id = 'MAGEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'cmol(c)/kg' WHERE property_num_id = 'POTEXT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'cmol(c)/kg' WHERE property_num_id = 'SODEXT' AND unit_of_measure_id = '%';
-- MANTOT: dimensional error — delete the cmol(c)/kg rows entirely
DELETE FROM soil_data.observation_num WHERE property_num_id = 'MANTOT' AND unit_of_measure_id = 'cmol(c)/kg';
-- Switch to g/100g (mass fraction): texture fractions and gypsum
UPDATE soil_data.observation_num SET unit_of_measure_id = 'g/100g' WHERE property_num_id = 'TEXTCLAY' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'g/100g' WHERE property_num_id = 'TEXTSAND' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'g/100g' WHERE property_num_id = 'TEXTSILT' AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'g/100g' WHERE property_num_id = 'GYP'      AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'g/100g'   WHERE property_num_id = 'COAFRA'   AND procedure_num_id = 'CRSFRG_LAB'    AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'm³/100m³' WHERE property_num_id = 'COAFRA'   AND procedure_num_id = 'CRSFRG_FLD'    AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET unit_of_measure_id = 'm³/100m³' WHERE property_num_id = 'COAFRA'   AND procedure_num_id = 'CRSFRG_FLDCLS' AND unit_of_measure_id = '%';

-- value_min/value_max, as sanity bounds for rejecting values that are physically impossible or off by orders of magnitude
-- typical_min/typical_max for science-meaningful bounds (5th–95th percentile of typical agricultural soils)
-- Percentages
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0,    typical_max = 100   WHERE property_num_id = 'BASCAL'   AND unit_of_measure_id = '%';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0,    typical_max = 100   WHERE property_num_id = 'PHORET'   AND unit_of_measure_id = '%';
-- Mix
UPDATE soil_data.observation_num SET value_min = 0, value_max = 100, typical_min = 0, typical_max = 80 WHERE property_num_id = 'COAFRA' AND procedure_num_id = 'CRSFRG_LAB'    AND unit_of_measure_id = 'g/100g';
UPDATE soil_data.observation_num SET value_min = 0, value_max = 100, typical_min = 0, typical_max = 80 WHERE property_num_id = 'COAFRA' AND procedure_num_id = 'CRSFRG_FLD'    AND unit_of_measure_id = 'm³/100m³';
UPDATE soil_data.observation_num SET value_min = 0, value_max = 100, typical_min = 0, typical_max = 80 WHERE property_num_id = 'COAFRA' AND procedure_num_id = 'CRSFRG_FLDCLS' AND unit_of_measure_id = 'm³/100m³';
-- Hydraulic conductivity (cm/h)
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 5000,   typical_min = 0.01, typical_max = 100   WHERE property_num_id = 'HYDCOND'  AND unit_of_measure_id = 'cm/h';
-- Charge per mass (cmol(c)/kg)
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 30,     typical_min = 0,    typical_max = 10    WHERE property_num_id = 'ACIEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 20,     typical_min = 0,    typical_max = 5     WHERE property_num_id = 'ALUEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 150,    typical_min = 0.1,  typical_max = 40    WHERE property_num_id = 'CALEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 150,    typical_min = 0.1,  typical_max = 40    WHERE property_num_id = 'CALEXT'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 200,    typical_min = 1,    typical_max = 60    WHERE property_num_id = 'CEC'      AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 200,    typical_min = 1,    typical_max = 50    WHERE property_num_id = 'ECEC'     AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 30,     typical_min = 0,    typical_max = 5     WHERE property_num_id = 'HYDEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 50,     typical_min = 0.05, typical_max = 15    WHERE property_num_id = 'MAGEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 50,     typical_min = 0.05, typical_max = 15    WHERE property_num_id = 'MAGEXT'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 30,     typical_min = 0.02, typical_max = 5     WHERE property_num_id = 'POTEXC'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 30,     typical_min = 0.02, typical_max = 5     WHERE property_num_id = 'POTEXT'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0,    typical_max = 30    WHERE property_num_id = 'SODEXP'   AND unit_of_measure_id = 'cmol(c)/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0,    typical_max = 30    WHERE property_num_id = 'SODEXT'   AND unit_of_measure_id = 'cmol(c)/kg';
-- Charge per volume (cmol(c)/L)
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 0,    typical_max = 200   WHERE property_num_id = 'SOLSAL'   AND unit_of_measure_id = 'cmol(c)/L';
-- Conductivity (dS/m)
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 200,    typical_min = 0,    typical_max = 16    WHERE property_num_id = 'ELECCOND' AND unit_of_measure_id = 'dS/m';
-- Bulk density (kg/dm³)
UPDATE soil_data.observation_num SET value_min = 0.1, value_max = 2.5,    typical_min = 0.8,  typical_max = 1.8   WHERE property_num_id = 'BULDFINE' AND unit_of_measure_id = 'kg/dm³';
UPDATE soil_data.observation_num SET value_min = 0.1, value_max = 2.5,    typical_min = 0.8,  typical_max = 1.8   WHERE property_num_id = 'BULDWHOLE' AND unit_of_measure_id = 'kg/dm³';
-- Volume fractions (m³/100m³)
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 60,     typical_min = 3,    typical_max = 40    WHERE property_num_id = 'AVAVOL'   AND unit_of_measure_id = 'm³/100m³';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 90,     typical_min = 30,   typical_max = 70    WHERE property_num_id = 'POR'      AND unit_of_measure_id = 'm³/100m³';
-- Mass fractions in mg/kg
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 500000, typical_min = 10000, typical_max = 200000 WHERE property_num_id = 'ALUTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0.1,  typical_max = 5     WHERE property_num_id = 'BOREXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 500,    typical_min = 1,    typical_max = 100   WHERE property_num_id = 'BORTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 0,    typical_max = 3     WHERE property_num_id = 'CAD'     AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 500000, typical_min = 1000, typical_max = 100000 WHERE property_num_id = 'CALTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 0.1,  typical_max = 20    WHERE property_num_id = 'COPEXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 5000,   typical_min = 1,    typical_max = 100   WHERE property_num_id = 'COPTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 5000,   typical_min = 1,    typical_max = 200   WHERE property_num_id = 'IROEXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 500000, typical_min = 1000, typical_max = 100000 WHERE property_num_id = 'IROTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100000, typical_min = 500,  typical_max = 30000 WHERE property_num_id = 'MAGTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 5000,   typical_min = 1,    typical_max = 200   WHERE property_num_id = 'MANEXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 50000,  typical_min = 50,   typical_max = 3000  WHERE property_num_id = 'MANTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 500,    typical_min = 0,    typical_max = 5     WHERE property_num_id = 'MOL'     AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 1,    typical_max = 200   WHERE property_num_id = 'PHOEXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 10000,  typical_min = 100,  typical_max = 2000  WHERE property_num_id = 'PHOTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 50000,  typical_min = 1000, typical_max = 30000 WHERE property_num_id = 'POTTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 50000,  typical_min = 100,  typical_max = 20000 WHERE property_num_id = 'SODTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 1,    typical_max = 50    WHERE property_num_id = 'SULEXT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 10000,  typical_min = 50,   typical_max = 1000  WHERE property_num_id = 'SULTOT'  AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 10000,  typical_min = 10,   typical_max = 300   WHERE property_num_id = 'ZIN'     AND unit_of_measure_id = 'mg/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 0.5,  typical_max = 50    WHERE property_num_id = 'ZINEXT'  AND unit_of_measure_id = 'mg/kg';
-- Mass fractions in g/kg
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 0,    typical_max = 800   WHERE property_num_id = 'CCETOT'   AND unit_of_measure_id = 'g/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 200,    typical_min = 0,    typical_max = 100   WHERE property_num_id = 'CARINORG' AND unit_of_measure_id = 'g/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 600,    typical_min = 1,    typical_max = 80    WHERE property_num_id = 'CARORG'   AND unit_of_measure_id = 'g/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 600,    typical_min = 1,    typical_max = 100   WHERE property_num_id = 'CARTOT'   AND unit_of_measure_id = 'g/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0.1,  typical_max = 8     WHERE property_num_id = 'NITTOT'   AND unit_of_measure_id = 'g/kg';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 1000,   typical_min = 1,    typical_max = 150   WHERE property_num_id = 'ORGMAT'   AND unit_of_measure_id = 'g/kg';
-- Mass fractions in g/100g
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 0,    typical_max = 60    WHERE property_num_id = 'GYP'      AND unit_of_measure_id = 'g/100g';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 5,    typical_max = 95    WHERE property_num_id = 'TEXTSAND' AND unit_of_measure_id = 'g/100g';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 5,    typical_max = 80    WHERE property_num_id = 'TEXTSILT' AND unit_of_measure_id = 'g/100g';
UPDATE soil_data.observation_num SET value_min = 0,   value_max = 100,    typical_min = 1,    typical_max = 80    WHERE property_num_id = 'TEXTCLAY' AND unit_of_measure_id = 'g/100g';
-- pH
UPDATE soil_data.observation_num SET value_min = 2,   value_max = 12,     typical_min = 4,    typical_max = 8.5   WHERE property_num_id = 'PH'       AND unit_of_measure_id = 'pH';

-- Add unit conversions
INSERT INTO soil_data.unit_conversion (unit_from, operation, value, unit_to) VALUES
  ('in',           '*',     2.54,  'cm'),
  ('ft',           '*',    30.48,  'cm'),
  ('%',            '*',      1.0,  'm³/100m³'),
  ('cm³/cm³',      '*',    100.0,  'm³/100m³'),
  ('m³/m³',        '*',    100.0,  'm³/100m³'),
  ('cm³/100cm³',   '*',      1.0,  'm³/100m³'),
  ('g/cm³',        '*',      1.0,  'kg/dm³'),
  ('g/dm³',        '/',   1000.0,  'kg/dm³'),
  ('mmol(c)/kg',   '/',     10.0,  'cmol(c)/kg'),
  ('meq/100g',     '*',      1.0,  'cmol(c)/kg'),
  ('mmol(c)/100g', '*',     10.0,  'cmol(c)/kg'),
  ('mmol(c)/L',    '/',     10.0,  'cmol(c)/L'),
  ('mol(c)/L',     '*',    100.0,  'cmol(c)/L'),
  ('meq/L',        '*',      1.0,  'cmol(c)/L'),
  ('µmol(c)/L',    '/',  10000.0,  'cmol(c)/L'),
  ('mS/cm',        '*',      1.0,  'dS/m'),
  ('S/m',          '*',     10.0,  'dS/m'),
  ('µS/cm',        '/',   1000.0,  'dS/m'),
  ('%',            '*',     10.0,  'g/kg'),
  ('ppm',          '/',   1000.0,  'g/kg'),
  ('g/100g',       '*',     10.0,  'g/kg'),
  ('mg/kg',        '/',   1000.0,  'g/kg'),
  ('mg/100g',      '/',    100.0,  'g/kg'),
  ('%',            '*',      1.0,  'g/100g'),
  ('ppm',          '/',  10000.0,  'g/100g'),
  ('g/kg',         '/',     10.0,  'g/100g'),
  ('mg/kg',        '/',  10000.0,  'g/100g'),
  ('mg/100g',      '/',   1000.0,  'g/100g'),
  ('%',            '*',  10000.0,  'mg/kg'),
  ('ppm',          '*',      1.0,  'mg/kg'),
  ('g/100g',       '*',  10000.0,  'mg/kg'),
  ('g/kg',         '*',   1000.0,  'mg/kg'),
  ('mg/100g',      '*',     10.0,  'mg/kg'),
  ('mm/h',         '/',     10.0,  'cm/h'),
  ('mm/day',       '/',    240.0,  'cm/h'),
  ('cm/day',       '/',     24.0,  'cm/h'),
  ('m/day',        '*',   4.1667,  'cm/h'),
  ('in/h',         '*',     2.54,  'cm/h');

-- Add correct source reference
UPDATE soil_data.observation_desc SET procedure_desc_id = 'ISRIC Report 2019/01' WHERE property_desc_id = 'fragmentsClassProperty';

