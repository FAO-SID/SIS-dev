#!/bin/bash

# variables
PROJECT_DIR="/home/carva014/Work/Code/FAO/SIS-dev"      # << EDIT THIS LINE!
DATE=`date +%Y-%m-%d`


#################
#   Database    #
#################

pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v --schema-only -f $PROJECT_DIR/sis-database/sis-database_v$DATE.sql
pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v --schema-only -f $PROJECT_DIR/sis-database/sis-database_latest.sql
psql -h localhost -p 5432 -d postgres -U postgres -c "DROP DATABASE IF EXISTS sis"
psql -h localhost -p 5432 -d postgres -U sis -c "CREATE DATABASE sis"


#################
#   Extension   #
#################

psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis"
psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis_raster"
psql -h localhost -p 5432 -d sis -U sis -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal"
psql -h localhost -p 5432 -d sis -U sis -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'


#################
#   Schemas     #
#################

psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/sis-database_latest.sql


#################
#   Inserts     #
#################

psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/property_desc.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/category_desc.sql
psql -h localhost -p 5432 -d sis -U sis -c "INSERT INTO soil_data.procedure_desc (procedure_desc_id,reference,uri) VALUES
	 ('FAO GfSD 2006','Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 2006.','https://www.fao.org/publications/card/en/c/903943c7-f56a-521a-8d32-459e7e0cdae9/'),
	 ('FAO GfSD 1990','Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 1990','FAO GfSD 1990'),
	 ('ISRIC Report 2019/01','ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System','https://www.isric.org/documents/document-type/isric-report-201901-tier-1-and-tier-2-data-context-federated-global-soil'),
	 ('Keys to Soil Taxonomy 13th edition 2022','Keys to Soil Taxonomy, 13th ed.2022','https://nrcspad.sc.egov.usda.gov/DistributionCenter/product.aspx?ProductID=1709'),
	 ('Köppen-Geiger Climate Classification','DOI: 10.1127/0941-2948/2006/0130','https://www.schweizerbart.de/papers/metz/detail/15/55034/World_Map_of_the_Koppen_Geiger_climate_classificat?af=crossref'),
	 ('Soil Survey Manual 2017','Soil Survey Manual 2017','https://www.nrcs.usda.gov/resources/guides-and-instructions/soil-survey-manual'),
	 ('WRB fourth edition 2022','WRB fourth edition 2022','https://www.fao.org/soils-portal/data-hub/soil-classification/world-reference-base/en/');"
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/observation_desc.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/property_num.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/procedure_num.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/unit_of_measure.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/output/observation_num.sql
psql -h localhost -p 5432 -d sis -U sis -f $PROJECT_DIR/sis-database/owl2sql/fix.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_country_latest.sql
psql -h localhost -p 5432 -d sis -U sis -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/backups/data_property_latest.sql


#################
#   Dump        #
#################

pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v --schema-only -f $PROJECT_DIR/sis-database/sis-database_v$DATE.sql
pg_dump -h localhost -p 5432 -d sis -U sis -F plain -v --schema-only -f $PROJECT_DIR/sis-database/sis-database_latest.sql





# BASAT	Base saturation	%	3.9748352	310.83453	BASCAL
# BKD	Bulk Density of the fine earth fraction	kg/dm³	0.00078795	1.6824608	BULDFINE
# CAEXC	Calcium (Ca++) - exchangeable	cmol/kg	0.64788485	31.82854	CALEXC
# CORG	Carbon (C) - organic	%	0.102681465	424.47433	CARORG
# CACO3ET	Calcium carbonate equivalent - total	g/kg	0.0022378669	9.722537	CCETOT
# ECX	Electrical conductivity	dS/m	-2160.8682	21054397349888	ELECCOND
# MGEXC	Magnesium (Mg++) - exchangeable	cmol/kg	0.1713	7.6219	MAGEXC
# NTOT	Nitrogen (N) - total	%	0.023296468	37738.81	NITTOT
# PEXT	Phosphorus (P) - extractable	%	7.6332707	336.86963	PHOEXT
# PTOT	Phosphorus (P) - total	%	0.023891324	1.083517	PHOTOT
# KEXC	Potassium (K+) - exchangeable	cmol/kg	0.23427553	478.14163	POTEXC
# KEXT	Potassium (K) - extractable	cmol/kg	4.5881696	1249.2526	POTEXT
# KTOT	Potassium (K) - total	%	0.14559056	2.4445798	POTTOT
# NAEXC	Sodium (Na+) - exchangeable	cmol/kg	0.0	100.001	SODEXP
# CLAY	Clay texture fraction	%	2.0954218	67.95525	TEXTCLAY
# SAND	Sand texture fraction	%	0.009413641	89.83889	TEXTSAND
# SILT	Silt texture fraction	%	0.21143602	89.91184	TEXTSILT

# BSATS	Base saturation - sum of cations	%	0.5860444	21.523035							--> BSEXC Exchangeable bases, them DELETE
# PHAQ	pH - Hydrogen potential in water	pH	0	38.24991									--> PHX them DELETE
# CFRAGF	Coarse fragments - field class	%	0.00006592	47.75318								--> COAFRA Coarse fragments ?
# KXX	Potassium (K)	mg/kg	0.16248894	756.61646												--> POTEXT POTTOT POTEXC wich one?
# PXX	Phosphorus (P)	mg/kg	1.18992	414.6663													--> PHOEXT PHORET PHOTOT wich one?
