#!/bin/bash

# Set working directory
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev"      # << EDIT THIS LINE!
COUNTRY=BT
COUNTRY_LONG="Bhutan"

# Load .env so shell can use the same vars docker compose sees
set -a
source "$PROJECT_DIR/.env"
set +a

# Hosts:port in dev and prod
# sis-nginx:        80:80, 443:443
# sis-web-mapping:  8001:8000
# sis-api:          8002:8000
# sis-metadata:     8003:8000
# sis-web-services: 8004:80
# sis-database:     8005:5432

# # PRODUCTION (only nginx exposed)
# sis-nginx:        80:80, 443:443  # Only this exposed!
# sis-web-mapping:  expose: 8000    # Internal only
# sis-api:          expose: 8000
# sis-metadata:     expose: 8000
# sis-web-services: expose: 80
# sis-database:     expose: 5432

HOST_SIS_API_DEV="localhost:8002" # make sure is the same as API_URL in docker compose.yml
HOST_SIS_API_PROD="sis-api:8000"
HOST_SIS_API=$HOST_SIS_API_DEV

HOST_SIS_METADATA_DEV="localhost:8003" # make sure is the same as PYCSW_SERVER_URL in docker compose.yml
HOST_SIS_METADATA_PROD="sis-metadata:8000"
HOST_SIS_METADATA=$HOST_SIS_METADATA_DEV

HOST_SIS_WEB_SERVICES_DEV="localhost:8004"
HOST_SIS_WEB_SERVICES_PROD="sis-web-services:80"
HOST_SIS_WEB_SERVICES=$HOST_SIS_WEB_SERVICES_DEV

# Navigate to the project folder
cd $PROJECT_DIR
clear


####################
#      Docker      #
####################

# Clean up Docker 
# THE COMMANDS BELOW WILL DELETE ALL EXISTING CONTAINERS ON YOUR MACHINE!!!
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
docker cp $PROJECT_DIR/sis-database/init.sql sis-database:/tmp/init.sql
docker cp $PROJECT_DIR/sis-database/sis-database_latest_with_codelist.sql sis-database:/tmp/sis-database_latest_with_codelist.sql

# Execute SQL scripts inside the container
sleep 5
docker exec sis-database psql -d sis -U sis -f /tmp/init.sql
docker exec sis-database psql -d sis -U sis -f /tmp/sis-database_latest_with_codelist.sql

# insert dummy data for test
docker exec sis-database psql -U sis -d sis -c "SELECT api.insert_dummy_data(
                                                    p_project_id := 'DUMMY_DATA_1',
                                                    p_project_name := 'Dummy data 1',
                                                    p_num_plots := 200,
                                                    p_observation_ids := ARRAY[911,912,913],
                                                    p_xmin := 89.11,
                                                    p_xmax := 92.12,
                                                    p_ymin := 26.71,
                                                    p_ymax := 28.28
                                                )"

docker exec sis-database psql -U sis -d sis -c "SELECT api.insert_dummy_data(
                                                    p_project_id := 'DUMMY_DATA_2',
                                                    p_project_name := 'Dummy data 2',
                                                    p_num_plots := 100,
                                                    p_observation_ids := ARRAY[1,20,50,911,912,913],
                                                    p_xmin := 89.11,
                                                    p_xmax := 92.12,
                                                    p_ymin := 26.71,
                                                    p_ymax := 28.28
                                                )"

# Add sis-Web-mapping applications settings
docker exec sis-database psql -d sis -U sis -c "INSERT INTO api.setting(key, value) VALUES
 ('ORG_LOGO_URL','https://tse4.mm.bing.net/th/id/OIP.hV37F63PxOkqMwTAlCNnvQAAAA?r=0&pid=Api'),
 ('APP_TITLE','Bhutan Soil Information System'),
 ('LATITUDE','27.5'),
 ('LONGITUDE','89.7'),
 ('ZOOM','9'),
 ('BASE_MAP_DEFAULT','esri-imagery'),
 ('DOWNLOAD_BASE_URL','/downloads/');"

# Seed API client used by sis-web-mapping (key matches .env WEB_MAPPING_API_KEY)
docker exec sis-database psql -d sis -U sis -c \
 "INSERT INTO api.api_client (api_client_id, api_key, description, is_active)
  VALUES ('sis-web-mapping', '${WEB_MAPPING_API_KEY}', 'Web mapping frontend', true);"


##################
#     sis-api    #
##################

# Build and start container
docker compose up --build sis-api -d

# Test SIS API
curl -s http://localhost:8002/health


##################
# sis-api-glosis #
##################

# Connects as the read-only sis_glosis Postgres role. Federation access is
# OFF by default — the SIS admin enables it from Administration → GloSIS
# Federation, which sets api.setting GLOSIS_FEDERATION_ENABLED='true' and
# generates the token to share with the Discovery Hub.
docker compose up --build sis-api-glosis -d
curl -s http://localhost:8006/health


####################
#     sis-nginx    #
####################

# Build and start container
docker compose up sis-nginx -d


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
docker exec sis-metadata sed -i "s/pycsw website/${COUNTRY_LONG} SIS metadata/g" pycsw/pycsw/ogc/api/templates/_base.html
docker exec sis-metadata sed -i "s|https://pycsw.org/img/pycsw-logo-vertical.png|${ORG_LOGO_URL}|g" pycsw/pycsw/ogc/api/templates/_base.html
docker exec sis-metadata sed -i "s/https:\/\/pycsw.org/http:\/\/$HOST_SIS_METADATA\/collections\/metadata:main\/items/g" pycsw/pycsw/ogc/api/templates/_base.html

# Load records
docker exec sis-database psql -U sis -d sis -c "DELETE FROM spatial_metadata.records;"
rm $PROJECT_DIR/sis-metadata/volume/*.xml
cp /home/carva014/Downloads/FAO/AFACI/$COUNTRY/output/*.xml $PROJECT_DIR/sis-metadata/volume
docker exec sis-metadata ls -l /records
rm $PROJECT_DIR/sis-metadata/volume/*.tif.aux.xml
docker exec sis-metadata pycsw-admin.py load-records -c /etc/pycsw/pycsw.yml -p /records -r -y

# Verify if records were loaded
docker exec sis-database psql -U sis -d sis -c "SELECT identifier, title FROM spatial_metadata.records ORDER BY title LIMIT 5;"


##########################
#     sis-web-mapping    #
##########################

# Build and start container
docker compose up --build sis-web-mapping -d

