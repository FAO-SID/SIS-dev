#!/bin/bash

# Set working directory
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev"      # << EDIT THIS LINE!
COUNTRY=BT
COUNTRY_LONG="Bhutan"
ORG_LOGO_URL="https:\/\/tse4.mm.bing.net\/th\/id/OIP.hV37F63PxOkqMwTAlCNnvQAAAA?r=0&pid=Api" # PH "https:\/\/www.bswm.da.gov.ph\/wp-content\/uploads\/BAGONG-PILIPINAS.png"
LATITUDE=27.5   # 27 BT / 12 PH
LONGITUDE=89.7  # 90 BT / 120 PH
ZOOM=9
LAYER_DEFAULT='BT-GSNM-BKD-2024-0-30'
BASE_MAP_DEFAULT='esri-imagery' # esri-imagery / OpenStreetMap / Open TopoMap

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
  sleep 1
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


##########################
#     sis-web-mapping    #
##########################

# collapsed group layer names in main.js line 323
# collapsed group layer names in layers.js line 84

# Overwrite logo file
cp $PROJECT_DIR/sis-web-mapping/public/img/logo_${COUNTRY}.png $PROJECT_DIR/sis-web-mapping/public/img/logo.png # index.html line 9 and 13

# Overwrite layer info file
cp $PROJECT_DIR/sis-web-mapping/public/layer_info_${COUNTRY}.csv $PROJECT_DIR/sis-web-mapping/public/layer_info.csv # layers.js line 8

# Reset main.js
cp $PROJECT_DIR/sis-web-mapping/src/js/main.default $PROJECT_DIR/sis-web-mapping/src/js/main.js

# Set map center
sed -i "s/MAP_CENTER_LONG/$LONGITUDE/g" $PROJECT_DIR/sis-web-mapping/src/js/main.js         # main.js line 98
sed -i "s/MAP_CENTER_LAT/$LATITUDE/g" $PROJECT_DIR/sis-web-mapping/src/js/main.js           # main.js line 98

# Set zoom level
sed -i "s/MAP_ZOOM/$ZOOM/g" $PROJECT_DIR/sis-web-mapping/src/js/main.js                     # main.js line 99

# Set default base map
sed -i "s/BASE_MAP_DEFAULT/$BASE_MAP_DEFAULT/g" $PROJECT_DIR/sis-web-mapping/src/js/main.js # main.js line 465

# Set default layer
sed -i "s/LAYER_DEFAULT/$LAYER_DEFAULT/g" $PROJECT_DIR/sis-web-mapping/src/js/main.js       # main.js line 476

# Reset index.html
cp $PROJECT_DIR/sis-web-mapping/src/index.default $PROJECT_DIR/sis-web-mapping/src/index.html

# Set country name
sed -i "s/COUNTRY_LONG/$COUNTRY_LONG/g" $PROJECT_DIR/sis-web-mapping/src/index.html       # main.js line 476

# Build and start container
docker compose up --build sis-web-mapping -d
