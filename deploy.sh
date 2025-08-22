#!/bin/bash

# Set working directory
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev"      # << EDIT THIS LINE!

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


####################
#      Docker      #
####################

# Build and start Docker shiny containers
# docker compose up --build sis-shiny -d
# Update Global.R script to sis-shiny container
# docker cp $PROJECT_DIR/sis-shiny/global/global.R sis-shiny:/srv/shiny-server/iso28258/global.R

# Build and start other Docker containers
docker compose up --build sis-metadata -d
docker compose up --build sis-web-services -d
docker compose up --build sis-web-mapping -d


####################
#   sis-metadata   #
####################

# Load records
docker compose exec sis-metadata ls -l /records
docker compose exec sis-metadata pycsw-admin.py load-records -c /etc/pycsw/pycsw.yml -p /records -r -y

# Verify if records were loaded
docker compose exec sis-database psql -U sis -d sis -c "SELECT identifier, title FROM spatial_metadata.pycsw_records ORDER BY title LIMIT 5;"

# Customize pyCSW UI - https://docs.pycsw.org/en/latest/configuration.html
docker compose exec sis-metadata sed -i 's/pycsw website/Philippines SIS metadata/g' pycsw/pycsw/ogc/api/templates/_base.html
docker compose exec sis-metadata sed -i 's/https:\/\/pycsw.org\/img\/pycsw-logo-vertical.png/https:\/\/www.bswm.da.gov.ph\/wp-content\/uploads\/BAGONG-PILIPINAS.png/g' pycsw/pycsw/ogc/api/templates/_base.html
docker compose exec sis-metadata sed -i 's/https:\/\/pycsw.org/http:\/\/localhost:8001\/collections\/metadata:main\/items/g' pycsw/pycsw/ogc/api/templates/_base.html
