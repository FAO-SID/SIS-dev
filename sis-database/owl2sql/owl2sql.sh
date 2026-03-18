#!/bin/bash

clear
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql"
cd $PROJECT_DIR


# Create folders
mkdir -p ontology
mkdir -p output


# Start Virtuoso
docker run -d \
    --name virtuoso \
    -p 8890:8890 \
    -p 1111:1111 \
    -e DBA_PASSWORD=dba \
    -e VIRT_Parameters_DirsAllowed="., /database, /opt/virtuoso-opensource/vad" \
    -v "$(pwd)/ontology:/database" \
    openlink/virtuoso-opensource-7:latest

# Wait ~10 seconds, then test
sleep 10
# docker logs virtuoso

# Test if it works
# docker exec virtuoso isql 1111 dba dba exec="SELECT 1;"


# Download GloSIS modules
cd $PROJECT_DIR/ontology
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_cl.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_common.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_layer_horizon.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_main.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_observation.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_procedure.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_profile.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_siteplot.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_surface.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/glosis_unit.ttl
curl -fsSLO https://raw.githubusercontent.com/glosis-ld/glosis/refs/heads/v2.0/iso28258.ttl


# Fix glosis_layer_horizon.ttl Issue opened: https://github.com/glosis-ld/glosis/issues/212
# grep -n "centimolePerLitre" glosis_layer_horizon.ttl
# Fix the typo: replace cm: with om: for centimolePerLitre
sed -i 's/cm:centimolePerLitre/om:centimolePerLitre/g' glosis_layer_horizon.ttl
# Verify fix
# grep -n "centimolePerLitre" glosis_layer_horizon.ttl


# Import ontology files
cd $PROJECT_DIR
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_cl.ttl'), '', 'http://w3id.org/glosis/model/codelists');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_common.ttl'), '', 'http://w3id.org/glosis/model/common');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_layer_horizon.ttl'), '', 'http://w3id.org/glosis/model/layerhorizon');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_main.ttl'), '', 'http://w3id.org/glosis/model/main');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_observation.ttl'), '', 'http://w3id.org/glosis/model/observation');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_procedure.ttl'), '', 'http://w3id.org/glosis/model/procedure');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_profile.ttl'), '', 'http://w3id.org/glosis/model/profile');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_siteplot.ttl'), '', 'http://w3id.org/glosis/model/siteplot');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_surface.ttl'), '', 'http://w3id.org/glosis/model/surface');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/glosis_unit.ttl'), '', 'http://w3id.org/glosis/model/unit');"
docker exec virtuoso isql 1111 dba dba exec="DB.DBA.TTLP_MT (file_to_string_output ('/database/iso28258.ttl'), '', 'http://w3id.org/glosis/model/iso28258');"


# Verify - count triples per graph
# docker exec virtuoso isql 1111 dba dba exec="SPARQL SELECT ?g (COUNT(*) as ?triples) WHERE { GRAPH ?g { ?s ?p ?o } } GROUP BY ?g ORDER BY ?g;"


# Generate SQL files, extracting only INSERT statements
docker exec -i virtuoso isql 1111 dba dba < sparql/property_desc.sparql 2>/dev/null | grep "^INSERT" > output/property_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/category_desc.sparql 2>/dev/null | grep "^INSERT" > output/category_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/observation_desc.sparql 2>/dev/null | grep "^INSERT" > output/observation_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/property_num.sparql 2>/dev/null | grep "^INSERT" > output/property_num.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/procedure_num.sparql 2>/dev/null | grep "^INSERT" > output/procedure_num.sql
# docker exec -i virtuoso isql 1111 dba dba < sparql/unit_of_measure.sparql 2>/dev/null | grep "^INSERT" > output/unit_of_measure.sql # The QUDT units are not loaded in Virtuoso, so they can't be queried. https://github.com/glosis-ld/glosis/issues/182
# So units are extracted from observation_num.sql
grep -oP "unit_of_measure WHERE uri LIKE '\K[^']+" output/observation_num.sql | sort -u | while read uri; do
    unit_id="${uri##*/}"
    query="SELECT ?label WHERE { <$uri> <http://www.w3.org/2000/01/rdf-schema#label> ?label . FILTER(lang(?label) = 'en') } LIMIT 1"
    label=$(curl -sf -G "https://www.qudt.org/sparql" \
        --data-urlencode "query=$query" \
        -H "Accept: application/sparql-results+json" \
        | grep -oP '"value"\s*:\s*"\K[^"]+')
    [ -z "$label" ] && label="$unit_id"
    echo "INSERT INTO soil_data.unit_of_measure (unit_of_measure_id, unit_name, uri) VALUES ('${unit_id}', '${label}', '${uri}') ON CONFLICT DO NOTHING;"
done > output/unit_of_measure.sql



# Check counts
# wc -l output/*.sql


# # Recreate combined file with all data
# cat > owl2sql.sql << 'EOF'
# -- GloSIS v2.0 Ontology Data
# -- Generated from SPARQL queries

# BEGIN;

# -- Thesaurus (code lists)
# EOF

# cat output/thesaurus_desc.sql >> owl2sql.sql

# cat >> owl2sql.sql << 'EOF'

# -- Properties
# EOF

# cat output/property_desc.sql >> owl2sql.sql

# cat >> owl2sql.sql << 'EOF'

# -- Procedures
# EOF

# cat output/procedures_phys_chem.sql >> owl2sql.sql

# cat >> owl2sql.sql << 'EOF'

# -- Physio-chemical
# EOF

# cat output/phys_chem.sql >> owl2sql.sql

# cat >> owl2sql.sql << 'EOF'

# -- Observations
# EOF

# cat output/observation_desc.sql >> owl2sql.sql

# echo -e "\nCOMMIT;" >> owl2sql.sql

# wc -l output/*.sql


# Clean up
# docker stop virtuoso
# docker rm virtuoso
# rm -Rf $PROJECT_DIR/ontology


pg_dump -h localhost -p 5432 -d sis -U sis -n soil_data --schema-only -F custom -v -f /home/carva014/Downloads/tmp.backup
psql -h localhost -p 5432 -d postgres -U sis -c "DROP DATABASE tmp"
psql -h localhost -p 5432 -d postgres -U sis -c "CREATE DATABASE tmp TEMPLATE postgis"
pg_restore -h localhost -p 5432 -d tmp -U sis -v -j 2 /home/carva014/Downloads/tmp.backup

docker exec -i virtuoso isql 1111 dba dba < sparql/property_desc.sparql 2>/dev/null | grep "^INSERT" > output/property_desc.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/property_desc.sql

docker exec -i virtuoso isql 1111 dba dba < sparql/category_desc.sparql 2>/dev/null | grep "^INSERT" > output/category_desc.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/category_desc.sql

docker exec -i virtuoso isql 1111 dba dba < sparql/observation_desc.sparql 2>/dev/null | grep "^INSERT" > output/observation_desc.sql
psql -h localhost -p 5432 -d tmp -U sis -c "INSERT INTO soil_data.procedure_desc (procedure_desc_id,reference,uri) VALUES
	 ('FAO GfSD 2006','Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 2006.','https://www.fao.org/publications/card/en/c/903943c7-f56a-521a-8d32-459e7e0cdae9/'),
	 ('FAO GfSD 1990','Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 1990','FAO GfSD 1990'),
	 ('ISRIC Report 2019/01','ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System. Appendix 1','https://www.isric.org/documents/document-type/isric-report-201901-tier-1-and-tier-2-data-context-federated-global-soil'),
	 ('Keys to Soil Taxonomy 13th edition 2022','Keys to Soil Taxonomy, 13th ed.2022','https://nrcspad.sc.egov.usda.gov/DistributionCenter/product.aspx?ProductID=1709'),
	 ('Köppen-Geiger Climate Classification','DOI: 10.1127/0941-2948/2006/0130','https://www.schweizerbart.de/papers/metz/detail/15/55034/World_Map_of_the_Koppen_Geiger_climate_classificat?af=crossref'),
	 ('Soil Survey Manual 2017','Soil Survey Manual 2017','https://www.nrcs.usda.gov/resources/guides-and-instructions/soil-survey-manual'),
	 ('WRB fourth edition 2022','WRB fourth edition 2022','https://www.fao.org/soils-portal/data-hub/soil-classification/world-reference-base/en/');"
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/observation_desc.sql

docker exec -i virtuoso isql 1111 dba dba < sparql/property_num.sparql 2>/dev/null | grep "^INSERT" > output/property_num.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/property_num.sql

docker exec -i virtuoso isql 1111 dba dba < sparql/procedure_num.sparql 2>/dev/null | grep "^INSERT" > output/procedure_num.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/procedure_num.sql

docker exec -i virtuoso isql 1111 dba dba < sparql/observation_num.sparql 2>/dev/null | grep "^INSERT" > output/observation_num.sql
grep -oP "unit_of_measure WHERE uri LIKE '\K[^']+" output/observation_num.sql | sort -u | while read uri; do
    unit_id="${uri##*/}"
    query="SELECT ?label WHERE { <$uri> <http://www.w3.org/2000/01/rdf-schema#label> ?label . FILTER(lang(?label) = 'en') } LIMIT 1"
    label=$(curl -sf -G "https://www.qudt.org/sparql" \
        --data-urlencode "query=$query" \
        -H "Accept: application/sparql-results+json" \
        | grep -oP '"value"\s*:\s*"\K[^"]+')
    [ -z "$label" ] && label="$unit_id"
    echo "INSERT INTO soil_data.unit_of_measure (unit_of_measure_id, unit_name, uri) VALUES ('${unit_id}', '${label}', '${uri}') ON CONFLICT DO NOTHING;"
done > output/unit_of_measure.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/unit_of_measure.sql
psql -h localhost -p 5432 -d tmp -U sis -f /home/carva014/Work/Code/FAO/SIS-dev/sis-database/owl2sql/output/observation_num.sql
