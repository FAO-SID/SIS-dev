# Set working directory
$PROJECT_DIR = "C:\Users\luis\Desktop\GloSIS-main"

# Navigate to the project folder
Set-Location "$PROJECT_DIR"


####################
#      Docker      #
####################

# Clean up Docker
docker ps -q | ForEach-Object { docker stop $_ }
docker ps -aq | ForEach-Object { docker rm $_ }
docker images -q | ForEach-Object { docker rmi $_ -f }
docker network prune -f
docker volume prune -f
docker system prune -a --volumes -f

# Remove old DB volume content
Remove-Item -Path "$PROJECT_DIR/sis-database/volume/*" -Recurse -Force -ErrorAction SilentlyContinue


####################
#     sis-database    #
####################

# Build and run sis-database container
docker compose up --build sis-database -d

# Wait for the PostgreSQL server to be ready
Write-Host "Waiting for sis-database PostgreSQL to start..."
while ($true) {
    $readyCheck = docker exec sis-database pg_isready -U sis -d sis 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "sis-database PostgreSQL is ready."
        break
    }
    Start-Sleep -Seconds 1
}

# Copy SQL scripts to sis-database container
docker cp "$PROJECT_DIR\sis-database\initdb\init-01.sql" sis-database:/tmp/init-01.sql
docker cp "$PROJECT_DIR\sis-database\versions\sis-database_latest.sql" sis-database:/tmp/init-02.sql
docker cp "$PROJECT_DIR\sis-database\initdb\init-03.sql" sis-database:/tmp/init-03.sql

# Execute SQL scripts inside the container
Start-Sleep -Seconds 10
docker exec -i sis-database psql -d sis -U sis -f /tmp/init-01.sql
docker exec -i sis-database psql -d sis -U sis -f /tmp/init-02.sql
docker exec -i sis-database psql -d sis -U sis -f /tmp/init-03.sql


####################
#      Docker      #
####################

# Build and start Docker shiny containers
docker compose up --build sis-shiny -d
# Update Global.R script to sis-shiny container
docker cp "$PROJECT_DIR\sis-shiny\global\global.R" sis-shiny:/srv/shiny-server/iso28258/global.R

# Build and start other Docker containers
docker compose up --build sis-web-mapping -d
docker compose up --build sis-web-services -d
docker compose up --build sis-metadata -d


####################
#   sis-metadata   #
####################

# Load records
docker-compose exec sis-metadata ls -l /records
docker-compose exec sis-metadata pycsw-admin.py load-records -c /etc/pycsw/pycsw.yml -p /records -r -y

# Verify records loaded
docker-compose exec sis-database psql -U sis -d sis -c "SELECT identifier, title FROM pycsw.records ORDER BY title LIMIT 5;"

# Customize pyCSW UI
docker-compose exec sis-metadata sed -i 's/pycsw website/Philippines SIS metadata/g' pycsw/pycsw/ogc/api/templates/_base.html
docker-compose exec sis-metadata sed -i 's/https:\/\/pycsw.org\/img\/pycsw-logo-vertical.png/https:\/\/www.bswm.da.gov.ph\/wp-content\/uploads\/BAGONG-PILIPINAS.png/g' pycsw/pycsw/ogc/api/templates/_base.html
docker-compose exec sis-metadata sed -i 's/https:\/\/pycsw.org/http:\/\/localhost:8001\/collections\/metadata:main\/items/g' pycsw/pycsw/ogc/api/templates/_base.html
