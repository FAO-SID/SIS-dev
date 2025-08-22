# OBJECT: project_organisation and site_project
# ISSUE: remove Guide lines for Soil description and insert the reviewd ones from Luis Rodriguez Lado

# working dir 
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev/sis-database"

psql -h localhost -p 5432 -d sis -U glosis -c "
DROP TABLE IF EXISTS core.glosis_db_vocab;
CREATE TABLE IF NOT EXISTS core.glosis_db_vocab (
    feature	text,
    property_db_name text,
    property_rename text,
    property_pretty_name text,
    thesaurus text,
    thesaurus_order smallint,
    property_uri text,
    thesaurus_uri text,
    procedure text,
    note text)"

cat $PROJECT_DIR/versions/sis-database_vocab.csv | psql -h localhost -p 5432 -d sis -U glosis -c "COPY core.glosis_db_vocab FROM STDIN WITH (FORMAT CSV, HEADER, DELIMITER E'\t', NULL '')"

psql -h localhost -p 5432 -d sis -U glosis -c "
    INSERT INTO core.procedure_desc (procedure_desc_id, reference, uri)
    SELECT DISTINCT procedure,procedure,procedure FROM core.glosis_db_vocab WHERE procedure NOT IN (SELECT procedure_desc_id FROM core.procedure_desc);

    ALTER TABLE core.observation_desc_plot ADD COLUMN thesaurus_order SMALLINT;
	ALTER TABLE core.observation_desc_profile ADD COLUMN thesaurus_order SMALLINT;
	ALTER TABLE core.observation_desc_element ADD COLUMN thesaurus_order SMALLINT;"

# SELECT 'plot', '', p.property_desc_plot_id, p.uri, o.thesaurus_desc_plot_id, t.label, t.uri
# FROM 
# (
# 	SELECT property_desc_plot_id, uri FROM core.property_desc_plot
# 	WHERE uri IN (
# 		(SELECT uri FROM core.property_desc_plot
# 			UNION
# 		SELECT uri FROM core.property_desc_profile
# 			UNION
# 		SELECT uri FROM core.property_desc_element)
# 			EXCEPT
# 		SELECT uri FROM core.glosis_db_vocab
# 	)
# ) p
# LEFT JOIN core.observation_desc_plot o ON o.property_desc_plot_id = p.property_desc_plot_id
# LEFT JOIN core.thesaurus_desc_plot t ON t.thesaurus_desc_plot_id = o.thesaurus_desc_plot_id
# ORDER BY p.property_desc_plot_id, o.thesaurus_desc_plot_id;

# SELECT * FROM 
# (SELECT 'plot', property_desc_plot_id p, uri FROM core.property_desc_plot
# 	UNION
# SELECT 'profile', property_desc_profile_id p, uri FROM core.property_desc_profile
# 	UNION
# SELECT 'element', property_desc_element_id p, uri FROM core.property_desc_element) t
# WHERE t.uri IN (
# 	(SELECT uri FROM core.property_desc_plot
# 		UNION
# 	SELECT uri FROM core.property_desc_profile
# 		UNION
# 	SELECT uri FROM core.property_desc_element)
# 		EXCEPT
# 	SELECT uri FROM core.glosis_db_vocab
# ) ORDER BY 3;--46


# SELECT 'plot' feature, p.property_desc_plot_id property_db_name, '' property_rename, '' property_pretty_name, t.label thesaurus, '' thesaurus_order, p.uri property_uri, t.uri thesaurus_uri, o.procedure_desc_id "procedure", 'TO BE REVIWED' note
# FROM 
# (
# 	SELECT property_desc_plot_id, uri FROM core.property_desc_plot
# 	WHERE uri IN (
# 		(SELECT uri FROM core.property_desc_plot
# 			UNION
# 		SELECT uri FROM core.property_desc_profile
# 			UNION
# 		SELECT uri FROM core.property_desc_element)
# 			EXCEPT
# 		SELECT property_uri FROM core.glosis_db_vocab
# 	)
# ) p
# LEFT JOIN core.observation_desc_plot o ON o.property_desc_plot_id = p.property_desc_plot_id
# LEFT JOIN core.thesaurus_desc_plot t ON t.thesaurus_desc_plot_id = o.thesaurus_desc_plot_id
# ORDER BY p.property_desc_plot_id, o.thesaurus_desc_plot_id;

# SELECT 'profile' feature, p.property_desc_profile_id property_db_name, '' property_rename, '' property_pretty_name, t.label thesaurus, '' thesaurus_order, p.uri property_uri, t.uri thesaurus_uri, o.procedure_desc_id "procedure", 'TO BE REVIWED' note
# FROM 
# (
# 	SELECT property_desc_profile_id, uri FROM core.property_desc_profile
# 	WHERE uri IN (
# 		(SELECT uri FROM core.property_desc_profile
# 			UNION
# 		SELECT uri FROM core.property_desc_profile
# 			UNION
# 		SELECT uri FROM core.property_desc_element)
# 			EXCEPT
# 		SELECT property_uri FROM core.glosis_db_vocab
# 	)
# ) p
# LEFT JOIN core.observation_desc_profile o ON o.property_desc_profile_id = p.property_desc_profile_id
# LEFT JOIN core.thesaurus_desc_profile t ON t.thesaurus_desc_profile_id = o.thesaurus_desc_profile_id
# ORDER BY p.property_desc_profile_id, o.thesaurus_desc_profile_id;

# SELECT 'element' feature, p.property_desc_element_id property_db_name, '' property_rename, '' property_pretty_name, t.label thesaurus, '' thesaurus_order, p.uri property_uri, t.uri thesaurus_uri, o.procedure_desc_id "procedure", 'TO BE REVIWED' note
# FROM 
# (
# 	SELECT property_desc_element_id, uri FROM core.property_desc_element
# 	WHERE uri IN (
# 		(SELECT uri FROM core.property_desc_element
# 			UNION
# 		SELECT uri FROM core.property_desc_element
# 			UNION
# 		SELECT uri FROM core.property_desc_element)
# 			EXCEPT
# 		SELECT property_uri FROM core.glosis_db_vocab
# 	)
# ) p
# LEFT JOIN core.observation_desc_element o ON o.property_desc_element_id = p.property_desc_element_id
# LEFT JOIN core.thesaurus_desc_element t ON t.thesaurus_desc_element_id = o.thesaurus_desc_element_id
# ORDER BY p.property_desc_element_id, o.thesaurus_desc_element_id;

psql -h localhost -p 5432 -d sis -U glosis -c "
	ALTER TABLE core.glosis_db_vocab DROP COLUMN tmp_prop_uri;
	ALTER TABLE core.glosis_db_vocab ADD COLUMN tmp_prop_uri text;
	UPDATE core.glosis_db_vocab g SET tmp_prop_uri = p.uri FROM core.property_desc_plot p WHERE g.property_db_name = p.property_desc_plot_id;--1559
	UPDATE core.glosis_db_vocab g SET tmp_prop_uri = p.uri FROM core.property_desc_profile p WHERE g.property_db_name = p.property_desc_profile_id;--723
	UPDATE core.glosis_db_vocab g SET tmp_prop_uri = p.uri FROM core.property_desc_element p WHERE g.property_db_name = p.property_desc_element_id;--1539
	ALTER TABLE core.glosis_db_vocab DROP COLUMN tmp_prop_uri"

psql -h localhost -p 5432 -d sis -U glosis -c "
	UPDATE core.glosis_db_vocab g
	SET thesaurus_uri = u.uri
	FROM (
		SELECT o.property_desc_plot_id, t.label, t.uri
		FROM core.observation_desc_plot o 
		LEFT JOIN core.thesaurus_desc_plot t ON t.thesaurus_desc_plot_id = o.thesaurus_desc_plot_id
	) u
	WHERE g.property_db_name = u.property_desc_plot_id 
	AND (g.thesaurus = u.label OR u.label ILIKE trim(SPLIT_PART(g.thesaurus, ' - ', 2)));--351
	
	UPDATE core.glosis_db_vocab g
	SET thesaurus_uri = u.uri
	FROM (
		SELECT o.property_desc_profile_id, t.label, t.uri
		FROM core.observation_desc_profile o 
		LEFT JOIN core.thesaurus_desc_profile t ON t.thesaurus_desc_profile_id = o.thesaurus_desc_profile_id
	) u
	WHERE g.property_db_name = u.property_desc_profile_id
	AND (g.thesaurus = u.label OR u.label ILIKE trim(SPLIT_PART(g.thesaurus, ' - ', 2)));--1

	UPDATE core.glosis_db_vocab g
	SET thesaurus_uri = u.uri
	FROM (
		SELECT o.property_desc_element_id, t.label, t.uri
		FROM core.observation_desc_element o 
		LEFT JOIN core.thesaurus_desc_element t ON t.thesaurus_desc_element_id = o.thesaurus_desc_element_id
	) u
	WHERE g.property_db_name = u.property_desc_element_id 
	AND (g.thesaurus = u.label OR u.label ILIKE trim(SPLIT_PART(g.thesaurus, ' - ', 2)));--187"
