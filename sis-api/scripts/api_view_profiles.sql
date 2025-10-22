-- OBJECT: core.vw_api_profiles
-- ISSUE: table to expose thru REST API endpoint (2) the list of profiles


DROP VIEW IF EXISTS core.vw_api_profiles;

CREATE OR REPLACE VIEW core.vw_api_profiles AS
SELECT 
    proj.name AS project_name,
    p.profile_code,
    plt.altitude,
    plt.time_stamp AS date,
    ST_AsGeoJSON(plt."position")::json AS geometry
FROM core.profile p
    INNER JOIN core.plot plt ON p.plot_id = plt.plot_id
    INNER JOIN core.site s ON plt.site_id = s.site_id
    LEFT JOIN core.project_site ps ON s.site_id = ps.site_id
    LEFT JOIN core.project proj ON ps.project_id = proj.project_id
WHERE plt."position" IS NOT NULL
ORDER BY p.profile_id;