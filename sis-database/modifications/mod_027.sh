#OBJECT: project_organisation and site_project
#ISSUE: remove Guide lines for Soil description and insert the reviewd ones from Luis Rodriguez Lado

# working dir 
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev/sis-database"


psql -h localhost -p 5432 -d sis -U sis -c "

	DROP TABLE IF EXISTS core.property_desc_plot CASCADE;
	DROP TABLE IF EXISTS core.property_desc_profile CASCADE;
	DROP TABLE IF EXISTS core.property_desc_element CASCADE;
	DROP TABLE IF EXISTS core.thesaurus_desc_plot CASCADE;
	DROP TABLE IF EXISTS core.thesaurus_desc_profile CASCADE;
	DROP TABLE IF EXISTS core.thesaurus_desc_element CASCADE;

	TRUNCATE core.observation_desc_plot CASCADE;
	TRUNCATE core.observation_desc_profile CASCADE;
	TRUNCATE core.observation_desc_element CASCADE;

	CREATE TABLE IF NOT EXISTS core.property_desc (
	property_desc_id text NOT NULL,
	property_pretty_name text,
	uri text,
	CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id));
	
	CREATE TABLE IF NOT EXISTS core.category_desc (
	category_desc_id text NOT NULL,
	uri text,
	CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id));

	ALTER TABLE core.result_desc_plot DROP CONSTRAINT result_desc_plot_property_desc_plot_id_thesaurus_desc_plot_fkey;
	ALTER TABLE core.result_desc_plot RENAME COLUMN property_desc_plot_id TO property_desc_id;
	ALTER TABLE core.result_desc_plot RENAME COLUMN thesaurus_desc_plot_id TO category_desc_id;
	ALTER TABLE core.result_desc_plot ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.result_desc_surface DROP CONSTRAINT result_desc_surface_property_desc_plot_id_thesaurus_desc_p_fkey;
	ALTER TABLE core.result_desc_surface RENAME COLUMN property_desc_plot_id TO property_desc_id;
	ALTER TABLE core.result_desc_surface RENAME COLUMN thesaurus_desc_plot_id TO category_desc_id;
	ALTER TABLE core.result_desc_surface ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.result_desc_profile DROP CONSTRAINT result_desc_profile_property_desc_profile_id_thesaurus_des_fkey;
	ALTER TABLE core.result_desc_profile RENAME COLUMN property_desc_profile_id TO property_desc_id;
	ALTER TABLE core.result_desc_profile RENAME COLUMN thesaurus_desc_profile_id TO category_desc_id;
	ALTER TABLE core.result_desc_profile ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.result_desc_element DROP CONSTRAINT result_desc_element_property_desc_element_id_thesaurus_des_fkey;
	ALTER TABLE core.result_desc_element RENAME COLUMN property_desc_element_id TO property_desc_id;
	ALTER TABLE core.result_desc_element RENAME COLUMN thesaurus_desc_element_id TO category_desc_id;
	ALTER TABLE core.result_desc_element ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.observation_desc_plot RENAME COLUMN property_desc_plot_id TO property_desc_id;
	ALTER TABLE core.observation_desc_plot RENAME COLUMN thesaurus_desc_plot_id TO category_desc_id;
	ALTER TABLE core.observation_desc_plot ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.observation_desc_profile RENAME COLUMN property_desc_profile_id TO property_desc_id;
	ALTER TABLE core.observation_desc_profile RENAME COLUMN thesaurus_desc_profile_id TO category_desc_id;
	ALTER TABLE core.observation_desc_profile ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.observation_desc_element RENAME COLUMN property_desc_element_id TO property_desc_id;
	ALTER TABLE core.observation_desc_element RENAME COLUMN thesaurus_desc_element_id TO category_desc_id;
	ALTER TABLE core.observation_desc_element ALTER COLUMN category_desc_id TYPE text USING category_desc_id::text;

	ALTER TABLE core.result_desc_plot ADD FOREIGN KEY (property_desc_id,category_desc_id) REFERENCES core.observation_desc_plot(property_desc_id,category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.result_desc_surface ADD FOREIGN KEY (property_desc_id,category_desc_id) REFERENCES core.observation_desc_plot(property_desc_id,category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.result_desc_profile ADD FOREIGN KEY (property_desc_id,category_desc_id) REFERENCES core.observation_desc_profile(property_desc_id,category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.result_desc_element ADD FOREIGN KEY (property_desc_id,category_desc_id) REFERENCES core.observation_desc_element(property_desc_id,category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;

	ALTER TABLE core.observation_desc_plot ADD FOREIGN KEY (property_desc_id) REFERENCES core.property_desc(property_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.observation_desc_plot ADD FOREIGN KEY (category_desc_id) REFERENCES core.category_desc(category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	
	ALTER TABLE core.observation_desc_profile ADD FOREIGN KEY (property_desc_id) REFERENCES core.property_desc(property_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.observation_desc_profile ADD FOREIGN KEY (category_desc_id) REFERENCES core.category_desc(category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	
	ALTER TABLE core.observation_desc_element ADD FOREIGN KEY (property_desc_id) REFERENCES core.property_desc(property_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;
	ALTER TABLE core.observation_desc_element ADD FOREIGN KEY (category_desc_id) REFERENCES core.category_desc(category_desc_id) MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE;

	ALTER TABLE core.observation_desc_plot ADD COLUMN category_order SMALLINT;
	ALTER TABLE core.observation_desc_profile ADD COLUMN category_order SMALLINT;
	ALTER TABLE core.observation_desc_element ADD COLUMN category_order SMALLINT;

	CREATE TABLE IF NOT EXISTS core.glosis_db_vocab (
		feature	text,
		property_desc_id_old text,
		property_desc_id text,
		property_pretty_name text,
		category_desc_id text,
		category_order smallint,
		property_uri text,
		category_uri text,
		procedure_desc_id text,
		note text)"

cat $PROJECT_DIR/modifications/mod_027.csv | psql -h localhost -p 5432 -d sis -U sis -c "COPY core.glosis_db_vocab FROM STDIN WITH (FORMAT CSV, HEADER, NULL '')"

psql -h localhost -p 5432 -d sis -U sis -c "
	
	INSERT INTO core.property_desc (property_desc_id, property_pretty_name, uri) 
		SELECT DISTINCT property_desc_id, property_pretty_name, property_uri 
		FROM core.glosis_db_vocab;
	
	INSERT INTO core.category_desc (category_desc_id) 
		SELECT DISTINCT category_desc_id
		FROM core.glosis_db_vocab
	    WHERE category_desc_id IS NOT NULL;
	
	INSERT INTO core.procedure_desc (procedure_desc_id, reference, uri) VALUES
	('FAO GfSD 1990', 'Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 1990', 'FAO GfSD 1990'),
	('ISRIC Report 2019/01', 'ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System. Appendix 1', 'https://www.isric.org/documents/document-type/isric-report-201901-tier-1-and-tier-2-data-context-federated-global-soil'),
	('Keys to Soil Taxonomy 13th edition 2022', 'Keys to Soil Taxonomy, 13th ed.2022', 'https://nrcspad.sc.egov.usda.gov/DistributionCenter/product.aspx?ProductID=1709'),
	('Köppen-Geiger Climate Classification', 'DOI: 10.1127/0941-2948/2006/0130', 'https://www.schweizerbart.de/papers/metz/detail/15/55034/World_Map_of_the_Koppen_Geiger_climate_classificat?af=crossref'),
	('Soil Survey Manual 2017', 'Soil Survey Manual 2017', 'https://www.nrcs.usda.gov/resources/guides-and-instructions/soil-survey-manual'),
	('WRB fourth edition 2022', 'WRB fourth edition 2022', 'https://www.fao.org/soils-portal/data-hub/soil-classification/world-reference-base/en/');

	INSERT INTO core.observation_desc_plot (procedure_desc_id, property_desc_id, category_desc_id, category_order) 
		SELECT DISTINCT procedure_desc_id, property_desc_id, category_desc_id, category_order 
		FROM core.glosis_db_vocab
		WHERE feature = 'plot'
	      AND category_desc_id IS NOT NULL;
	
	INSERT INTO core.observation_desc_profile (procedure_desc_id, property_desc_id, category_desc_id, category_order) 
		SELECT DISTINCT procedure_desc_id, property_desc_id, category_desc_id, category_order 
		FROM core.glosis_db_vocab
		WHERE feature = 'profile'
	      AND category_desc_id IS NOT NULL;

	INSERT INTO core.observation_desc_element (procedure_desc_id, property_desc_id, category_desc_id, category_order) 
		SELECT DISTINCT procedure_desc_id, property_desc_id, category_desc_id, category_order 
		FROM core.glosis_db_vocab
		WHERE feature = 'element'
	      AND category_desc_id IS NOT NULL;
	
	DROP TABLE IF EXISTS core.glosis_db_vocab;"
