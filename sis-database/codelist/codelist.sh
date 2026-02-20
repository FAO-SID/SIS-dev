#!/bin/bash

PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev/sis-database"
cd $PROJECT_DIR/codelist

# wget -O glosis_cl.csv https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/csv_codelists/glosis_cl.csv
# wget -O glosis_procedure.csv https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/csv_codelists/glosis_procedure.csv

psql -h localhost -p 5432 -d sis -U sis -c "
    DROP TABLE IF EXISTS soil_data.glosis_cl;
    DROP TABLE IF EXISTS soil_data.glosis_procedure;
    DROP TABLE IF EXISTS soil_data.gfsd_2006;

    CREATE TABLE soil_data.glosis_cl (
        "attribute" text,
        "instance" text,
        parent_instance text,
        notation text,
        "label" text,
        definition text,
        reference text,
        citation text,
        isproperty bool,
        concept_definition text,
        pub_chem text,
        inchi_key text,
        inchi text
    );

    CREATE TABLE soil_data.glosis_procedure (
        "attribute" text,
        "instance" text,
        parent_instance text,
        notation text,
        "label" text,
        definition text,
        reference text,
        citation text,
        isproperty bool,
        concept_definition text,
        pub_chem text,
        inchi_key text,
        inchi text
    );

    CREATE TABLE soil_data.gfsd_2006 (
        object text,
        num smallint,
        title text,
        page smallint
    );"

cat $PROJECT_DIR/codelist/glosis_cl.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY soil_data.glosis_cl FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"
cat $PROJECT_DIR/codelist/glosis_procedure.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY soil_data.glosis_procedure FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"
cat $PROJECT_DIR/codelist/gfsd_2006.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY soil_data.gfsd_2006 FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"

psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/codelist/codelist.sql
