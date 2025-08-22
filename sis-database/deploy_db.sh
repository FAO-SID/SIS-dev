#!/bin/bash

# variables
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev/sis-database"      # << EDIT THIS LINE!
DATE=`date +%Y-%m-%d`


#################
#      Role     #
#################

psql -h localhost -p 5432 -d postgres -U postgres -c "CREATE ROLE sis WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD 'sis'"
psql -h localhost -p 5432 -d postgres -U postgres -c "CREATE ROLE sis_r WITH LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD 'sis'"
psql -h localhost -p 5432 -d postgres -U postgres -c "CREATE ROLE pycsw WITH LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD 'pycsw'"
psql -h localhost -p 5432 -d postgres -U postgres -c 'ALTER ROLE pycsw SET search_path TO "spatial_metadata, ""$user"", public"'
psql -h localhost -p 5432 -d postgres -U postgres -c "CREATE ROLE kobo WITH LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD 'kobo'"
psql -h localhost -p 5432 -d postgres -U postgres -c 'ALTER ROLE kobo SET search_path TO "kobo, ""$user"", public"'


#################
#    Database   #
#################

psql -h localhost -p 5432 -d postgres -U postgres -c "DROP DATABASE IF EXISTS sis"
psql -h localhost -p 5432 -d postgres -U sis -c "CREATE DATABASE sis"


#################
#   Extension   #
#################

psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis SCHEMA public"
psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis_raster SCHEMA public"
psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal SCHEMA public"
psql -h localhost -p 5432 -d sis -U sis -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public'


#################
# Modifications #
#################

psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/versions/sis-database_v1.5_changed.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_001.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_002.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_003.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_004.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_005.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_006.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_007.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_008.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_009.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_010.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_011.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_012.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_013.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_014.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_015.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_016.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_017.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_018.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_019.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_020.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_021.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_022.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_023.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_024.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_025.sql
$PROJECT_DIR/modifications/mod_026.sh
$PROJECT_DIR/modifications/mod_027.sh
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_028.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_029.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_030.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_031.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/modifications/mod_032.sql


#################
#    Schema     #
#################

psql -h localhost -p 5432 -d sis -U sis -c "CREATE SCHEMA kobo"
psql -h localhost -p 5432 -d sis -U sis -c "COMMENT ON SCHEMA kobo IS 'GloSIS data collection database schema'"
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/schema.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_country_latest.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_individual_latest.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_organisation_latest.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_property_latest.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-dev/sis-api/schema.sql


#################
#     Grant     #
#################

psql -h localhost -p 5432 -d sis -U sis -c "GRANT USAGE   ON SCHEMA soil_data TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL TABLES IN SCHEMA soil_data TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL SEQUENCES IN SCHEMA soil_data TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA soil_data TO sis_r"

psql -h localhost -p 5432 -d sis -U sis -c "GRANT USAGE   ON SCHEMA spatial_metadata TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL TABLES IN SCHEMA spatial_metadata TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL SEQUENCES IN SCHEMA spatial_metadata TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA spatial_metadata TO sis_r"

psql -h localhost -p 5432 -d sis -U sis -c "GRANT USAGE   ON SCHEMA kobo TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL TABLES IN SCHEMA kobo TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT SELECT  ON ALL SEQUENCES IN SCHEMA kobo TO sis_r"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA kobo TO sis_r"

psql -h localhost -p 5432 -d sis -U sis -c "GRANT ALL ON SCHEMA kobo TO kobo"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT ALL ON ALL TABLES IN SCHEMA kobo TO kobo"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA kobo TO kobo"
psql -h localhost -p 5432 -d sis -U sis -c "GRANT ALL ON ALL FUNCTIONS IN SCHEMA kobo TO kobo"


#################
#     Dump      #
#################

pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v -f $PROJECT_DIR/versions/sis-database_v$DATE.sql
pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v -f $PROJECT_DIR/versions/sis-database_latest.sql

# Export table with codelists of properties, procedures, units and alowed value range
psql -h localhost -p 5432 -d sis -U sis -c "\COPY (
        SELECT o.property_phys_chem_id, o.procedure_phys_chem_id, o.unit_of_measure_id, o.value_min, o.value_max, p.definition, p.citation, p.reference 
        FROM soil_data.observation_phys_chem o
        LEFT JOIN soil_data.procedure_phys_chem p ON p.procedure_phys_chem_id = o.procedure_phys_chem_id
        ORDER BY 1, 2) 
        TO '$PROJECT_DIR/versions/sis-database_observation_phys_chem_code_list.csv' WITH CSV HEADER"
