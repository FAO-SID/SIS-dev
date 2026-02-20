DROP TABLE IF EXISTS soil_data.codelist;
DROP TABLE IF EXISTS soil_data.codelist_item;

CREATE TABLE soil_data.codelist (
    "attribute" text,
    codelist_type text,
    concept_definition text,
    "source" text,
    "year" int2,
    page int2,
    object text,
    num real,
    uri text
    CONSTRAINT codelist_codelist_type_check CHECK ((codelist_type = ANY (ARRAY['classification'::text, 'procedure'::text]))),
    CONSTRAINT codelist_pkey PRIMARY KEY (attribute)
);

CREATE TABLE soil_data.codelist_item (
    "attribute" text,
    "instance" text,
    parent_instance text,
    notation text,
    "label" text,
    definition text,
    reference text,
    citation text,
    is_property bool DEFAULT false,
    pub_chem text,
    inchi_key text,
    inchi text,
    uri text,
    parent_uri text
    --CONSTRAINT codelist_item_pkey PRIMARY KEY (attribute, instance)
);

UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. More information is in the g','. See more in G') WHERE concept_definition LIKE '%. More information is in the g%'; -- 4
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. More in the G','. See more in G') WHERE concept_definition LIKE '%. More in the G%'; -- 3
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. More in the g','. See more in G') WHERE concept_definition LIKE '%. More in the g%'; -- 5
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'.See in G','. See more in G') WHERE concept_definition LIKE '%.See in G%'; -- 12
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more information in the G','. See more in G') WHERE concept_definition LIKE '%. See more information in the G%'; -- 4
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more in g','. See more in G') WHERE concept_definition LIKE '%. See more in g%'; -- 147
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'.See more in G','. See more in G') WHERE concept_definition LIKE '%.See more in G%'; -- 52
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more in the  G','. See more in G') WHERE concept_definition LIKE '%. See more in the  G%'; -- 4
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more in the g','. See more in G') WHERE concept_definition LIKE '%. See more in the g%'; -- 159
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more in the G','. See more in G') WHERE concept_definition LIKE '%. See more in the G%'; -- 68
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more on G','. See more in G') WHERE concept_definition LIKE '%. See more on G%'; -- 4
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'. See more onG','. See more in G') WHERE concept_definition LIKE '%. See more onG%'; -- 7
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'FAO: 20,1','FAO: table 20,1') WHERE concept_definition LIKE '%FAO: 20,1%'; -- 1
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'FAO: 77','FAO: table 77') WHERE concept_definition LIKE '%FAO: 77%'; -- 1
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'FAO: Guidelines for Soil Description issued by the FAO: table 56','FAO: table 56') WHERE concept_definition LIKE '%FAO: Guidelines for Soil Description issued by the FAO: table 56%'; -- 1
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'Guidelines for Soil Description issued by the FAO: table 54;Consistence when moist','Consistence when moist') WHERE concept_definition LIKE '%Guidelines for Soil Description issued by the FAO: table 54;Consistence when moist%'; -- 1
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'Guidelines for Soil Description issued by the FAO: table 47; Classification of structure','Classification of structure') WHERE concept_definition LIKE '%Guidelines for Soil Description issued by the FAO: table 47; Classification of structure%'; -- 1
UPDATE soil_data.glosis_cl SET concept_definition = REPLACE(concept_definition,'Guidelines for Soil Description issued by the FAO','Guidelines for Soil Description issued by the FAO 4th edition') WHERE concept_definition LIKE '%Guidelines for Soil Description issued by the FAO%'; -- 

TRUNCATE soil_data.codelist CASCADE; -- 118 -> 181
INSERT INTO soil_data.codelist ("attribute", codelist_type, concept_definition, "source")
    SELECT DISTINCT "attribute", 'classification', concept_definition, NULL
    FROM soil_data.glosis_cl
        UNION
    SELECT "instance", 'procedure', label || ' || ' || definition, concept_definition
    FROM soil_data.glosis_cl
    WHERE "attribute" = 'physioChemical';

TRUNCATE soil_data.codelist_item; -- 1212 -> 1121
--ALTER TABLE soil_data.codelist_item DROP CONSTRAINT IF EXISTS ontology_codelist_item_attribute_fkey;
INSERT INTO soil_data.codelist_item ("attribute", "instance", parent_instance, notation, "label", definition, reference, citation, is_property, pub_chem, inchi_key, inchi)
    SELECT "attribute", "instance", parent_instance, notation, "label", definition, reference, citation, isproperty, pub_chem, inchi_key, inchi
    FROM soil_data.glosis_cl
    WHERE "attribute" != 'physioChemical'
        UNION
    SELECT "attribute", "instance", parent_instance, notation, "label", definition, reference, citation, isproperty, pub_chem, inchi_key, inchi
    FROM soil_data.glosis_procedure;

DELETE FROM soil_data.codelist WHERE "attribute" = 'physioChemical';
UPDATE soil_data.codelist 
    SET codelist_type = 'procedure',
        "source" = concept_definition,
        concept_definition = NULL
WHERE concept_definition ILIKE 'ISRIC Report 2019/01%';

UPDATE soil_data.codelist SET "source" = split_part(split_part(concept_definition,'See more in ',2),':',1) WHERE concept_definition ILIKE '%See more in%' AND "source" IS NULL;
UPDATE soil_data.codelist SET "source" = 'ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System. Appendix 3' WHERE "attribute" = 'fragmentsClass';
UPDATE soil_data.codelist SET "source" = concept_definition WHERE "source" IS NULL;

UPDATE soil_data.codelist SET object = split_part(concept_definition,': ',2) WHERE concept_definition ILIKE '%: table%';
UPDATE soil_data.codelist SET object = split_part(concept_definition,': ',2) WHERE concept_definition ILIKE '%: figure%';
UPDATE soil_data.codelist SET object = replace(object,',','.') WHERE object ILIKE '%,%';

UPDATE soil_data.codelist SET num = replace(object,'figure','')::real WHERE object ILIKE 'figure%';
UPDATE soil_data.codelist SET num = replace(object,'table','')::real WHERE object ILIKE 'table%';

UPDATE soil_data.codelist SET object = 'table' WHERE object ILIKE 'table%';
UPDATE soil_data.codelist SET object = 'figure' WHERE object ILIKE 'figure%';

UPDATE soil_data.codelist c
SET page = g.page
FROM soil_data.gfsd_2006 g
WHERE c.object = g.object AND c.num::int = g.num;

UPDATE soil_data.codelist SET year = 2006 WHERE concept_definition ILIKE '%Guidelines for Soil Description issued by the FAO 4th%';
UPDATE soil_data.codelist SET year = 2019 WHERE "source" ILIKE 'ISRIC Report 2019%';
UPDATE soil_data.codelist SET year = 2017 WHERE "source" ILIKE 'ISO 14688-1:2017%';
UPDATE soil_data.codelist SET year = 2022 WHERE "source" ILIKE '%Geoderma, Volume 416, 2022%';

UPDATE soil_data.codelist SET uri = 'http://w3id.org/glosis/model/codelists/'||"attribute" WHERE codelist_type = 'classification';
UPDATE soil_data.codelist SET uri = 'http://w3id.org/glosis/model/procedure/'||"attribute" WHERE codelist_type = 'procedure';
UPDATE soil_data.codelist_item SET uri = 'http://w3id.org/glosis/model/codelists/'||"attribute"||'/'||instance;

--ALTER TABLE soil_data.codelist_item ADD CONSTRAINT ontology_codelist_item_attribute_fkey FOREIGN KEY ("attribute") REFERENCES soil_data.codelist("attribute") ON DELETE CASCADE;
