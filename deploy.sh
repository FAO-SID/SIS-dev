#!/bin/bash

# Set working directory
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev"      # << EDIT THIS LINE!
COUNTRY=BT
COUNTRY_LONG="Bhutan"

# Navigate to the project folder
cd $PROJECT_DIR


####################
#      Docker      #
####################

# Clean up Docker
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi $(docker images -q) --force
docker network prune -f
docker volume prune -f
docker system prune -a --volumes -f

# Remove old DB volume content
rm -rf $PROJECT_DIR/sis-database/volume/*


####################
#  sis-database    #
####################

# Build and run sis-database container
docker compose up --build sis-database -d

# Wait for the PostgreSQL server to be ready
echo "Waiting for sis-database PostgreSQL to start..."
until docker exec sis-database pg_isready -U sis -d sis; do
  sleep 2
done
echo "sis-database PostgreSQL is ready."

# Copy SQL scripts to sis-database container
docker cp $PROJECT_DIR/sis-database/initdb/init-01.sql sis-database:/tmp/init-01.sql
docker cp $PROJECT_DIR/sis-database/versions/sis-database_latest.sql sis-database:/tmp/sis-database_latest.sql

# Execute SQL scripts inside the container
sleep 5
docker exec -it sis-database psql -d sis -U sis -f /tmp/init-01.sql
docker exec -it sis-database psql -d sis -U sis -f /tmp/sis-database_latest.sql


###########################
#     sis-web-services    #
###########################

# Copy .tif and .map files
rm $PROJECT_DIR/sis-web-services/volume/*.map
rm $PROJECT_DIR/sis-web-services/volume/*.tif
cp /home/carva014/Downloads/FAO/AFACI/$COUNTRY/output/*.tif $PROJECT_DIR/sis-web-services/volume
cp /home/carva014/Downloads/FAO/AFACI/$COUNTRY/output/*.map $PROJECT_DIR/sis-web-services/volume

# Build and start MapServer container
docker compose up --build sis-web-services -d


#######################
#     sis-metadata    #
#######################

# Customize pyCSW
cp $PROJECT_DIR/sis-metadata/pycsw_default.yml $PROJECT_DIR/sis-metadata/pycsw.yml
sed -i "s|COUNTRY_SIS|$COUNTRY_LONG|g" $PROJECT_DIR/sis-metadata/pycsw.yml

# Build and start pyCSW container
docker compose up --build sis-metadata -d

# Customize pyCSW UI - https://docs.pycsw.org/en/latest/configuration.html
docker compose exec sis-metadata sed -i "s/pycsw website/${COUNTRY_LONG} SIS metadata/g" pycsw/pycsw/ogc/api/templates/_base.html
docker compose exec sis-metadata sed -i "s|https://pycsw.org/img/pycsw-logo-vertical.png|${ORG_LOGO_URL}|g" pycsw/pycsw/ogc/api/templates/_base.html
docker compose exec sis-metadata sed -i "s/https:\/\/pycsw.org/http:\/\/localhost:8001\/collections\/metadata:main\/items/g" pycsw/pycsw/ogc/api/templates/_base.html

# Load records
docker compose exec sis-database psql -U sis -d sis -c "DELETE FROM spatial_metadata.records;"
rm $PROJECT_DIR/sis-metadata/volume/*.xml
cp /home/carva014/Downloads/FAO/AFACI/$COUNTRY/output/*.xml $PROJECT_DIR/sis-metadata/volume
docker compose exec sis-metadata ls -l /records
rm $PROJECT_DIR/sis-metadata/volume/*.tif.aux.xml
docker compose exec sis-metadata pycsw-admin.py load-records -c /etc/pycsw/pycsw.yml -p /records -r -y

# Verify if records were loaded
docker compose exec sis-database psql -U sis -d sis -c "SELECT identifier, title FROM spatial_metadata.records ORDER BY title LIMIT 5;"


##################
#     sis-api    #
##################

# Build and start container
docker compose up --build sis-api -d

# Two types of authentication:
# 🔑 JWT tokens (for humans): Login with email/password to manage users, layers, API clients
# 🎫 API keys (for applications): Long-lived keys for sis and external servers to access data

# Create admin user (admin/admin123). This user can manage other users (humans) and API clients (servers)
docker exec -it sis-database psql -U sis -d sis -c "
  INSERT INTO api.user (user_id, password_hash, is_admin, is_active) 
  VALUES ('admin@server.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5oi2W6H9j7K4G', true, true)
  ON CONFLICT (user_id) DO NOTHING"

# Login as admin to get admin token
# This should return something like:
# Hash: $2b$12$3p1Ot6azqWVYPVVc9Id1vebvts98XN0LdubWqEVXbGn.hfnd4vlze
# Admin user created successfully!
docker exec -i sis-api python << 'EOF'
from main import hash_password, get_db

password_hash = hash_password("admin123")
print(f"Hash: {password_hash}")

with get_db() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO api.user (user_id, password_hash, is_admin, is_active) VALUES (%s, %s, %s, %s) ON CONFLICT (user_id) DO UPDATE SET password_hash = EXCLUDED.password_hash",
            ('admin@server.com', password_hash, True, True)
        )
print("Admin user created successfully!")
EOF

# Login to get temporary token. This token is valid for 60 minutes.
# {"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBzZXJ2ZXIuY29tIiwiZXhwIjoxNzYyNDMzMzE5fQ.TzN9KX6pFwfJk3lqnRLh7BMwetQad2Pq5EIj2EaoBZs","token_type":"bearer"}
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "admin@server.com",
    "password": "admin123"
  }'

# Create the API client for sis
# {"message":"API client created successfully","api_client_id":"sis","api_key":"5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk","warning":"Save this API key now. You won't be able to see it again!"}
curl -X POST http://localhost:8000/api/clients \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBzZXJ2ZXIuY29tIiwiZXhwIjoxNzYyNDMzMzE5fQ.TzN9KX6pFwfJk3lqnRLh7BMwetQad2Pq5EIj2EaoBZs" \
  -H "Content-Type: application/json" \
  -d '{
    "api_client_id": "sis",
    "description": "SIS OpenLayers web mapping application"
  }'

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
        WHERE m.country_id = '$COUNTRY'
        ORDER BY p.project_name, l.layer_id
        ) 
TO $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY}.csv WITH CSV HEADER"

# Copy to sis database
cat $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY}.csv | psql -h localhost -p 5442 -d sis -U sis -c "COPY api.layer FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"
rm $PROJECT_DIR/sis-api/scripts/layer_info_${COUNTRY}.csv

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

# Add Profiles layers
psql -h localhost -p 5442 -d sis -U sis -c "INSERT INTO api.setting(key, value) VALUES
 ('ORG_LOGO_URL','https://tse4.mm.bing.net/th/id/OIP.hV37F63PxOkqMwTAlCNnvQAAAA?r=0&pid=Api'),
 ('APP_TITLE','Bhutan Soil Information System'),
 ('LATITUDE','27.5'),
 ('LONGITUDE','89.7'),
 ('ZOOM','9'),
 ('BASE_MAP_DEFAULT','esri-imagery')"

# Test with API key
curl http://localhost:8000/api/manifest -H "X-API-Key: 5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk"
curl http://localhost:8000/api/profile -H "X-API-Key: 5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk"
curl http://localhost:8000/api/observation -H "X-API-Key: 5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk"
curl http://localhost:8000/api/layer -H "X-API-Key: 5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk"
curl http://localhost:8000/api/setting -H "X-API-Key: 5P3_cUmQ_jsVacn8WSOWd112gwNF9QfsRfx3t5T8SKk"

# Create the API client for glosis
# {"message":"API client created successfully","api_client_id":"glosis","api_key":"4H8YLhkteRrC5Lo9jY49bmmzEsya9a0eErJ2gtJTSz4","warning":"Save this API key now. You won't be able to see it again!"}
curl -X POST http://localhost:8000/api/clients \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBzZXJ2ZXIuY29tIiwiZXhwIjoxNzYyNDMzMzE5fQ.TzN9KX6pFwfJk3lqnRLh7BMwetQad2Pq5EIj2EaoBZs" \
  -H "Content-Type: application/json" \
  -d '{
    "api_client_id": "glosis",
    "description": "GloSIS Discovery Hub access"
  }'


##########################
#     sis-web-mapping    #
##########################


docker-compose stop sis-web-mapping
docker-compose rm -f sis-web-mapping
docker rmi sis-dev-sis-web-mapping
# docker-compose run --rm sis-web-mapping rm -rf .parcel-cache
docker-compose build sis-web-mapping
docker-compose up --no-deps -d sis-web-mapping
# docker logs sis-web-mapping -f





# Build and start container
docker compose up --build sis-web-mapping -d


####################
#     sis-nginx    #
####################

# Build and start container
docker compose up --build sis-nginx -d

