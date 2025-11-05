#!/bin/bash

# OBJECT: procedure_phys_chem
# ISSUE: add data from https://github.com/glosis-ld/glosis/blob/master/csv_codelists/glosis_procedure.csv

# working dir 
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev/sis-database"


psql -h localhost -p 5432 -d sis -U sis -c "
    CREATE TABLE IF NOT EXISTS core.procedure_phys_chem_tmp (
        attribute text,
        instance text,
        parent_instance text,
        notation text,
        label text,
        definition text,
        reference text,
        citation text,
        isproperty text,
        concept_definition text,
        pub_chem text,
        inchi_key text,
        inchi text,
        CONSTRAINT procedure_phys_chem_tmp_pkey PRIMARY KEY (attribute, instance)
        );"

cat $PROJECT_DIR/modifications/mod_026.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY core.procedure_phys_chem_tmp FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"

psql -h localhost -p 5432 -d sis -U sis -c "
    DO \$\$ 
    BEGIN
        BEGIN
            ALTER TABLE core.procedure_phys_chem ADD COLUMN definition text;
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column definition already exists in procedure_phys_chem.';
        END;
        BEGIN
            ALTER TABLE core.procedure_phys_chem ADD COLUMN reference text;
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column reference already exists in procedure_phys_chem.';
        END;
        BEGIN
            ALTER TABLE core.procedure_phys_chem ADD COLUMN citation text;
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column citation already exists in procedure_phys_chem.';
        END;
    END \$\$"


psql -h localhost -p 5432 -d sis -U sis -c "
    UPDATE core.procedure_phys_chem SET definition = t.definition FROM core.procedure_phys_chem_tmp t WHERE procedure_phys_chem_id = t.instance;
    UPDATE core.procedure_phys_chem SET reference = t.reference FROM core.procedure_phys_chem_tmp t WHERE procedure_phys_chem_id = t.instance;
    UPDATE core.procedure_phys_chem SET citation = t.citation FROM core.procedure_phys_chem_tmp t WHERE procedure_phys_chem_id = t.instance;
    DROP TABLE IF EXISTS core.procedure_phys_chem_tmp;"
