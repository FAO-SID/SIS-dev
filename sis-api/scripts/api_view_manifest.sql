-- OBJECT: core.api_manifest
-- ISSUE: table to expose thru REST API endpoint (1) the available data in the SIS

DROP VIEW IF EXISTS core.vw_api_manifest;

CREATE OR REPLACE VIEW core.vw_api_manifest AS
SELECT 
    'Portugal SIS' AS sis,
    opc.property_phys_chem_id AS property,
    COUNT(DISTINCT p.profile_id) AS profiles,
    COUNT(rpc.result_phys_chem_id) AS observations,
    ST_Envelope(ST_Collect(plt."position")) AS geom
FROM core.observation_phys_chem opc
    INNER JOIN core.result_phys_chem rpc ON opc.observation_phys_chem_id = rpc.observation_phys_chem_id
    INNER JOIN core.specimen s ON rpc.specimen_id = s.specimen_id
    INNER JOIN core.element e ON s.element_id = e.element_id
    INNER JOIN core.profile p ON e.profile_id = p.profile_id
    INNER JOIN core.plot plt ON p.plot_id = plt.plot_id
GROUP BY opc.property_phys_chem_id
ORDER BY opc.property_phys_chem_id;
