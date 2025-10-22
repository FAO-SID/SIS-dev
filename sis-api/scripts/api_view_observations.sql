-- OBJECT: core.vw_api_observations
-- ISSUE: table to expose thru REST API endpoint (3) the observational data


DROP VIEW IF EXISTS core.vw_api_observations;

CREATE OR REPLACE VIEW core.vw_api_observations AS
SELECT p3.profile_code,
    e.upper_depth,
    e.lower_depth,
    o.property_phys_chem_id,
    o.procedure_phys_chem_id,
    o.unit_of_measure_id,
    r.value
   FROM core.project p
     LEFT JOIN core.project_site sp ON sp.project_id = p.project_id
     LEFT JOIN core.site s ON s.site_id = sp.site_id
     LEFT JOIN core.plot p2 ON p2.site_id = s.site_id
     LEFT JOIN core.profile p3 ON p3.plot_id = p2.plot_id
     LEFT JOIN core.element e ON e.profile_id = p3.profile_id
     LEFT JOIN core.specimen s2 ON s2.element_id = e.element_id
     LEFT JOIN core.result_phys_chem r ON r.specimen_id = s2.specimen_id
     LEFT JOIN core.observation_phys_chem o ON o.observation_phys_chem_id = r.observation_phys_chem_id
  ORDER BY p3.profile_code, e.upper_depth, o.property_phys_chem_id;