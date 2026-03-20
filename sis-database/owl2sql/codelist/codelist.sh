#!/bin/bash

PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev/sis-database"
cd $PROJECT_DIR/codelist

psql -h localhost -p 5432 -d sis -U sis -c "
    DROP TABLE IF EXISTS soil_data.gfsd_2006;

    CREATE TABLE soil_data.gfsd_2006 (
        object text,
        num smallint,
        title text,
        page smallint
    );"

cat $PROJECT_DIR/codelist/gfsd_2006.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY soil_data.gfsd_2006 FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"

psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/codelist/codelist.sql
