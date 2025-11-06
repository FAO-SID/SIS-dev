#!/bin/bash

# Set working directory
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev" 

# Set country
COUNTRY_ID="BT"

# create function to insert dummy data for test
psql -h localhost -p 5442 -U sis -d sis -f $PROJECT_DIR/sis-api/scripts/db_insert_dummy_data.sql

# run function
psql -h localhost -p 5442 -U sis -d sis -c "SELECT api.insert_dummy_data(
                                                    p_num_plots := 200,
                                                    p_observation_ids := ARRAY[514,635,587,683,69,30, 497,742,970,54],
                                                    p_xmin := 88,
                                                    p_xmax := 92,
                                                    p_ymin := 26,
                                                    p_ymax := 28
                                                )"

# Export overall layer info to build web-mapping interface
psql -h localhost -p 5432 -U sis -d iso19139 -c "\copy (
        SELECT  p.project_id,
                p.project_name,
                l.layer_id,
                'TRUE' AS publish,
                p2.name AS property_name,
                l.dimension_depth || '-' || l.dimension_stats AS dimension,
                m.creation_date::text AS version,
                p2.unit_of_measure_id,
                'http://localhost:8001/collections/metadata:main/items/'||m.file_identifier metadata_url,
                u.url AS download_url,
                'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX=4.584249999999999936%2C116.5172270000000054%2C21.22970700000000122%2C126.8480870000000067&CRS=EPSG%3A4326&WIDTH=567&HEIGHT=914&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&DPI=96&MAP_RESOLUTION=96&FORMAT_OPTIONS=dpi%3A96&TRANSPARENT=TRUE' AS get_map_url,
                'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.1.1&LAYER='||l.layer_id||'&REQUEST=getlegendgraphic&FORMAT=image/png' AS get_legend_url,
                'http://localhost:8082/?map=/etc/mapserver/'||l.layer_id||'.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo&LAYERS='||l.layer_id||'&STYLES=&FORMAT=image%2Fpng&QUERY_LAYERS='||l.layer_id||'&INFO_FORMAT=text%2Fhtml&I=282&J=429' AS get_feature_info_url
        FROM spatial_metadata.layer l
        LEFT JOIN spatial_metadata.mapset m ON m.mapset_id = l.mapset_id
        LEFT JOIN spatial_metadata.project p ON p.country_id = m.country_id AND p.project_id = m.project_id
        LEFT JOIN spatial_metadata.property p2 ON p2.property_id = m.property_id 
        LEFT JOIN spatial_metadata.url u ON u.mapset_id = m.mapset_id AND u.url_name = 'Download '||l.dimension_depth || ' ' || l.dimension_stats
        WHERE m.country_id = '$COUNTRY_ID'
        ORDER BY p.project_name, l.layer_id
        ) 
TO $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY_ID}.csv WITH CSV HEADER"

# Copy to sis database
cat $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY_ID}.csv | psql -h localhost -p 5442 -d sis -U sis -c "COPY api.layer FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"
rm $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY_ID}.csv

# Add Profiles layers
psql -h localhost -p 5442 -d sis -U sis -c "INSERT INTO api.layer 
    (project_id,
     project_name,
     layer_id,
     publish,
     property_name,
     metadata_url,
     download_url,
     get_map_url,
     get_legend_url,
     get_feature_info_url)
 VALUES ('Profiles',
         'Profiles',
         'Profiles',
         'TRUE',
         'Soil profiles',
         'http://localhost:8001/collections/metadata:main/items/00aaaa0a-ebeb-11ef-bc12-6b4a6fcd8b5e',
         NULL,
         'http://localhost:8082?map=/etc/mapserver/Profiles.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX=26.69988199999999878%2C88.74999900000000252%2C28.24941499999999905%2C92.12528600000000267&CRS=EPSG%3A4326&WIDTH=661&HEIGHT=304&LAYERS=Profiles&STYLES=&FORMAT=image%2Fpng&DPI=96&MAP_RESOLUTION=96&FORMAT_OPTIONS=dpi%3A96&TRANSPARENT=TRUE',
         'http://localhost:8082/?map=/etc/mapserver/Profiles.map&SERVICE=WMS&VERSION=1.1.1&LAYER=Profiles&REQUEST=getlegendgraphic&FORMAT=image/png',
         'http://localhost:8082/?map=/etc/mapserver/Profiles.map&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo&BBOX=1.16625995882351496%2C116.25895549999999901%2C24.6476970411764853%2C127.10635850000001312&CRS=EPSG%3A4326&WIDTH=595&HEIGHT=1288&LAYERS=Profiles&STYLES=&FORMAT=image%2Fpng&QUERY_LAYERS=Profiles&INFO_FORMAT=text%2Fhtml&I=282&J=429')"

