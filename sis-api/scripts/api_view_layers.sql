-- OBJECT: core.vw_api_layers
-- ISSUE: layers to be displayed in web mapping

DROP VIEW IF EXISTS core.vw_api_layers;

CREATE OR REPLACE VIEW core.vw_api_layers AS
SELECT  p.project_name, 
        l.layer_id, 
        p2.property_id, 
        p2.name property_name, 
        p2.unit_of_measure_id, 
        l.dimension_depth || ' '||l.dimension_stats AS dimension_des, 
        'http://localhost:8001/collections/metadata:main/items/'||m.file_identifier metadata_url, 
        u.url download_url,
        'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX='||l.south_bound_latitude||'%2C'||l.west_bound_longitude||'%2C'||l.north_bound_latitude||'%2C'||l.east_bound_longitude||'&CRS=EPSG%3A4326&WIDTH='||l.raster_size_x||'&HEIGHT='||l.raster_size_y||'&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&DPI=96&MAP_RESOLUTION=96&FORMAT_OPTIONS=dpi%3A96&TRANSPARENT=TRUE' get_map_url,
        'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.1.1&LAYER='||l.layer_id||'&REQUEST=getlegendgraphic&FORMAT=image/png' get_legend_url,
        'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&QUERY_LAYERS='||l.layer_id||'&INFO_FORMAT=text%2Fhtml&I=282&J=429' get_feature_info_url
FROM spatial_metadata.layer l
LEFT JOIN spatial_metadata.mapset m ON m.mapset_id = l.mapset_id
LEFT JOIN spatial_metadata.project p ON p.country_id = m.country_id AND p.project_id = m.project_id
LEFT JOIN spatial_metadata.property p2 ON p2.property_id = m.property_id 
LEFT JOIN spatial_metadata.url u ON u.mapset_id = m.mapset_id AND u.url_name = 'Download '||l.dimension_depth || ' '||l.dimension_stats
WHERE m.country_id = '$COUNTRY_ID'
ORDER BY p.project_name, l.layer_id;
