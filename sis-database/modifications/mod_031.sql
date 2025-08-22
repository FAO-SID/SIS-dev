-- OBJECT: soil_data.profiles
-- ISSUE: add view with profiles and speciment data for web services

CREATE VIEW soil_data.profiles AS
SELECT 
	r.result_phys_chem_id AS gid,
	p.name AS project_name,
	s.site_id,
	p3.profile_id,
	r.specimen_id, 
	e.upper_depth,
	e.lower_depth,
	o.property_phys_chem_id,
	o.procedure_phys_chem_id,
	r.value,
	o.unit_of_measure_id,
	p2."position" AS geom 
FROM soil_data.project p
LEFT JOIN soil_data.project_site sp ON sp.project_id = p.project_id
LEFT JOIN soil_data.site s ON s.site_id = sp.site_id
LEFT JOIN soil_data.plot p2 ON p2.site_id = s.site_id
LEFT JOIN soil_data.profile p3 ON p3.plot_id = p2.plot_id
LEFT JOIN soil_data."element" e ON e.profile_id = p3.profile_id
LEFT JOIN soil_data.specimen s2 ON s2.element_id = e.element_id
LEFT JOIN soil_data.result_phys_chem r ON r.specimen_id = s2.specimen_id
LEFT JOIN soil_data.observation_phys_chem o ON o.observation_phys_chem_id = r.observation_phys_chem_id 
ORDER BY p.name, s.site_id, p3.profile_id, e.upper_depth, o.property_phys_chem_id;
