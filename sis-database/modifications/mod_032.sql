-- OBJECT: soil_data.unit_of_measure
-- ISSUE: add units


INSERT INTO soil_data.unit_of_measure (unit_of_measure_id, label, uri)
 VALUES
	('mg/kg','Miligram per kilogram (also ppm)','http://qudt.org/vocab/unit/MilliGM-PER-KiloGM'),
	('t/(ha·a)','Tonne per hectare year','https://qudt.org/vocab/unit/TONNE-PER-HA-YR'),
	('class','categorical','https://qudt.org/vocab/unit/class'),
	('dimensionless','no dimension','https://qudt.org/vocab/unit/dimensionless');
