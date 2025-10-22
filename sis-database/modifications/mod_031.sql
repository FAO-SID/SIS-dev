-- OBJECT: soil_data.profiles
-- ISSUE: tables for REST API endpoint


-- view to expose the available data in the SIS
CREATE OR REPLACE VIEW soil_data.vw_api_manifest AS
SELECT 
    'Portugal SIS' AS sis,
    opc.property_phys_chem_id AS property,
    COUNT(DISTINCT p.profile_id) AS profiles,
    COUNT(rpc.result_phys_chem_id) AS observations,
    ST_Envelope(ST_Collect(plt."position")) AS geom
FROM soil_data.observation_phys_chem opc
    INNER JOIN soil_data.result_phys_chem rpc ON opc.observation_phys_chem_id = rpc.observation_phys_chem_id
    INNER JOIN soil_data.specimen s ON rpc.specimen_id = s.specimen_id
    INNER JOIN soil_data.element e ON s.element_id = e.element_id
    INNER JOIN soil_data.profile p ON e.profile_id = p.profile_id
    INNER JOIN soil_data.plot plt ON p.plot_id = plt.plot_id
GROUP BY opc.property_phys_chem_id
ORDER BY opc.property_phys_chem_id;


-- view to expose the list of profiles
CREATE OR REPLACE VIEW soil_data.vw_api_profiles AS
SELECT 
    proj.name AS project_name,
    p.profile_code,
    plt.altitude,
    plt.time_stamp AS date,
    ST_AsGeoJSON(plt."position")::json AS geometry
FROM soil_data.profile p
    INNER JOIN soil_data.plot plt ON p.plot_id = plt.plot_id
    INNER JOIN soil_data.site s ON plt.site_id = s.site_id
    LEFT JOIN soil_data.project_site ps ON s.site_id = ps.site_id
    LEFT JOIN soil_data.project proj ON ps.project_id = proj.project_id
WHERE plt."position" IS NOT NULL
ORDER BY p.profile_id;


-- view to expose the observational data
CREATE OR REPLACE VIEW soil_data.vw_api_observations AS
SELECT p3.profile_code,
    e.upper_depth,
    e.lower_depth,
    o.property_phys_chem_id,
    o.procedure_phys_chem_id,
    o.unit_of_measure_id,
    r.value
   FROM soil_data.project p
     LEFT JOIN soil_data.project_site sp ON sp.project_id = p.project_id
     LEFT JOIN soil_data.site s ON s.site_id = sp.site_id
     LEFT JOIN soil_data.plot p2 ON p2.site_id = s.site_id
     LEFT JOIN soil_data.profile p3 ON p3.plot_id = p2.plot_id
     LEFT JOIN soil_data.element e ON e.profile_id = p3.profile_id
     LEFT JOIN soil_data.specimen s2 ON s2.element_id = e.element_id
     LEFT JOIN soil_data.result_phys_chem r ON r.specimen_id = s2.specimen_id
     LEFT JOIN soil_data.observation_phys_chem o ON o.observation_phys_chem_id = r.observation_phys_chem_id
  ORDER BY p3.profile_code, e.upper_depth, o.property_phys_chem_id;


-- view with the layers to be displayed in web mapping
-- CREATE OR REPLACE VIEW soil_data.vw_api_layers AS
-- SELECT  p.project_name, 
--         l.layer_id, 
--         p2.property_id, 
--         p2.name property_name, 
--         p2.unit_of_measure_id, 
--         l.dimension_depth || ' '||l.dimension_stats AS dimension_des, 
--         'http://localhost:8001/collections/metadata:main/items/'||m.file_identifier metadata_url, 
--         u.url download_url,
--         'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX='||l.south_bound_latitude||'%2C'||l.west_bound_longitude||'%2C'||l.north_bound_latitude||'%2C'||l.east_bound_longitude||'&CRS=EPSG%3A4326&WIDTH='||l.raster_size_x||'&HEIGHT='||l.raster_size_y||'&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&DPI=96&MAP_RESOLUTION=96&FORMAT_OPTIONS=dpi%3A96&TRANSPARENT=TRUE' get_map_url,
--         'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.1.1&LAYER='||l.layer_id||'&REQUEST=getlegendgraphic&FORMAT=image/png' get_legend_url,
--         'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&QUERY_LAYERS='||l.layer_id||'&INFO_FORMAT=text%2Fhtml&I=282&J=429' get_feature_info_url
-- FROM spatial_metadata.layer l
-- LEFT JOIN spatial_metadata.mapset m ON m.mapset_id = l.mapset_id
-- LEFT JOIN spatial_metadata.project p ON p.country_id = m.country_id AND p.project_id = m.project_id
-- LEFT JOIN spatial_metadata.property p2 ON p2.property_id = m.property_id 
-- LEFT JOIN spatial_metadata.url u ON u.mapset_id = m.mapset_id AND u.url_name = 'Download '||l.dimension_depth || ' '||l.dimension_stats
-- WHERE m.country_id = '$COUNTRY_ID'
-- ORDER BY p.project_name, l.layer_id;
