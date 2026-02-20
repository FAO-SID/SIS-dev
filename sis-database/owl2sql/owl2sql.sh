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
docker exec -i virtuoso isql 1111 dba dba < sparql/properties_desc.sparql 2>/dev/null | grep "^INSERT" > output/properties_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/thesaurus_desc.sparql 2>/dev/null | grep "^INSERT" > output/thesaurus_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/observations_desc.sparql 2>/dev/null | grep "^INSERT" > output/observations_desc.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/phys_chem.sparql 2>/dev/null | grep "^INSERT" > output/phys_chem.sql
docker exec -i virtuoso isql 1111 dba dba < sparql/procedures_phys_chem.sparql 2>/dev/null | grep "^INSERT" > output/procedures_phys_chem.sql

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

# cat output/properties_desc.sql >> owl2sql.sql

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

# cat output/observations_desc.sql >> owl2sql.sql

# echo -e "\nCOMMIT;" >> owl2sql.sql

# wc -l output/*.sql


# Clean up
docker stop virtuoso
docker rm virtuoso
rm -Rf $PROJECT_DIR/ontology
