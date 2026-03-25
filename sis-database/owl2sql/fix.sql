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

-- Pretifying unit names
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cm/h', unit_name = 'Centimetre per hour' WHERE uri = 'http://qudt.org/vocab/unit/CentiM-PER-HR';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = '%', unit_name = 'Percent' WHERE uri = 'http://qudt.org/vocab/unit/PERCENT';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cmol/kg', unit_name = 'Centimole per kilogram' WHERE uri = 'http://qudt.org/vocab/unit/CentiMOL-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'dS/m', unit_name = 'Decisiemens per metre' WHERE uri = 'http://qudt.org/vocab/unit/DeciS-PER-M';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'g/kg', unit_name = 'Gram per kilogram' WHERE uri = 'http://qudt.org/vocab/unit/GM-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'kg/dm³', unit_name = 'Kilogram per cubic decimetre' WHERE uri = 'http://qudt.org/vocab/unit/KiloGM-PER-DeciM3';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'pH', unit_name = 'Acidity' WHERE uri = 'http://qudt.org/vocab/unit/PH';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cmol/L', unit_name = 'Centimol per litre' WHERE uri = 'http://w3id.org/glosis/model/unit/CentiMOL-PER-L';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'g/hg', unit_name = 'Gram per hectogram' WHERE uri = 'http://w3id.org/glosis/model/unit/GM-PER-HectoGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'm³/100 m³', unit_name = 'Cubic metre per one hundred cubic metre' WHERE uri = 'http://w3id.org/glosis/model/unit/M3-PER-HundredM3';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'mg/kg', unit_name = 'Miligram per kilogram (also ppm)' WHERE uri = 'http://qudt.org/vocab/unit/MilliGM-PER-KiloGM';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'cmol/L', unit_name = 'Centimole per litre' WHERE uri = 'https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/centimolePerLitre';
UPDATE soil_data.unit_of_measure SET unit_of_measure_id = 'g/hg', unit_name = 'Gram per hectogram' WHERE uri = 'https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/gramPerHectogram';

-- Add units
INSERT INTO soil_data.unit_of_measure (unit_of_measure_id, unit_name, uri) 
VALUES  ('t/(ha·a)', 'Tonne per hectare per year', 'https://qudt.org/vocab/unit/TONNE-PER-HA-YR'),
        ('class', 'Categorical', 'https://qudt.org/vocab/unit/class'),
        ('dimensionless', 'No dimension', 'https://qudt.org/vocab/unit/dimensionless');

-- Add correct source reference
UPDATE soil_data.observation_desc SET procedure_desc_id = 'ISRIC Report 2019/01' WHERE property_desc_id = 'fragmentsClassProperty';
