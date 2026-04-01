--
-- PostgreSQL database dump
--

\restrict epgGUAy2V2FKhYOL7ndefyUxmdcSemClNPyYxS6kgSUiwBhf1l7uMsgbzkeakng

-- Dumped from database version 12.22 (Ubuntu 12.22-3.pgdg22.04+1)
-- Dumped by pg_dump version 18.3 (Ubuntu 18.3-1.pgdg22.04+1)

-- Started on 2026-04-01 14:45:07 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 11 (class 2615 OID 55548721)
-- Name: api; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO sis;

--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA api IS 'REST API tables';


--
-- TOC entry 12 (class 2615 OID 55548722)
-- Name: kobo; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA kobo;


ALTER SCHEMA kobo OWNER TO sis;

--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA kobo; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA kobo IS 'GloSIS data collection database schema';


--
-- TOC entry 13 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: sis
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO sis;

--
-- TOC entry 14 (class 2615 OID 55548723)
-- Name: soil_data; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data;


ALTER SCHEMA soil_data OWNER TO sis;

--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data IS 'Core entities and relations from the ISO-28258 domain model';


--
-- TOC entry 15 (class 2615 OID 55548724)
-- Name: soil_data_upload; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data_upload;


ALTER SCHEMA soil_data_upload OWNER TO sis;

--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA soil_data_upload; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data_upload IS 'Schema to upload soil data';


--
-- TOC entry 16 (class 2615 OID 55548725)
-- Name: spatial_metadata; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA spatial_metadata;


ALTER SCHEMA spatial_metadata OWNER TO sis;

--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA spatial_metadata; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA spatial_metadata IS 'Schema for spatial metadata';


--
-- TOC entry 5 (class 3079 OID 55546962)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 4 (class 3079 OID 55548048)
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- TOC entry 3 (class 3079 OID 55548609)
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- TOC entry 2 (class 3079 OID 55548686)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1641 (class 1255 OID 55548726)
-- Name: check_result_value(); Type: FUNCTION; Schema: soil_data; Owner: sis
--

CREATE FUNCTION soil_data.check_result_value() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    observation soil_data.observation_phys_chem%ROWTYPE;
BEGIN
    SELECT * 
      INTO observation
      FROM soil_data.observation_phys_chem
     WHERE observation_phys_chem_id = NEW.observation_phys_chem_id;
    
    IF NEW.value < observation.value_min OR NEW.value > observation.value_max THEN
        RAISE EXCEPTION 'Result value outside admissable bounds for the related observation.';
    ELSE
        RETURN NEW;
    END IF; 
END;
$$;


ALTER FUNCTION soil_data.check_result_value() OWNER TO sis;

--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 1641
-- Name: FUNCTION check_result_value(); Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON FUNCTION soil_data.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';


--
-- TOC entry 1642 (class 1255 OID 55548727)
-- Name: generate_item_uri(); Type: FUNCTION; Schema: soil_data; Owner: sis
--

CREATE FUNCTION soil_data.generate_item_uri() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_codelist_type TEXT;
    v_attribute TEXT;
    v_base_uri TEXT;
BEGIN
    SELECT codelist_type, attribute INTO v_codelist_type, v_attribute
    FROM soil_data.ontology_codelist
    WHERE attribute = NEW.attribute;
    
    IF v_codelist_type = 'classification' THEN
        v_base_uri := 'http://w3id.org/glosis/model/codelists/';
    ELSE
        v_base_uri := 'http://w3id.org/glosis/model/procedure/';
    END IF;
    
    NEW.uri := v_base_uri || v_attribute || '/' || NEW.instance;
    
    IF NEW.parent_instance IS NOT NULL AND NEW.parent_instance != '' THEN
        NEW.parent_uri := v_base_uri || v_attribute || '/' || NEW.parent_instance;
    ELSE
        NEW.parent_uri := NULL;
    END IF;
    
    NEW.updated_at := CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION soil_data.generate_item_uri() OWNER TO sis;

--
-- TOC entry 1643 (class 1255 OID 55548728)
-- Name: class(); Type: FUNCTION; Schema: spatial_metadata; Owner: sis
--

CREATE FUNCTION spatial_metadata.class() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec_layer RECORD;
  rec_property RECORD;
  range FLOAT;
  interval_size FLOAT;
  current_min FLOAT;
  current_max FLOAT;
  i INT := 1;
  start_r INT;
  start_g INT;
  start_b INT;
  end_r INT;
  end_g INT;
  end_b INT;
  color TEXT;
BEGIN

SELECT  mapset_id, 
        min(stats_minimum) min, 
        max(stats_maximum) max
INTO rec_layer
FROM spatial_metadata.layer
WHERE mapset_id = NEW.mapset_id
GROUP BY mapset_id;

SELECT  property_type, 
        num_intervals,
        start_color,
        end_color
INTO rec_property
FROM spatial_metadata.property
WHERE property_id = split_part(NEW.mapset_id,'-',3);

  -- Only when property_type is quantitative
  IF rec_property.property_type = 'quantitative' THEN

    -- Validate num_intervals
    IF rec_property.num_intervals <= 0 THEN
        RAISE EXCEPTION 'Number of intervals must be greater than 0.';
    END IF;

    -- Validate start_color and end_color
    IF rec_property.start_color NOT LIKE '#______' OR rec_property.end_color NOT LIKE '#______' THEN
        RAISE EXCEPTION 'Colors must be in HEX format (e.g., #F4E7D3).';
    END IF;

    -- Check if stats_minimum and max are not NULL
    -- IF rec_layer.min IS NULL OR rec_layer.max IS NULL THEN
    --     RAISE EXCEPTION 'min and max must not be NULL.';
    -- END IF;

    -- Calculate the range and interval size
    range := rec_layer.max - rec_layer.min;
    IF range = 0 THEN
        RAISE EXCEPTION 'Range is 0. Cannot create intervals for layer_id %.', rec_property.layer_id;
    END IF;
    interval_size := range / rec_property.num_intervals;
    current_min := rec_layer.min;
    current_max := rec_layer.min + interval_size;

    -- Delete existing rows for this mapset_id
    DELETE FROM spatial_metadata.class WHERE mapset_id = rec_layer.mapset_id;

    -- Extract RGB components from start_color and end_color
    start_r := ('x' || SUBSTRING(rec_property.start_color FROM 2 FOR 2))::BIT(8)::INT;
    start_g := ('x' || SUBSTRING(rec_property.start_color FROM 4 FOR 2))::BIT(8)::INT;
    start_b := ('x' || SUBSTRING(rec_property.start_color FROM 6 FOR 2))::BIT(8)::INT;
    end_r := ('x' || SUBSTRING(rec_property.end_color FROM 2 FOR 2))::BIT(8)::INT;
    end_g := ('x' || SUBSTRING(rec_property.end_color FROM 4 FOR 2))::BIT(8)::INT;
    end_b := ('x' || SUBSTRING(rec_property.end_color FROM 6 FOR 2))::BIT(8)::INT;

    -- Loop to create intervals
    WHILE i <= rec_property.num_intervals LOOP
        -- Interpolate the color based on the interval index
        color := '#' || 
                LPAD(TO_HEX(start_r + (end_r - start_r) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_g + (end_g - start_g) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_b + (end_b - start_b) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0');

        -- Insert the class interval and color into the categories table
        INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish)
        VALUES (rec_layer.mapset_id, 
                COALESCE(current_min::numeric(30,2),0), 
                COALESCE(current_min::numeric(30,2),0) || ' - ' || COALESCE(current_max::numeric(30,2),0), 
                COALESCE(current_min::numeric(30,2),0) || ' - ' || COALESCE(current_max::numeric(30,2),0), 
                color, 
                1, 
                't')
        ON CONFLICT (mapset_id, value)
        DO UPDATE SET
            code = EXCLUDED.code,
            label = EXCLUDED.label,
            color = EXCLUDED.color,
            opacity = EXCLUDED.opacity,
            publish = EXCLUDED.publish;

        -- Update the current_min and current_max for the next interval
        current_min := current_max;
        current_max := current_max + interval_size;
        i := i + 1;
    END LOOP;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION spatial_metadata.class() OWNER TO sis;

--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 1643
-- Name: FUNCTION class(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.class() IS 'Trigger function that automatically generates classification intervals and colors for quantitative properties in mapsets based on layer statistics. Creates class entries with interpolated colors between start and end colors.';


--
-- TOC entry 1644 (class 1255 OID 55548729)
-- Name: map(); Type: FUNCTION; Schema: spatial_metadata; Owner: sis
--

CREATE FUNCTION spatial_metadata.map() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec_property RECORD;
  rec_layer RECORD;
BEGIN

SELECT 
	l.layer_id,
  CASE 
    WHEN l.distance_uom='m'  THEN 'METERS'
    WHEN l.distance_uom='km' THEN 'KILOMETERS'
    WHEN l.distance_uom='deg' THEN 'DD'
  END distance_uom,
  l.reference_system_identifier_code,
	l.extent,
	l.file_extension,
	l.stats_minimum,
	l.stats_maximum
INTO rec_layer
FROM spatial_metadata.layer l 
WHERE l.layer_id = NEW.layer_id;

SELECT m.mapset_id,
  p.start_color,
  p.end_color
INTO rec_property
FROM spatial_metadata.mapset m, spatial_metadata.property p
WHERE m.property_id = split_part(NEW.layer_id,'-',3);

UPDATE spatial_metadata.layer l SET map = 'MAP
  NAME "'||rec_layer.layer_id||'"
  EXTENT '||rec_layer.extent||'
  UNITS '||rec_layer.distance_uom||'
  SHAPEPATH "./"
  SIZE 800 600
  IMAGETYPE "PNG24"
  PROJECTION
      "init=epsg:'||rec_layer.reference_system_identifier_code||'"
  END # PROJECTION
  WEB
      METADATA
          "ows_title" "'||rec_layer.layer_id||' web-service" 
          "ows_enable_request" "*" 
          "ows_srs" "EPSG:'||rec_layer.reference_system_identifier_code||' EPSG:4326 EPSG:3857"
          "wms_getfeatureinfo_formatlist" "text/plain,text/html,application/json,geojson,application/vnd.ogc.gml,gml"
          "wms_feature_info_mime_type" "application/json"
      END # METADATA
  END # WEB
  LAYER
      TEMPLATE "getfeatureinfo.tmpl"
      NAME "'||rec_layer.layer_id||'"
      DATA "'||rec_layer.layer_id||'.'||rec_layer.file_extension||'"
      TYPE RASTER
      STATUS ON
      METADATA
        "wms_include_items" "all"
        "gml_include_items" "all"
      END # METADATA
      CLASS
        NAME "'||rec_layer.layer_id||'"
        STYLE
            COLORRANGE "'||rec_property.start_color||'" "'||rec_property.end_color||'"
            DATARANGE '||rec_layer.stats_minimum||' '||rec_layer.stats_maximum||'
            RANGEITEM "pixel"
          END # STYLE
      END # CLASS
  END # LAYER
END # MAP'
WHERE l.layer_id = NEW.layer_id;

  RETURN NEW;
END
$$;


ALTER FUNCTION spatial_metadata.map() OWNER TO sis;

--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 1644
-- Name: FUNCTION map(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.map() IS 'Trigger function that generates MapServer MAP file content for raster layers. Creates the complete MAP configuration including projection, WMS metadata, and styling based on property colors and layer statistics.';


--
-- TOC entry 1645 (class 1255 OID 55548730)
-- Name: sld(); Type: FUNCTION; Schema: spatial_metadata; Owner: sis
--

CREATE FUNCTION spatial_metadata.sld() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  sub_rec RECORD;
  part_1 text := '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>LAYER_NAME</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="property_type">';
  part_2 text :='';
  new_row text;
  part_3 text := '
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>';

BEGIN
    FOR rec IN SELECT DISTINCT NEW.mapset_id, 
            CASE WHEN p.property_type='categorical'  THEN 'values'
                 WHEN p.property_type='quantitative' THEN 'intervals'
              END property_type
            FROM spatial_metadata.mapset m, 
                 spatial_metadata.property p
            WHERE split_part(NEW.mapset_id,'-',3) = p.property_id
            ORDER BY NEW.mapset_id

    LOOP
	
      FOR sub_rec IN SELECT code, value, color, opacity, label FROM spatial_metadata.class WHERE mapset_id = NEW.mapset_id AND publish IS TRUE ORDER BY value
    	LOOP
		
			SELECT E'\n             <sld:ColorMapEntry quantity="' ||sub_rec.value|| '" color="' ||sub_rec.color|| '" opacity="' ||sub_rec.opacity|| '" label="' ||sub_rec.label|| '"/>' INTO new_row;

			SELECT part_2 || new_row INTO part_2;
		
		END LOOP;
		
		  UPDATE spatial_metadata.mapset SET sld = replace(replace(part_1,'LAYER_NAME',NEW.mapset_id),'property_type',rec.property_type) || part_2 || part_3 WHERE mapset_id = NEW.mapset_id;
		  SELECT '' INTO part_2;
		  SELECT '' INTO new_row;
		  
	END LOOP;
  RETURN NEW;
END
$$;


ALTER FUNCTION spatial_metadata.sld() OWNER TO sis;

--
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 1645
-- Name: FUNCTION sld(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.sld() IS 'Trigger function that generates Styled Layer Descriptor (SLD) XML for mapsets. Creates OGC-compliant SLD documents with ColorMap entries based on the class table for map styling.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 55548731)
-- Name: api_client; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.api_client (
    api_client_id text NOT NULL,
    api_key text NOT NULL,
    is_active boolean DEFAULT true,
    created_at date DEFAULT CURRENT_DATE,
    expires_at date,
    last_login timestamp without time zone,
    description text DEFAULT ''::text NOT NULL
);


ALTER TABLE api.api_client OWNER TO sis;

--
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE api_client; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.api_client IS 'For server-to-server authentication';


--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.api_client_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.api_client_id IS 'Unique identifier for the API client';


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.api_key; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.api_key IS 'Secret API key for authentication';


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.is_active; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.is_active IS 'Flag indicating whether the client is active';


--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.created_at IS 'Date when the client was created';


--
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.expires_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.expires_at IS 'Date when the API key expires';


--
-- TOC entry 5333 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.last_login; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.last_login IS 'Timestamp of the last successful authentication';


--
-- TOC entry 5334 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN api_client.description; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.description IS 'Description of the API client purpose';


--
-- TOC entry 227 (class 1259 OID 55548740)
-- Name: audit; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.audit (
    audit_id integer NOT NULL,
    user_id text,
    api_client_id text,
    action text,
    details jsonb,
    ip_address inet,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE api.audit OWNER TO sis;

--
-- TOC entry 5336 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE audit; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.audit IS 'Track authentication attempts and API usage';


--
-- TOC entry 5337 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.audit_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.audit_id IS 'Synthetic primary key for the audit record';


--
-- TOC entry 5338 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.user_id IS 'Reference to the user who performed the action';


--
-- TOC entry 5339 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.api_client_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.api_client_id IS 'Reference to the API client that performed the action';


--
-- TOC entry 5340 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.action; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.action IS 'Type of action performed';


--
-- TOC entry 5341 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.details; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.details IS 'JSON object with action details';


--
-- TOC entry 5342 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.ip_address; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.ip_address IS 'IP address from which the action was performed';


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN audit.created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.created_at IS 'Timestamp when the action occurred';


--
-- TOC entry 228 (class 1259 OID 55548747)
-- Name: audit_audit_id_seq; Type: SEQUENCE; Schema: api; Owner: sis
--

ALTER TABLE api.audit ALTER COLUMN audit_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME api.audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 55548749)
-- Name: setting; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.setting (
    key text NOT NULL,
    value text
);


ALTER TABLE api.setting OWNER TO sis;

--
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE setting; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.setting IS 'Key-value store for API configuration settings';


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN setting.key; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.setting.key IS 'Setting identifier key';


--
-- TOC entry 5347 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN setting.value; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.setting.value IS 'Setting value';


--
-- TOC entry 230 (class 1259 OID 55548755)
-- Name: uploaded_dataset; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.uploaded_dataset (
    user_id text,
    project_id text,
    table_name text NOT NULL,
    file_name text NOT NULL,
    upload_date date DEFAULT CURRENT_DATE,
    ingestion_date date,
    status text,
    depth_if_topsoil smallint,
    n_rows integer,
    n_col smallint,
    has_cords boolean,
    cords_epsg integer,
    cords_check boolean DEFAULT false,
    note text,
    CONSTRAINT uploaded_dataset_status_check CHECK ((status = ANY (ARRAY['Uploaded'::text, 'Ingested'::text, 'Removed'::text])))
);


ALTER TABLE api.uploaded_dataset OWNER TO sis;

--
-- TOC entry 5349 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE uploaded_dataset; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.uploaded_dataset IS 'Tracks datasets uploaded by users for ingestion into the soil data schema';


--
-- TOC entry 5350 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.user_id IS 'Reference to the user who uploaded the dataset';


--
-- TOC entry 5351 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.project_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.project_id IS 'Reference to the project this dataset belongs to';


--
-- TOC entry 5352 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.table_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.table_name IS 'Name of the staging table containing the uploaded data';


--
-- TOC entry 5353 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.file_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.file_name IS 'Original filename of the uploaded file';


--
-- TOC entry 5354 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.upload_date; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.upload_date IS 'Date when the file was uploaded';


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.ingestion_date; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.ingestion_date IS 'Date when the data was ingested into the main schema';


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.status; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.status IS 'Current status: Uploaded, Ingested, or Removed';


--
-- TOC entry 5357 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.depth_if_topsoil; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.depth_if_topsoil IS 'Depth in cm if this is topsoil data';


--
-- TOC entry 5358 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.n_rows; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.n_rows IS 'Number of rows in the uploaded dataset';


--
-- TOC entry 5359 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.n_col; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.n_col IS 'Number of columns in the uploaded dataset';


--
-- TOC entry 5360 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.has_cords; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.has_cords IS 'Flag indicating whether the dataset contains coordinates';


--
-- TOC entry 5361 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.cords_epsg; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.cords_epsg IS 'EPSG code of the coordinate reference system';


--
-- TOC entry 5362 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.cords_check; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.cords_check IS 'Flag indicating whether coordinates have been validated';


--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN uploaded_dataset.note; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.note IS 'Additional notes about the dataset';


--
-- TOC entry 231 (class 1259 OID 55548764)
-- Name: uploaded_dataset_column; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.uploaded_dataset_column (
    table_name text NOT NULL,
    column_name text NOT NULL,
    property_num_id text,
    procedure_num_id text,
    unit_of_measure_id text,
    ignore_column boolean DEFAULT false,
    note text
);


ALTER TABLE api.uploaded_dataset_column OWNER TO sis;

--
-- TOC entry 5365 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE uploaded_dataset_column; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.uploaded_dataset_column IS 'Column mapping configuration for uploaded datasets';


--
-- TOC entry 5366 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.table_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.table_name IS 'Reference to the uploaded dataset table';


--
-- TOC entry 5367 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.column_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.column_name IS 'Name of the column in the uploaded dataset';


--
-- TOC entry 5368 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.property_num_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.property_num_id IS 'Mapped soil property identifier';


--
-- TOC entry 5369 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.procedure_num_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.procedure_num_id IS 'Mapped analytical procedure identifier';


--
-- TOC entry 5370 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.unit_of_measure_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.unit_of_measure_id IS 'Mapped unit of measure identifier';


--
-- TOC entry 5371 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.ignore_column; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.ignore_column IS 'Flag to ignore this column during ingestion';


--
-- TOC entry 5372 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN uploaded_dataset_column.note; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.note IS 'Additional notes about the column mapping';


--
-- TOC entry 232 (class 1259 OID 55548771)
-- Name: user; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api."user" (
    user_id text NOT NULL,
    password_hash text NOT NULL,
    is_active boolean DEFAULT true,
    is_admin boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_DATE,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone
);


ALTER TABLE api."user" OWNER TO sis;

--
-- TOC entry 5374 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "user"; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api."user" IS 'For human users who log in through the web application';


--
-- TOC entry 5375 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".user_id IS 'Unique identifier for the user (typically email or username)';


--
-- TOC entry 5376 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".password_hash; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".password_hash IS 'Bcrypt hash of the user password';


--
-- TOC entry 5377 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".is_active; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".is_active IS 'Flag indicating whether the user account is active';


--
-- TOC entry 5378 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".is_admin; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".is_admin IS 'Flag indicating whether the user has administrator privileges';


--
-- TOC entry 5379 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".created_at IS 'Timestamp when the user was created';


--
-- TOC entry 5380 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".updated_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".updated_at IS 'Timestamp of the last update to the user record';


--
-- TOC entry 5381 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "user".last_login; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".last_login IS 'Timestamp of the last successful login';


--
-- TOC entry 233 (class 1259 OID 55548781)
-- Name: element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.element (
    element_id integer NOT NULL,
    profile_id integer NOT NULL,
    order_element integer,
    upper_depth integer NOT NULL,
    lower_depth integer NOT NULL,
    type text NOT NULL,
    CONSTRAINT element_check CHECK ((lower_depth > upper_depth)),
    CONSTRAINT element_order_element_check CHECK ((order_element > 0)),
    CONSTRAINT element_type_check CHECK ((type = ANY (ARRAY['Horizon'::text, 'Layer'::text]))),
    CONSTRAINT element_upper_depth_check CHECK ((upper_depth >= 0)),
    CONSTRAINT element_upper_depth_check1 CHECK ((upper_depth <= 1000))
);


ALTER TABLE soil_data.element OWNER TO sis;

--
-- TOC entry 5383 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.element IS 'ProfileElement is the super-class of Horizon and Layer, which share the same basic properties. Horizons develop in a layer, which in turn have been developed throught geogenesis or anthropogenic action. Layers can be used to describe common characteristics of a set of adjoining horizons. For the time being no assocation is previewed between Horizon and Layer.';


--
-- TOC entry 5384 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.element_id IS 'Synthetic primary key.';


--
-- TOC entry 5385 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.profile_id IS 'Reference to the Profile to which this element belongs';


--
-- TOC entry 5386 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.order_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.order_element IS 'Order of this element within the Profile';


--
-- TOC entry 5387 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.upper_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.upper_depth IS 'Upper depth of this profile element in centimetres.';


--
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.lower_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.lower_depth IS 'Lower depth of this profile element in centimetres.';


--
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN element.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.type IS 'Type of profile element, Horizon or Layer';


--
-- TOC entry 234 (class 1259 OID 55548792)
-- Name: observation_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.observation_num (
    observation_num_id integer NOT NULL,
    property_num_id text NOT NULL,
    procedure_num_id text NOT NULL,
    unit_of_measure_id text NOT NULL,
    value_min real,
    value_max real
);


ALTER TABLE soil_data.observation_num OWNER TO sis;

--
-- TOC entry 5391 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE observation_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_num IS 'Physio-chemical observations for the Element feature of interest';


--
-- TOC entry 5392 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.observation_num_id IS 'Synthetic primary key for the observation';


--
-- TOC entry 5393 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.property_num_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5394 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.procedure_num_id IS 'Foreign key to the corresponding procedure';


--
-- TOC entry 5395 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.unit_of_measure_id IS 'Foreign key to the corresponding unit of measure (if applicable)';


--
-- TOC entry 5396 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.value_min; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_min IS 'Minimum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 5397 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN observation_num.value_max; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_max IS 'Maximum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 235 (class 1259 OID 55548798)
-- Name: plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.plot (
    plot_id integer NOT NULL,
    site_id integer NOT NULL,
    parent_plot_id integer,
    type text,
    altitude smallint,
    sampling_date date,
    positional_accuracy smallint,
    geom public.geometry(Point,4326),
    is_surface boolean DEFAULT false
);


ALTER TABLE soil_data.plot OWNER TO sis;

--
-- TOC entry 5399 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot IS 'Elementary area or location where individual observations are made and/or samples are taken. Plot is the main spatial feature of interest in ISO-28258. Plot has three sub-classes: Borehole, Pit and Surface. Surface features its own table since it has its own properties and a different geometry.';


--
-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_id IS 'Synthetic primary key.';


--
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN plot.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.site_id IS 'Foreign key to Site table.';


--
-- TOC entry 236 (class 1259 OID 55548805)
-- Name: profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.profile (
    profile_id integer NOT NULL,
    plot_id integer,
    profile_code character varying
);


ALTER TABLE soil_data.profile OWNER TO sis;

--
-- TOC entry 5403 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.profile IS 'An abstract, ordered set of soil horizons and/or layers.';


--
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_id IS 'Synthetic primary key.';


--
-- TOC entry 5405 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.plot_id IS 'Foreign key to Plot feature of interest';


--
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_code IS 'Natural primary key, if existing';


--
-- TOC entry 237 (class 1259 OID 55548811)
-- Name: result_num; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.result_num (
    observation_num_id integer NOT NULL,
    specimen_id integer NOT NULL,
    value real NOT NULL
);


ALTER TABLE soil_data.result_num OWNER TO carva014;

--
-- TOC entry 238 (class 1259 OID 55548814)
-- Name: specimen; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen (
    specimen_id integer NOT NULL,
    element_id integer NOT NULL,
    specimen_prep_process_id integer,
    code character varying
);


ALTER TABLE soil_data.specimen OWNER TO sis;

--
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE specimen; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen IS 'Soil Specimen is defined in ISO-28258 as: "a subtype of SF_Specimen. Soil Specimen may be taken in the Site, Plot, Profile, or ProfileElement including their subtypes." In this database Specimen is for now only associated to Plot for simplification.';


--
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN specimen.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_id IS 'Synthetic primary key.';


--
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN specimen.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.element_id IS 'Foreign key to the associated soil Plot';


--
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN specimen.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_prep_process_id IS 'Foreign key to the preparation process used on this soil Specimen.';


--
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN specimen.code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.code IS 'External code used to identify the soil Specimen (if used).';


--
-- TOC entry 239 (class 1259 OID 55548820)
-- Name: vw_api_manifest; Type: VIEW; Schema: api; Owner: sis
--

CREATE VIEW api.vw_api_manifest AS
 SELECT opc.property_num_id AS property,
    count(DISTINCT p.profile_id) AS profiles,
    count(*) AS observations,
    public.st_envelope(public.st_collect(plt.geom)) AS geom
   FROM (((((soil_data.observation_num opc
     JOIN soil_data.result_num rpc ON ((opc.observation_num_id = rpc.observation_num_id)))
     JOIN soil_data.specimen s ON ((rpc.specimen_id = s.specimen_id)))
     JOIN soil_data.element e ON ((s.element_id = e.element_id)))
     JOIN soil_data.profile p ON ((e.profile_id = p.profile_id)))
     JOIN soil_data.plot plt ON ((p.plot_id = plt.plot_id)))
  GROUP BY opc.property_num_id
  ORDER BY opc.property_num_id;


ALTER VIEW api.vw_api_manifest OWNER TO sis;

--
-- TOC entry 5414 (class 0 OID 0)
-- Dependencies: 239
-- Name: VIEW vw_api_manifest; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_manifest IS 'View to expose the list of soil properties and geographical extent';


--
-- TOC entry 240 (class 1259 OID 55548825)
-- Name: project; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project (
    project_id text NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE soil_data.project OWNER TO sis;

--
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE project; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project IS 'Provides the context of the data collection as a prerequisite for the proper use or reuse of these data.';


--
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.project_id IS 'Synthetic primary key.';


--
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.name IS 'Natural key with project name.';


--
-- TOC entry 241 (class 1259 OID 55548831)
-- Name: project_site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_site (
    project_id text NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE soil_data.project_site OWNER TO sis;

--
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE project_site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project_site IS 'Junction table linking projects to sites (many-to-many relationship)';


--
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN project_site.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_site.project_id IS 'Reference to the project';


--
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN project_site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_site.site_id IS 'Reference to the site';


--
-- TOC entry 242 (class 1259 OID 55548837)
-- Name: site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.site (
    site_id integer NOT NULL,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.site OWNER TO sis;

--
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.site IS 'Defined area which is subject to a soil quality investigation. Site is not a spatial feature of interest, but provides the link between the spatial features of interest (Plot) to the Project. The geometry can either be a location (point) or extent (polygon) but not both at the same time.';


--
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_id IS 'Synthetic primary key.';


--
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN site.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.geom IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 243 (class 1259 OID 55548843)
-- Name: vw_api_observation; Type: VIEW; Schema: api; Owner: sis
--

CREATE VIEW api.vw_api_observation AS
 SELECT p3.profile_code,
    e.upper_depth,
    e.lower_depth,
    o.property_num_id,
    o.procedure_num_id,
    r.value,
    o.unit_of_measure_id
   FROM ((((((((soil_data.project p
     LEFT JOIN soil_data.project_site sp ON ((sp.project_id = p.project_id)))
     LEFT JOIN soil_data.site s ON ((s.site_id = sp.site_id)))
     LEFT JOIN soil_data.plot p2 ON ((p2.site_id = s.site_id)))
     LEFT JOIN soil_data.profile p3 ON ((p3.plot_id = p2.plot_id)))
     LEFT JOIN soil_data.element e ON ((e.profile_id = p3.profile_id)))
     LEFT JOIN soil_data.specimen s2 ON ((s2.element_id = e.element_id)))
     LEFT JOIN soil_data.result_num r ON ((r.specimen_id = s2.specimen_id)))
     LEFT JOIN soil_data.observation_num o ON ((o.observation_num_id = r.observation_num_id)))
  ORDER BY p3.profile_code, e.upper_depth, o.property_num_id;


ALTER VIEW api.vw_api_observation OWNER TO sis;

--
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 243
-- Name: VIEW vw_api_observation; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';


--
-- TOC entry 244 (class 1259 OID 55548848)
-- Name: vw_api_profile; Type: VIEW; Schema: api; Owner: sis
--

CREATE VIEW api.vw_api_profile AS
 SELECT p.profile_id AS gid,
    p.profile_code,
    proj.name AS project_name,
    plt.altitude,
    plt.sampling_date AS date,
    plt.geom,
    (public.st_asgeojson(plt.geom))::json AS geometry
   FROM ((((soil_data.profile p
     JOIN soil_data.plot plt ON ((p.plot_id = plt.plot_id)))
     JOIN soil_data.site s ON ((plt.site_id = s.site_id)))
     LEFT JOIN soil_data.project_site ps ON ((s.site_id = ps.site_id)))
     LEFT JOIN soil_data.project proj ON ((ps.project_id = proj.project_id)))
  WHERE (plt.geom IS NOT NULL)
  ORDER BY p.profile_id;


ALTER VIEW api.vw_api_profile OWNER TO sis;

--
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 244
-- Name: VIEW vw_api_profile; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_profile IS 'View to expose the list of profiles';


--
-- TOC entry 245 (class 1259 OID 55548853)
-- Name: category_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.category_desc (
    category_desc_id text NOT NULL,
    notation text,
    category_name text,
    definition text,
    uri text
);


ALTER TABLE soil_data.category_desc OWNER TO sis;

--
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE category_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.category_desc IS 'Controlled vocabulary categories for descriptive properties. Contains thesaurus entries from GloSIS or other vocabularies.';


--
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN category_desc.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.category_desc.category_desc_id IS 'Primary key identifier for the category';


--
-- TOC entry 246 (class 1259 OID 55548859)
-- Name: element_element_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.element ALTER COLUMN element_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.element_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 55548861)
-- Name: individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE soil_data.individual OWNER TO sis;

--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE individual; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.individual IS 'Individuals associated with soil data collection, analysis, or project management';


--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN individual.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.individual.individual_id IS 'Unique identifier for the individual (typically name)';


--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN individual.email; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.individual.email IS 'Email address of the individual';


--
-- TOC entry 248 (class 1259 OID 55548867)
-- Name: languages; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.languages (
    language_code text NOT NULL,
    language_name text NOT NULL
);


ALTER TABLE soil_data.languages OWNER TO sis;

--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE languages; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.languages IS 'Reference table of supported languages for translations';


--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN languages.language_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.languages.language_code IS 'ISO 639-1 two-letter language code';


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN languages.language_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.languages.language_name IS 'Full name of the language in English';


--
-- TOC entry 249 (class 1259 OID 55548873)
-- Name: observation_desc; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.observation_desc (
    procedure_desc_id text NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL,
    category_order smallint,
    plot boolean,
    surface boolean,
    profile boolean,
    element boolean
);


ALTER TABLE soil_data.observation_desc OWNER TO carva014;

--
-- TOC entry 250 (class 1259 OID 55548879)
-- Name: observation_phys_chem_element_observation_phys_chem_element_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.observation_num ALTER COLUMN observation_num_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.observation_phys_chem_element_observation_phys_chem_element_seq
    START WITH 1008
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 251 (class 1259 OID 55548881)
-- Name: organisation; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.organisation (
    organisation_id text NOT NULL,
    url text,
    email text,
    country text,
    city text,
    postal_code text,
    delivery_point text,
    phone text,
    facsimile text
);


ALTER TABLE soil_data.organisation OWNER TO sis;

--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE organisation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.organisation IS 'Organizations involved in soil data projects and surveys';


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.organisation_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.organisation_id IS 'Unique identifier for the organization (typically name)';


--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.url; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.url IS 'Website URL of the organization';


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.email; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.email IS 'Contact email for the organization';


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.country; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.country IS 'Country where the organization is located';


--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.city; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.city IS 'City where the organization is located';


--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.postal_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.postal_code IS 'Postal code of the organization address';


--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.delivery_point; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.delivery_point IS 'Street address of the organization';


--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.phone; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.phone IS 'Phone number of the organization';


--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN organisation.facsimile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.facsimile IS 'Fax number of the organization';


--
-- TOC entry 252 (class 1259 OID 55548887)
-- Name: plot_plot_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.plot ALTER COLUMN plot_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.plot_plot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 253 (class 1259 OID 55548889)
-- Name: procedure_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_desc (
    procedure_desc_id text NOT NULL,
    reference character varying,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.procedure_desc OWNER TO sis;

--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE procedure_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_desc IS 'Descriptive Procedures for all features of interest. In most cases the procedure is described in a document such as the FAO Guidelines for Soil Description or the World Reference Base of Soil Resources.';


--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN procedure_desc.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.procedure_desc_id IS 'Synthetic primary key.';


--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN procedure_desc.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.reference IS 'Long and human readable reference to the publication.';


--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN procedure_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.uri IS 'URI to the corresponding publication, optimally a DOI. Follow this URI for the full definition of the procedure.';


--
-- TOC entry 254 (class 1259 OID 55548895)
-- Name: procedure_model; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.procedure_model (
    procedure_model_id integer NOT NULL,
    procedure_name text
);


ALTER TABLE soil_data.procedure_model OWNER TO carva014;

--
-- TOC entry 255 (class 1259 OID 55548901)
-- Name: procedure_model_def; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.procedure_model_def (
    procedure_model_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE soil_data.procedure_model_def OWNER TO carva014;

--
-- TOC entry 256 (class 1259 OID 55548907)
-- Name: procedure_model_procedure_model_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: carva014
--

ALTER TABLE soil_data.procedure_model ALTER COLUMN procedure_model_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.procedure_model_procedure_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 55548909)
-- Name: procedure_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_num (
    procedure_num_id text NOT NULL,
    broader_id text,
    procedure_name text,
    reference text,
    citation text,
    uri text
);


ALTER TABLE soil_data.procedure_num OWNER TO sis;

--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE procedure_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_num IS 'Physio-chemical Procedures for the Profile Element feature of interest';


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN procedure_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.procedure_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN procedure_num.broader_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.broader_id IS 'Foreign key to brader procedure in the hierarchy';


--
-- TOC entry 258 (class 1259 OID 55548915)
-- Name: procedure_spectrometer; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.procedure_spectrometer (
    procedure_spectrometer_id integer NOT NULL,
    procedure_name text
);


ALTER TABLE soil_data.procedure_spectrometer OWNER TO carva014;

--
-- TOC entry 259 (class 1259 OID 55548921)
-- Name: procedure_spectrometer_def; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.procedure_spectrometer_def (
    procedure_spectrometer_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE soil_data.procedure_spectrometer_def OWNER TO carva014;

--
-- TOC entry 260 (class 1259 OID 55548927)
-- Name: procedure_spectrometer_procedure_spectrometer_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: carva014
--

ALTER TABLE soil_data.procedure_spectrometer ALTER COLUMN procedure_spectrometer_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.procedure_spectrometer_procedure_spectrometer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 261 (class 1259 OID 55548929)
-- Name: profile_profile_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.profile ALTER COLUMN profile_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.profile_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 262 (class 1259 OID 55548931)
-- Name: proj_x_org_x_ind; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.proj_x_org_x_ind (
    project_id text NOT NULL,
    organisation_id text NOT NULL,
    individual_id text NOT NULL,
    "position" text NOT NULL,
    tag text NOT NULL,
    role text NOT NULL,
    CONSTRAINT proj_x_org_x_ind_role_check CHECK ((role = ANY (ARRAY['author'::text, 'custodian'::text, 'distributor'::text, 'originator'::text, 'owner'::text, 'pointOfContact'::text, 'principalInvestigator'::text, 'processor'::text, 'publisher'::text, 'resourceProvider'::text, 'user'::text]))),
    CONSTRAINT proj_x_org_x_ind_tag_check CHECK ((tag = ANY (ARRAY['contact'::text, 'pointOfContact'::text])))
);


ALTER TABLE soil_data.proj_x_org_x_ind OWNER TO sis;

--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE proj_x_org_x_ind; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.proj_x_org_x_ind IS 'Junction table linking projects, organizations, and individuals with their roles';


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.project_id IS 'Reference to the project';


--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind.organisation_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.organisation_id IS 'Reference to the organization';


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.individual_id IS 'Reference to the individual';


--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind."position"; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind."position" IS 'Position or job title of the individual within the organization';


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind.tag; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.tag IS 'Contact type: contact or pointOfContact';


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN proj_x_org_x_ind.role; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.role IS 'ISO 19115 CI_RoleCode: author, custodian, distributor, etc.';


--
-- TOC entry 263 (class 1259 OID 55548939)
-- Name: project_soil_map; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_soil_map (
    project_id text NOT NULL,
    soil_map_id integer NOT NULL,
    remarks text
);


ALTER TABLE soil_data.project_soil_map OWNER TO sis;

--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project_soil_map IS 'Links soil maps to projects (relatedMap many-to-many)';


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN project_soil_map.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.project_id IS 'Reference to the project';


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN project_soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.soil_map_id IS 'Reference to the soil map (relatedMap)';


--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN project_soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 264 (class 1259 OID 55548945)
-- Name: property_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_desc (
    property_desc_id text NOT NULL,
    property_name text,
    definition text,
    uri text
);


ALTER TABLE soil_data.property_desc OWNER TO sis;

--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE property_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_desc IS 'Descriptive soil properties used for categorical observations';


--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN property_desc.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_desc.property_desc_id IS 'Primary key identifier for the property';


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN property_desc.property_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_desc.property_name IS 'Human-readable display name for the property';


--
-- TOC entry 265 (class 1259 OID 55548951)
-- Name: property_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_num (
    property_num_id text NOT NULL,
    property_name text,
    definition text,
    uri text
);


ALTER TABLE soil_data.property_num OWNER TO sis;

--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE property_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_num IS 'Physio-chemical properties for the Element feature of interest';


--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN property_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.property_num_id IS 'Synthetic primary key.';


--
-- TOC entry 266 (class 1259 OID 55548957)
-- Name: result_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_element (
    element_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_element OWNER TO sis;

--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE result_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_element IS 'Descriptive results for the Element feature interest.';


--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN result_desc_element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.element_id IS 'Foreign key to the corresponding Element feature of interest.';


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN result_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.property_desc_id IS 'Foreign key to property_desc_element table.';


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN result_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.category_desc_id IS 'Foreign key to thesaurus_desc_element table.';


--
-- TOC entry 267 (class 1259 OID 55548963)
-- Name: result_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_plot (
    plot_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_plot OWNER TO sis;

--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE result_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_plot IS 'Descriptive results for the Plot feature interest.';


--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN result_desc_plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.plot_id IS 'Foreign key to the corresponding Plot feature of interest.';


--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN result_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.property_desc_id IS 'Foreign key to property_desc_plot table.';


--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN result_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.category_desc_id IS 'Foreign key to thesaurus_desc_plot table.';


--
-- TOC entry 268 (class 1259 OID 55548969)
-- Name: result_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_profile (
    profile_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_profile OWNER TO sis;

--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE result_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_profile IS 'Descriptive results for the Profile feature interest.';


--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN result_desc_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.profile_id IS 'Foreign key to the corresponding Profile feature of interest.';


--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN result_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.property_desc_id IS 'Foreign key to property_desc_profile table.';


--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN result_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.category_desc_id IS 'Foreign key to thesaurus_desc_profile table.';


--
-- TOC entry 269 (class 1259 OID 55548975)
-- Name: result_desc_surface; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.result_desc_surface (
    surface_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_surface OWNER TO carva014;

--
-- TOC entry 270 (class 1259 OID 55548981)
-- Name: result_spectral; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.result_spectral (
    result_spectral_id integer NOT NULL,
    observation_num_id integer NOT NULL,
    procedure_model_id integer NOT NULL,
    value real NOT NULL
);


ALTER TABLE soil_data.result_spectral OWNER TO carva014;

--
-- TOC entry 271 (class 1259 OID 55548984)
-- Name: result_spectral_result_spectral_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: carva014
--

ALTER TABLE soil_data.result_spectral ALTER COLUMN result_spectral_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.result_spectral_result_spectral_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 272 (class 1259 OID 55548986)
-- Name: site_site_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.site ALTER COLUMN site_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.site_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 273 (class 1259 OID 55548988)
-- Name: soil_map; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_map (
    soil_map_id integer NOT NULL,
    name text NOT NULL,
    description text,
    scale_denominator integer,
    spatial_resolution_m numeric(10,2),
    publication_date date,
    remarks text,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.soil_map OWNER TO sis;

--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_map IS 'A soil map containing delineated mapping units (ISO 28258 SoilMap feature)';


--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.soil_map_id IS 'Unique identifier for the soil map';


--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.name IS 'Name of the soil map';


--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.description IS 'Detailed description of the soil map';


--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.scale_denominator; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.scale_denominator IS 'Map scale denominator (e.g., 50000 for 1:50,000)';


--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.spatial_resolution_m; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.spatial_resolution_m IS 'Spatial resolution in meters';


--
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.publication_date; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.publication_date IS 'Date when the map was published';


--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.geom IS 'Polygon geometry representing the map extent (EPSG:4326)';


--
-- TOC entry 274 (class 1259 OID 55548994)
-- Name: soil_map_soil_map_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.soil_map ALTER COLUMN soil_map_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.soil_map_soil_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 275 (class 1259 OID 55548996)
-- Name: soil_mapping_unit; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_mapping_unit (
    mapping_unit_id integer NOT NULL,
    category_id integer NOT NULL,
    explanation text,
    remarks text,
    geom public.geometry(MultiPolygon,4326) NOT NULL
);


ALTER TABLE soil_data.soil_mapping_unit OWNER TO sis;

--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE soil_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit IS 'Delineated polygon on a soil map (ISO 28258 SoilMappingUnit feature)';


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN soil_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.mapping_unit_id IS 'Unique identifier for the mapping unit';


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN soil_mapping_unit.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.category_id IS 'Reference to the mapping unit category (required, many-to-one)';


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN soil_mapping_unit.explanation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.explanation IS 'Explanation or description of the mapping unit';


--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN soil_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN soil_mapping_unit.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.geom IS 'MultiPolygon geometry of the mapping unit (EPSG:4326)';


--
-- TOC entry 276 (class 1259 OID 55549002)
-- Name: soil_mapping_unit_category; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_mapping_unit_category (
    category_id integer NOT NULL,
    soil_map_id integer,
    parent_category_id integer,
    name text NOT NULL,
    description text,
    legend_order integer,
    symbol text,
    colour_rgb text,
    remarks text
);


ALTER TABLE soil_data.soil_mapping_unit_category OWNER TO sis;

--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_category IS 'Legend category describing soil types in a map with hierarchical subcategories (ISO 28258 SoilMappingUnitCategory)';


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.category_id IS 'Unique identifier for the category';


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.soil_map_id IS 'Reference to soil map - only set for root categories (rootCategory relationship)';


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.parent_category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.parent_category_id IS 'Reference to parent category for subcategory hierarchy';


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.name IS 'Name of the mapping unit category';


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.description IS 'Detailed description of the category';


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.legend_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.legend_order IS 'Order in the map legend';


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.symbol; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.symbol IS 'Symbol used in the map legend';


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.colour_rgb; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.colour_rgb IS 'RGB colour code for map display (e.g., #A52A2A)';


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.remarks IS 'Additional remarks or notes';


--
-- TOC entry 277 (class 1259 OID 55549008)
-- Name: soil_mapping_unit_category_category_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.soil_mapping_unit_category ALTER COLUMN category_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.soil_mapping_unit_category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 278 (class 1259 OID 55549010)
-- Name: soil_mapping_unit_mapping_unit_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.soil_mapping_unit ALTER COLUMN mapping_unit_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.soil_mapping_unit_mapping_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 279 (class 1259 OID 55549012)
-- Name: soil_mapping_unit_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_mapping_unit_profile (
    mapping_unit_id integer NOT NULL,
    profile_id integer NOT NULL,
    is_representative boolean DEFAULT true,
    remarks text
);


ALTER TABLE soil_data.soil_mapping_unit_profile OWNER TO sis;

--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE soil_mapping_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_profile IS 'Links profiles to mapping units (profile relationship 0..*)';


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN soil_mapping_unit_profile.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN soil_mapping_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.profile_id IS 'Reference to the soil profile';


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN soil_mapping_unit_profile.is_representative; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.is_representative IS 'Whether this profile is representative for the mapping unit';


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN soil_mapping_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 280 (class 1259 OID 55549019)
-- Name: soil_typological_unit; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_typological_unit (
    typological_unit_id integer NOT NULL,
    name text NOT NULL,
    classification_scheme text NOT NULL,
    classification_version text NOT NULL,
    description text,
    remarks text
);


ALTER TABLE soil_data.soil_typological_unit OWNER TO sis;

--
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit IS 'Soil type classification unit (ISO 28258 SoilTypologicalUnit feature)';


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.typological_unit_id IS 'Unique identifier for the typological unit';


--
-- TOC entry 5539 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.name IS 'Name of the soil typological unit';


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_scheme; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_scheme IS 'Classification scheme used (e.g., WRB, Soil Taxonomy)';


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_version; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_version IS 'Version of the Classification scheme used';


--
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.description IS 'Detailed description of the typological unit';


--
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 281 (class 1259 OID 55549025)
-- Name: soil_typological_unit_mapping_unit; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_typological_unit_mapping_unit (
    typological_unit_id integer NOT NULL,
    mapping_unit_id integer NOT NULL,
    percentage smallint NOT NULL,
    remarks text,
    CONSTRAINT chk_percentage_range CHECK (((percentage > 0) AND (percentage <= 100)))
);


ALTER TABLE soil_data.soil_typological_unit_mapping_unit OWNER TO sis;

--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_mapping_unit IS 'Links typological units to mapping units with percentage composition (representedUnit/mapRepresentation). Percentages per SMU should sum to 100%.';


--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.typological_unit_id IS 'Reference to the soil typological unit (STU)';


--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.percentage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.percentage IS 'Percentage of the STU within the SMU (sum per SMU should equal 100)';


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 282 (class 1259 OID 55549032)
-- Name: soil_typological_unit_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_typological_unit_profile (
    typological_unit_id integer NOT NULL,
    profile_id integer NOT NULL,
    is_typical boolean DEFAULT true,
    remarks text
);


ALTER TABLE soil_data.soil_typological_unit_profile OWNER TO sis;

--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_profile IS 'Links profiles to typological units as typical profiles (typicalProfile relationship)';


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.typological_unit_id IS 'Reference to the typological unit';


--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.profile_id IS 'Reference to the profile (typicalProfile)';


--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.is_typical; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.is_typical IS 'Whether this is a typical profile for the typological unit';


--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 283 (class 1259 OID 55549039)
-- Name: soil_typological_unit_typological_unit_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.soil_typological_unit ALTER COLUMN typological_unit_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.soil_typological_unit_typological_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 55549041)
-- Name: specimen_prep_process; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_prep_process (
    specimen_prep_process_id integer NOT NULL,
    specimen_transport_id integer,
    specimen_storage_id integer,
    definition character varying NOT NULL
);


ALTER TABLE soil_data.specimen_prep_process OWNER TO sis;

--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE specimen_prep_process; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_prep_process IS 'Describes the preparation process of a soil Specimen. Contains information that does not result from observation(s).';


--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN specimen_prep_process.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_prep_process_id IS 'Synthetic primary key.';


--
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN specimen_prep_process.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_transport_id IS 'Foreign key for the corresponding mode of transport';


--
-- TOC entry 5561 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN specimen_prep_process.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_storage_id IS 'Foreign key for the corresponding mode of storage';


--
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN specimen_prep_process.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.definition IS 'Further details necessary to define the preparation process.';


--
-- TOC entry 285 (class 1259 OID 55549047)
-- Name: specimen_prep_process_specimen_prep_process_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.specimen_prep_process ALTER COLUMN specimen_prep_process_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.specimen_prep_process_specimen_prep_process_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 286 (class 1259 OID 55549049)
-- Name: specimen_specimen_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.specimen ALTER COLUMN specimen_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.specimen_specimen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 287 (class 1259 OID 55549051)
-- Name: specimen_storage; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_storage (
    specimen_storage_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_storage OWNER TO sis;

--
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE specimen_storage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_storage IS 'Modes of storage of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN specimen_storage.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.specimen_storage_id IS 'Synthetic primary key.';


--
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN specimen_storage.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.label IS 'Short label for the storage mode.';


--
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN specimen_storage.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.definition IS 'Long definition providing all the necessary details for the storage mode.';


--
-- TOC entry 288 (class 1259 OID 55549057)
-- Name: specimen_storage_specimen_storage_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.specimen_storage ALTER COLUMN specimen_storage_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.specimen_storage_specimen_storage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 289 (class 1259 OID 55549059)
-- Name: specimen_transport; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_transport (
    specimen_transport_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_transport OWNER TO sis;

--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE specimen_transport; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_transport IS 'Modes of transport of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN specimen_transport.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.specimen_transport_id IS 'Synthetic primary key.';


--
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN specimen_transport.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.label IS 'Short label for the transport mode.';


--
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN specimen_transport.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.definition IS 'Long definition providing all the necessary details for the transport mode.';


--
-- TOC entry 290 (class 1259 OID 55549065)
-- Name: specimen_transport_specimen_transport_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.specimen_transport ALTER COLUMN specimen_transport_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.specimen_transport_specimen_transport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 291 (class 1259 OID 55549067)
-- Name: spectral_sample; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.spectral_sample (
    spectral_sample_id text NOT NULL,
    specimen_id integer NOT NULL
);


ALTER TABLE soil_data.spectral_sample OWNER TO carva014;

--
-- TOC entry 292 (class 1259 OID 55549073)
-- Name: spectrum; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.spectrum (
    spectrum_id integer NOT NULL,
    spectral_sample_id text NOT NULL,
    procedure_spectrometer_id integer NOT NULL,
    spectrum jsonb
);


ALTER TABLE soil_data.spectrum OWNER TO carva014;

--
-- TOC entry 293 (class 1259 OID 55549079)
-- Name: spectrum_spectrum_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: carva014
--

ALTER TABLE soil_data.spectrum ALTER COLUMN spectrum_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.spectrum_spectrum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 294 (class 1259 OID 55549081)
-- Name: spectrum_x_result_spectral; Type: TABLE; Schema: soil_data; Owner: carva014
--

CREATE TABLE soil_data.spectrum_x_result_spectral (
    result_spectral_id integer NOT NULL,
    spectrum_id integer NOT NULL
);


ALTER TABLE soil_data.spectrum_x_result_spectral OWNER TO carva014;

--
-- TOC entry 295 (class 1259 OID 55549084)
-- Name: translate; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.translate (
    table_name text NOT NULL,
    column_name text NOT NULL,
    language_code text NOT NULL,
    string text NOT NULL,
    translation text
);


ALTER TABLE soil_data.translate OWNER TO sis;

--
-- TOC entry 5578 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE translate; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.translate IS 'Multilingual translations for database content';


--
-- TOC entry 5579 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN translate.table_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.table_name IS 'Name of the source table containing the translatable content';


--
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN translate.column_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.column_name IS 'Name of the column containing the translatable content';


--
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN translate.language_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.language_code IS 'Target language code (ISO 639-1)';


--
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN translate.string; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.string IS 'Original string to be translated';


--
-- TOC entry 5583 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN translate.translation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.translation IS 'Translated string in the target language';


--
-- TOC entry 296 (class 1259 OID 55549090)
-- Name: unit_of_measure; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.unit_of_measure (
    unit_of_measure_id text NOT NULL,
    unit_name character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.unit_of_measure OWNER TO sis;

--
-- TOC entry 5585 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE unit_of_measure; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.unit_of_measure IS 'Unit of measure';


--
-- TOC entry 5586 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN unit_of_measure.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_of_measure_id IS 'Synthetic primary key.';


--
-- TOC entry 5587 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN unit_of_measure.unit_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_name IS 'Short label for this unit of measure';


--
-- TOC entry 5588 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN unit_of_measure.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.uri IS 'URI to the corresponding unit of measuree in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this unit of measure';


--
-- TOC entry 297 (class 1259 OID 55549096)
-- Name: class; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.class (
    mapset_id text NOT NULL,
    value real NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    color text NOT NULL,
    opacity real NOT NULL,
    publish boolean NOT NULL
);


ALTER TABLE spatial_metadata.class OWNER TO sis;

--
-- TOC entry 5590 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE class; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.class IS 'Legend classes for mapsets defining color and label for value ranges or categories';


--
-- TOC entry 5591 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.mapset_id IS 'Reference to the mapset this class belongs to';


--
-- TOC entry 5592 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.value; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.value IS 'Numeric value (for quantitative) or category code (for categorical)';


--
-- TOC entry 5593 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.code IS 'Short code for the class';


--
-- TOC entry 5594 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.label; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.label IS 'Display label for the class in legends';


--
-- TOC entry 5595 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.color IS 'Hex color code for map display (e.g., #FF5733)';


--
-- TOC entry 5596 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.opacity; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.opacity IS 'Opacity value from 0 to 1';


--
-- TOC entry 5597 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN class.publish; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.publish IS 'Flag indicating whether this class should be published';


--
-- TOC entry 298 (class 1259 OID 55549102)
-- Name: country; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.country (
    country_id character(2) NOT NULL,
    iso3_code character(3),
    gaul_code integer,
    color_code character(3),
    ar text,
    en text,
    es text,
    fr text,
    pt text,
    ru text,
    zh text,
    status text,
    disp_area character varying(3),
    capital text,
    continent text,
    un_reg text,
    unreg_note text,
    continent_custom text
);


ALTER TABLE spatial_metadata.country OWNER TO sis;

--
-- TOC entry 5599 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE country; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.country IS 'Reference table of countries with ISO codes and multilingual names';


--
-- TOC entry 5600 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.country_id IS 'ISO 3166-1 alpha-2 country code (primary key)';


--
-- TOC entry 5601 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.iso3_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.iso3_code IS 'ISO 3166-1 alpha-3 country code';


--
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.gaul_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.gaul_code IS 'FAO GAUL country code';


--
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.color_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.color_code IS 'Color code for map display';


--
-- TOC entry 5604 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.ar; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.ar IS 'Country name in Arabic';


--
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.en; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.en IS 'Country name in English';


--
-- TOC entry 5606 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.es; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.es IS 'Country name in Spanish';


--
-- TOC entry 5607 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.fr; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.fr IS 'Country name in French';


--
-- TOC entry 5608 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.pt; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.pt IS 'Country name in Portuguese';


--
-- TOC entry 5609 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.ru; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.ru IS 'Country name in Russian';


--
-- TOC entry 5610 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.zh; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.zh IS 'Country name in Chinese';


--
-- TOC entry 5611 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.status; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.status IS 'Country status (e.g., Member State, Territory)';


--
-- TOC entry 5612 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.disp_area; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.disp_area IS 'Disputed area indicator';


--
-- TOC entry 5613 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.capital; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.capital IS 'Capital city name';


--
-- TOC entry 5614 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.continent; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.continent IS 'Continent name';


--
-- TOC entry 5615 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.un_reg; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.un_reg IS 'UN region classification';


--
-- TOC entry 5616 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.unreg_note; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.unreg_note IS 'Notes about UN region classification';


--
-- TOC entry 5617 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN country.continent_custom; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.continent_custom IS 'Custom continent grouping for specific applications';


--
-- TOC entry 299 (class 1259 OID 55549108)
-- Name: individual; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE spatial_metadata.individual OWNER TO sis;

--
-- TOC entry 5619 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE individual; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.individual IS 'Individuals associated with spatial data projects';


--
-- TOC entry 5620 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN individual.individual_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.individual.individual_id IS 'Unique identifier for the individual';


--
-- TOC entry 5621 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN individual.email; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.individual.email IS 'Email address of the individual';


--
-- TOC entry 300 (class 1259 OID 55549114)
-- Name: layer; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.layer (
    mapset_id text NOT NULL,
    dimension_depth text,
    dimension_stats text,
    file_path text NOT NULL,
    layer_id text NOT NULL,
    file_extension text,
    file_size integer,
    file_size_pretty text,
    reference_layer boolean DEFAULT false,
    reference_system_identifier_code text,
    distance text,
    distance_uom text,
    extent text,
    west_bound_longitude numeric(4,1),
    east_bound_longitude numeric(4,1),
    south_bound_latitude numeric(4,1),
    north_bound_latitude numeric(4,1),
    distribution_format text,
    compression text,
    raster_size_x real,
    raster_size_y real,
    pixel_size_x real,
    pixel_size_y real,
    origin_x real,
    origin_y real,
    spatial_reference text,
    data_type text,
    no_data_value double precision,
    stats_minimum real,
    stats_maximum real,
    stats_mean real,
    stats_std_dev real,
    scale text,
    n_bands integer,
    metadata text[],
    map text,
    CONSTRAINT layer_dimension_stats_check CHECK ((dimension_stats = ANY (ARRAY['MEAN'::text, 'SDEV'::text, 'UNCT'::text, 'X'::text]))),
    CONSTRAINT layer_distance_uom_check CHECK ((distance_uom = ANY (ARRAY['m'::text, 'km'::text, 'deg'::text])))
);


ALTER TABLE spatial_metadata.layer OWNER TO sis;

--
-- TOC entry 5623 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE layer; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.layer IS 'Raster layer metadata and file information for spatial data';


--
-- TOC entry 5624 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.mapset_id IS 'Reference to the parent mapset';


--
-- TOC entry 5625 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.dimension_depth; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.dimension_depth IS 'Depth dimension value (e.g., 0-5cm, 5-15cm)';


--
-- TOC entry 5626 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.dimension_stats; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.dimension_stats IS 'Statistical dimension: MEAN, SDEV, UNCT, or X';


--
-- TOC entry 5627 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.file_path; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_path IS 'File system path to the raster file';


--
-- TOC entry 5628 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.layer_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.layer_id IS 'Unique identifier for the layer';


--
-- TOC entry 5629 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.file_extension; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_extension IS 'File extension (e.g., tif, nc)';


--
-- TOC entry 5630 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.file_size; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_size IS 'File size in bytes';


--
-- TOC entry 5631 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.file_size_pretty; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_size_pretty IS 'Human-readable file size';


--
-- TOC entry 5632 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.reference_layer; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.reference_layer IS 'Flag indicating if this is the reference layer for the mapset';


--
-- TOC entry 5633 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.reference_system_identifier_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.reference_system_identifier_code IS 'EPSG code of the coordinate reference system';


--
-- TOC entry 5634 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.distance; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distance IS 'Spatial resolution value';


--
-- TOC entry 5635 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.distance_uom; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distance_uom IS 'Unit of measure for distance: m, km, or deg';


--
-- TOC entry 5636 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.extent; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.extent IS 'Bounding box extent as text';


--
-- TOC entry 5637 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.west_bound_longitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.west_bound_longitude IS 'Western boundary longitude';


--
-- TOC entry 5638 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.east_bound_longitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.east_bound_longitude IS 'Eastern boundary longitude';


--
-- TOC entry 5639 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.south_bound_latitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.south_bound_latitude IS 'Southern boundary latitude';


--
-- TOC entry 5640 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.north_bound_latitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.north_bound_latitude IS 'Northern boundary latitude';


--
-- TOC entry 5641 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.distribution_format; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distribution_format IS 'Data distribution format';


--
-- TOC entry 5642 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.compression; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.compression IS 'Compression type used';


--
-- TOC entry 5643 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.raster_size_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.raster_size_x IS 'Number of columns in the raster';


--
-- TOC entry 5644 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.raster_size_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.raster_size_y IS 'Number of rows in the raster';


--
-- TOC entry 5645 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.pixel_size_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.pixel_size_x IS 'Pixel width in map units';


--
-- TOC entry 5646 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.pixel_size_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.pixel_size_y IS 'Pixel height in map units';


--
-- TOC entry 5647 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.origin_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.origin_x IS 'X coordinate of the raster origin';


--
-- TOC entry 5648 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.origin_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.origin_y IS 'Y coordinate of the raster origin';


--
-- TOC entry 5649 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.spatial_reference; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.spatial_reference IS 'Full spatial reference definition';


--
-- TOC entry 5650 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.data_type; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.data_type IS 'Raster data type (e.g., Float32, Int16)';


--
-- TOC entry 5651 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.no_data_value; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.no_data_value IS 'NoData value for the raster';


--
-- TOC entry 5652 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.stats_minimum; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_minimum IS 'Minimum value in the raster';


--
-- TOC entry 5653 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.stats_maximum; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_maximum IS 'Maximum value in the raster';


--
-- TOC entry 5654 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.stats_mean; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_mean IS 'Mean value in the raster';


--
-- TOC entry 5655 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.stats_std_dev; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_std_dev IS 'Standard deviation of values in the raster';


--
-- TOC entry 5656 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.scale; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.scale IS 'Map scale (e.g., 1:250000)';


--
-- TOC entry 5657 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.n_bands; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.n_bands IS 'Number of bands in the raster';


--
-- TOC entry 5658 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.metadata; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.metadata IS 'Array of additional metadata strings';


--
-- TOC entry 5659 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN layer.map; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.map IS 'Generated MapServer MAP file content';


--
-- TOC entry 301 (class 1259 OID 55549123)
-- Name: mapset; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.mapset (
    country_id text NOT NULL,
    project_id text NOT NULL,
    property_id text NOT NULL,
    mapset_id text NOT NULL,
    dimension text DEFAULT 'depth'::text,
    parent_identifier uuid,
    file_identifier uuid DEFAULT public.uuid_generate_v1(),
    language_code text DEFAULT 'eng'::text,
    metadata_standard_name text DEFAULT 'ISO 19115/19139'::text,
    metadata_standard_version text DEFAULT '1.0'::text,
    reference_system_identifier_code_space text DEFAULT 'EPSG'::text,
    title text,
    unit_of_measure_id text,
    creation_date date,
    publication_date date,
    revision_date date,
    edition text,
    citation_md_identifier_code text,
    citation_md_identifier_code_space text DEFAULT 'doi'::text,
    abstract text,
    status text DEFAULT 'completed'::text,
    update_frequency text DEFAULT 'asNeeded'::text,
    md_browse_graphic text,
    keyword_theme text[],
    keyword_place text[],
    keyword_discipline text[] DEFAULT '{"Soil science"}'::text[],
    access_constraints text DEFAULT 'copyright'::text,
    use_constraints text DEFAULT 'license'::text,
    other_constraints text,
    spatial_representation_type_code text DEFAULT 'grid'::text,
    presentation_form text DEFAULT 'mapDigital'::text,
    topic_category text[] DEFAULT '{geoscientificInformation,environment}'::text[],
    time_period_begin date,
    time_period_end date,
    scope_code text DEFAULT 'dataset'::text,
    lineage_statement text,
    lineage_source_uuidref text,
    lineage_source_title text,
    xml text,
    sld text,
    CONSTRAINT mapset_access_constraints_check CHECK ((access_constraints = ANY (ARRAY['copyright'::text, 'patent'::text, 'patentPending'::text, 'trademark'::text, 'license'::text, 'intellectualPropertyRights'::text, 'restricted'::text, 'otherRestrictions'::text]))),
    CONSTRAINT mapset_citation_md_identifier_code_space_check CHECK ((citation_md_identifier_code_space = ANY (ARRAY['doi'::text, 'uuid'::text]))),
    CONSTRAINT mapset_dimension_check CHECK ((dimension = ANY (ARRAY['depth'::text, 'time'::text]))),
    CONSTRAINT mapset_presentation_form_check CHECK ((presentation_form = ANY (ARRAY['mapDigital'::text, 'tableDigital'::text, 'mapHardcopy'::text, 'atlasHardcopy'::text]))),
    CONSTRAINT mapset_spatial_representation_type_code_check CHECK ((spatial_representation_type_code = ANY (ARRAY['grid'::text, 'vector'::text, 'textTable'::text, 'tin'::text, 'stereoModel'::text, 'video'::text]))),
    CONSTRAINT mapset_status_check CHECK ((status = ANY (ARRAY['completed'::text, 'historicalArchive'::text, 'obsolete'::text, 'onGoing'::text, 'planned'::text, 'required'::text, 'underDevelopment'::text]))),
    CONSTRAINT mapset_update_frequency_check CHECK ((update_frequency = ANY (ARRAY['continual'::text, 'daily'::text, 'weekly'::text, 'fortnightly'::text, 'monthly'::text, 'quarterly'::text, 'biannually'::text, 'annually'::text, 'asNeeded'::text, 'irregular'::text, 'notPlanned'::text, 'unknown'::text]))),
    CONSTRAINT mapset_use_constraints_check CHECK ((use_constraints = ANY (ARRAY['copyright'::text, 'patent'::text, 'patentPending'::text, 'trademark'::text, 'license'::text, 'intellectualPropertyRights'::text, 'restricted'::text, 'otherRestrictions'::text])))
);


ALTER TABLE spatial_metadata.mapset OWNER TO sis;

--
-- TOC entry 5661 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE mapset; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.mapset IS 'Mapset metadata container for organizing related spatial layers with ISO 19139 compliant metadata';


--
-- TOC entry 5662 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.country_id IS 'Reference to the country';


--
-- TOC entry 5663 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.project_id IS 'Reference to the project';


--
-- TOC entry 5664 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.property_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.property_id IS 'Reference to the soil property';


--
-- TOC entry 5665 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.mapset_id IS 'Unique identifier for the mapset';


--
-- TOC entry 5666 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.dimension; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.dimension IS 'Dimension type: depth or time';


--
-- TOC entry 5667 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.parent_identifier; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.parent_identifier IS 'UUID of a parent mapset for hierarchical relationships';


--
-- TOC entry 5668 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.file_identifier; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.file_identifier IS 'UUID for ISO 19139 metadata identification';


--
-- TOC entry 5669 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.language_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.language_code IS 'ISO 639-2 language code for metadata';


--
-- TOC entry 5670 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.metadata_standard_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.metadata_standard_name IS 'Name of the metadata standard used';


--
-- TOC entry 5671 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.metadata_standard_version; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.metadata_standard_version IS 'Version of the metadata standard';


--
-- TOC entry 5672 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.reference_system_identifier_code_space; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.reference_system_identifier_code_space IS 'Code space for CRS (typically EPSG)';


--
-- TOC entry 5673 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.title; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.title IS 'Title of the mapset for display';


--
-- TOC entry 5674 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.unit_of_measure_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.unit_of_measure_id IS 'Reference to the unit of measure';


--
-- TOC entry 5675 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.creation_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.creation_date IS 'Date when the mapset was created';


--
-- TOC entry 5676 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.publication_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.publication_date IS 'Date when the mapset was published';


--
-- TOC entry 5677 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.revision_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.revision_date IS 'Date of the last revision';


--
-- TOC entry 5678 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.edition; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.edition IS 'Edition or version identifier';


--
-- TOC entry 5679 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.citation_md_identifier_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.citation_md_identifier_code IS 'DOI or other persistent identifier';


--
-- TOC entry 5680 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.citation_md_identifier_code_space; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.citation_md_identifier_code_space IS 'Code space for identifier: doi or uuid';


--
-- TOC entry 5681 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.abstract; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.abstract IS 'Abstract describing the mapset content';


--
-- TOC entry 5682 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.status; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.status IS 'ISO 19115 MD_ProgressCode: completed, onGoing, etc.';


--
-- TOC entry 5683 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.update_frequency; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.update_frequency IS 'ISO 19115 MD_MaintenanceFrequencyCode';


--
-- TOC entry 5684 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.md_browse_graphic; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.md_browse_graphic IS 'URL to a browse graphic/thumbnail';


--
-- TOC entry 5685 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.keyword_theme; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_theme IS 'Array of thematic keywords';


--
-- TOC entry 5686 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.keyword_place; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_place IS 'Array of place keywords';


--
-- TOC entry 5687 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.keyword_discipline; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_discipline IS 'Array of discipline keywords';


--
-- TOC entry 5688 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.access_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.access_constraints IS 'ISO 19115 MD_RestrictionCode for access';


--
-- TOC entry 5689 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.use_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.use_constraints IS 'ISO 19115 MD_RestrictionCode for use';


--
-- TOC entry 5690 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.other_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.other_constraints IS 'Text description of other constraints';


--
-- TOC entry 5691 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.spatial_representation_type_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.spatial_representation_type_code IS 'ISO 19115 MD_SpatialRepresentationTypeCode';


--
-- TOC entry 5692 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.presentation_form; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.presentation_form IS 'ISO 19115 CI_PresentationFormCode';


--
-- TOC entry 5693 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.topic_category; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.topic_category IS 'Array of ISO 19115 MD_TopicCategoryCode values';


--
-- TOC entry 5694 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.time_period_begin; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.time_period_begin IS 'Start date of the temporal extent';


--
-- TOC entry 5695 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.time_period_end; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.time_period_end IS 'End date of the temporal extent';


--
-- TOC entry 5696 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.scope_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.scope_code IS 'ISO 19115 MD_ScopeCode';


--
-- TOC entry 5697 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.lineage_statement; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_statement IS 'Statement describing data lineage';


--
-- TOC entry 5698 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.lineage_source_uuidref; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_source_uuidref IS 'UUID reference to source data';


--
-- TOC entry 5699 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.lineage_source_title; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_source_title IS 'Title of source data';


--
-- TOC entry 5700 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.xml; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.xml IS 'Generated ISO 19139 XML metadata';


--
-- TOC entry 5701 (class 0 OID 0)
-- Dependencies: 301
-- Name: COLUMN mapset.sld; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.sld IS 'Generated SLD XML for styling';


--
-- TOC entry 302 (class 1259 OID 55549153)
-- Name: organisation; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.organisation (
    organisation_id text NOT NULL,
    url text,
    email text,
    country text,
    city text,
    postal_code text,
    delivery_point text,
    phone text,
    facsimile text
);


ALTER TABLE spatial_metadata.organisation OWNER TO sis;

--
-- TOC entry 5703 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE organisation; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.organisation IS 'Organizations associated with spatial data projects';


--
-- TOC entry 5704 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.organisation_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.organisation_id IS 'Unique identifier for the organization';


--
-- TOC entry 5705 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.url IS 'Website URL of the organization';


--
-- TOC entry 5706 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.email; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.email IS 'Contact email for the organization';


--
-- TOC entry 5707 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.country; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.country IS 'Country where the organization is located';


--
-- TOC entry 5708 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.city; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.city IS 'City where the organization is located';


--
-- TOC entry 5709 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.postal_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.postal_code IS 'Postal code of the organization address';


--
-- TOC entry 5710 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.delivery_point; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.delivery_point IS 'Street address of the organization';


--
-- TOC entry 5711 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.phone; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.phone IS 'Phone number of the organization';


--
-- TOC entry 5712 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN organisation.facsimile; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.facsimile IS 'Fax number of the organization';


--
-- TOC entry 303 (class 1259 OID 55549159)
-- Name: proj_x_org_x_ind; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.proj_x_org_x_ind (
    country_id text NOT NULL,
    project_id text NOT NULL,
    organisation_id text NOT NULL,
    individual_id text NOT NULL,
    "position" text NOT NULL,
    tag text NOT NULL,
    role text NOT NULL,
    CONSTRAINT proj_x_org_x_ind_role_check CHECK ((role = ANY (ARRAY['author'::text, 'custodian'::text, 'distributor'::text, 'originator'::text, 'owner'::text, 'pointOfContact'::text, 'principalInvestigator'::text, 'processor'::text, 'publisher'::text, 'resourceProvider'::text, 'user'::text]))),
    CONSTRAINT proj_x_org_x_ind_tag_check CHECK ((tag = ANY (ARRAY['contact'::text, 'pointOfContact'::text])))
);


ALTER TABLE spatial_metadata.proj_x_org_x_ind OWNER TO sis;

--
-- TOC entry 5714 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE proj_x_org_x_ind; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.proj_x_org_x_ind IS 'Junction table linking spatial projects, organizations, and individuals with their roles';


--
-- TOC entry 5715 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.country_id IS 'Reference to the country (part of project key)';


--
-- TOC entry 5716 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.project_id IS 'Reference to the project';


--
-- TOC entry 5717 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.organisation_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.organisation_id IS 'Reference to the organization';


--
-- TOC entry 5718 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.individual_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.individual_id IS 'Reference to the individual';


--
-- TOC entry 5719 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind."position"; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind."position" IS 'Position or job title of the individual';


--
-- TOC entry 5720 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.tag; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.tag IS 'Contact type: contact or pointOfContact';


--
-- TOC entry 5721 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN proj_x_org_x_ind.role; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.role IS 'ISO 19115 CI_RoleCode';


--
-- TOC entry 304 (class 1259 OID 55549167)
-- Name: project; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.project (
    country_id text NOT NULL,
    project_id text NOT NULL,
    project_name text,
    project_description text
);


ALTER TABLE spatial_metadata.project OWNER TO sis;

--
-- TOC entry 5723 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE project; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.project IS 'Spatial data projects organized by country';


--
-- TOC entry 5724 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN project.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.country_id IS 'Reference to the country (part of primary key)';


--
-- TOC entry 5725 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_id IS 'Unique identifier for the project within the country';


--
-- TOC entry 5726 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN project.project_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_name IS 'Human-readable name of the project';


--
-- TOC entry 5727 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN project.project_description; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_description IS 'Description of the project scope and objectives';


--
-- TOC entry 305 (class 1259 OID 55549173)
-- Name: property; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.property (
    property_id text NOT NULL,
    name text,
    property_num_id text,
    unit_of_measure_id text,
    min real,
    max real,
    property_type text NOT NULL,
    num_intervals smallint NOT NULL,
    start_color text NOT NULL,
    end_color text NOT NULL,
    keyword_theme text[],
    property_id_old text,
    CONSTRAINT property_property_type_check CHECK ((property_type = ANY (ARRAY['quantitative'::text, 'categorical'::text])))
);


ALTER TABLE spatial_metadata.property OWNER TO sis;

--
-- TOC entry 5729 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE property; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.property IS 'Soil properties for spatial data layers with visualization settings';


--
-- TOC entry 5730 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.property_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_id IS 'Unique identifier for the property';


--
-- TOC entry 5731 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.name IS 'Human-readable name of the property';


--
-- TOC entry 5732 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.property_num_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_num_id IS 'Reference to the numerical property definition';


--
-- TOC entry 5733 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.unit_of_measure_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.unit_of_measure_id IS 'Reference to the unit of measure';


--
-- TOC entry 5734 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.min; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.min IS 'Expected minimum value for the property';


--
-- TOC entry 5735 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.max; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.max IS 'Expected maximum value for the property';


--
-- TOC entry 5736 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.property_type; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_type IS 'Type: quantitative or categorical';


--
-- TOC entry 5737 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.num_intervals; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.num_intervals IS 'Number of classification intervals for legends';


--
-- TOC entry 5738 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.start_color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.start_color IS 'Start color for gradient (hex format)';


--
-- TOC entry 5739 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.end_color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.end_color IS 'End color for gradient (hex format)';


--
-- TOC entry 5740 (class 0 OID 0)
-- Dependencies: 305
-- Name: COLUMN property.keyword_theme; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.keyword_theme IS 'Array of thematic keywords for this property';


--
-- TOC entry 306 (class 1259 OID 55549180)
-- Name: url; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.url (
    mapset_id text NOT NULL,
    protocol text NOT NULL,
    url text NOT NULL,
    url_name text,
    url_description text,
    CONSTRAINT url_protocol_check CHECK ((protocol = ANY (ARRAY['OGC:WFS'::text, 'OGC:WCS'::text, 'OGC:WMS'::text, 'OGC:WMTS'::text, 'OGC:WMS-1.3.0-http-get-capabilities'::text, 'OGC:WMS-1.1.1-http-get-map'::text, 'OGC:WMS-1.3.0-http-get-map'::text, 'WWW:LINK-1.0-http--link'::text, 'WWW:LINK-1.0-http--related'::text, 'WWW:DOWNLOAD-1.0-http--download'::text])))
);


ALTER TABLE spatial_metadata.url OWNER TO sis;

--
-- TOC entry 5742 (class 0 OID 0)
-- Dependencies: 306
-- Name: TABLE url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.url IS 'Online resource URLs for mapsets (download, WMS, WFS, etc.)';


--
-- TOC entry 5743 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN url.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.mapset_id IS 'Reference to the mapset';


--
-- TOC entry 5744 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN url.protocol; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.protocol IS 'OGC or WWW protocol identifier';


--
-- TOC entry 5745 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN url.url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url IS 'Full URL to the resource';


--
-- TOC entry 5746 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN url.url_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url_name IS 'Display name for the URL';


--
-- TOC entry 5747 (class 0 OID 0)
-- Dependencies: 306
-- Name: COLUMN url.url_description; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url_description IS 'Description of what the URL provides';


--
-- TOC entry 5221 (class 0 OID 55548731)
-- Dependencies: 226
-- Data for Name: api_client; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api.api_client (api_client_id, api_key, is_active, created_at, expires_at, last_login, description) FROM stdin;
\.


--
-- TOC entry 5222 (class 0 OID 55548740)
-- Dependencies: 227
-- Data for Name: audit; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api.audit (audit_id, user_id, api_client_id, action, details, ip_address, created_at) FROM stdin;
\.


--
-- TOC entry 5224 (class 0 OID 55548749)
-- Dependencies: 229
-- Data for Name: setting; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api.setting (key, value) FROM stdin;
\.


--
-- TOC entry 5225 (class 0 OID 55548755)
-- Dependencies: 230
-- Data for Name: uploaded_dataset; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api.uploaded_dataset (user_id, project_id, table_name, file_name, upload_date, ingestion_date, status, depth_if_topsoil, n_rows, n_col, has_cords, cords_epsg, cords_check, note) FROM stdin;
\.


--
-- TOC entry 5226 (class 0 OID 55548764)
-- Dependencies: 231
-- Data for Name: uploaded_dataset_column; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api.uploaded_dataset_column (table_name, column_name, property_num_id, procedure_num_id, unit_of_measure_id, ignore_column, note) FROM stdin;
\.


--
-- TOC entry 5227 (class 0 OID 55548771)
-- Dependencies: 232
-- Data for Name: user; Type: TABLE DATA; Schema: api; Owner: sis
--

COPY api."user" (user_id, password_hash, is_active, is_admin, created_at, updated_at, last_login) FROM stdin;
\.


--
-- TOC entry 4798 (class 0 OID 55547280)
-- Dependencies: 212
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: sis
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 5237 (class 0 OID 55548853)
-- Dependencies: 245
-- Data for Name: category_desc; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.category_desc (category_desc_id, notation, category_name, definition, uri) FROM stdin;
bleachedSandValueCode-0	None	Bleached sand of surface coverage 0-2%	Bleached sand of surface coverage 0-2%	http://w3id.org/glosis/model/codelists/bleachedSandValueCode-0
bleachedSandValueCode-1	Low	Bleached sand of surface coverage 2-15%	Bleached sand of surface coverage 2-15%	http://w3id.org/glosis/model/codelists/bleachedSandValueCode-1
bleachedSandValueCode-2	Moderate	Bleached sand of surface coverage 15-40%	Bleached sand of surface coverage 15-40%	http://w3id.org/glosis/model/codelists/bleachedSandValueCode-2
bleachedSandValueCode-3	High	Bleached sand of surface coverage  40-80%	Bleached sand of surface coverage  40-80%	http://w3id.org/glosis/model/codelists/bleachedSandValueCode-3
bleachedSandValueCode-4	Dominant	Bleached sand of surface coverage more than 80%	Bleached sand of surface coverage more than 80%	http://w3id.org/glosis/model/codelists/bleachedSandValueCode-4
cracksDepthValueCode-D	D	Deep 10–20	Deep surface crack of 10 - 20 cm in depth	http://w3id.org/glosis/model/codelists/cracksDepthValueCode-D
cracksDepthValueCode-M	M	Medium 2–10	Medium surface crack of 2 - 10 cm in depth	http://w3id.org/glosis/model/codelists/cracksDepthValueCode-M
cracksDepthValueCode-S	S	Surface < 2	Surface crack less than 2 cm in depth	http://w3id.org/glosis/model/codelists/cracksDepthValueCode-S
cracksDepthValueCode-V	V	Very deep > 20	Very deep surface crack of more than 20 cm in depth	http://w3id.org/glosis/model/codelists/cracksDepthValueCode-V
cracksDistanceValueCode-C	C	Very closely spaced < 0.2	Very closely spaced surface crack with distance less than 0.2 m	http://w3id.org/glosis/model/codelists/cracksDistanceValueCode-C
cracksDistanceValueCode-D	D	Closely spaced 0.2–0.5	Closely spaced surface crack with distance between 0.2 - 0.5 m	http://w3id.org/glosis/model/codelists/cracksDistanceValueCode-D
cracksDistanceValueCode-M	M	Moderately widely spaced 0.5–2	Moderately widely spaced surface crack with distance between 0.5–2 m	http://w3id.org/glosis/model/codelists/cracksDistanceValueCode-M
cracksDistanceValueCode-V	V	Very widely spaced > 5	Very widely spaced surface crack with distance more than 5 m	http://w3id.org/glosis/model/codelists/cracksDistanceValueCode-V
cracksDistanceValueCode-W	W	Widely spaced 2–5	Widely spaced surface crack with distance between 2–5 m	http://w3id.org/glosis/model/codelists/cracksDistanceValueCode-W
cracksWidthValueCode-E	E	Extremely wide > 10cm	Extremely wide surface crack with width more than 10cm	http://w3id.org/glosis/model/codelists/cracksWidthValueCode-E
cracksWidthValueCode-F	F	Fine < 1cm	Fine surface crack with width less than 1 cm	http://w3id.org/glosis/model/codelists/cracksWidthValueCode-F
cracksWidthValueCode-M	M	Medium 1cm–2cm	Medium surface crack with width 1 - 2 cm	http://w3id.org/glosis/model/codelists/cracksWidthValueCode-M
cracksWidthValueCode-V	V	Very wide 5cm–10cm	Very wide surface crack with width 5cm - 10 cm	http://w3id.org/glosis/model/codelists/cracksWidthValueCode-V
cracksWidthValueCode-W	W	Wide 2cm–5cm	Wide surface crack with width 2 - 5 cm	http://w3id.org/glosis/model/codelists/cracksWidthValueCode-W
fragmentCoverValueCode-A	A	Abundant	40%–80% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-A
fragmentCoverValueCode-C	C	Common	5%–15% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-C
fragmentCoverValueCode-D	D	Dominant	> 80% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-D
fragmentCoverValueCode-F	F	Few	2%–5% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-F
fragmentCoverValueCode-M	M	Many	15%–40% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-M
fragmentCoverValueCode-N	N	None	0% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-N
fragmentCoverValueCode-V	V	Very few	0%–2% of coarse surface fragments	http://w3id.org/glosis/model/codelists/fragmentCoverValueCode-V
fragmentsSizeValueCode-B	B	Boulders	Boulders of coarse size of 20cm–60cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-B
fragmentsSizeValueCode-C	C	Coarse gravel	Coarse gravel of size 2cm–6cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-C
fragmentsSizeValueCode-F	F	Fine gravel	Fine gravel coarse size of 0.2cm–0.6cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-F
fragmentsSizeValueCode-L	L	Large boulders	Large boulders of coarse size 60cm–200cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-L
fragmentsSizeValueCode-M	M	Medium gravel	Medium gravel coarse size of 0.6cm–2.0cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-M
fragmentsSizeValueCode-S	S	Stones	Stones of coarse size 6cm–20cm	http://w3id.org/glosis/model/codelists/fragmentsSizeValueCode-S
rockAbundanceValueCode-A	A	Abundant	40%–80% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-A
rockAbundanceValueCode-C	C	Common	5%–15% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-C
rockAbundanceValueCode-D	D	Dominant	> 80% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-D
rockAbundanceValueCode-F	F	Few	2%–5% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-F
rockAbundanceValueCode-M	M	Many	15%–40% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-M
rockAbundanceValueCode-N	N	None	0% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-N
rockAbundanceValueCode-S	S	Stone line	any content, but concentrated at a distinct depth of a horizon	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-S
rockAbundanceValueCode-V	V	Very few	0%–2% of rock fragments	http://w3id.org/glosis/model/codelists/rockAbundanceValueCode-V
rockShapeValueCode-A	A	Angular	Angular rock shape	http://w3id.org/glosis/model/codelists/rockShapeValueCode-A
rockShapeValueCode-F	F	Flat	Flat rock shape	http://w3id.org/glosis/model/codelists/rockShapeValueCode-F
rockShapeValueCode-R	R	Rounded	Rounded rock shape	http://w3id.org/glosis/model/codelists/rockShapeValueCode-R
rockShapeValueCode-S	S	Subrounded	Subrounded rock shape	http://w3id.org/glosis/model/codelists/rockShapeValueCode-S
rockSizeValueCode-A	A	Artefacts	Aretfacts in soil measured in (mm)	http://w3id.org/glosis/model/codelists/rockSizeValueCode-A
rockSizeValueCode-AC	AC	Coarse artefacts	Coarse artefacts in soil greater than 20mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-AC
rockSizeValueCode-AF	AF	Fine artefacts	Fine artefacts in soild of size between 2mm–6mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-AF
rockSizeValueCode-AM	AM	Medium artefacts	6mm–20mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-AM
rockSizeValueCode-AV	AV	Very fine artefacts	Very fine artefacsts in soil of size < 2mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-AV
rockSizeValueCode-BL	BL	Boulders and large boulders	Combination of boulderds and large boulders	http://w3id.org/glosis/model/codelists/rockSizeValueCode-BL
rockSizeValueCode-C	C	Combination of classes	Class combination of rock fragment and artefacts	http://w3id.org/glosis/model/codelists/rockSizeValueCode-C
rockSizeValueCode-CS	CS	Coarse gravel and stones	Combination rock fragments and artefacts of coarse gravel and stones	http://w3id.org/glosis/model/codelists/rockSizeValueCode-CS
rockSizeValueCode-FM	FM	Fine and medium gravel/artefacts	Combination of fine and medium gravel and artefacts	http://w3id.org/glosis/model/codelists/rockSizeValueCode-FM
rockSizeValueCode-MC	MC	Medium and coarse gravel/artefacts	Combination of medium and course gravels and artefacts	http://w3id.org/glosis/model/codelists/rockSizeValueCode-MC
rockSizeValueCode-R	R	Rock fragments	Rock fragments measured in mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-R
rockSizeValueCode-RB	RB	Boulders	60mm–200mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RB
rockSizeValueCode-RC	RC	Coarse gravel	Coarse gravel of size  20mm–60mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RC
rockSizeValueCode-RF	RF	Fine gravel	Rock fragments of mainly fine gravel of size from 2mm–6mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RF
rockSizeValueCode-RL	RL	Large boulders	Rock fragments mainly in the form of large boulders of size more than 600mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RL
rockSizeValueCode-RM	RM	Medium gravel	Combination of rocks and artefacts of medium gravel of size from 6mm–20mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RM
rockSizeValueCode-RS	RS	Stones	Rock fragments mainly stones of size from 60mm–200mm	http://w3id.org/glosis/model/codelists/rockSizeValueCode-RS
rockSizeValueCode-SB	SB	Stones and boulders	Combination of stone and boulders	http://w3id.org/glosis/model/codelists/rockSizeValueCode-SB
weatheringValueCode-F	F	Fresh or slightly weathered	Fragments show little or no signs of weathering.	http://w3id.org/glosis/model/codelists/weatheringValueCode-F
weatheringValueCode-S	S	Strongly weathered	All but the most resistant minerals are weathered, strongly discoloured and altered throughout the fragments, which tend to disintegrate under only moderate pressure.	http://w3id.org/glosis/model/codelists/weatheringValueCode-S
weatheringValueCode-W	W	Weathered	Partial weathering is indicated by discoloration and loss of crystal form in the outer parts of the fragments while the centres remain relatively fresh and the fragments have lost little of their original strength.	http://w3id.org/glosis/model/codelists/weatheringValueCode-W
saltCoverValueCode-0	0	None	No salt content of 0%–2%	http://w3id.org/glosis/model/codelists/saltCoverValueCode-0
saltCoverValueCode-1	1	Low	Low salt content of 2%–15%	http://w3id.org/glosis/model/codelists/saltCoverValueCode-1
saltCoverValueCode-2	2	Moderate	Moderate salt content of 15%–40%	http://w3id.org/glosis/model/codelists/saltCoverValueCode-2
saltCoverValueCode-3	3	High	High salt content of 40%–80%	http://w3id.org/glosis/model/codelists/saltCoverValueCode-3
saltCoverValueCode-4	4	Dominant	Dominant salt content of more than 80%	http://w3id.org/glosis/model/codelists/saltCoverValueCode-4
saltThicknessValueCode-C	C	Thick	Layer of salt occurance is  5mm–20mm	http://w3id.org/glosis/model/codelists/saltThicknessValueCode-C
saltThicknessValueCode-F	F	Thin	Layer of salt occurance is  < 2mm	http://w3id.org/glosis/model/codelists/saltThicknessValueCode-F
saltThicknessValueCode-M	M	Medium	Layer of salt occurance is 2mm–5mm	http://w3id.org/glosis/model/codelists/saltThicknessValueCode-M
saltThicknessValueCode-N	N	None	No salt occurance	http://w3id.org/glosis/model/codelists/saltThicknessValueCode-N
saltThicknessValueCode-V	V	Very thick	Layer of salt occurance is > 20mm	http://w3id.org/glosis/model/codelists/saltThicknessValueCode-V
sealingConsistenceValueCode-E	E	Extremely hard	Surface sealing with consistency Extremely hard	http://w3id.org/glosis/model/codelists/sealingConsistenceValueCode-E
sealingConsistenceValueCode-H	H	Hard	Surface sealing with consistency Hard	http://w3id.org/glosis/model/codelists/sealingConsistenceValueCode-H
sealingConsistenceValueCode-S	S	Slightly hard	Surface sealing with consistency Slightly hard	http://w3id.org/glosis/model/codelists/sealingConsistenceValueCode-S
sealingConsistenceValueCode-V	V	Very hard	Surface sealing with consistency Very hard	http://w3id.org/glosis/model/codelists/sealingConsistenceValueCode-V
sealingThicknessValueCode-C	C	Thick	Surface sealing with thickness  5mm–20mm	http://w3id.org/glosis/model/codelists/sealingThicknessValueCode-C
sealingThicknessValueCode-F	F	Thin	Surface sealing with thickness < 2mm	http://w3id.org/glosis/model/codelists/sealingThicknessValueCode-F
sealingThicknessValueCode-M	M	Medium	Surface sealing with thickness  2mm–5mm	http://w3id.org/glosis/model/codelists/sealingThicknessValueCode-M
sealingThicknessValueCode-N	N	None	No surface sealing	http://w3id.org/glosis/model/codelists/sealingThicknessValueCode-N
sealingThicknessValueCode-V	V	Very thick	Surface sealing with thickness > 20mm	http://w3id.org/glosis/model/codelists/sealingThicknessValueCode-V
cropClassValueCode-Ce	Ce	Cereals	Crop code for Cereals class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce
cropClassValueCode-Ce_Ba	Ce_Ba	Barley	Crop code for Barley from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Ba
cropClassValueCode-Ce_Ma	Ce_Ma	Maize	Crop code for Maize from Cereals class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Ma
cropClassValueCode-Ce_Mi	Ce_Mi	Millet	Crop code for Millet from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Mi
cropClassValueCode-Ce_Oa	Ce_Oa	Oats	Crop code for Oats from Cereals class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Oa
cropClassValueCode-Ce_Pa	Ce_Pa	Rice, paddy	Crop code for Rice and paddy from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Pa
cropClassValueCode-Ce_Ri	Ce_Ra	Rice, dry	Crop code for Rice(dry) from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Ri
cropClassValueCode-Ce_Ry	Ce_Ry	Rye	Crop code for Rye from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Ry
cropClassValueCode-Ce_So	Ce_So	Sorghum	Crop code for Sorghum from Cereals class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_So
cropClassValueCode-Ce_Wh	Ce_Wh	Wheat	Crop code for Wheat from Cereal class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ce_Wh
cropClassValueCode-Fi	Fi	Fibre crops	Crop code for Fibre crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fi
cropClassValueCode-Fi_Co	Fi_Co	Cotton	Crop code for Cotton from Fiber crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fi_Co
cropClassValueCode-Fi_Ju	Fi_Ju	Jute	Crop code for Jute from Fiber crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fi_Ju
cropClassValueCode-Fo	Fo	Fodder plants	Crop code for Fodder plants class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo
cropClassValueCode-Fo_Al	Fo_Al	Alfalfa	Crop code for Alfalfa from fodder plants class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Al
cropClassValueCode-Fo_Cl	Fo_Cl	Clover	Crop code for Clover from Fodder class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Cl
cropClassValueCode-Fo_Gr	Fo_Gr	Grasses	Crop code for Grasses from Fodder plants class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Gr
cropClassValueCode-Fo_Ha	Fo_Ha	Hay	Crop code for Hay from Fodder class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Ha
cropClassValueCode-Fo_Le	Fo_Le	Leguminous	Crop code for Leguminous from fodder plants class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Le
cropClassValueCode-Fo_Ma	Fo_Ma	Maize	Crop code for Maize from Fodder plants class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Ma
cropClassValueCode-Fo_Pu	Fo_Pu	Pumpkins	Crop code for Pumpkins from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fo_Pu
cropClassValueCode-Fr	Fr	Fruits and melons	Crop code for Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr
cropClassValueCode-Fr_Ap	Fr_Ap	Apples	Crop code for Apples from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Ap
cropClassValueCode-Fr_Ba	Fr_Ba	Bananas	Crop code for Bananas from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Ba
cropClassValueCode-Fr_Ci	Fr_Ci	Citrus	Crop code for Citrus from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Ci
cropClassValueCode-Fr_Gr	Fr_Gr	Grapes, Wine, Raisins	Crop code for Grapes, Wine, Raisins from fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Gr
cropClassValueCode-Fr_Ma	Fr_Ma	Mangoes	Crop code for Mangoes from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Ma
cropClassValueCode-Fr_Me	Fr_Me	Melons	Crop code for Melons from Fruits and melons class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Fr_Me
cropClassValueCode-Lu	Lu	Semi-luxury foods and tobacco	Crop code for Semi-luxury foods and tobacco class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Lu
cropClassValueCode-Lu_Cc	Lu_Cc	Cocoa	Crop code for Cocoa from Semi-luxury foods and tobacco class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Lu_Cc
cropClassValueCode-Lu_Co	Lu_Co	Coffee	Crop code for Coffee from Semi-luxury foods and tobacco class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Lu_Co
cropClassValueCode-Lu_Te	Lu_Te	Tea	Crop code for Tea from Semi-luxury foods and tobacco class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Lu_Te
cropClassValueCode-Lu_To	Lu_To	Tobacco	Crop code for Tobacco from Semi-luxury foods and tobacco class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Lu_To
cropClassValueCode-Oi	Oi	Oilcrops	Crop code for Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi
cropClassValueCode-Oi_Cc	Oi_Cc	Coconuts	Crop code for Coconuts from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Cc
cropClassValueCode-Oi_Gr	Oi_Gr	Groundnuts	Crop code for Groundnuts from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Gr
cropClassValueCode-Oi_Li	Li	Linseed	Crop code for Linseed class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Li
cropClassValueCode-Oi_Op	Oi_Op	Oil-palm	Crop code for Oil-palm from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Op
cropClassValueCode-Oi_Ra	Oi_Ra	Rape	Crop code for Rape from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Ra
cropClassValueCode-Oi_Se	Oi_Se	Sesame	Crop code for Sesame from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Se
cropClassValueCode-Oi_So	Oi_So	Soybeans	Crop code for Soybeans from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_So
cropClassValueCode-Oi_Su	Oi_Su	Sunflower	Crop code for Sunflower from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Oi_Su
cropClassValueCode-Ol	Oi_Ol	Olives	Crop code for Olives from Oilcrops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ol
cropClassValueCode-Ot	Ot	Other crops	Crop code for Other crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ot
cropClassValueCode-Ot_Pa	Ot_Pa	Palm (fibres, kernels)	Crop code for Palm (fibres, kernels) from other crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ot_Pa
cropClassValueCode-Ot_Ru	Ot_Ru	Rubber	Crop code for Rubber from Other crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ot_Ru
cropClassValueCode-Ot_Sc	Ot_Sc	Sugar cane	Crop code for Sugar cane from other crops class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ot_Sc
cropClassValueCode-Pu	Pu	Pulses	Crop code for Pulses class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Pu
cropClassValueCode-Pu_Be	Pu_Be	Beans	Crop code for Beans from Pulses class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Pu_Be
cropClassValueCode-Pu_Le	Pu_Le	Lentils	Crop code for Lentils from Pulses class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Pu_Le
cropClassValueCode-Pu_Pe	Pu_Pe	Peas	Crop code for Peas from Pulses class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Pu_Pe
cropClassValueCode-Ro	Ro	Roots and tubers	Crop code for Roots and tubers class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ro
cropClassValueCode-Ro_Ca	Ro_Ca	Cassava	Crop code for Cassava from Roots and tubers class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ro_Ca
cropClassValueCode-Ro_Po	Ro_Po	Potatoes	Crop code for Potatoes from Roots and tubers class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ro_Po
cropClassValueCode-Ro_Su	Ro_Su	Sugar beets	Crop code for Sugar beets from Roots and tubers class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ro_Su
cropClassValueCode-Ro_Ya	Ro_Ya	Yams	Crop code for Yams from Roots and tubers class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ro_Ya
cropClassValueCode-Ve	Ve	Vegetables	Crop code for Vegetables class	http://w3id.org/glosis/model/codelists/cropClassValueCode-Ve
erosionActivityPeriodValueCode-A	A	Active at present	Active at present	http://w3id.org/glosis/model/codelists/erosionActivityPeriodValueCode-A
erosionActivityPeriodValueCode-H	H	Active in historical times	Active in historical times	http://w3id.org/glosis/model/codelists/erosionActivityPeriodValueCode-H
erosionActivityPeriodValueCode-N	N	Period of activity not known	Period of activity not known	http://w3id.org/glosis/model/codelists/erosionActivityPeriodValueCode-N
erosionActivityPeriodValueCode-R	R	Active in recent past	Active in recent past (previous 50–100 years)	http://w3id.org/glosis/model/codelists/erosionActivityPeriodValueCode-R
erosionActivityPeriodValueCode-X	X	Accelerated and natural erosion not distinguished	Accelerated and natural erosion not distinguished	http://w3id.org/glosis/model/codelists/erosionActivityPeriodValueCode-X
erosionAreaAffectedValueCode-0	0	Zero	0%	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-0
erosionAreaAffectedValueCode-1	1	Between 0% and 5%	0-5(%)	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-1
erosionAreaAffectedValueCode-2	2	Between 5% and 10%	5-10(%)	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-2
erosionAreaAffectedValueCode-3	3	Between 10% and 25%	10-25(%)	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-3
erosionAreaAffectedValueCode-4	4	Between 25% and 50%	25-50(%)	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-4
erosionAreaAffectedValueCode-5	5	More than 50%	> 50%	http://w3id.org/glosis/model/codelists/erosionAreaAffectedValueCode-5
erosionCategoryValueCode-A	A	Wind (aeolian) erosion or deposition	Erosion caused by wind	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-A
erosionCategoryValueCode-AD	AD	Wind deposition	Soil deposition caused by wind	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-AD
erosionCategoryValueCode-AM	AM	Wind erosion and deposition	Erosion and deposition caused by wind	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-AM
erosionCategoryValueCode-AS	AS	Shifting sands	Erosion caused by shifting of sands	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-AS
erosionCategoryValueCode-AZ	AZ	Salt deposition	Erosion caused by salt deposition	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-AZ
erosionCategoryValueCode-M	N	Mass movement	Mass movements are defined as processes of erosion, transport and accumulation of material that occur on both gentle and steep slopes mainly owing to gravitational forces.	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-M
erosionCategoryValueCode-N	N	No evidence of erosion	Refers to a condition in which the soil shows no visible signs of erosion, indicating that the surface is intact and not undergoing significant degradation due to physical forces like water, wind, or human activity. This category is often used in soil conservation and land management to evaluate the stability of soil. It suggests that soil properties are being maintained, and there is no noticeable loss of topsoil or alteration in the soil structure that would be indicative of erosion processes such as rill, sheet, or gully erosion. In agricultural and ecological contexts, the absence of erosion is a positive indicator that the land is being properly managed, with adequate vegetation cover or protective measures in place to prevent soil degradation​. Source: Soil Erosion from Intro to Environmental Science	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-N
erosionCategoryValueCode-NK	N	Not known	Unknown causes of Soil erosion	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-NK
erosionCategoryValueCode-W	W	Water erosion or deposition	Erosion and decposition caused by flowing surface water	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-W
erosionCategoryValueCode-WA	WA	Water and wind erosion	Erosion and deposition caused by wind	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WA
erosionCategoryValueCode-WD	WD	Deposition by water	Soil deposition caused by water	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WD
erosionCategoryValueCode-WG	WG	Gully erosion	Erosion caused by flowing surface water	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WG
erosionCategoryValueCode-WR	WR	Rill erosion	Rill erosion is the type of erosion that occurs as water flows over a hillslope and cuts shallow, curvy channels into the top soil.	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WR
erosionCategoryValueCode-WS	WS	Sheet erosion	Uniform erosion of soil in the form of thin layers or sheets.	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WS
erosionCategoryValueCode-WT	WT	Tunnel erosion	Erosion caused by the movement of excess water through a dispersive subsoil.	http://w3id.org/glosis/model/codelists/erosionCategoryValueCode-WT
erosionDegreeValueCode-E	E	Extreme	Extreme Substantial removal of deeper subsurface horizons (badlands). Original biotic functions fully destroyed.	http://w3id.org/glosis/model/codelists/erosionDegreeValueCode-E
erosionDegreeValueCode-M	M	Moderate	Moderate Clear evidence of removal of surface horizons. Original biotic functions partly destroyed.	http://w3id.org/glosis/model/codelists/erosionDegreeValueCode-M
erosionDegreeValueCode-S	S	Slight	Slight Some evidence of damage to surface horizons. Original biotic functions largely intact.	http://w3id.org/glosis/model/codelists/erosionDegreeValueCode-S
erosionDegreeValueCode-V	V	Severe	Severe Surface horizons completely removed and subsurface horizons exposed. Original biotic functions largely destroyed.	http://w3id.org/glosis/model/codelists/erosionDegreeValueCode-V
erosionTotalAreaAffectedValueCode-0	0	Zero	The total area affected by erosion is zero	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-0
erosionTotalAreaAffectedValueCode-1	1	Between 0% and 5%	The total percentage of area affected by erosion is between 0 to 5	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-1
erosionTotalAreaAffectedValueCode-2	2	Between 5% and 10%	The total percentage of area affected by erosion is between 5 - 10	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-2
erosionTotalAreaAffectedValueCode-3	3	Between 10% and 25%	The total percentage of area affected by erosion is between 10 to 25	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-3
erosionTotalAreaAffectedValueCode-4	4	Between 25% and 50%	The total percentage of area affected by erosion is between 25 to 50	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-4
erosionTotalAreaAffectedValueCode-5	5	More than 50%	The total percentage of area affected by erosion is more than 50: >50%	http://w3id.org/glosis/model/codelists/erosionTotalAreaAffectedValueCode-5
humanInfluenceClassValueCode-AC	AC	Archaeological (burial mound, midden)	Human Influence on landsacpe affected by archeological activities i.e burial mound, midden etc	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-AC
humanInfluenceClassValueCode-AD	AD	Artificial drainage	Human Influence on landsacpe affected by artificial drainage	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-AD
humanInfluenceClassValueCode-BP	BP	Borrow pit	Human Influence on landsacpe affected by borrow pit	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-BP
humanInfluenceClassValueCode-BR	BR	Burning	Human Influence on landsacpe affected by burning	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-BR
humanInfluenceClassValueCode-BU	BU	Bunding	Human Influence on landsacpe affected by bunding	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-BU
humanInfluenceClassValueCode-CL	CL	Clearing	Human Influence on landsacpe affected by clearing	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-CL
humanInfluenceClassValueCode-CR	CR	Impact crater	Human Influence on landsacpe affected by impact factors	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-CR
humanInfluenceClassValueCode-DU	DU	Dump (not specified)	Human Influence on landsacpe affected by unspecified dumpings	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-DU
humanInfluenceClassValueCode-FE	FE	Application of fertilizers	Human Influence on landsacpe affected by application of fertilizers	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-FE
humanInfluenceClassValueCode-IB	IB	Border irrigation	Human Influence on landsacpe affected by border irrigation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-IB
humanInfluenceClassValueCode-ID	ID	Drip irrigation	Human Influence on landsacpe affected by drip irrigation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-ID
humanInfluenceClassValueCode-IF	IF	Furrow irrigation	Human Influence on landsacpe affected by furrow irrigation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-IF
humanInfluenceClassValueCode-IP	IP	Flood irrigation	Human Influence on landsacpe affected by flood irrigation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-IP
humanInfluenceClassValueCode-IS	IS	Sprinkler irrigation	Human Influence on landsacpe affected by sprinkler irrigation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-IS
humanInfluenceClassValueCode-IU	IU	Irrigation (not specified)	Human Influence on landsacpe affected by unspecified irrgation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-IU
humanInfluenceClassValueCode-LF	LF	Landfill (also sanitary)	Human Influence on landsacpe affected by sanitary activities like landfills	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-LF
humanInfluenceClassValueCode-LV	LV	Levelling	Human Influence on landsacpe affected by levelling	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-LV
humanInfluenceClassValueCode-ME	ME	Raised beds (engineering purposes)	Human Influence on landsacpe affected by engineering activites like raised beds	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-ME
humanInfluenceClassValueCode-MI	MI	Mine (surface, including openpit, gravel and quarries)	Human Influence on landsacpe affected by mining activities e.g. surface mining, openpit mining, gravel and quarries	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MI
humanInfluenceClassValueCode-MO	MO	Organic additions (not specified)	Human Influence on landsacpe affected by unspecified Organic additions	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MO
humanInfluenceClassValueCode-MP	MP	Plaggen	Human Influence on landsacpe affected by plaggen	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MP
humanInfluenceClassValueCode-MR	MR	Raised beds (agricultural purposes)	Human Influence on landsacpe affected by raised bed due to agricultural activity	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MR
humanInfluenceClassValueCode-MS	MS	Sand additions	Human Influence on landsacpe affected by sand additions	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MS
humanInfluenceClassValueCode-MU	MU	Mineral additions (not specified)	Human Influence on landsacpe affected by unspecified addition of minerals	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-MU
humanInfluenceClassValueCode-N	N	No influence	No visible human influence on landscape	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-N
humanInfluenceClassValueCode-NK	NK	Not known	Human Influence on landsacpe affected by unkown reasons	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-NK
humanInfluenceClassValueCode-PL	PL	Ploughing	Human Influence on landsacpe affected by ploughing	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-PL
humanInfluenceClassValueCode-PO	PO	Pollution	Human Influence on landsacpe affected by pollution	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-PO
humanInfluenceClassValueCode-SA	SA	Scalped area	Human Influence on landsacpe affected by scalped area	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-SA
humanInfluenceClassValueCode-SC	SC	Surface compaction	Human Influence on landsacpe affected by surface compaction	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-SC
humanInfluenceClassValueCode-TE	TE	Terracing	Human Influence on landsacpe affected by terracing	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-TE
humanInfluenceClassValueCode-VE	VE	Vegetation strongly disturbed	Human Influence on landsacpe affected by strongly disturbed vegetation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-VE
slopePathwaysValueCode-VV	VV	VV	Convex vertical slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-VV
humanInfluenceClassValueCode-VM	VM	Vegetation moderately disturbed	Human Influence on landsacpe affected by moderately disturbed vegetation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-VM
humanInfluenceClassValueCode-VS	VS	Vegetation slightly disturbed	Human Influence on landsacpe affected by slightly disturbed vegetation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-VS
humanInfluenceClassValueCode-VU	VU	Vegetation disturbed (not specified)	Human Influence on landsacpe affected by unspecified disturbed vegitation	http://w3id.org/glosis/model/codelists/humanInfluenceClassValueCode-VU
landUseClassValueCode-A	A	Crop agriculture (cropping)	Land-use classification of main class Crop agriculture (cropping)	http://w3id.org/glosis/model/codelists/landUseClassValueCode-A
landUseClassValueCode-AA	AA	Annual field cropping	Land-use classification of main class Crop agriculture and of subclass Annual field cropping	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA
landUseClassValueCode-AA1	AA1	Shifting cultivation	Land-use classification of main class Crop agriculture and of subclass Annual field cropping and of type Shifting cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA1
landUseClassValueCode-AA2	AA2	Fallow system cultivation	Land-use classification of main class Crop agriculture and of sub-class Annual field cropping and of type Fallow system cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA2
landUseClassValueCode-AA3	AA3	Ley system cultivation	Land-use classification of main class Crop agriculture and of subclass Annual field cropping and of type Ley system cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA3
landUseClassValueCode-AA4	AA4	Rainfed arable cultivation	Land-use classification of main class Crop agriculture and of subclass Annual field cropping and of type Rainfed arable cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA4
landUseClassValueCode-AA5	AA5	Wet rice cultivation	Land-use classification of mainclass Crop agriculture and of class Annual field cropping and of type Wet rice cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA5
landUseClassValueCode-AA6	AA6	Irrigated cultivation	Land-use classification of main class Crop agriculture and of subclass Annual field cropping and of type Irrigated cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AA6
landUseClassValueCode-AP	AP	Perennial field cropping	Land-use classification of main class Crop agriculture and of subclass Perennial field cropping	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AP
landUseClassValueCode-AP1	AP1	Non-irrigated cultivation	Land-use classification of main class Crop agriculture and of subclass Perennial field cropping and of type Non-irrigated cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AP1
landUseClassValueCode-AP2	AP2	Irrigated cultivation	Land-use classification of main class Crop agriculture and of subclass Perennial field cropping and of type Irrigated cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AP2
landUseClassValueCode-AT	AT	Tree and shrub cropping	Land-use classification of main class Crop agriculture and of subclass Tree and shrub cropping	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AT
landUseClassValueCode-AT1	AT1	Non-irrigated tree crop cultivation	Land-use classification of main class Crop agriculture and of subclass Tree and shrub cropping and of type Non-irrigated shrub crop cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AT1
landUseClassValueCode-AT2	AT2	Irrigated tree crop cultivation	Land-use classification of main class Crop agriculture and of subclass Tree and shrub cropping and of type Irrigated tree crop cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AT2
landUseClassValueCode-AT3	AT3	Non-irrigated shrub crop cultivation	Land-use classification of main class Crop agriculture and of subclass Tree and shrub cropping and of type Non-irrigated shrub crop cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AT3
landUseClassValueCode-AT4	AT4	Irrigated shrub crop cultivation	Land-use classification of main class Crop agriculture and of subclass Tree and shrub cropping and of type Irrigated shrub crop cultivation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-AT4
landUseClassValueCode-F	F	F = Forestry	Land-use classification of main class Forestry	http://w3id.org/glosis/model/codelists/landUseClassValueCode-F
landUseClassValueCode-FN	FN	Natural forest and woodland	Land-use classification of main class Forestry and of subclass Natural forest and woodland	http://w3id.org/glosis/model/codelists/landUseClassValueCode-FN
landUseClassValueCode-FN1	FN1	Selective felling	Land-use classification of main class Forestry and of subclass Natural forest and woodland and of type Selective felling	http://w3id.org/glosis/model/codelists/landUseClassValueCode-FN1
landUseClassValueCode-FN2	FN2	Clear felling	Land-use classification of main class Forestry and of subclass Natural forest and woodland and of type Clear felling	http://w3id.org/glosis/model/codelists/landUseClassValueCode-FN2
landUseClassValueCode-FP	FP	Plantation forestry	Land-use classification of main class Forestry and of subclass Plantation forestry	http://w3id.org/glosis/model/codelists/landUseClassValueCode-FP
landUseClassValueCode-H	H	Animal husbandry	Land-use classification of main class Animal husbandry	http://w3id.org/glosis/model/codelists/landUseClassValueCode-H
landUseClassValueCode-HE	HE	Extensive grazing	Land-use classification of main class Animal husbandry and of subclass Extensive grazing	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HE
landUseClassValueCode-HE1	HE1	Nomadism	Land-use classification of main class Animal husbandry and of subclass Extensive grazing and of type Nomadism	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HE1
landUseClassValueCode-HE2	HE2	Semi-nomadism	Land-use classification of main class Animal husbandry and of subclass Extensive grazing and of type Semi-nomadism	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HE2
landUseClassValueCode-HE3	HE3	Ranching	Land-use classification of main class Animal husbandry and of subclass Extensive grazing and of type Ranching	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HE3
landUseClassValueCode-HI	HI	Intensive grazing	Land-use classification of main class Animal husbandry and of subclass Intensive grazing	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HI
landUseClassValueCode-HI1	HI1	Animal production	Land-use classification of main class Animal husbandry and of subclass Intensive grazing and of type Animal production	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HI1
vegetationClassValueCode-S	S	Shrub	Vegetation class of Shrub (S)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-S
landUseClassValueCode-HI2	HI2	Dairying	Land-use classification of main class Animal husbandry and of subclass Intensive grazing and of type Dairying	http://w3id.org/glosis/model/codelists/landUseClassValueCode-HI2
landUseClassValueCode-M	M	M = Mixed farming	Land-use classification of main class Mixed farming	http://w3id.org/glosis/model/codelists/landUseClassValueCode-M
landUseClassValueCode-MF	MF	Agroforestry	Land-use classification of main class Mixed farming and of subclass Agroforestry	http://w3id.org/glosis/model/codelists/landUseClassValueCode-MF
landUseClassValueCode-MP	MP	Agropastoralism	Land-use classification of main class Mixed farming and of subclass Agropastoralism	http://w3id.org/glosis/model/codelists/landUseClassValueCode-MP
landUseClassValueCode-Oi	O	Other land uses	Land-use classification of main class Other land uses	http://w3id.org/glosis/model/codelists/landUseClassValueCode-Oi
landUseClassValueCode-P	P	P = Nature protection	Land-use classification of main class Nature protection	http://w3id.org/glosis/model/codelists/landUseClassValueCode-P
landUseClassValueCode-PD	PD	Degradation control	Land-use classification of main class Nature protection and of subclass Degradation control	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PD
landUseClassValueCode-PD1	PD1	Without interference	Land-use classification of main class Nature protection and of subclass Degradation control and of type Without interference	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PD1
landUseClassValueCode-PD2	PD2	With interference	Land-use classification of main class Nature protection and of subclass Degradation control and of type With interference	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PD2
landUseClassValueCode-PN	PN	Nature and game preservation	Land-use classification of main class Nature protection and of subclass Nature and game preservation	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PN
landUseClassValueCode-PN1	PN1	Reserves	Land-use classification of main class Nature protection and of subclass Nature and game preservationand of type Reserves	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PN1
landUseClassValueCode-PN2	PN2	Parks	Land-use classification of main class Nature protection and of subclass Nature and game preservation and of type Parks	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PN2
landUseClassValueCode-PN3	PN3	Wildlife management	Land-use classification of main class Nature protection and of subclass Nature and game preservation and of type Wildlife management	http://w3id.org/glosis/model/codelists/landUseClassValueCode-PN3
landUseClassValueCode-S	S	S = Settlement, industry	Land-use classification of main class Settlement, industry	http://w3id.org/glosis/model/codelists/landUseClassValueCode-S
landUseClassValueCode-SC	SC	Recreational use	Land-use classification of main class Settlement, industry and of subclass Recreational use	http://w3id.org/glosis/model/codelists/landUseClassValueCode-SC
landUseClassValueCode-SD	SD	Disposal sites	Land-use classification of main class Settlement, industry and of subclass Disposal sites	http://w3id.org/glosis/model/codelists/landUseClassValueCode-SD
landUseClassValueCode-SI	SI	Industrial use	Land-use classification of main class Settlement, industry and of subclass Industrial use	http://w3id.org/glosis/model/codelists/landUseClassValueCode-SI
landUseClassValueCode-SR	SR	Residential use	Land-use classification of main class Settlement or industry and of subclass Residential use	http://w3id.org/glosis/model/codelists/landUseClassValueCode-SR
landUseClassValueCode-ST	ST	Transport	Land-use classification of main class Settlement, industry and of subclass Transport	http://w3id.org/glosis/model/codelists/landUseClassValueCode-ST
landUseClassValueCode-SX	SX	Excavations	Land-use classification of main class Settlement, industry and of subclass Excavations	http://w3id.org/glosis/model/codelists/landUseClassValueCode-SX
landUseClassValueCode-U	U	Not used and not managed	Land-use classification of main class Not used and not managed	http://w3id.org/glosis/model/codelists/landUseClassValueCode-U
landUseClassValueCode-Y	Y	Military area	Land-use classification of main class Military area	http://w3id.org/glosis/model/codelists/landUseClassValueCode-Y
landformComplexValueCode-CU	CU	Cuesta-shaped	Cuesta-shaped lanform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-CU
landformComplexValueCode-DO	DO	Dome-shaped	Dome-shaped landform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-DO
landformComplexValueCode-DU	DU	Dune-shaped	Dune-shaped landform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-DU
landformComplexValueCode-IM	IM	With intermontane plains (occupying > 15%)	With intermontane plains landform(occupying > 15%)	http://w3id.org/glosis/model/codelists/landformComplexValueCode-IM
landformComplexValueCode-IN	IN	Inselberg covered (occupying > 1% of level land)	Inselberg covered (occupying > 1% of level land)	http://w3id.org/glosis/model/codelists/landformComplexValueCode-IN
landformComplexValueCode-KA	KA	Strong karst	Strong karst landform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-KA
landformComplexValueCode-RI	RI	Ridged	Ridged Landform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-RI
landformComplexValueCode-TE	TE	Terraced	Terraced landform	http://w3id.org/glosis/model/codelists/landformComplexValueCode-TE
landformComplexValueCode-WE	WE	With wetlands (occupying > 15%)	With wetlands landform (occupying > 15%)	http://w3id.org/glosis/model/codelists/landformComplexValueCode-WE
lithologyValueCode-I	I	igneous rock	Hierarchy of lithology from the major class of igneous rock	http://w3id.org/glosis/model/codelists/lithologyValueCode-I
lithologyValueCode-IA	IA	acid igneous	Hierarchy of lithology from the major class of igneous rock and the group of acid igneous	http://w3id.org/glosis/model/codelists/lithologyValueCode-IA
lithologyValueCode-IA1	IA1	diorite	Hierarchy of lithology from the major class of igneous rock and the group of acid igneous of type diorite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IA1
lithologyValueCode-IA2	IA2	grano-diorite	Hierarchy of lithology from the major class of igneous rock and the group of acid igneous of type grano-diorite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IA2
lithologyValueCode-IA3	IA3	quartz-diorite	Hierarchy of lithology from the major class of igneous rock and the group of acid igneous of type quartz-diorite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IA3
lithologyValueCode-IA4	IA4	rhyolite	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of acid igneous of type rhyolite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IA4
lithologyValueCode-IB	IB	basic igneous	Hierarchy of lithology from the major class of igneous rock and the group of basic igneous	http://w3id.org/glosis/model/codelists/lithologyValueCode-IB
lithologyValueCode-IB1	IB1	gabbro	Hierarchy of lithology from the major class of igneous rock and the group of basic igneous of type gabbro	http://w3id.org/glosis/model/codelists/lithologyValueCode-IB1
lithologyValueCode-IB2	IB2	basalt	Hierarchy of lithology from the major class of igneous rock and the group of basic igneous of type basalt	http://w3id.org/glosis/model/codelists/lithologyValueCode-IB2
lithologyValueCode-IB3	IB3	dolerite	Hierarchy of lithology from the major class of igneous rock and the group of basic igneous of type dolerite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IB3
lithologyValueCode-II	II	intermediate igneous	Hierarchy of lithology from the major class of igneous rock and the group of intermediate igneous	http://w3id.org/glosis/model/codelists/lithologyValueCode-II
lithologyValueCode-II1	II1	andesite, trachyte, phonolite	Hierarchy of lithology from the major class of igneous rock and the group of intermediate igneous of type andesite, trachyte, phonolite	http://w3id.org/glosis/model/codelists/lithologyValueCode-II1
lithologyValueCode-II2	II2	diorite-syenite	Hierarchy of lithology from the major class of igneous rock and the group of intermediate igneous of type diorite-syenite	http://w3id.org/glosis/model/codelists/lithologyValueCode-II2
lithologyValueCode-IP	IP	pyroclastic	Hierarchy of lithology from the major class of igneous rock and the group of pyroclastic	http://w3id.org/glosis/model/codelists/lithologyValueCode-IP
lithologyValueCode-IP1	IP1	tuff, tuffite	Hierarchy of lithology from the major class of igneous rock and the group of pyroclastic of type tuff, tuffite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IP1
lithologyValueCode-IP2	IP2	volcanic scoria/breccia	Hierarchy of lithology from the major class of igneous rock and the group of pyroclastic of type volcanic scoria/breccia	http://w3id.org/glosis/model/codelists/lithologyValueCode-IP2
lithologyValueCode-IP3	IP3	volcanic ash	Hierarchy of lithology from the major class of igneous rock and the group of pyroclastic of type volcanic ash	http://w3id.org/glosis/model/codelists/lithologyValueCode-IP3
lithologyValueCode-IP4	IP4	ignimbrite	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type ignimbrite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IP4
lithologyValueCode-IU	IU	ultrabasic igneous	Hierarchy of lithology from the major class of igneous rock and the group of ultrabasic igneous	http://w3id.org/glosis/model/codelists/lithologyValueCode-IU
lithologyValueCode-IU1	IU1	peridotite	Hierarchy of lithology from the major class of igneous rock and the group of ultrabasic igneous of type peridotite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IU1
lithologyValueCode-IU2	IU2	pyroxenite	Hierarchy of lithology from the major class of igneous rock and the group of ultrabasic igneous of type pyroxenite	http://w3id.org/glosis/model/codelists/lithologyValueCode-IU2
lithologyValueCode-IU3	IU3	ilmenite, magnetite, ironstone, serpentine	Hierarchy of lithology from the major class of igneous rock and the group of ultrabasic igneous of type ilmenite, magnetite, ironstone, serpentine	http://w3id.org/glosis/model/codelists/lithologyValueCode-IU3
lithologyValueCode-M	M	metamorphic rock	Hierarchy of lithology from the major class of metamorphic rock	http://w3id.org/glosis/model/codelists/lithologyValueCode-M
lithologyValueCode-MA	MA	acid metamorphic	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic	http://w3id.org/glosis/model/codelists/lithologyValueCode-MA
lithologyValueCode-MA1	MA1	quartzite	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type quartzite	http://w3id.org/glosis/model/codelists/lithologyValueCode-MA1
lithologyValueCode-MA2	MA2	gneiss, migmatite	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type gneiss, migmatite	http://w3id.org/glosis/model/codelists/lithologyValueCode-MA2
lithologyValueCode-MA3	MA3	slate, phyllite (pelitic rocks)	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type slate, phyllite (pelitic rocks)	http://w3id.org/glosis/model/codelists/lithologyValueCode-MA3
lithologyValueCode-MA4	MA4	schist	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type schist	http://w3id.org/glosis/model/codelists/lithologyValueCode-MA4
lithologyValueCode-MB	MB	basic metamorphic	Hierarchy of lithology from the major class of metamorphic rock and the group of basic metamorphic	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB
lithologyValueCode-MB1	MB1	slate, phyllite (pelitic rocks)	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type slate, phyllite (pelitic rocks)	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB1
lithologyValueCode-MB2	MB2	(green)schist	Hierarchy of lithology from the major class of metamorphic rock and the group of acid metamorphic of type (green)schist	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB2
lithologyValueCode-MB3	MB3	gneiss rich in Fe–Mg minerals	Hierarchy of lithology from the major class of metamorphic rock and the group of basic metamorphic of type gneiss rich in Fe–Mg minerals	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB3
lithologyValueCode-MB4	MB4	metamorphic limestone (marble)	Hierarchy of lithology from the major class of metamorphic rock and the group of basic metamorphic of type metamorphic limestone (marble)	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB4
lithologyValueCode-MB5	MB5	amphibolite	Hierarchy of lithology from the major class of metamorphic rock and the group of basic metamorphic of type amphibolite	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB5
lithologyValueCode-MB6	MB6	eclogite	Hierarchy of lithology from the major class of metamorphic rock and the group of basic metamorphic of type eclogite	http://w3id.org/glosis/model/codelists/lithologyValueCode-MB6
lithologyValueCode-MU	MU	ultrabasic metamorphic	Hierarchy of lithology from the major class of metamorphic rock and the group of ultrabasic metamorphic	http://w3id.org/glosis/model/codelists/lithologyValueCode-MU
lithologyValueCode-MU1	MU1	serpentinite, greenstone	Hierarchy of lithology from the major class of metamorphic rock and the group of ultrabasic metamorphic of type serpentinite, greenstone	http://w3id.org/glosis/model/codelists/lithologyValueCode-MU1
lithologyValueCode-S	S	sedimentary rock (consolidated)	Hierarchy of lithology from the major class of sedimentary rock (consolidated)	http://w3id.org/glosis/model/codelists/lithologyValueCode-S
lithologyValueCode-SC	SC	clastic sediments	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of clastic sediments	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC
lithologyValueCode-SC1	SC1	conglomerate, breccia	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of clastic sediments of type conglomerate, breccia	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC1
lithologyValueCode-SC2	SC2	sandstone, greywacke, arkose	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of clastic sediments of type sandstone, greywacke, arkose	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC2
lithologyValueCode-SC3	SC3	silt-, mud-, claystone	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of clastic sediments of type silt-, mud-, claystone	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC3
lithologyValueCode-SC4	SC4	shale	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of clastic sediments of type shale	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC4
lithologyValueCode-SC5	SC5	ironstone	Hierarchy of lithology from the major class of sedimentary rock (consolidated)and the group of acid metamorphic of type ironstone	http://w3id.org/glosis/model/codelists/lithologyValueCode-SC5
lithologyValueCode-SE	SE	evaporites	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of evaporites	http://w3id.org/glosis/model/codelists/lithologyValueCode-SE
lithologyValueCode-SE1	SE1	anhydrite, gypsum	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of acid evaporites of type anhydrite, gypsum	http://w3id.org/glosis/model/codelists/lithologyValueCode-SE1
lithologyValueCode-SE2	SE2	halite	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of evaporites of type halite	http://w3id.org/glosis/model/codelists/lithologyValueCode-SE2
lithologyValueCode-SO	SO	carbonatic, organic	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of carbonatic, organic	http://w3id.org/glosis/model/codelists/lithologyValueCode-SO
lithologyValueCode-SO1	SO1	limestone, other carbonate rock	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of carbonatic, organic of type limestone, other carbonate rock	http://w3id.org/glosis/model/codelists/lithologyValueCode-SO1
lithologyValueCode-SO2	SO2	marl and other mixtures	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of carbonatic, organic of type marl and other mixtures	http://w3id.org/glosis/model/codelists/lithologyValueCode-SO2
lithologyValueCode-SO3	SO3	coals, bitumen and related rocks	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of carbonatic, organic of type coals, bitumen and related rocks	http://w3id.org/glosis/model/codelists/lithologyValueCode-SO3
lithologyValueCode-U	U	sedimentary rock (unconsolidated)	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated)	http://w3id.org/glosis/model/codelists/lithologyValueCode-U
lithologyValueCode-UA	UA	anthropogenic/technogenic	Hierarchy of lithology from the group of anthropogenic/technogenic	http://w3id.org/glosis/model/codelists/lithologyValueCode-UA
lithologyValueCode-UA1	UA1	redeposited natural material	Hierarchy of lithology from the group of anthropogenic/technogenic of type redeposited natural material	http://w3id.org/glosis/model/codelists/lithologyValueCode-UA1
lithologyValueCode-UA2	UA2	industrial/artisanal deposits	Hierarchy of lithology from the group of unspecified deposits of type industrial/artisanal deposits	http://w3id.org/glosis/model/codelists/lithologyValueCode-UA2
lithologyValueCode-UC	UC	colluvial	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of colluvial	http://w3id.org/glosis/model/codelists/lithologyValueCode-UC
lithologyValueCode-UC1	UC1	slope deposits	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of colluvial of type slope deposits	http://w3id.org/glosis/model/codelists/lithologyValueCode-UC1
lithologyValueCode-UC2	UC2	lahar	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of colluvial of type lahar	http://w3id.org/glosis/model/codelists/lithologyValueCode-UC2
lithologyValueCode-UE	UE	eolian	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of eolian	http://w3id.org/glosis/model/codelists/lithologyValueCode-UE
lithologyValueCode-UE1	UE1	loess	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of eolian of type loess	http://w3id.org/glosis/model/codelists/lithologyValueCode-UE1
lithologyValueCode-UE2	UE2	sand	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of lacustrine of type sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UE2
lithologyValueCode-UF	UF	fluvial	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of fluvial	http://w3id.org/glosis/model/codelists/lithologyValueCode-UF
lithologyValueCode-UF1	UF1	sand and gravel	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of fluvial of type sand and gravel	http://w3id.org/glosis/model/codelists/lithologyValueCode-UF1
lithologyValueCode-UF2	UF2	clay, silt and loam	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of fluvial of type clay, silt and loam	http://w3id.org/glosis/model/codelists/lithologyValueCode-UF2
lithologyValueCode-UG	UG	glacial	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of glacial	http://w3id.org/glosis/model/codelists/lithologyValueCode-UG
lithologyValueCode-UG1	UG1	moraine	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of glacial of type moraine	http://w3id.org/glosis/model/codelists/lithologyValueCode-UG1
lithologyValueCode-UG2	UG2	UG2 glacio-fluvial sand	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of glacial of type glacio-fluvial sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UG2
lithologyValueCode-UG3	UG3	UG3 glacio-fluvial gravel	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of kryogenic of type glacio-fluvial gravel	http://w3id.org/glosis/model/codelists/lithologyValueCode-UG3
lithologyValueCode-UK	UK	kryogenic	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of kryogenic	http://w3id.org/glosis/model/codelists/lithologyValueCode-UK
lithologyValueCode-UK1	UK1	periglacial rock debris	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of kryogenic of type periglacial rock debris	http://w3id.org/glosis/model/codelists/lithologyValueCode-UK1
lithologyValueCode-UK2	UK2	periglacial solifluction layer	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of kryogenic of type periglacial solifluction layer	http://w3id.org/glosis/model/codelists/lithologyValueCode-UK2
lithologyValueCode-UL	UL	lacustrine	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of lacustrine	http://w3id.org/glosis/model/codelists/lithologyValueCode-UL
lithologyValueCode-UL1	UL1	sand	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of lacustrine of type sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UL1
lithologyValueCode-UL2	UL2	silt and clay	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of lacustrine of type silt and clay	http://w3id.org/glosis/model/codelists/lithologyValueCode-UL2
lithologyValueCode-UM	UM	marine, estuarine	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of marine, estuarine	http://w3id.org/glosis/model/codelists/lithologyValueCode-UM
lithologyValueCode-UM1	UM1	sand	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of marine, estuarine of type sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UM1
lithologyValueCode-UM2	UM2	clay and silt	Hierarchy of lithology from the major class of sedimentary rock (consolidated) and the group of marine and estuarine of type clay and silt	http://w3id.org/glosis/model/codelists/lithologyValueCode-UM2
lithologyValueCode-UO	UO	organic	Hierarchy of lithology from the group of organic	http://w3id.org/glosis/model/codelists/lithologyValueCode-UO
lithologyValueCode-UO1	UO1	rainwater-fed moor peat	Hierarchy of lithology from the group of organic of type rainwater-fed moor peat	http://w3id.org/glosis/model/codelists/lithologyValueCode-UO1
lithologyValueCode-UO2	UO2	groundwater-fed bog peat	Hierarchy of lithology from the group of organic of type groundwater-fed bog peat	http://w3id.org/glosis/model/codelists/lithologyValueCode-UO2
lithologyValueCode-UR	UR	weathered residuum	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of weathered residuum	http://w3id.org/glosis/model/codelists/lithologyValueCode-UR
lithologyValueCode-UR1	UR1	bauxite, laterite	Hierarchy of lithology from the major class of sedimentary rock (unconsolidated) and the group of weathered residuum of type bauxite, laterite	http://w3id.org/glosis/model/codelists/lithologyValueCode-UR1
lithologyValueCode-UU	UU	unspecified deposits	Hierarchy of lithology from the group of unspecified deposits	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU
lithologyValueCode-UU1	UU1	clay	Hierarchy of lithology from the group of unspecified deposits of type clay	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU1
lithologyValueCode-UU2	UU2	loam and silt	Hierarchy of lithology from the group of unspecified deposits of type loam and silt	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU2
lithologyValueCode-UU3	UU3	sand	Hierarchy of lithology from group of unspecified depositsof type sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU3
lithologyValueCode-UU4	UU4	gravelly sand	Hierarchy of lithology from the group of unspecified deposits of type gravelly sand	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU4
lithologyValueCode-UU5	UU5	gravel, broken rock	Hierarchy of lithology from the group of unspecified deposits of type gravel, broken rock	http://w3id.org/glosis/model/codelists/lithologyValueCode-UU5
majorLandFormValueCode-L	L	level land	first level of landform is level land (L)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-L
majorLandFormValueCode-LD	LD	depression	first level of landform is level land (L) and the second level is depression (LD)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-LD
majorLandFormValueCode-LL	LL	plateau	first level of landform is level land (L) and the second level is plateau (LL)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-LL
majorLandFormValueCode-LP	LP	plain	first level of landform is level land (L) and the second level is plain (LP)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-LP
majorLandFormValueCode-LV	LV	valley floor	first level of landform is level land (L) and the second level is valley floor (LV)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-LV
majorLandFormValueCode-S	S	sloping land	first level of landform is sloping land (S)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-S
majorLandFormValueCode-SE	SE	medium-gradient escarpment zone	first level of landform is sloping land (S) and the second level is medium-gradient escarpment zone (SE)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-SE
majorLandFormValueCode-SH	SH	medium-gradient hill	first level of landform is sloping land (S) and the second level is medium gradient hill (SH)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-SH
majorLandFormValueCode-SM	SM	medium-gradient mountain	first level of landform is sloping land (S) and the second level is medium-gradient mountain (SM)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-SM
majorLandFormValueCode-SP	SP	dissected plain	first level of landform is sloping land (S) and the second level is dissected plain (SP)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-SP
majorLandFormValueCode-SV	SV	medium-gradient valley	first level of landform is sloping land (S) and the second level is medium gradient valley (SV)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-SV
majorLandFormValueCode-T	T	steep land	first level of landform is steep land (T)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-T
majorLandFormValueCode-TE	TE	high-gradient escarpment zone	first level of landform is steep land (T) and the second level is high-gradient escarpment zone (TE)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-TE
majorLandFormValueCode-TH	TH	high-gradient hill	first level of landform is steep land (T) and the second level is high gradient hill (TH)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-TH
majorLandFormValueCode-TM	TM	high-gradient mountain	first level of landform is steep land (T) and the second level is high-gradient mountain (TM)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-TM
majorLandFormValueCode-TV	TV	high-gradient valley	first level of landform is steep land (T) and the second level is high gradient valley (TV)	http://w3id.org/glosis/model/codelists/majorLandFormValueCode-TV
physiographyValueCode-BOdl	BOdl	Bottom (drainage line)	Position in flat or almost flat terrain: Bottom (drainage line)	http://w3id.org/glosis/model/codelists/physiographyValueCode-BOdl
physiographyValueCode-BOf	BOf	Bottom (flat)	Position in undulating to mountainous terrain: Bottom (flat)	http://w3id.org/glosis/model/codelists/physiographyValueCode-BOf
physiographyValueCode-CR	CR	Crest (summit)	Position in undulating to mountainous terrain: Crest (summit)	http://w3id.org/glosis/model/codelists/physiographyValueCode-CR
physiographyValueCode-HI	HI	Higher part (rise)	Position in flat or almost flat terrain: Higher part (rise)	http://w3id.org/glosis/model/codelists/physiographyValueCode-HI
physiographyValueCode-IN	IN	Intermediate part (talf)	Position in flat or almost flat terrain: Intermediate part (talf)	http://w3id.org/glosis/model/codelists/physiographyValueCode-IN
physiographyValueCode-LO	LO	Lower part (and dip)	Position in flat or almost flat terrain: Lower part (and dip)	http://w3id.org/glosis/model/codelists/physiographyValueCode-LO
physiographyValueCode-LS	LS	Lower slope (foot slope)	Position in undulating to mountainous terrain: Lower slope (foot slope)	http://w3id.org/glosis/model/codelists/physiographyValueCode-LS
physiographyValueCode-MS	MS	Middle slope (back slope)	Position in undulating to mountainous terrain: Middle slope (back slope)	http://w3id.org/glosis/model/codelists/physiographyValueCode-MS
physiographyValueCode-TS	TS	Toe slope	Position in undulating to mountainous terrain: Toe slope	http://w3id.org/glosis/model/codelists/physiographyValueCode-TS
physiographyValueCode-UP	UP	Upper slope (shoulder)	Position in undulating to mountainous terrain: Upper slope (shoulder)	http://w3id.org/glosis/model/codelists/physiographyValueCode-UP
rockOutcropsCoverValueCode-A	M	Abundant	Rock outcorps of 40–80% with distance between rockcorps less than 2 m	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-A
rockOutcropsCoverValueCode-C	C	Common	Rock outcorps of 5–15% with distance between rockcorps 5–20 m	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-C
rockOutcropsCoverValueCode-D	D	Dominant	Rock outcorps of more than 80%	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-D
rockOutcropsCoverValueCode-F	F	Few	Rock outcorps of 2–5 % with distance between rockcorps 20–50 m	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-F
rockOutcropsCoverValueCode-M	M	Many	Rock outcorps of 15–40 % with distance between rockcorps 2–5 m	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-M
rockOutcropsCoverValueCode-N	N	None	No rock outcorps on surface	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-N
rockOutcropsCoverValueCode-V	V	Very few	Rock outcorps of 0–2 % with distance between rockcorps greater than 50 m	http://w3id.org/glosis/model/codelists/rockOutcropsCoverValueCode-V
rockOutcropsDistanceValueCode-1	1	More than 50m	Distance between rock outcrops is more than 50m: >50m	http://w3id.org/glosis/model/codelists/rockOutcropsDistanceValueCode-1
rockOutcropsDistanceValueCode-2	2	Between 20m and 50m	Distance between rock outcrops between 20 and 50 m	http://w3id.org/glosis/model/codelists/rockOutcropsDistanceValueCode-2
rockOutcropsDistanceValueCode-3	3	Between 5m and 20m	Distance between rock outcrops between 5 and 20 m	http://w3id.org/glosis/model/codelists/rockOutcropsDistanceValueCode-3
rockOutcropsDistanceValueCode-4	4	Between 2m and 5m	Distance between rock outcrops between 2 and 5 m	http://w3id.org/glosis/model/codelists/rockOutcropsDistanceValueCode-4
rockOutcropsDistanceValueCode-5	5	Less than 2	Distance between rock outcrops is less than 2m: < 2	http://w3id.org/glosis/model/codelists/rockOutcropsDistanceValueCode-5
slopeFormValueCode-C	C	concave	concave slope form	http://w3id.org/glosis/model/codelists/slopeFormValueCode-C
slopeFormValueCode-S	S	straight	straight slope form	http://w3id.org/glosis/model/codelists/slopeFormValueCode-S
slopeFormValueCode-T	T	terraced	terraced slope form	http://w3id.org/glosis/model/codelists/slopeFormValueCode-T
slopeFormValueCode-V	V	convex	convex slope form	http://w3id.org/glosis/model/codelists/slopeFormValueCode-V
slopeFormValueCode-X	X	complex (irregular)	complex (irregular) slope form	http://w3id.org/glosis/model/codelists/slopeFormValueCode-X
slopeGradientClassValueCode-1	1	Flat	0–0.2% of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-1
slopeGradientClassValueCode-10	10	Very steep	> 60% of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-10
slopeGradientClassValueCode-2	2	Level	0.2–0.5 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-2
slopeGradientClassValueCode-3	3	Nearly level	0.5–1.0 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-3
slopeGradientClassValueCode-4	4	Very gently sloping	1.0–2.0 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-4
slopeGradientClassValueCode-5	5	Gently sloping	2–5% of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-5
slopeGradientClassValueCode-6	6	Sloping	5–10 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-6
slopeGradientClassValueCode-7	7	Strongly sloping	10–15% of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-7
slopeGradientClassValueCode-8	8	Moderately steep	15–30 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-8
slopeGradientClassValueCode-9	9	Steep	30–60 % of slope gradient	http://w3id.org/glosis/model/codelists/slopeGradientClassValueCode-9
slopePathwaysValueCode-CC	CC	CC	Concave slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-CC
slopePathwaysValueCode-CS	CS	CS	concave stright slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-CS
slopePathwaysValueCode-CV	CV	CV	concave vertical slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-CV
slopePathwaysValueCode-SC	SC	SC	Straight concave slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-SC
slopePathwaysValueCode-SS	SS	SS	straight slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-SS
slopePathwaysValueCode-SV	SV	SV	straight convex slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-SV
slopePathwaysValueCode-VC	VC	VC	Vertical concave slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-VC
slopePathwaysValueCode-VS	VS	VS	Convex straight slope	http://w3id.org/glosis/model/codelists/slopePathwaysValueCode-VS
surfaceAgeValueCode-Ha	Ha	Holocene anthropogeomorphic	Holocene (100–10 000 years) anthropogeomorphic: human-made relief modifications, such as terracing of forming hills or walls by early civilizations or during the Middle Ages or earlier, restriction of flooding by dykes, or surface raising.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-Ha
surfaceAgeValueCode-Hn	Hn	Holocene natural	Holocene (100–10 000 years) natural: with loss by erosion or deposition of materials such as on tidal flats, of coastal dunes, in river valleys, landslides or desert areas.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-Hn
surfaceAgeValueCode-O	O	Older, pre-Tertiary land surfaces	Older, pre-Tertiary land surfaces, commonly high planes, terraces or peneplains, except incised valleys, frequent occurrence of palaeosoils.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-O
surfaceAgeValueCode-T	T	Tertiary land surfaces	Tertiary land surfaces, commonly high planes, terraces or peneplains, except incised valleys, frequent occurrence of palaeosoils.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-T
surfaceAgeValueCode-Ya	Ya	Young anthropogeomorphic	Young (10–100 years) anthropogeomorphic: with complete disturbance of any natural surfaces (and soils) such as in urban, industrial and mining areas with early soil development from fresh natural, technogenic or a mixture of materials, or restriction of flooding by dykes.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-Ya
surfaceAgeValueCode-Yn	Yn	Young natural	Young (10–100 years) natural: with loss by erosion or deposition of materials such as on tidal flats, of coastal dunes, river valleys, landslides or desert areas.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-Yn
surfaceAgeValueCode-lPf	lPf	Late Pleistocene, without periglacial influence.	Late Pleistocene, without periglacial influence.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-lPf
surfaceAgeValueCode-lPi	lPi	Late Pleistocene, ice covered	Late Pleistocene, ice covered, commonly recent soil formation on fresh materials.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-lPi
surfaceAgeValueCode-lPp	lPp	Late Pleistocene, periglacial	Late Pleistocene, periglacial, commonly recent soil formation on preweathered materials.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-lPp
surfaceAgeValueCode-oPf	oPf	Older Pleistocene, without periglacial influence.	Older Pleistocene, without periglacial influence.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-oPf
surfaceAgeValueCode-oPi	oPi	Older Pleistocene, ice covered	Older Pleistocene, ice covered, commonly the recent soil formation on younger over older, preweathered materials.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-oPi
surfaceAgeValueCode-oPp	oPp	Older Pleistocene, with periglacial influence	Older Pleistocene, with periglacial influence, commonly the recent soil formation on younger over older, preweathered materials.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-oPp
surfaceAgeValueCode-vYa	vYa	Very young anthropogeomorphic	Very young (1–10 years) anthropogeomorphic: with complete disturbance of natural surfaces (and soils) such as in urban, industrial and mining areas with very early soil development from fresh natural or technogenic or mixed materials.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-vYa
surfaceAgeValueCode-vYn	vYn	Very young natural	Very young (1–10 years) natural: with loss by erosion or deposition of materials such as on tidal flats, of coastal dunes, in river valleys, landslides or desert areas.	http://w3id.org/glosis/model/codelists/surfaceAgeValueCode-vYn
vegetationClassValueCode-B	B	Groundwater-fed bog peat	Vegetation class of Groundwater-fed bog peat  (B)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-B
vegetationClassValueCode-D	D	Dwarf shrub	Vegetation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-D
vegetationClassValueCode-DD	DD	Deciduous dwarf shrub	Deciduous dwarf shrub from the vegtation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-DD
vegetationClassValueCode-DE	DE	Evergreen dwarf shrub	Evergreen dwarf shrub from the vegtation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-DE
vegetationClassValueCode-DS	DS	Semi-deciduous dwarf shrub	Semi-deciduous dwarf shrub from the vegtation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-DS
vegetationClassValueCode-DT	DT	Tundra	Tundra from the vegtation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-DT
vegetationClassValueCode-DX	DX	Xermomorphic dwarf shrub	Xermomorphic dwarf shrub from the vegtation class of Dwarf shrub (D)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-DX
vegetationClassValueCode-F	F	Closed forest	Vegetation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-F
vegetationClassValueCode-FC	FC	Coniferous forest	Coniferous forest from the vegtation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-FC
vegetationClassValueCode-FD	FD	Deciduous forest	Deciduous forest from the vegtation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-FD
vegetationClassValueCode-FE	FE	Evergreen broad-leaved forest	Evergreen broad-leaved forest from the vegtation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-FE
vegetationClassValueCode-FS	FS	Semi-deciduous forest	Semi-deciduous forest from the vegtation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-FS
vegetationClassValueCode-FX	FX	Xeromorphic forest	Xeromorphic forest from the vegtation class of Closed forest (F)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-FX
vegetationClassValueCode-H	H	Herbaceous	Vegetation class of Herbaceous (H)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-H
vegetationClassValueCode-HF	HF	Forb	Forb from the vegtation class of Herbaceous (H)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-HF
vegetationClassValueCode-HM	HM	Medium grassland	Medium grassland from the vegtation class of Herbaceous (H)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-HM
vegetationClassValueCode-HS	HS	Short grassland	Short grassland from the vegtation class of Herbaceous (H)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-HS
vegetationClassValueCode-HT	HT	Tall grassland	Tall grassland from the vegtation class of Herbaceous (H)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-HT
vegetationClassValueCode-M	M	Rainwater-fed moor peat	Vegetation class of Rainwater-fed moor peat (M)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-M
vegetationClassValueCode-SD	SD	Deciduous shrub	Deciduous shrub from the vegtation class of Shrub (S)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-SD
vegetationClassValueCode-SE	SE	Evergreen shrub	Evergreen shrub from the vegtation class of Shrub (S)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-SE
vegetationClassValueCode-SS	SS	Semi-deciduous shrub	Semi-deciduous shrub from the vegtation class of Shrub (S)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-SS
vegetationClassValueCode-SX	SX	Xeromorphic shrub	Xeromorphic shrub from the vegtation class of Shrub (S)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-SX
vegetationClassValueCode-W	W	Woodland	Vegetation class of Woodland (W)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-W
vegetationClassValueCode-WD	WD	Deciduous woodland	Deciduous woodland from the vegtation class of Woodland (W)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-WD
vegetationClassValueCode-WE	WE	Evergreen woodland	Evergreen woodland from the vegtation class of Woodland (W)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-WE
vegetationClassValueCode-WS	WS	Semi-deciduous woodland	Semi-deciduous woodland from the vegtation class of Woodland (W)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-WS
vegetationClassValueCode-WX	WX	Xeromorphic woodland	Xeromorphic woodland from the vegtation class of Woodland (W)	http://w3id.org/glosis/model/codelists/vegetationClassValueCode-WX
weatherConditionsValueCode-OV	OV	overcast	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-OV
weatherConditionsValueCode-PC	PC	partly cloudy	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-PC
weatherConditionsValueCode-RA	RA	rain	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-RA
weatherConditionsValueCode-SL	SL	sleet	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-SL
weatherConditionsValueCode-SN	SN	snow	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-SN
weatherConditionsValueCode-SU	SU	sunny/clear	Present weather conditions (Schoeneberger et al., 2002)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-SU
weatherConditionsValueCode-WC1	WC1	no rain in the last month	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC1
weatherConditionsValueCode-WC2	WC2	no rain in the last week	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC2
weatherConditionsValueCode-WC3	WC3	no rain in the last 24 hours	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC3
weatherConditionsValueCode-WC4	WC4	rainy without heavy rain in the last 24 hours	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC4
weatherConditionsValueCode-WC5	WC5	heavier rain for some days or rainstorm in the last 24 hours	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC5
weatherConditionsValueCode-WC6	WC6	extremely rainy time or snow melting	Former weather conditions (Ad-hoc-AG-Boden, 2005)	http://w3id.org/glosis/model/codelists/weatherConditionsValueCode-WC6
profileDescriptionStatusValueCode-2.1	2.1	Routine profile description - no sampling	If soil description is done without sampling.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-2.1
profileDescriptionStatusValueCode-4.1	4.1	Soil augering description - no sampling	If soil description is done without sampling.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-4.1
profileDescriptionStatusValueCode-1.1	1.1	Reference profile description - no sampling	If soil description is done without sampling.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-1.1
profileDescriptionStatusValueCode-3.1	3.1	Incomplete description - no sampling	If soil description is done without sampling.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-3.1
profileDescriptionStatusValueCode-1	1	Reference profile description	No essential elements or details are missing from the description, sampling or analysis. The accuracy and reliability of the description and analytical results permit the full characterization of all soil horizons to a depth of 125 cm, or more if required for classification, or down to a C or R horizon or layer, which may be shallower.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-1
profileDescriptionStatusValueCode-4	4	Soil augering description	Soil augerings do no permit a comprehensive soil profile description. Augerings are made for routine soil observation and identification in soil mapping, and for that purpose normally provide a satisfactory indication of the soil characteristics. Soil samples may be collected from augerings.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-4
profileDescriptionStatusValueCode-2	2	Routine profile description	No essential elements are missing from the description, sampling or analysis. The number of samples collected is sufficient to characterize all major soil horizons, but may not allow precise definition of all subhorizons, especially in the deeper soil. The profile depth is 80 cm or more, or down to a C or R horizon or layer, which may be shallower. Additional augering and sampling may be required for lower level classification.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-2
profileDescriptionStatusValueCode-5	5	Other descriptions	Essential elements are missing from the description, preventing a satisfactory soil characterization and classification.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-5
profileDescriptionStatusValueCode-3	3	Incomplete description	Certain relevant elements are missing from the description, an insufficient number of samples was collected, or the reliability of the analytical data does not permit a complete characterization of the soil. However, the description is useful for specific purposes and provides a satisfactory indication of the nature of the soil at high levels of soil taxonomic classification.	http://w3id.org/glosis/model/codelists/profileDescriptionStatusValueCode-3
biologicalAbundanceValueCode-C	C	Common	Common biological activity in soil	http://w3id.org/glosis/model/codelists/biologicalAbundanceValueCode-C
biologicalAbundanceValueCode-F	F	Few	Few biological activity in soil	http://w3id.org/glosis/model/codelists/biologicalAbundanceValueCode-F
biologicalAbundanceValueCode-M	M	Many	Many biological activity in soil	http://w3id.org/glosis/model/codelists/biologicalAbundanceValueCode-M
biologicalAbundanceValueCode-N	N	None	No biological activity in soil	http://w3id.org/glosis/model/codelists/biologicalAbundanceValueCode-N
biologicalFeaturesValueCode-A	A	Artefacts	Biological feature of  Artefacts	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-A
biologicalFeaturesValueCode-B	B	Burrows (unspecified)	Biological feature of Burrows (unspecified)	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-B
biologicalFeaturesValueCode-BI	BI	Infilled large burrows	Biological feature of  Infilled large burrows	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-BI
biologicalFeaturesValueCode-BO	BO	Open large burrows	Biological feature of  Open large burrows	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-BO
biologicalFeaturesValueCode-C	C	Charcoal	Biological feature of  Charcoal	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-C
biologicalFeaturesValueCode-E	E	Earthworm channels	Biological feature of Earthworm channels	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-E
biologicalFeaturesValueCode-I	I	Other insect activity	Biological feature of Other insect activity	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-I
biologicalFeaturesValueCode-P	P	Pedotubules	Biological feature of  Pedotubules	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-P
biologicalFeaturesValueCode-T	T	Termite or ant channels and nests	Biological feature of Termite or ant channels and nests	http://w3id.org/glosis/model/codelists/biologicalFeaturesValueCode-T
boundaryDistinctnessValueCode-A	A	Abrupt	0cm–2cm	http://w3id.org/glosis/model/codelists/boundaryDistinctnessValueCode-A
boundaryDistinctnessValueCode-C	C	Clear	2cm–5cm	http://w3id.org/glosis/model/codelists/boundaryDistinctnessValueCode-C
boundaryDistinctnessValueCode-D	D	Diffuse	> 15cm	http://w3id.org/glosis/model/codelists/boundaryDistinctnessValueCode-D
boundaryDistinctnessValueCode-G	G	Gradual	5cm–15cm	http://w3id.org/glosis/model/codelists/boundaryDistinctnessValueCode-G
boundaryTopographyValueCode-B	B	Broken	Discontinuous	http://w3id.org/glosis/model/codelists/boundaryTopographyValueCode-B
boundaryTopographyValueCode-I	I	Irregular	Pockets more deep than wide	http://w3id.org/glosis/model/codelists/boundaryTopographyValueCode-I
boundaryTopographyValueCode-S	S	Smooth	Nearly plane surface	http://w3id.org/glosis/model/codelists/boundaryTopographyValueCode-S
boundaryTopographyValueCode-W	W	Wavy	Pockets less deep than wide	http://w3id.org/glosis/model/codelists/boundaryTopographyValueCode-W
bulkDensityMineralValueCode-BD1	BD1	Many pores, moist materials drop easily out of the auger.	materials with vesicular pores, mineral soils with andic properties. Sample disintegrates at the instant of sampling, many pores visible onthe pit wall. Sample disintegrates at the instant of sampling, many pores visible on the pit wall. Loamy soils with high clay content, clayey soils When dropped, sample disintegrates into numerous fragments, further disintegration of subfragments after application of weak pressure.	http://w3id.org/glosis/model/codelists/bulkDensityMineralValueCode-BD1
bulkDensityMineralValueCode-BD2	BD2	Sample disintegrates into numerous fragments after application of weak pressure.	Loamy soils with high clay content, clayey soils. When dropped, sample disintegrates into few fragments, further disintegration of subfragments after application of mild pressure.	http://w3id.org/glosis/model/codelists/bulkDensityMineralValueCode-BD2
bulkDensityMineralValueCode-BD3	BD3	Knife can be pushed into the moist soil with weak pressure, sample disintegrates into few fragments, which may be further divided.	Loamy soils with high clay content, clayey soils. Sample remains mostly intact when dropped, further disintegration possible after application of large pressure.	http://w3id.org/glosis/model/codelists/bulkDensityMineralValueCode-BD3
bulkDensityMineralValueCode-BD4	BD4	Knife penetrates only 1–2 cm into the moist soil, some effort required, sample disintegrates into few fragments, which cannot be subdivided further.	Loamy soils with high clay content, clayey soils. Sample remains intact when dropped, no further disintegration after application of very large pressure.	http://w3id.org/glosis/model/codelists/bulkDensityMineralValueCode-BD4
bulkDensityMineralValueCode-BD5	BD5	Very large pressure necessary to force knife into the soil, no further disintegration of sample.	Loamy soils with high clay content, clayey soils. Sample remains intact when dropped, no further disintegration after application of very large pressure.	http://w3id.org/glosis/model/codelists/bulkDensityMineralValueCode-BD5
bulkDensityPeatValueCode-BD1	BD1	Very low	Very low (fibric) class of decomposition: < 0.04g cm-3	http://w3id.org/glosis/model/codelists/bulkDensityPeatValueCode-BD1
bulkDensityPeatValueCode-BD2	BD2	Low	Low (fibric) class of decomposition: 0.04–0.07g cm-3	http://w3id.org/glosis/model/codelists/bulkDensityPeatValueCode-BD2
bulkDensityPeatValueCode-BD3	BD3	Moderate low	Moderate(fibric) class of decomposition: 0.07–0.11g cm-3	http://w3id.org/glosis/model/codelists/bulkDensityPeatValueCode-BD3
bulkDensityPeatValueCode-BD4	BD4	Moderate high	Moderate(fibric) class of decomposition: 0.11–0.17g cm-3	http://w3id.org/glosis/model/codelists/bulkDensityPeatValueCode-BD4
bulkDensityPeatValueCode-BD5	BD5	Strong (hemic)	Strong (hemic) class of decomposition: > 0.17g cm-3	http://w3id.org/glosis/model/codelists/bulkDensityPeatValueCode-BD5
carbonatesContentValueCode-EX	EX	Extremely calcareous	Extremely strong reaction forming thick foam forms quickly: ≈ > 25	http://w3id.org/glosis/model/codelists/carbonatesContentValueCode-EX
carbonatesContentValueCode-MO	MO	Moderately calcareous	Visible effervescence: ≈ 2–10	http://w3id.org/glosis/model/codelists/carbonatesContentValueCode-MO
carbonatesContentValueCode-N	N	Non-calcareous	No detectable visible or audible effervescence.	http://w3id.org/glosis/model/codelists/carbonatesContentValueCode-N
carbonatesContentValueCode-SL	SL	Slightly calcareous	Audible effervescence but not visible: ≈ 0–2	http://w3id.org/glosis/model/codelists/carbonatesContentValueCode-SL
carbonatesContentValueCode-ST	ST	Strongly calcareous	Strong visible effervescence. Bubbles form a low foam: ≈ 10–25	http://w3id.org/glosis/model/codelists/carbonatesContentValueCode-ST
carbonatesFormsValueCode-D	D	disperse powdery lime	Secondary carbonates in soil in the form of disperse powdery lime	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-D
carbonatesFormsValueCode-HC	HC	hard concretions	Secondary carbonates in soil in the form of hard concretions	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-HC
carbonatesFormsValueCode-HHC	HHC	hard hollow concretions	Secondary carbonates in soil in the form of hard hollow concretions	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-HHC
carbonatesFormsValueCode-HL	HL	hard cemented layer or layers of carbonates (less than 10 cm thick)	Secondary carbonates in soil in the form of hard cemented layer or layers of carbonates	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-HL
carbonatesFormsValueCode-M	M	marl layer	Secondary carbonates in soil in the form of marl layer	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-M
carbonatesFormsValueCode-PM	PM	pseudomycelia* (carbonate infillings in pores, resembling mycelia)	Secondary carbonates in soil in the form of pseudomycelia i.e. carbonate infillings in pores, resembling mycelia	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-PM
carbonatesFormsValueCode-SC	SC	soft concretions	Secondary carbonates in soil in the form of soft concretions	http://w3id.org/glosis/model/codelists/carbonatesFormsValueCode-SC
cementationContinuityValueCode-B	B	Broken	The layer is less than 50 percent cemented or compacted, and shows a rather irregular appearance.	http://w3id.org/glosis/model/codelists/cementationContinuityValueCode-B
cementationContinuityValueCode-C	C	Continuous	The layer is more than 90 percent cemented or compacted, and is only interrupted in places by cracks or fissures.	http://w3id.org/glosis/model/codelists/cementationContinuityValueCode-C
cementationContinuityValueCode-D	D	Discontinuous	The layer is 50–90 percent cemented or compacted, and in general shows a regular appearance.	http://w3id.org/glosis/model/codelists/cementationContinuityValueCode-D
cementationDegreeValueCode-C	C	Cemented	Cemented mass cannot be broken in the hands and is continuous (more than 90 percent of soil mass).	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-C
cementationDegreeValueCode-I	I	Indurated	Cemented mass cannot be broken by body weight (75-kg standard soil scientist) (more than 90 percent of soil mass).	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-I
cementationDegreeValueCode-M	M	Moderately cemented	Cemented mass cannot be broken in the hands but is discontinuous (less than 90 percent of soil mass).	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-M
cementationDegreeValueCode-N	N	Non-cemented and non-compacted	Neither cementation nor compaction observed (slakes in water).	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-N
cementationDegreeValueCode-W	W	Weakly cemented	Cemented mass is brittle and hard, but can be broken in the hands.	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-W
cementationDegreeValueCode-Y	Y	Compacted but non-cemented	Compacted mass is appreciably harder or more brittle than other comparable soil mass (slakes in water).	http://w3id.org/glosis/model/codelists/cementationDegreeValueCode-Y
cementationFabricValueCode-D	D	Nodular	The layer is largely constructed from cemented nodules or concretions of irregular shape.	http://w3id.org/glosis/model/codelists/cementationFabricValueCode-D
cementationFabricValueCode-Pi	Pi	Pisolithic	The layer is largely constructed from cemented spherical nodules.	http://w3id.org/glosis/model/codelists/cementationFabricValueCode-Pi
cementationFabricValueCode-Pl	Pl	Platy	The compacted or cemented parts are platelike and have a horizontal or subhorizontal orientation.	http://w3id.org/glosis/model/codelists/cementationFabricValueCode-Pl
cementationFabricValueCode-V	V	Vesicular	The layer has large, equidimensional voids that may be filled with uncemented material.	http://w3id.org/glosis/model/codelists/cementationFabricValueCode-V
cementationNatureValueCode-C	C	Clay	Primary cementing material containing Clay	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-C
cementationNatureValueCode-CS	CS	Clay–sesquioxides	Primary cementing material containing Clay–sesquioxides	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-CS
cementationNatureValueCode-F	F	Iron	Primary cementing material containing Iron	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-F
cementationNatureValueCode-FM	FM	Iron–manganese (sesquioxides)	Primary cementing material containing Iron–manganese (sesquioxides)	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-FM
cementationNatureValueCode-FO	FO	Iron–organic matter	Primary cementing material containing Iron–organic matter	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-FO
cementationNatureValueCode-GY	GY	Gypsum	Primary cementing material containing Gypsum	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-GY
cementationNatureValueCode-I	I	Ice	Primary cementing material containing Ice	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-I
cementationNatureValueCode-K	K	Carbonates	Primary cementing material containing Carbonates	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-K
cementationNatureValueCode-KQ	KQ	Carbonates–silica	Primary cementing material containing Carbonates–silica	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-KQ
cementationNatureValueCode-M	M	Mechanical	Primary cementing material containing Mechanical	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-M
cementationNatureValueCode-NK	NK	Not known	Primary cementing material containing Not known contents	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-NK
cementationNatureValueCode-P	P	Ploughing	Primary cementing material containing Ploughing	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-P
cementationNatureValueCode-Q	Q	Silica	Primary cementing material containing Silica	http://w3id.org/glosis/model/codelists/cementationNatureValueCode-Q
coatingAbundanceValueCode-A	A	Abundant	40–80% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-A
coatingAbundanceValueCode-C	C	Common	5–15% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-C
coatingAbundanceValueCode-D	D	Dominant	> 80% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-D
coatingAbundanceValueCode-F	F	Few	2–5% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-F
coatingAbundanceValueCode-M	M	Many	15–40% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-M
coatingAbundanceValueCode-N	N	None	0% of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-N
coatingAbundanceValueCode-V	V	Very few	0–2 % of coating abundance	http://w3id.org/glosis/model/codelists/coatingAbundanceValueCode-V
consistenceDryValueCode-LO	LO	Loose	Non-coherent.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-LO
coatingContrastValueCode-D	D	Distinct	Surface of coating is distinctly smoother or different in colour from the adjacent surface. Fine sand grains are enveloped in the coating but their outlines are still visible. Lamellae are 2–5 mm thick.	http://w3id.org/glosis/model/codelists/coatingContrastValueCode-D
coatingContrastValueCode-F	F	Faint	Surface of coating shows only little contrast in colour, smoothness or any other property to the adjacent surface. Fine sand grains are readily apparent in the cutan. Lamellae are less than 2 mm thick.	http://w3id.org/glosis/model/codelists/coatingContrastValueCode-F
coatingContrastValueCode-P	P	Prominent	Surface of coatings contrasts strongly in smoothness or colour with the adjacent surfaces. Outlines of fine sand grains are not visible. Lamellae are more than 5 mm thick.	http://w3id.org/glosis/model/codelists/coatingContrastValueCode-P
coatingFormValueCode-C	C	Continuous	Continuous form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-C
coatingFormValueCode-CI	CI	Continuous irregular (non-uniform, heterogeneous)	Continuous irregular (non-uniform, heterogeneous)form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-CI
coatingFormValueCode-DC	DC	Discontinuous circular	Discontinuous circular form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-DC
coatingFormValueCode-DE	DE	Dendroidal	Dendroidal form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-DE
coatingFormValueCode-DI	DI	Discontinuous irregular	Discontinuous irregular form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-DI
coatingFormValueCode-O	O	Other	Other kind of form coatings	http://w3id.org/glosis/model/codelists/coatingFormValueCode-O
coatingLocationValueCode-BR	BR	Bridges between sand grains	Location of coatings and clay accumulation in the form of bridges between sand grains	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-BR
coatingLocationValueCode-CF	CF	Coarse fragments	Location of coatings and clay accumulation in the form of coarse fragments	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-CF
coatingLocationValueCode-LA	LA	Lamellae (clay bands)	Location of coatings and clay accumulation in the form of Lamellae (clay bands)	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-LA
coatingLocationValueCode-NS	NS	No specific location	No specific location of coatings and clay accumulation	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-NS
coatingLocationValueCode-P	P	Pedfaces	Location of coatings and clay accumulation in the form of Pedfaces	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-P
coatingLocationValueCode-PH	PH	Horizontal pedfaces	Location of coatings and clay accumulation in the form of horizontal pedfaces	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-PH
coatingLocationValueCode-PV	PV	Vertical pedfaces	Location of coatings and clay accumulation in the form of vertical pedfaces	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-PV
coatingLocationValueCode-VO	VO	Voids	Location of coatings and clay accumulation in the form of voids	http://w3id.org/glosis/model/codelists/coatingLocationValueCode-VO
coatingNatureValueCode-C	C	Clay	Clay	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-C
coatingNatureValueCode-CC	CC	Calcium carbonate	Calcium carbonate	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-CC
coatingNatureValueCode-CH	CH	Clay and humus (organic matter)	Clay and humus (organic matter)	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-CH
coatingNatureValueCode-CS	CS	Clay and sesquioxides	Clay and sesquioxides	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-CS
coatingNatureValueCode-GB	GB	Gibbsite	Gibbsite	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-GB
coatingNatureValueCode-H	H	Humus	Humus	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-H
coatingNatureValueCode-HC	HC	Hypodermic coatings (Hypodermic coatings, as used here, are field-scale features, commonly only expressed as hydromorphic features. Micromorphological hypodermic coatings include non-redox features [Bullock et al., 1985].)	Hypodermic coatings (Hypodermic coatings, as used here, are field-scale features, commonly only expressed as hydromorphic features. Micromorphological hypodermic coatings include non-redox features [Bullock et al., 1985].)	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-HC
coatingNatureValueCode-JA	JA	Jarosite	Jarosite	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-JA
coatingNatureValueCode-MN	MN	Manganese	Manganese	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-MN
coatingNatureValueCode-PF	PF	Pressure faces	Pressure faces	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-PF
coatingNatureValueCode-S	S	Sesquioxides	Sesquioxides	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-S
coatingNatureValueCode-SA	SA	Sand coatings	Sand coatings	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SA
coatingNatureValueCode-SF	SF	Shiny faces (as in nitic horizon)	Shiny faces (as in nitic horizon)	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SF
coatingNatureValueCode-SI	SI	Slickensides, predominantly intersecting (Slickensides are polished and grooved ped surfaces that are produced by aggregates sliding one past another.)	Slickensides, predominantly intersecting (Slickensides are polished and grooved ped surfaces that are produced by aggregates sliding one past another.)	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SI
coatingNatureValueCode-SL	SL	Silica (opal)	Silica (opal)	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SL
coatingNatureValueCode-SN	SN	Slickensides, non intersecting	Slickensides, non intersecting	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SN
coatingNatureValueCode-SP	SP	Slickensides, partly intersecting	Slickensides, partly intersecting	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-SP
coatingNatureValueCode-ST	ST	Silt coatings	Silt coatings	http://w3id.org/glosis/model/codelists/coatingNatureValueCode-ST
consistenceDryValueCode-EHA	EHA	Extremely hard	Extremely resistant to pressure; cannot be broken in the hands.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-EHA
consistenceDryValueCode-HA	HA	Hard	Moderately resistant to pressure; can be broken in the hands; not breakable between thumb and forefinger.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-HA
consistenceDryValueCode-HVH	HVH	hard to very hard	Additional code formed by combining HA and VHA	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-HVH
consistenceDryValueCode-SHA	SHA	Slightly hard	Weakly resistant to pressure; easily broken between thumb and forefinger.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-SHA
consistenceDryValueCode-SHH	SHH	slightly hard to hard	slightly hard to hard	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-SHH
consistenceDryValueCode-SO	SO	Soft	Soil mass is very weakly coherent and fragile; breaks to powder or individual grains under very slight pressure.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-SO
consistenceDryValueCode-SSH	SSH	soft to slightly hard	soft to slightly hard	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-SSH
consistenceDryValueCode-VHA	VHA	Very hard	Very hard Very resistant to pressure; can be broken in the hands only with difficulty.	http://w3id.org/glosis/model/codelists/consistenceDryValueCode-VHA
consistenceMoistValueCode-EFI	EFI	Extremely firm	Soil material crushes only under very strong pressure; cannot be crushed between thumb and forefinger.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-EFI
consistenceMoistValueCode-FI	FI	Firm	Soil material crushes under moderate pressure between thumb and forefinger, but resistance is distinctly noticeable.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-FI
consistenceMoistValueCode-FR	FR	Friable	Soil material crushes easily under gentle to moderate pressure between thumb and forefinger, and coheres when pressed together.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-FR
consistenceMoistValueCode-LO	LO	Loose	Non-coherent.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-LO
consistenceMoistValueCode-VFI	VFI	Very firm	Soil material crushes under strong pressures; barely crushable between thumb and forefinger.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-VFI
consistenceMoistValueCode-VFR	VFR	Very friable	Soil material crushes under very gentle pressure, but coheres when pressed together.	http://w3id.org/glosis/model/codelists/consistenceMoistValueCode-VFR
fragmentsClassValueCode-FGF1	FGF1	FragmentsGravimetricFraction01	Horizon layer property of Coarse fragments - gravimetric fraction 01	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FGF1
fragmentsClassValueCode-FGF2	FGF2	FragmentsGravimetricFraction02	Horizon layer property of Coarse fragments - gravimetric fraction 02	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FGF2
fragmentsClassValueCode-FGF3	FGF3	FragmentsGravimetricFraction03	Horizon layer property of Coarse fragments - gravimetric fraction 03	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FGF3
fragmentsClassValueCode-FGF4	FGF4	FragmentsGravimetricFraction04	Horizon layer property of Coarse fragments - gravimetric fraction 04	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FGF4
fragmentsClassValueCode-FGT	FGT	FragmentsGravimetricTotal	Horizon layer property of Coarse fragments - gravimetric total	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FGT
fragmentsClassValueCode-FV1	FV1	FragmentsVolumetric01	Horizon layer property of Coarse fragments - volumetric fraction 01	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FV1
fragmentsClassValueCode-FV2	FV2	FragmentsVolumetric02	Horizon layer property of Coarse fragments - volumetric fraction 02	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FV2
fragmentsClassValueCode-FV3	FV3	FragmentsVolumetric03	Horizon layer property of Coarse fragments - volumetric fraction 03	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FV3
fragmentsClassValueCode-FVE	FVE	FragmentsVolumetricEstimate	Horizon layer property of Coarse fragments - volumetric total, field estimated 	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FVE
fragmentsClassValueCode-FVT	FVT	FragmentsVolumetricTotal	Horizon layer property of Coarse fragments - volumetric total	http://w3id.org/glosis/model/codelists/fragmentsClassValueCode-FVT
gypsumContentValueCode-EX	EX	Extremely gypsiric	≈ > 60	http://w3id.org/glosis/model/codelists/gypsumContentValueCode-EX
gypsumContentValueCode-MO	MO	Moderately gypsiric	≈ 5–15 EC = > 1.8 dS m-1 in 10 g soil/250 ml H2O	http://w3id.org/glosis/model/codelists/gypsumContentValueCode-MO
gypsumContentValueCode-N	N	Non-gypsiric	0 EC = < 0.18 dS m-1 in 10 g soil/250 ml H2O	http://w3id.org/glosis/model/codelists/gypsumContentValueCode-N
gypsumContentValueCode-SL	SL	Slightly gypsiric	≈ 0–5 EC = < 1.8 dS m-1 in 10 g soil/250 ml H2O	http://w3id.org/glosis/model/codelists/gypsumContentValueCode-SL
gypsumContentValueCode-ST	ST	Strongly gypsiric	≈ 15–60 higher amounts may be differentiated by abundance of H2O-soluble pseudomycelia/crystals and soil colour	http://w3id.org/glosis/model/codelists/gypsumContentValueCode-ST
gypsumFormsValueCode-D	D	disperse powdery gypsum	Secondary gypson in the form of disperse powdery gypsum	http://w3id.org/glosis/model/codelists/gypsumFormsValueCode-D
gypsumFormsValueCode-G	G	gazha	Secondary gypson in the form of gazha (clayey water-saturated layer with high gypsum content)	http://w3id.org/glosis/model/codelists/gypsumFormsValueCode-G
gypsumFormsValueCode-HL	HL	hard cemented layer or layers of gypsum	Secondary gypson in the form of hard cemented layer or layers of gypsum less than 10 cm thick	http://w3id.org/glosis/model/codelists/gypsumFormsValueCode-HL
gypsumFormsValueCode-SC	SC	soft concretions	Secondary gypsum in the form of soft concretions	http://w3id.org/glosis/model/codelists/gypsumFormsValueCode-SC
mineralConcColourValueCode-BB	BB	Bluish-black	Mineral concentration of color code Bluish-black	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-BB
mineralConcColourValueCode-BL	BL	Black	Mineral concentration of color code Black	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-BL
mineralConcColourValueCode-BR	BR	Brown	Mineral concentration of color code Brown	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-BR
mineralConcColourValueCode-BS	BS	Brownish	Mineral concentration of color code Brownish	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-BS
mineralConcColourValueCode-BU	BU	Blue	Mineral concentration of color code Blue	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-BU
mineralConcColourValueCode-GE	GE	Greenish	Mineral concentration of color code Greenish	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-GE
mineralConcColourValueCode-GR	GR	Grey	Mineral concentration of color code Grey	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-GR
mineralConcColourValueCode-GS	GS	Greyish	Mineral concentration of color code Greyish	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-GS
mineralConcColourValueCode-MC	MC	Multicoloured	Mineral concentration of color code Multicoloured	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-MC
mineralConcColourValueCode-RB	RB	Reddish brown	Mineral concentration of color code Reddish brown	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-RB
mineralConcColourValueCode-RE	RE	Red	Mineral concentration of color code Red	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-RE
mineralConcColourValueCode-RS	RS	Reddish	Mineral concentration of color code Reddish	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-RS
mineralConcColourValueCode-RY	RY	Reddish yellow	Mineral concentration of color code Reddish yellow	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-RY
mineralConcColourValueCode-WH	WH	White	Mineral concentration of color code White	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-WH
mineralConcColourValueCode-YB	YB	Yellowish brown	Mineral concentration of color code Yellowish brown	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-YB
mineralConcColourValueCode-YE	YE	Yellow	Mineral concentration of color code Yellow	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-YE
mineralConcColourValueCode-YR	YR	Yellowish red	Mineral concentration of color code Yellowish red	http://w3id.org/glosis/model/codelists/mineralConcColourValueCode-YR
mineralConcHardnessValueCode-B	B	Both hard and soft.	Both hard and soft.	http://w3id.org/glosis/model/codelists/mineralConcHardnessValueCode-B
mineralConcHardnessValueCode-H	H	Hard	Cannot be broken in the fingers.	http://w3id.org/glosis/model/codelists/mineralConcHardnessValueCode-H
mineralConcHardnessValueCode-S	S	Soft	Can be broken between forefinger and thumb nail	http://w3id.org/glosis/model/codelists/mineralConcHardnessValueCode-S
mineralConcKindValueCode-C	C	Concretion	A discrete body with a concentric internal structure, generally cemented.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-C
mineralConcKindValueCode-IC	IC	Crack infillings	Crack infillings refer to the materials that accumulate within cracks or fissures in the soil, typically formed due to drying or other physical stresses on the soil structure. These materials can include clays, silt, sand, or mineral deposits that enter cracks over time, often through the action of water or wind. Crack infillings can influence the soil's physical properties, such as its permeability and structure, as they may either facilitate or impede the movement of water and air through the soil. Additionally, crack infillings can impact soil fertility, as they may contain higher concentrations of certain nutrients or minerals that accumulate in these voids. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-IC
mineralConcKindValueCode-IP	IP	Pore infillings	Including pseudomycelium of carbonates or opal.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-IP
mineralConcKindValueCode-N	N	Nodule	Discrete body without an internal organization.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-N
mineralConcKindValueCode-O	O	Other	The term Other in the context of soil mineral concentrations generally refers to any minerals or materials found in the soil that do not fall under commonly categorized types such as clay, silt, or sand. This could include uncommon minerals, organic matter, or anthropogenic substances that are present in the soil but don't fit into the standard classifications of soil texture or composition. These other substances may have a significant effect on soil properties, influencing aspects like nutrient availability, soil pH, and the ability to retain water. In many cases, Other minerals are identified through advanced soil testing and chemical analysis. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-O
mineralConcKindValueCode-R	R	Residual rock fragment	Discrete impregnated body still showing rock structure.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-R
mineralConcKindValueCode-S	S	Soft segregation (or soft accumulation)	Differs from the surrounding soil mass in colour and composition but is not easily separated as a discrete body.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-S
mineralConcKindValueCode-SC	SC	Soft concretion	Soft concretion	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-SC
mineralConcKindValueCode-T	T	Crystal	Crystals in soil refer to solid, naturally occurring minerals that have a regular and repeating internal structure, which can often be seen under a microscope or with the naked eye. These crystal formations typically occur when minerals precipitate from water or melt and re-crystallize under certain environmental conditions, such as changes in temperature or pressure. Common crystal minerals in soil include quartz, gypsum, calcite, and halite. The presence of crystals in soil can significantly affect its properties, including drainage, fertility, and nutrient availability. For example, gypsum crystals can improve soil structure, while the presence of salt crystals can lead to soil salinity problems. Source: Brady & Weil (2017), The Nature and Properties of Soils.	http://w3id.org/glosis/model/codelists/mineralConcKindValueCode-T
mineralConcNatureValueCode-C	C	Clay (argillaceous)	Nature of mineral concentration with Clay (argillaceous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-C
mineralConcNatureValueCode-CS	CS	Clay–sesquioxides	Nature of mineral concentration with Clay–sesquioxides	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-CS
mineralConcNatureValueCode-F	F	Iron (ferruginous)	Nature of mineral concentration with Iron (ferruginous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-F
mineralConcNatureValueCode-FM	FM	Iron–manganese (sesquioxides)	Nature of mineral concentration with Iron–manganese (sesquioxides)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-FM
mineralConcNatureValueCode-GB	GB	Gibbsite	Nature of mineral concentration with Gibbsite	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-GB
mineralConcNatureValueCode-GY	GY	Gypsum (gypsiferous)	Nature of mineral concentration with Gypsum (gypsiferous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-GY
mineralConcNatureValueCode-JA	JA	Jarosite	Nature of mineral concentration with Jarosite	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-JA
mineralConcNatureValueCode-K	K	Carbonates (calcareous)	Nature of mineral concentration with Carbonates (calcareous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-K
mineralConcNatureValueCode-KQ	KQ	Carbonates–silica	Nature of mineral concentration with Carbonates–silica	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-KQ
mineralConcNatureValueCode-M	M	Manganese (manganiferous)	Nature of mineral concentration with Manganese (manganiferous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-M
mineralConcNatureValueCode-NK	NK	Not known	Nature of mineral concentration with unknown substances	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-NK
mineralConcNatureValueCode-Q	Q	Silica (siliceous)	Nature of mineral concentration with Silica (siliceous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-Q
mineralConcNatureValueCode-S	S	Sulphur (sulphurous)	Nature of mineral concentration with Sulphur (sulphurous)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-S
mineralConcNatureValueCode-SA	SA	Salt (saline)	Nature of mineral concentration with Salt (saline)	http://w3id.org/glosis/model/codelists/mineralConcNatureValueCode-SA
mineralConcShapeValueCode-A	A	Angular	Angular shape of mineral concentrations	http://w3id.org/glosis/model/codelists/mineralConcShapeValueCode-A
mineralConcShapeValueCode-E	E	Elongated	Elongated shape of mineral concentrations	http://w3id.org/glosis/model/codelists/mineralConcShapeValueCode-E
mineralConcShapeValueCode-F	F	Flat	Flat shape of mineral concentrations	http://w3id.org/glosis/model/codelists/mineralConcShapeValueCode-F
mineralConcShapeValueCode-I	I	Irregular	Irregular shape of mineral concentrations	http://w3id.org/glosis/model/codelists/mineralConcShapeValueCode-I
mineralConcShapeValueCode-R	R	Rounded (spherical)	Rounded (spherical) shape of mineral concentrations	http://w3id.org/glosis/model/codelists/mineralConcShapeValueCode-R
mineralConcSizeValueCode-C	C	Coarse	Mineral concentration ranging fron size of  > 20mm	http://w3id.org/glosis/model/codelists/mineralConcSizeValueCode-C
mineralConcSizeValueCode-F	F	Fine	Mineral concentration ranging fron size of 2mm–6mm	http://w3id.org/glosis/model/codelists/mineralConcSizeValueCode-F
mineralConcSizeValueCode-M	M	Medium	Mineral concentration ranging fron size of 6mm–20mm	http://w3id.org/glosis/model/codelists/mineralConcSizeValueCode-M
mineralConcSizeValueCode-V	V	Very fine	Mineral concentration ranging fron size of < 2mm	http://w3id.org/glosis/model/codelists/mineralConcSizeValueCode-V
mineralConcVolumeValueCode-A	A	Abundant	Having mineral concentarion volume of 40–80%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-A
mineralConcVolumeValueCode-C	C	Common	Having mineral concentarion volume of 5–15%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-C
mineralConcVolumeValueCode-D	D	Dominant	Having mineral concentarion volume of more than 80%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-D
mineralConcVolumeValueCode-F	F	Few	Having mineral concentarion volume of 2–5%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-F
mineralConcVolumeValueCode-M	M	Many	Having mineral concentarion volume of 15–40%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-M
mineralConcVolumeValueCode-N	N	None	Having 0 mineral concentarion volume	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-N
mineralConcVolumeValueCode-V	V	Very few	Having mineral concentarion volume of 0–2%	http://w3id.org/glosis/model/codelists/mineralConcVolumeValueCode-V
mineralFragmentsValueCode-FE	FE	Feldspar	Rocks with primary mineral containing Feldspar	http://w3id.org/glosis/model/codelists/mineralFragmentsValueCode-FE
mineralFragmentsValueCode-MI	MI	Mica	Rocks with primary mineral containing Mica	http://w3id.org/glosis/model/codelists/mineralFragmentsValueCode-MI
mineralFragmentsValueCode-QU	QU	Quartz	Rocks with primary mineral containing Quartz	http://w3id.org/glosis/model/codelists/mineralFragmentsValueCode-QU
mottlesAbundanceValueCode-A	A	Abundant	The muttle abundance is more than 40%	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-A
mottlesAbundanceValueCode-C	C	Common	Commonly found muttle abundance of 5–15%	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-C
mottlesAbundanceValueCode-F	F	Few	Fewer muttle abundace with 2–5 %	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-F
mottlesAbundanceValueCode-M	M	Many	Muttle abundance of 15–40%	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-M
mottlesAbundanceValueCode-N	N	None	The muttle abundance is zero	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-N
mottlesAbundanceValueCode-V	V	Very few	Very few muttle abundace of 0–2 %	http://w3id.org/glosis/model/codelists/mottlesAbundanceValueCode-V
boundaryClassificationValueCode-C	C	Clear	Boundary of mottles 0.5–2 mm	http://w3id.org/glosis/model/codelists/boundaryClassificationValueCode-C
boundaryClassificationValueCode-D	D	Diffuse	Boundary of mottles > 2 mm	http://w3id.org/glosis/model/codelists/boundaryClassificationValueCode-D
boundaryClassificationValueCode-S	S	Sharp	Boundary of mottles < 0.5	http://w3id.org/glosis/model/codelists/boundaryClassificationValueCode-S
contrastValueCode-D	D	Distinct	Although not striking, the mottles are readily seen. The hue, chroma and value of the matrix are easily distinguished from those of the mottles. They may vary by as much as 2.5 units of hue or several units in chroma or value.	http://w3id.org/glosis/model/codelists/contrastValueCode-D
contrastValueCode-F	F	Faint	The mottles are evident only on close examination. Soil colours in both the matrix and mottles have closely related hues, chromas and values.	http://w3id.org/glosis/model/codelists/contrastValueCode-F
contrastValueCode-P	P	Prominent	The mottles are conspicuous and mottling is one of the outstanding features of the horizon. Hue, chroma and value alone or in combination are at least several units apart.	http://w3id.org/glosis/model/codelists/contrastValueCode-P
mottlesSizeValueCode-A	A	Coarse	Coarse mottle of > 20	http://w3id.org/glosis/model/codelists/mottlesSizeValueCode-A
mottlesSizeValueCode-F	F	F Fine	Fine mottle of size 2–6	http://w3id.org/glosis/model/codelists/mottlesSizeValueCode-F
mottlesSizeValueCode-M	M	M Medium	Medium mottle of size 6–20	http://w3id.org/glosis/model/codelists/mottlesSizeValueCode-M
mottlesSizeValueCode-V	V	Very fine	Very fine mottle size of less than  2	http://w3id.org/glosis/model/codelists/mottlesSizeValueCode-V
peatDecompostionValueCode-D1	D1	very low	Subtype Fibric and the degree of decomposition and humification of peat is very low	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D1
peatDecompostionValueCode-D2	D2	low	Subtype Fibric and the degree of decomposition and humification of peat is low	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D2
peatDecompostionValueCode-D3	D3	moderate	Subtype Fibric and the degree of decomposition and humification of peat is moderate	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D3
peatDecompostionValueCode-D4	D4	strong	Subtype Hemic and the degree of decomposition and humification of peat is strong	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D4
peatDecompostionValueCode-D5.1	D5.1	moderately strong	Subtype Hemic and the degree of decomposition and humification of peat is moderately strong	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D5.1
peatDecompostionValueCode-D5.2	D5.2	very strong	Subtype Sapric and the degree of decomposition and humification of peat is very strong	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-D5.2
peatDecompostionValueCode-Fibric	Fibric	Fibric	Degree of decomposition and humification of peat of subtype Fibric	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-Fibric
peatDecompostionValueCode-Hemic	Hemic	Hemic	Degree of decomposition and humification of peat of subtype Hemic	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-Hemic
peatDecompostionValueCode-Sapric	Sapric	Sapric	Degree of decomposition and humification of peat of subtype Sapric	http://w3id.org/glosis/model/codelists/peatDecompostionValueCode-Sapric
peatDrainageValueCode-DC1	DC1	Undrained	Undrained peat material	http://w3id.org/glosis/model/codelists/peatDrainageValueCode-DC1
peatDrainageValueCode-DC2	DC2	Weakly drained	Weakly drained peat material	http://w3id.org/glosis/model/codelists/peatDrainageValueCode-DC2
peatDrainageValueCode-DC3	DC3	Moderately drained	Moderately drained peat material	http://w3id.org/glosis/model/codelists/peatDrainageValueCode-DC3
peatDrainageValueCode-DC4	DC4	Well drained	Well drained peat material	http://w3id.org/glosis/model/codelists/peatDrainageValueCode-DC4
peatVolumeValueCode-SV1	SV1	Less than 3%	Solid Volume of percentage less than 3%: < 3%	http://w3id.org/glosis/model/codelists/peatVolumeValueCode-SV1
peatVolumeValueCode-SV2	SV2	Between 3% and 5%	Solid Volume of percentage of 3 - 5 %	http://w3id.org/glosis/model/codelists/peatVolumeValueCode-SV2
peatVolumeValueCode-SV3	SV3	Between 5% and 8%	Solid Volume of percentage of 5 - 8%	http://w3id.org/glosis/model/codelists/peatVolumeValueCode-SV3
peatVolumeValueCode-SV4	SV4	Between 8% and 12%	Solid Volume of percentage of 8 to 12%	http://w3id.org/glosis/model/codelists/peatVolumeValueCode-SV4
peatVolumeValueCode-SV5	SV5	More than or equal to 12 %	Solid Volume of percentage more than or equal to 12 %: ≥ 12%	http://w3id.org/glosis/model/codelists/peatVolumeValueCode-SV5
plasticityValueCode-NPL	NPL	Non-plastic	No wire is formable.	http://w3id.org/glosis/model/codelists/plasticityValueCode-NPL
plasticityValueCode-PL	PL	Plastic	Wire formable but breaks if bent into a ring; slight to moderate force required for deformation of the soil mass.	http://w3id.org/glosis/model/codelists/plasticityValueCode-PL
plasticityValueCode-PVP	PVP	plastic to very plastic	Additioanl plasticity code with combination of  PL and VPL	http://w3id.org/glosis/model/codelists/plasticityValueCode-PVP
plasticityValueCode-SPL	SPL	Slightly plastic	Wire formable but breaks immediately if bent into a ring; soil mass deformed by very slight force.	http://w3id.org/glosis/model/codelists/plasticityValueCode-SPL
plasticityValueCode-SPP	SPP	slightly plastic to plastic	Additioanl plasticity code with combination of  SPL and PL	http://w3id.org/glosis/model/codelists/plasticityValueCode-SPP
plasticityValueCode-VPL	VPL	Very plastic	Wire formable and can be bent into a ring; moderately strong to very strong force required for deformation of the soil mass.	http://w3id.org/glosis/model/codelists/plasticityValueCode-VPL
poresAbundanceValueCode-C	C	Common	< 2 mm (number)50–200 ;> 2 mm (number)5–20	http://w3id.org/glosis/model/codelists/poresAbundanceValueCode-C
poresAbundanceValueCode-F	F	Few	< 2 mm (number)20–50;> 2 mm (number) 2–5	http://w3id.org/glosis/model/codelists/poresAbundanceValueCode-F
poresAbundanceValueCode-M	M	Many	< 2 mm (number)> 200 ;> 2 mm (number)> 20	http://w3id.org/glosis/model/codelists/poresAbundanceValueCode-M
poresAbundanceValueCode-N	N	None	< 2 mm (number)0;> 2 mm (number)0	http://w3id.org/glosis/model/codelists/poresAbundanceValueCode-N
poresAbundanceValueCode-V	V	Very few	< 2 mm (number)1–20 ;> 2 mm (number)1–2	http://w3id.org/glosis/model/codelists/poresAbundanceValueCode-V
porosityClassValueCode-1	1	Very low	Very low porosity of les than 2%	http://w3id.org/glosis/model/codelists/porosityClassValueCode-1
porosityClassValueCode-2	2	Low	Low porosity of 2–5%	http://w3id.org/glosis/model/codelists/porosityClassValueCode-2
porosityClassValueCode-3	3	Medium	Medium porosity of 5–15%	http://w3id.org/glosis/model/codelists/porosityClassValueCode-3
porosityClassValueCode-4	4	High	High porosity of 15–40%	http://w3id.org/glosis/model/codelists/porosityClassValueCode-4
porosityClassValueCode-5	5	Very high	Very high porosity of more than 40%	http://w3id.org/glosis/model/codelists/porosityClassValueCode-5
rootsAbundanceValueCode-C	C	Common	< 2 mm (number)50–200 ;> 2 mm (number)5–20	http://w3id.org/glosis/model/codelists/rootsAbundanceValueCode-C
rootsAbundanceValueCode-F	F	Few	< 2 mm (number)20–50;> 2 mm (number) 2–5	http://w3id.org/glosis/model/codelists/rootsAbundanceValueCode-F
rootsAbundanceValueCode-M	M	Many	< 2 mm (number)> 200 ;> 2 mm (number)> 20	http://w3id.org/glosis/model/codelists/rootsAbundanceValueCode-M
rootsAbundanceValueCode-N	N	None	< 2 mm (number)0;> 2 mm (number)0	http://w3id.org/glosis/model/codelists/rootsAbundanceValueCode-N
rootsAbundanceValueCode-V	V	Very few	< 2 mm (number)1–20 ;> 2 mm (number)1–2	http://w3id.org/glosis/model/codelists/rootsAbundanceValueCode-V
saltContentValueCode-EX	EX	Extremely salty	Extremely salty soil with salt content > 15 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-EX
saltContentValueCode-MO	MO	Moderately salty	Extremely salty soil with salt content 2–4 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-MO
saltContentValueCode-N	N	(nearly)Not salty	Nearly not salty soild with salt content less than  0.75 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-N
saltContentValueCode-SL	SL	Slightly salty	Slightly salty soil with salt content 0.75–2 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-SL
saltContentValueCode-ST	ST	Strongly salty	Strongly salty soil with salt content 4–8 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-ST
saltContentValueCode-VST	VST	Very strongly salty	Very strongly salty soil with salt content 8–15 dS m-1	http://w3id.org/glosis/model/codelists/saltContentValueCode-VST
voidsDiameterValueCode-C	C	Coarse	Coarse void with diameter between 5–20 m	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-C
voidsDiameterValueCode-F	F	Fine	Fine void with diameter between 0.5–2 m	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-F
voidsDiameterValueCode-FF	FF	fine and very fine	Fine and very fine void with combination of fine and very fine type	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-FF
voidsDiameterValueCode-FM	FM	fine and medium	Fine and medium void with combination of fine and medium type	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-FM
voidsDiameterValueCode-M	M	Medium	medium void with diameter 2–5	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-M
voidsDiameterValueCode-MC	MC	medium and coarse	Medium and coarse void with combination of medium and coarse type	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-MC
voidsDiameterValueCode-V	V	Very fine	Very fine void with diameter less than 0.5 m	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-V
voidsDiameterValueCode-VC	VC	Very coarse	very coarse void with diameter 20–50 m	http://w3id.org/glosis/model/codelists/voidsDiameterValueCode-VC
sandyTextureValueCode-CS	CS	Coarse sand	Coarse sand is a subdivision of the unspecified Sand (S) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-CS
sandyTextureValueCode-CSL	CSL	Coarse sandy loam	Coarse sandy loam is a subdivision of the Sandy Loam (SL) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-CSL
sandyTextureValueCode-FS	FS	Fine sand	Fine sand is a subdivision of the unspecified Sand (S) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-FS
sandyTextureValueCode-FSL	FSL	Fine sandy loam	Fine sandy loam is a subdivision of the Sandy Loam (SL) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-FSL
sandyTextureValueCode-LCS	LCS	Loamy coarse sand	Loamy coarse sand is a subdivision of the Loamy sand (LS) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-LCS
sandyTextureValueCode-LFS	LFS	Loamy fine sand	Loamy fine sand is a subdivision of the Loamy sand (LS) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-LFS
sandyTextureValueCode-LVFS	LVFS	Loamy very fine sand	Loamy very fine sand is a subdivision of the Loamy sand (LS) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-LVFS
sandyTextureValueCode-MS	MS	Medium sand	Medium sand is a subdivision of the unspecified Sand (S) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-MS
sandyTextureValueCode-US	US	Sand, unsorted	Unsorted Sand is a subdivision of the unspecified Sand (S) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-US
sandyTextureValueCode-VFS	VFS	Very fine sand	Very fine sand is a subdivision of the unspecified Sand (S) textural class	http://w3id.org/glosis/model/codelists/sandyTextureValueCode-VFS
stickinessValueCode-NST	NST	Non-sticky	After release of pressure, practically no soil material adheres to thumb and finger.	http://w3id.org/glosis/model/codelists/stickinessValueCode-NST
stickinessValueCode-SSS	SSS	slightly sticky to sticky	Additional code of combination of SST and ST	http://w3id.org/glosis/model/codelists/stickinessValueCode-SSS
stickinessValueCode-SST	SST	Slightly sticky	After pressure, soil material adheres to both thumb and finger but comes off one or the other rather cleanly. It is not appreciably stretched when the digits are separated.	http://w3id.org/glosis/model/codelists/stickinessValueCode-SST
stickinessValueCode-ST	ST	Sticky	After pressure, soil material adheres to both thumb and finger and tends to stretch somewhat and pull apart rather than pulling free from either digit.	http://w3id.org/glosis/model/codelists/stickinessValueCode-ST
stickinessValueCode-SVS	SVS	sticky to very sticky	Additional code of combination of ST and VST	http://w3id.org/glosis/model/codelists/stickinessValueCode-SVS
stickinessValueCode-VST	VST	Very sticky	After pressure, soil material adheres strongly to both thumb and finger and is decidedly stretched when they are separated.	http://w3id.org/glosis/model/codelists/stickinessValueCode-VST
structureGradeValueCode-MO	MO	Moderate	Aggregates are observable in place and there is a distinct arrangement of natural surfaces of weakness. When disturbed, the soil material breaks into a mixture of many entire aggregates, some broken aggregates, and little material without aggregates faces. Aggregates surfaces generally show distinct differences with the aggregates interiors.	http://w3id.org/glosis/model/codelists/structureGradeValueCode-MO
structureGradeValueCode-MS	MS	Moderate to strong	Moderate to strong	http://w3id.org/glosis/model/codelists/structureGradeValueCode-MS
structureGradeValueCode-ST	ST	Strong	Aggregates are clearly observable in place and there is a prominent arrangement of natural surfaces of weakness. When disturbed, the soil material separates mainly into entire aggregates. Aggregates surfaces generally differ markedly from aggregate interiors.	http://w3id.org/glosis/model/codelists/structureGradeValueCode-ST
structureGradeValueCode-WE	WE	Weak	Aggregates are barely observable in place and there is only a weak arrangement of natural surfaces of weakness. When gently disturbed, the soil material breaks into a mixture of few entire aggregates, many broken aggregates, and much material without aggregate faces. Aggregate surfaces differ in some way from the aggregate interior.	http://w3id.org/glosis/model/codelists/structureGradeValueCode-WE
structureGradeValueCode-WM	WM	Weak to moderate	Weak to moderate	http://w3id.org/glosis/model/codelists/structureGradeValueCode-WM
structureSizeValueCode-CO	CO	Coarse/thick	5–10 50–100 20–50	http://w3id.org/glosis/model/codelists/structureSizeValueCode-CO
structureSizeValueCode-EC	EC	Extremely coarse	– > 500 –	http://w3id.org/glosis/model/codelists/structureSizeValueCode-EC
structureSizeValueCode-FI	FI	Fine/thin	1–2 10–20 5–10	http://w3id.org/glosis/model/codelists/structureSizeValueCode-FI
structureSizeValueCode-ME	ME	Medium	2–5 20–50 10–20	http://w3id.org/glosis/model/codelists/structureSizeValueCode-ME
structureSizeValueCode-VC	VC	Very coarse/thick	> 10 1.1.000 > 50	http://w3id.org/glosis/model/codelists/structureSizeValueCode-VC
structureSizeValueCode-VF	VF	Very fine/thin	< 1 < 10 < 5	http://w3id.org/glosis/model/codelists/structureSizeValueCode-VF
voidsClassificationValueCode-B	B	Vesicular	Discontinuous spherical or elliptical voids (chambers) of sedimentary origin or formed by compressed air, e.g. gas bubbles in slaking crusts after heavy rainfall. Relatively unimportant in connection with plant growth.	http://w3id.org/glosis/model/codelists/voidsClassificationValueCode-B
voidsClassificationValueCode-C	C	Channels	Elongated voids of faunal or floral origin, mostly tubular in shape and continuous, varying strongly in diameter. When wider than a few centimetres (burrow holes), they are more adequately described under biological activity.	http://w3id.org/glosis/model/codelists/voidsClassificationValueCode-C
voidsClassificationValueCode-I	I	Interstitial	Controlled by the fabric, or arrangement, of the soil particles, also known as textural voids. Subdivision possible into simple packing voids, which relate to the packing of sand particles, and compound packing voids, which result from the packing of non-accommodating peds. Predominantly irregular in shape and interconnected, and hard to quantify in the field.	http://w3id.org/glosis/model/codelists/voidsClassificationValueCode-I
voidsClassificationValueCode-P	P	Planes	Most planes are extra-pedal voids, related to accommodating ped surfaces or cracking patterns. They are often not persistent and vary in size, shape and quantity depending on the moisture condition of the soil. Planar voids may be recorded, describing width and frequency.	http://w3id.org/glosis/model/codelists/voidsClassificationValueCode-P
voidsClassificationValueCode-V	V	Vughs	Mostly irregular, equidimensional voids of faunal origin or resulting from tillage or disturbance of other voids. Discontinuous or interconnected. May be quantified in specific cases.	http://w3id.org/glosis/model/codelists/voidsClassificationValueCode-V
\.


--
-- TOC entry 5228 (class 0 OID 55548781)
-- Dependencies: 233
-- Data for Name: element; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.element (element_id, profile_id, order_element, upper_depth, lower_depth, type) FROM stdin;
\.


--
-- TOC entry 5239 (class 0 OID 55548861)
-- Dependencies: 247
-- Data for Name: individual; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.individual (individual_id, email) FROM stdin;
\.


--
-- TOC entry 5240 (class 0 OID 55548867)
-- Dependencies: 248
-- Data for Name: languages; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.languages (language_code, language_name) FROM stdin;
\.


--
-- TOC entry 5241 (class 0 OID 55548873)
-- Dependencies: 249
-- Data for Name: observation_desc; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.observation_desc (procedure_desc_id, property_desc_id, category_desc_id, category_order, plot, surface, profile, element) FROM stdin;
FAO GfSD 2006	saltCoverProperty	saltCoverValueCode-0	\N	\N	t	\N	\N
FAO GfSD 2006	saltCoverProperty	saltCoverValueCode-1	\N	\N	t	\N	\N
FAO GfSD 2006	saltCoverProperty	saltCoverValueCode-2	\N	\N	t	\N	\N
FAO GfSD 2006	saltCoverProperty	saltCoverValueCode-3	\N	\N	t	\N	\N
FAO GfSD 2006	saltCoverProperty	saltCoverValueCode-4	\N	\N	t	\N	\N
FAO GfSD 2006	SaltThicknessProperty	saltThicknessValueCode-C	\N	\N	t	\N	\N
FAO GfSD 2006	SaltThicknessProperty	saltThicknessValueCode-F	\N	\N	t	\N	\N
FAO GfSD 2006	SaltThicknessProperty	saltThicknessValueCode-M	\N	\N	t	\N	\N
FAO GfSD 2006	SaltThicknessProperty	saltThicknessValueCode-N	\N	\N	t	\N	\N
FAO GfSD 2006	SaltThicknessProperty	saltThicknessValueCode-V	\N	\N	t	\N	\N
FAO GfSD 2006	sealingConsistenceProperty	sealingConsistenceValueCode-E	\N	\N	t	\N	\N
FAO GfSD 2006	sealingConsistenceProperty	sealingConsistenceValueCode-H	\N	\N	t	\N	\N
FAO GfSD 2006	sealingConsistenceProperty	sealingConsistenceValueCode-S	\N	\N	t	\N	\N
FAO GfSD 2006	sealingConsistenceProperty	sealingConsistenceValueCode-V	\N	\N	t	\N	\N
FAO GfSD 2006	sealingThicknessProperty	sealingThicknessValueCode-C	\N	\N	t	\N	\N
FAO GfSD 2006	sealingThicknessProperty	sealingThicknessValueCode-F	\N	\N	t	\N	\N
FAO GfSD 2006	sealingThicknessProperty	sealingThicknessValueCode-M	\N	\N	t	\N	\N
FAO GfSD 2006	sealingThicknessProperty	sealingThicknessValueCode-N	\N	\N	t	\N	\N
FAO GfSD 2006	sealingThicknessProperty	sealingThicknessValueCode-V	\N	\N	t	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Ba	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Ma	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Mi	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Oa	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Pa	\N	t	\N	\N	\N
FAO GfSD 2006	weatheringFragmentsProperty	weatheringValueCode-W	\N	t	t	\N	t
FAO GfSD 2006	bleachedSandProperty	bleachedSandValueCode-0	\N	\N	t	\N	t
FAO GfSD 2006	bleachedSandProperty	bleachedSandValueCode-1	\N	\N	t	\N	t
FAO GfSD 2006	bleachedSandProperty	bleachedSandValueCode-2	\N	\N	t	\N	t
FAO GfSD 2006	bleachedSandProperty	bleachedSandValueCode-3	\N	\N	t	\N	t
FAO GfSD 2006	cracksDepthProperty	cracksDepthValueCode-D	\N	\N	t	\N	t
FAO GfSD 2006	cracksDepthProperty	cracksDepthValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	cracksDepthProperty	cracksDepthValueCode-S	\N	\N	t	\N	t
FAO GfSD 2006	cracksDepthProperty	cracksDepthValueCode-V	\N	\N	t	\N	t
FAO GfSD 2006	cracksDistanceProperty	cracksDistanceValueCode-C	\N	\N	t	\N	t
FAO GfSD 2006	cracksDistanceProperty	cracksDistanceValueCode-D	\N	\N	t	\N	t
FAO GfSD 2006	cracksDistanceProperty	cracksDistanceValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	cracksDistanceProperty	cracksDistanceValueCode-V	\N	\N	t	\N	t
FAO GfSD 2006	cracksDistanceProperty	cracksDistanceValueCode-W	\N	\N	t	\N	t
FAO GfSD 2006	cracksWidthProperty	cracksWidthValueCode-E	\N	\N	t	\N	t
FAO GfSD 2006	cracksWidthProperty	cracksWidthValueCode-F	\N	\N	t	\N	t
FAO GfSD 2006	cracksWidthProperty	cracksWidthValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	cracksWidthProperty	cracksWidthValueCode-W	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-A	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-C	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-D	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-F	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-N	\N	\N	t	\N	t
FAO GfSD 2006	fragmentCoverProperty	fragmentCoverValueCode-V	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-B	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-C	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-F	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-L	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	fragmentsSizeProperty	fragmentsSizeValueCode-S	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-A	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-C	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-D	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-F	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-M	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-N	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-S	\N	\N	t	\N	t
FAO GfSD 2006	rockAbundanceProperty	rockAbundanceValueCode-V	\N	\N	t	\N	t
FAO GfSD 2006	rockShapeProperty	rockShapeValueCode-A	\N	\N	t	\N	t
FAO GfSD 2006	rockShapeProperty	rockShapeValueCode-F	\N	\N	t	\N	t
FAO GfSD 2006	rockShapeProperty	rockShapeValueCode-S	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-A	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-AC	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-AF	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-AM	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-AV	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-BL	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-C	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-CS	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-FM	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-MC	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-R	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RB	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RC	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RF	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RL	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RM	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-RS	\N	\N	t	\N	t
FAO GfSD 2006	rockSizeProperty	rockSizeValueCode-SB	\N	\N	t	\N	t
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Ri	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Ry	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_So	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ce_Wh	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fi	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fi_Co	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fi_Ju	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Al	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Cl	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Gr	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Ha	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Le	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Ma	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fo_Pu	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Ap	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Ba	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Ci	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Gr	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Ma	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Fr_Me	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Lu	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Lu_Cc	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Lu_Co	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Lu_Te	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Lu_To	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Cc	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Gr	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Li	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Op	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Ra	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Se	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_So	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Oi_Su	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ol	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ot	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ot_Pa	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ot_Ru	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ot_Sc	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Pu	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Pu_Be	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Pu_Le	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Pu_Pe	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ro	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ro_Ca	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ro_Po	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ro_Su	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ro_Ya	\N	t	\N	\N	\N
FAO GfSD 2006	cropClassProperty	cropClassValueCode-Ve	\N	t	\N	\N	\N
FAO GfSD 2006	erosionActivityPeriodProperty	erosionActivityPeriodValueCode-A	\N	t	\N	\N	\N
FAO GfSD 2006	erosionActivityPeriodProperty	erosionActivityPeriodValueCode-H	\N	t	\N	\N	\N
FAO GfSD 2006	erosionActivityPeriodProperty	erosionActivityPeriodValueCode-N	\N	t	\N	\N	\N
FAO GfSD 2006	erosionActivityPeriodProperty	erosionActivityPeriodValueCode-R	\N	t	\N	\N	\N
FAO GfSD 2006	erosionActivityPeriodProperty	erosionActivityPeriodValueCode-X	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-0	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-1	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-2	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-3	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-4	\N	t	\N	\N	\N
FAO GfSD 2006	erosionAreaAffectedProperty	erosionAreaAffectedValueCode-5	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-A	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-AD	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-AM	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-AS	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-AZ	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-N	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-NK	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-W	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WA	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WD	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WG	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WR	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WS	\N	t	\N	\N	\N
FAO GfSD 2006	erosionCategoryProperty	erosionCategoryValueCode-WT	\N	t	\N	\N	\N
FAO GfSD 2006	erosionDegreeProperty	erosionDegreeValueCode-E	\N	t	\N	\N	\N
FAO GfSD 2006	erosionDegreeProperty	erosionDegreeValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	erosionDegreeProperty	erosionDegreeValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	erosionDegreeProperty	erosionDegreeValueCode-V	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-0	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-1	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-2	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-3	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-4	\N	t	\N	\N	\N
FAO GfSD 2006	erosionTotalAreaAffectedProperty	erosionTotalAreaAffectedValueCode-5	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-AC	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-AD	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-BP	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-BR	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-BU	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-CL	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-CR	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-DU	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-FE	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-IB	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-ID	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-IF	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-IP	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-IS	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-IU	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-LF	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-LV	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-ME	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MI	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MO	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MP	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MR	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MS	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-MU	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-N	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-NK	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-PL	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-PO	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-SA	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-TE	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-VE	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-VM	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-VS	\N	t	\N	\N	\N
FAO GfSD 2006	humanInfluenceClassProperty	humanInfluenceClassValueCode-VU	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-A	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA3	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA4	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA5	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AA6	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AP	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AP1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AP2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AT	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AT1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AT2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AT3	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-AT4	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-F	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-FN	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-FN1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-FN2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-FP	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-H	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HE	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HE1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HE2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HE3	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HI	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HI1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-HI2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-MF	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-MP	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-Oi	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-P	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PD	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PD1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PD2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PN	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PN1	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PN2	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-PN3	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-SD	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-SI	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-SR	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-ST	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-SX	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-U	\N	t	\N	\N	\N
FAO GfSD 2006	landUseClassProperty	landUseClassValueCode-Y	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-CU	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-DO	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-DU	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-IM	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-IN	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-KA	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-RI	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-TE	\N	t	\N	\N	\N
FAO GfSD 2006	landformComplexProperty	landformComplexValueCode-WE	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-I	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IA	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IA1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IA2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IA3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IA4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IB	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IB1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IB2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IB3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-II	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-II1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-II2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IP	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IP1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IP2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IP3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IP4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IU	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IU1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IU2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-IU3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MA	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MA1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MA2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MA3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MA4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB5	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MB6	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MU	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-MU1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SC5	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SE	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SE1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SE2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SO	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SO1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SO2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-SO3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-U	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UA	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UA1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UA2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UC	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UC1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UC2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UE	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UE1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UE2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UF	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UF1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UF2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UG	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UG1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UG2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UG3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UK	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UK1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UK2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UL	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UL1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UL2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UM	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UM1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UM2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UO	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UO1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UO2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UR	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UR1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU1	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU2	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU3	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU4	\N	t	\N	\N	\N
FAO GfSD 2006	lithologyProperty	lithologyValueCode-UU5	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-A	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-AD	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-AM	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-AS	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-AZ	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-N	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-NK	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-W	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WA	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WD	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WG	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WR	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WS	\N	t	\N	\N	\N
FAO GfSD 2006	ParentDepositionProperty	erosionCategoryValueCode-WT	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-I	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IA	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IA1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IA2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IA3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IA4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IB	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IB1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IB2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IB3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-II	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-II1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-II2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IP	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IP1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IP2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IP3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IP4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IU	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IU1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IU2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-IU3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MA	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MA1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MA2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MA3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MA4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB5	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MB6	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MU	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-MU1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SC5	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SE	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SE1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SE2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SO	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SO1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SO2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-SO3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-U	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UA	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UA1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UA2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UC	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UC1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UC2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UE	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UE1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UE2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UF	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UF1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UF2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UG	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UG1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UG2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UG3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UK	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UK1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UK2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UL	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UL1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UL2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UM	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UM1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UM2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UO	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UO1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UO2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UR	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UR1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU1	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU2	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU3	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU4	\N	t	\N	\N	\N
FAO GfSD 2006	parentLithologyProperty	lithologyValueCode-UU5	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-I	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IA	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IA1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IA2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IA3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IA4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IB	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IB1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IB2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IB3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-II	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-II1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-II2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IP	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IP1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IP2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IP3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IP4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IU	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IU1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IU2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-IU3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MA	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MA1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MA2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MA3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MA4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB5	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MB6	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MU	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-MU1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SC5	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SE	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SE1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SE2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SO	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SO1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SO2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-SO3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-U	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UA	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UA1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UA2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UC	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UC1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UC2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UE	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UE1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UE2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UF	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UF1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UF2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UG	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UG1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UG2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UG3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UK	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UK1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UK2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UL	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UL1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UL2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UM	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UM1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UM2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UO	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UO1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UO2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UR	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UR1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU1	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU2	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU3	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU4	\N	t	\N	\N	\N
FAO GfSD 2006	geologyProperty	lithologyValueCode-UU5	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-L	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-LD	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-LL	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-LP	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-LV	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-SE	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-SH	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-SM	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-SP	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-SV	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-T	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-TE	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-TH	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-TM	\N	t	\N	\N	\N
FAO GfSD 2006	MajorLandFormProperty	majorLandFormValueCode-TV	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-BOdl	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-BOf	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-CR	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-HI	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-IN	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-LO	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-LS	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-MS	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-TS	\N	t	\N	\N	\N
FAO GfSD 2006	PhysiographyProperty	physiographyValueCode-UP	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-A	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-C	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-D	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-F	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-N	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsCoverProperty	rockOutcropsCoverValueCode-V	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsDistanceProperty	rockOutcropsDistanceValueCode-1	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsDistanceProperty	rockOutcropsDistanceValueCode-2	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsDistanceProperty	rockOutcropsDistanceValueCode-3	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsDistanceProperty	rockOutcropsDistanceValueCode-4	\N	t	\N	\N	\N
FAO GfSD 2006	rockOutcropsDistanceProperty	rockOutcropsDistanceValueCode-5	\N	t	\N	\N	\N
FAO GfSD 2006	slopeFormProperty	slopeFormValueCode-C	\N	t	\N	\N	\N
FAO GfSD 2006	slopeFormProperty	slopeFormValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	slopeFormProperty	slopeFormValueCode-T	\N	t	\N	\N	\N
FAO GfSD 2006	slopeFormProperty	slopeFormValueCode-V	\N	t	\N	\N	\N
FAO GfSD 2006	slopeFormProperty	slopeFormValueCode-X	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-1	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-10	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-2	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-3	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-4	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-5	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-6	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-7	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-8	\N	t	\N	\N	\N
FAO GfSD 2006	slopeGradientClassProperty	slopeGradientClassValueCode-9	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-CC	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-CS	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-CV	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-SC	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-SS	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-SV	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-VC	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-VS	\N	t	\N	\N	\N
FAO GfSD 2006	slopePathwaysProperty	slopePathwaysValueCode-VV	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-Ha	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-Hn	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-O	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-T	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-Ya	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-Yn	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-lPf	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-lPi	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-lPp	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-oPf	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-oPi	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-oPp	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-vYa	\N	t	\N	\N	\N
FAO GfSD 2006	surfaceAgeProperty	surfaceAgeValueCode-vYn	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-B	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-D	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-DD	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-DE	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-DS	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-DT	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-DX	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-F	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-FC	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-FD	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-FE	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-FS	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-FX	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-H	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-HF	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-HM	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-HS	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-HT	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-M	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-SD	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-SE	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-SS	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-SX	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-W	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-WD	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-WE	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-WS	\N	t	\N	\N	\N
FAO GfSD 2006	VegetationClassProperty	vegetationClassValueCode-WX	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-OV	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-PC	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-RA	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-SL	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-SN	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-SU	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC1	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC2	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC3	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC4	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC5	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsCurrentProperty	weatherConditionsValueCode-WC6	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-OV	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-PC	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-RA	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-SL	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-SN	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-SU	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC1	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC2	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC3	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC4	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC5	\N	t	\N	\N	\N
FAO GfSD 2006	weatherConditionsPastProperty	weatherConditionsValueCode-WC6	\N	t	\N	\N	\N
FAO GfSD 2006	weatheringRockProperty	weatheringValueCode-F	\N	t	\N	\N	\N
FAO GfSD 2006	weatheringRockProperty	weatheringValueCode-S	\N	t	\N	\N	\N
FAO GfSD 2006	weatheringRockProperty	weatheringValueCode-W	\N	t	\N	\N	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-3.1	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-5	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-4.1	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-4	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-2.1	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-2	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-1.1	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-3	\N	\N	\N	t	\N
FAO GfSD 2006	profileDescriptionStatusProperty	profileDescriptionStatusValueCode-1	\N	\N	\N	t	\N
FAO GfSD 2006	bleachedSandProperty	bleachedSandValueCode-4	\N	\N	t	\N	t
FAO GfSD 2006	cracksWidthProperty	cracksWidthValueCode-V	\N	\N	t	\N	t
FAO GfSD 2006	rockShapeProperty	rockShapeValueCode-R	\N	\N	t	\N	t
FAO GfSD 2006	biologicalAbundanceProperty	biologicalAbundanceValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalAbundanceProperty	biologicalAbundanceValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalAbundanceProperty	biologicalAbundanceValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalAbundanceProperty	biologicalAbundanceValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-B	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-BI	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-BO	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-E	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	biologicalFeaturesProperty	biologicalFeaturesValueCode-T	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryDistinctnessProperty	boundaryDistinctnessValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryDistinctnessProperty	boundaryDistinctnessValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryDistinctnessProperty	boundaryDistinctnessValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryDistinctnessProperty	boundaryDistinctnessValueCode-G	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryTopographyProperty	boundaryTopographyValueCode-B	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryTopographyProperty	boundaryTopographyValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryTopographyProperty	boundaryTopographyValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	boundaryTopographyProperty	boundaryTopographyValueCode-W	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityMineralProperty	bulkDensityMineralValueCode-BD1	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityMineralProperty	bulkDensityMineralValueCode-BD2	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityMineralProperty	bulkDensityMineralValueCode-BD3	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityMineralProperty	bulkDensityMineralValueCode-BD4	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityMineralProperty	bulkDensityMineralValueCode-BD5	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityPeatProperty	bulkDensityPeatValueCode-BD1	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityPeatProperty	bulkDensityPeatValueCode-BD2	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityPeatProperty	bulkDensityPeatValueCode-BD3	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityPeatProperty	bulkDensityPeatValueCode-BD4	\N	\N	\N	\N	t
FAO GfSD 2006	bulkDensityPeatProperty	bulkDensityPeatValueCode-BD5	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesContentProperty	carbonatesContentValueCode-EX	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesContentProperty	carbonatesContentValueCode-MO	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesContentProperty	carbonatesContentValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesContentProperty	carbonatesContentValueCode-SL	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesContentProperty	carbonatesContentValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-HC	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-HHC	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-HL	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-PM	\N	\N	\N	\N	t
FAO GfSD 2006	carbonatesFormsProperty	carbonatesFormsValueCode-SC	\N	\N	\N	\N	t
FAO GfSD 2006	cementationContinuityProperty	cementationContinuityValueCode-B	\N	\N	\N	\N	t
FAO GfSD 2006	cementationContinuityProperty	cementationContinuityValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	cementationContinuityProperty	cementationContinuityValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-W	\N	\N	\N	\N	t
FAO GfSD 2006	cementationDegreeProperty	cementationDegreeValueCode-Y	\N	\N	\N	\N	t
FAO GfSD 2006	cementationFabricProperty	cementationFabricValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	cementationFabricProperty	cementationFabricValueCode-Pi	\N	\N	\N	\N	t
FAO GfSD 2006	cementationFabricProperty	cementationFabricValueCode-Pl	\N	\N	\N	\N	t
FAO GfSD 2006	cementationFabricProperty	cementationFabricValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-CS	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-FM	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-FO	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-GY	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-K	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-KQ	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-NK	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	cementationNatureProperty	cementationNatureValueCode-Q	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	coatingAbundanceProperty	coatingAbundanceValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	coatingContrastProperty	coatingContrastValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	coatingContrastProperty	coatingContrastValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	coatingContrastProperty	coatingContrastValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-CI	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-DC	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-DE	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-DI	\N	\N	\N	\N	t
FAO GfSD 2006	coatingFormProperty	coatingFormValueCode-O	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-BR	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-CF	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-LA	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-NS	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-PH	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-PV	\N	\N	\N	\N	t
FAO GfSD 2006	coatingLocationProperty	coatingLocationValueCode-VO	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-CC	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-CH	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-CS	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-GB	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-H	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-HC	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-JA	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-MN	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-PF	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SA	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SF	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SI	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SL	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SN	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-SP	\N	\N	\N	\N	t
FAO GfSD 2006	coatingNatureProperty	coatingNatureValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-EHA	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-HA	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-HVH	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-LO	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-SHA	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-SHH	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-SO	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-SSH	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceDryProperty	consistenceDryValueCode-VHA	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-EFI	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-FI	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-FR	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-LO	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-VFI	\N	\N	\N	\N	t
FAO GfSD 2006	consistenceMoistProperty	consistenceMoistValueCode-VFR	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumContentProperty	gypsumContentValueCode-EX	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumContentProperty	gypsumContentValueCode-MO	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumContentProperty	gypsumContentValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumContentProperty	gypsumContentValueCode-SL	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumContentProperty	gypsumContentValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumFormsProperty	gypsumFormsValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumFormsProperty	gypsumFormsValueCode-G	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumFormsProperty	gypsumFormsValueCode-HL	\N	\N	\N	\N	t
FAO GfSD 2006	gypsumFormsProperty	gypsumFormsValueCode-SC	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-BB	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-BL	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-BR	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-BS	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-BU	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-GE	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-GR	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-GS	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-MC	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-RB	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-RE	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-RS	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-RY	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-WH	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-YB	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-YE	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcColourProperty	mineralConcColourValueCode-YR	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcHardnessProperty	mineralConcHardnessValueCode-B	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcHardnessProperty	mineralConcHardnessValueCode-H	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcHardnessProperty	mineralConcHardnessValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-IC	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-IP	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-O	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-R	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-SC	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcKindProperty	mineralConcKindValueCode-T	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-CS	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-FM	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-GB	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-GY	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-JA	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-K	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-KQ	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-NK	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-Q	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcNatureProperty	mineralConcNatureValueCode-SA	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcShapeProperty	mineralConcShapeValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcShapeProperty	mineralConcShapeValueCode-E	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcShapeProperty	mineralConcShapeValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcShapeProperty	mineralConcShapeValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcShapeProperty	mineralConcShapeValueCode-R	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcSizeeProperty	mineralConcSizeValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcSizeeProperty	mineralConcSizeValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcSizeeProperty	mineralConcSizeValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcSizeeProperty	mineralConcSizeValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	mineralConcVolumeProperty	mineralConcVolumeValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	mineralFragmentsProperty	mineralFragmentsValueCode-FE	\N	\N	\N	\N	t
FAO GfSD 2006	mineralFragmentsProperty	mineralFragmentsValueCode-MI	\N	\N	\N	\N	t
FAO GfSD 2006	mineralFragmentsProperty	mineralFragmentsValueCode-QU	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesAbundanceProperty	mottlesAbundanceValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesBoundaryClassificationProperty	boundaryClassificationValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesBoundaryClassificationProperty	boundaryClassificationValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesBoundaryClassificationProperty	boundaryClassificationValueCode-S	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesContrastProperty	contrastValueCode-D	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesContrastProperty	contrastValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesContrastProperty	contrastValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesSizeProperty	mottlesSizeValueCode-A	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesSizeProperty	mottlesSizeValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesSizeProperty	mottlesSizeValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	mottlesSizeProperty	mottlesSizeValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D1	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D2	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D3	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D4	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D5.1	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-D5.2	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-Fibric	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-Hemic	\N	\N	\N	\N	t
FAO GfSD 2006	peatDecompostionProperty	peatDecompostionValueCode-Sapric	\N	\N	\N	\N	t
FAO GfSD 2006	peatDrainageProperty	peatDrainageValueCode-DC1	\N	\N	\N	\N	t
FAO GfSD 2006	peatDrainageProperty	peatDrainageValueCode-DC2	\N	\N	\N	\N	t
FAO GfSD 2006	peatDrainageProperty	peatDrainageValueCode-DC3	\N	\N	\N	\N	t
FAO GfSD 2006	peatDrainageProperty	peatDrainageValueCode-DC4	\N	\N	\N	\N	t
FAO GfSD 2006	peatVolumeProperty	peatVolumeValueCode-SV1	\N	\N	\N	\N	t
FAO GfSD 2006	peatVolumeProperty	peatVolumeValueCode-SV2	\N	\N	\N	\N	t
FAO GfSD 2006	peatVolumeProperty	peatVolumeValueCode-SV3	\N	\N	\N	\N	t
FAO GfSD 2006	peatVolumeProperty	peatVolumeValueCode-SV4	\N	\N	\N	\N	t
FAO GfSD 2006	peatVolumeProperty	peatVolumeValueCode-SV5	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-NPL	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-PL	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-PVP	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-SPL	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-SPP	\N	\N	\N	\N	t
FAO GfSD 2006	plasticityProperty	plasticityValueCode-VPL	\N	\N	\N	\N	t
FAO GfSD 2006	poresAbundanceProperty	poresAbundanceValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	poresAbundanceProperty	poresAbundanceValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	poresAbundanceProperty	poresAbundanceValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	poresAbundanceProperty	poresAbundanceValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	poresAbundanceProperty	poresAbundanceValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	porosityClassProperty	porosityClassValueCode-1	\N	\N	\N	\N	t
FAO GfSD 2006	porosityClassProperty	porosityClassValueCode-2	\N	\N	\N	\N	t
FAO GfSD 2006	porosityClassProperty	porosityClassValueCode-3	\N	\N	\N	\N	t
FAO GfSD 2006	porosityClassProperty	porosityClassValueCode-4	\N	\N	\N	\N	t
FAO GfSD 2006	porosityClassProperty	porosityClassValueCode-5	\N	\N	\N	\N	t
FAO GfSD 2006	rootsAbundanceProperty	rootsAbundanceValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	rootsAbundanceProperty	rootsAbundanceValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	rootsAbundanceProperty	rootsAbundanceValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	rootsAbundanceProperty	rootsAbundanceValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	rootsAbundanceProperty	rootsAbundanceValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-EX	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-MO	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-N	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-SL	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	saltContentProperty	saltContentValueCode-VST	\N	\N	\N	\N	t
FAO GfSD 2006	weatheringFragmentsProperty	weatheringValueCode-F	\N	t	t	\N	t
FAO GfSD 2006	weatheringFragmentsProperty	weatheringValueCode-S	\N	t	t	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-FF	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-FM	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-MC	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	poresSizeProperty	voidsDiameterValueCode-VC	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-CS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-CSL	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-FS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-FSL	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-LCS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-LFS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-LVFS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-MS	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-US	\N	\N	\N	\N	t
FAO GfSD 2006	sandyTextureProperty	sandyTextureValueCode-VFS	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-NST	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-SSS	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-SST	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-SVS	\N	\N	\N	\N	t
FAO GfSD 2006	stickinessProperty	stickinessValueCode-VST	\N	\N	\N	\N	t
FAO GfSD 2006	structureGradeProperty	structureGradeValueCode-MO	\N	\N	\N	\N	t
FAO GfSD 2006	structureGradeProperty	structureGradeValueCode-MS	\N	\N	\N	\N	t
FAO GfSD 2006	structureGradeProperty	structureGradeValueCode-ST	\N	\N	\N	\N	t
FAO GfSD 2006	structureGradeProperty	structureGradeValueCode-WE	\N	\N	\N	\N	t
FAO GfSD 2006	structureGradeProperty	structureGradeValueCode-WM	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-CO	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-EC	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-FI	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-ME	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-VC	\N	\N	\N	\N	t
FAO GfSD 2006	structureSizeProperty	structureSizeValueCode-VF	\N	\N	\N	\N	t
FAO GfSD 2006	VoidsClassificationProperty	voidsClassificationValueCode-B	\N	\N	\N	\N	t
FAO GfSD 2006	VoidsClassificationProperty	voidsClassificationValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	VoidsClassificationProperty	voidsClassificationValueCode-I	\N	\N	\N	\N	t
FAO GfSD 2006	VoidsClassificationProperty	voidsClassificationValueCode-P	\N	\N	\N	\N	t
FAO GfSD 2006	VoidsClassificationProperty	voidsClassificationValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-C	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-F	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-FF	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-FM	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-M	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-MC	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-V	\N	\N	\N	\N	t
FAO GfSD 2006	voidsDiameterProperty	voidsDiameterValueCode-VC	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FGF1	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FGF2	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FGF3	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FGF4	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FGT	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FV1	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FV2	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FV3	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FVE	\N	\N	\N	\N	t
ISRIC Report 2019/01	fragmentsClassProperty	fragmentsClassValueCode-FVT	\N	\N	\N	\N	t
\.


--
-- TOC entry 5229 (class 0 OID 55548792)
-- Dependencies: 234
-- Data for Name: observation_num; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.observation_num (observation_num_id, property_num_id, procedure_num_id, unit_of_measure_id, value_min, value_max) FROM stdin;
1048	BASCAL	BSAT_CALCUL-CEC	%	\N	\N
1049	BASCAL	BSAT_CALCUL-ECEC	%	\N	\N
1050	BOREXT	EXTR_AP14	%	\N	\N
1051	BOREXT	EXTR_AP15	%	\N	\N
1052	BOREXT	EXTR_AP20	%	\N	\N
1053	BOREXT	EXTR_AP21	%	\N	\N
1054	BOREXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1055	BOREXT	EXTR_CACL2	%	\N	\N
1056	BOREXT	EXTR_CAPO4	%	\N	\N
1057	BOREXT	EXTR_DTPA	%	\N	\N
1058	BOREXT	EXTR_EDTA	%	\N	\N
1008	ACIEXC	EXCHACID_PH0-KCL1M	cmol/kg	\N	\N
1009	ACIEXC	EXCHACID_PH0-NH4CL	cmol/kg	\N	\N
1010	ACIEXC	EXCHACID_PH0-UNKN	cmol/kg	\N	\N
1011	ACIEXC	EXCHACID_PH7-CAOAC	cmol/kg	\N	\N
1012	ACIEXC	EXCHACID_PH7-UNKN	cmol/kg	\N	\N
1013	ACIEXC	EXCHACID_PH8-BACL2TEA	cmol/kg	\N	\N
1014	ACIEXC	EXCHACID_PH8-UNKN	cmol/kg	\N	\N
1015	ALUEXC	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1016	ALUEXC	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1017	ALUEXC	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1018	ALUEXC	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1019	ALUEXC	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1020	ALUEXC	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1021	ALUEXC	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1022	ALUEXC	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1023	ALUEXC	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1024	ALUEXC	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1025	ALUEXC	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1094	BULDFINE	BLKDENSF_FE-CL-FC	kg/dm³	\N	\N
1095	BULDFINE	BLKDENSF_FE-CL-OD	kg/dm³	\N	\N
1096	BULDFINE	BLKDENSF_FE-CL-UNKN	kg/dm³	\N	\N
1097	BULDFINE	BLKDENSF_FE-CO-FC	kg/dm³	\N	\N
1098	BULDFINE	BLKDENSF_FE-CO-OD	kg/dm³	\N	\N
1099	BULDFINE	BLKDENSF_FE-CO-UNKN	kg/dm³	\N	\N
1100	BULDFINE	BLKDENSF_FE-RPL-UNKN	kg/dm³	\N	\N
1101	BULDFINE	BLKDENSF_FE-UNKN	kg/dm³	\N	\N
1102	BULDFINE	BLKDENSF_FE-UNKN-FC	kg/dm³	\N	\N
1103	BULDFINE	BLKDENSF_FE-UNKN-OD	kg/dm³	\N	\N
1045	AVAVOL	PAWHC_CALCUL-FC100WP	m³/100 m³	\N	\N
1046	AVAVOL	PAWHC_CALCUL-FC200WP	m³/100 m³	\N	\N
1047	AVAVOL	PAWHC_CALCUL-FC300WP	m³/100 m³	\N	\N
1026	ALUTOT	TOTAL_H2SO4	mg/kg	\N	\N
1027	ALUTOT	TOTAL_HCL	mg/kg	\N	\N
1028	ALUTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1029	ALUTOT	TOTAL_HCLO4	mg/kg	\N	\N
1030	ALUTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1031	ALUTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1032	ALUTOT	TOTAL_TP03	mg/kg	\N	\N
1033	ALUTOT	TOTAL_TP04	mg/kg	\N	\N
1034	ALUTOT	TOTAL_TP05	mg/kg	\N	\N
1035	ALUTOT	TOTAL_TP06	mg/kg	\N	\N
1036	ALUTOT	TOTAL_TP07	mg/kg	\N	\N
1037	ALUTOT	TOTAL_TP08	mg/kg	\N	\N
1038	ALUTOT	TOTAL_TP09	mg/kg	\N	\N
1039	ALUTOT	TOTAL_TP10	mg/kg	\N	\N
1040	ALUTOT	TOTAL_UNKN	mg/kg	\N	\N
1041	ALUTOT	TOTAL_XRD	mg/kg	\N	\N
1042	ALUTOT	TOTAL_XRF	mg/kg	\N	\N
1043	ALUTOT	TOTAL_XRF-P	mg/kg	\N	\N
1156	CALEXC	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1157	CALEXC	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1158	CALEXC	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1159	CALEXC	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1160	CALEXC	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1161	CALEXC	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1162	CALEXC	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1163	CALEXC	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1164	CALEXC	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1165	CALEXC	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1166	CALEXC	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1211	CEC	CEC_PH-UNKN-CACL2	cmol/kg	\N	\N
1212	CEC	CEC_PH-UNKN-LIOAC	cmol/kg	\N	\N
1213	CEC	CEC_PH-UNKN-M3	cmol/kg	\N	\N
1214	CEC	CEC_PH0-AG-THIOURA	cmol/kg	\N	\N
1215	CEC	CEC_PH0-BACL2	cmol/kg	\N	\N
1216	CEC	CEC_PH0-COHEX	cmol/kg	\N	\N
1217	CEC	CEC_PH0-KCL	cmol/kg	\N	\N
1218	CEC	CEC_PH0-NH4CL	cmol/kg	\N	\N
1219	CEC	CEC_PH0-NH4OAC	cmol/kg	\N	\N
1220	CEC	CEC_PH0-UNKN	cmol/kg	\N	\N
1221	CEC	CEC_PH7-EDTA	cmol/kg	\N	\N
1222	CEC	CEC_PH7-NH4OAC	cmol/kg	\N	\N
1223	CEC	CEC_PH7-UNKN	cmol/kg	\N	\N
1224	CEC	CEC_PH8-BACL2TEA	cmol/kg	\N	\N
1225	CEC	CEC_PH8-BAOAC	cmol/kg	\N	\N
1226	CEC	CEC_PH8-LICL2TEA	cmol/kg	\N	\N
1227	CEC	CEC_PH8-NAOAC	cmol/kg	\N	\N
1228	CEC	CEC_PH8-NH4OAC	cmol/kg	\N	\N
1229	CEC	CEC_PH8-UNKN	cmol/kg	\N	\N
1137	CAD	TOTAL_H2SO4	mg/kg	\N	\N
1138	CAD	TOTAL_HCL	mg/kg	\N	\N
1139	CAD	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1140	CAD	TOTAL_HCLO4	mg/kg	\N	\N
1141	CAD	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1142	CAD	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1143	CAD	TOTAL_TP03	mg/kg	\N	\N
1144	CAD	TOTAL_TP04	mg/kg	\N	\N
1145	CAD	TOTAL_TP05	mg/kg	\N	\N
1146	CAD	TOTAL_TP06	mg/kg	\N	\N
1147	CAD	TOTAL_TP07	mg/kg	\N	\N
1148	CAD	TOTAL_TP08	mg/kg	\N	\N
1149	CAD	TOTAL_TP09	mg/kg	\N	\N
1150	CAD	TOTAL_TP10	mg/kg	\N	\N
1231	COAFRA	CRSFRG_FLDCLS	%	\N	\N
1277	ECEC	EFFCEC_CALCUL-B	cmol/kg	\N	\N
1278	ECEC	EFFCEC_CALCUL-BA	cmol/kg	\N	\N
1285	HYDEXC	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1286	HYDEXC	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1287	HYDEXC	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1288	HYDEXC	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1289	HYDEXC	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1290	HYDEXC	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1291	HYDEXC	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1292	HYDEXC	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1293	HYDEXC	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1294	HYDEXC	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1295	HYDEXC	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1340	MAGEXC	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1341	MAGEXC	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1342	MAGEXC	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1343	MAGEXC	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1279	ELECCOND	EC_RATIO1-1	dS/m	\N	\N
1280	ELECCOND	EC_RATIO1-10	dS/m	\N	\N
1281	ELECCOND	EC_RATIO1-2	dS/m	\N	\N
1282	ELECCOND	EC_RATIO1-2.5	dS/m	\N	\N
1283	ELECCOND	EC_RATIO1-5	dS/m	\N	\N
1284	ELECCOND	ECE_SAT	dS/m	\N	\N
1258	COPTOT	TOTAL_H2SO4	mg/kg	\N	\N
1259	COPTOT	TOTAL_HCL	mg/kg	\N	\N
1260	COPTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1261	COPTOT	TOTAL_HCLO4	mg/kg	\N	\N
1262	COPTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1263	COPTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1264	COPTOT	TOTAL_TP03	mg/kg	\N	\N
1265	COPTOT	TOTAL_TP04	mg/kg	\N	\N
1266	COPTOT	TOTAL_TP05	mg/kg	\N	\N
1267	COPTOT	TOTAL_TP06	mg/kg	\N	\N
1268	COPTOT	TOTAL_TP07	mg/kg	\N	\N
1269	COPTOT	TOTAL_TP08	mg/kg	\N	\N
1270	COPTOT	TOTAL_TP09	mg/kg	\N	\N
1271	COPTOT	TOTAL_TP10	mg/kg	\N	\N
1272	COPTOT	TOTAL_UNKN	mg/kg	\N	\N
1273	COPTOT	TOTAL_XRD	mg/kg	\N	\N
1274	COPTOT	TOTAL_XRF	mg/kg	\N	\N
1275	COPTOT	TOTAL_XRF-P	mg/kg	\N	\N
1276	COPTOT	TOTAL_XTF-T	mg/kg	\N	\N
1321	IROTOT	TOTAL_H2SO4	mg/kg	\N	\N
1322	IROTOT	TOTAL_HCL	mg/kg	\N	\N
1323	IROTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1324	IROTOT	TOTAL_HCLO4	mg/kg	\N	\N
1325	IROTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1326	IROTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1327	IROTOT	TOTAL_TP03	mg/kg	\N	\N
1344	MAGEXC	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1345	MAGEXC	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1346	MAGEXC	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1347	MAGEXC	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1348	MAGEXC	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1349	MAGEXC	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1350	MAGEXC	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1395	MANTOT	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1396	MANTOT	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1397	MANTOT	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1398	MANTOT	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1399	MANTOT	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1400	MANTOT	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1401	MANTOT	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1402	MANTOT	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1403	MANTOT	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1404	MANTOT	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1405	MANTOT	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1376	MAGTOT	TOTAL_H2SO4	mg/kg	\N	\N
1377	MAGTOT	TOTAL_HCL	mg/kg	\N	\N
1378	MAGTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1379	MAGTOT	TOTAL_HCLO4	mg/kg	\N	\N
1380	MAGTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1381	MAGTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1382	MAGTOT	TOTAL_TP03	mg/kg	\N	\N
1383	MAGTOT	TOTAL_TP04	mg/kg	\N	\N
1384	MAGTOT	TOTAL_TP05	mg/kg	\N	\N
1385	MAGTOT	TOTAL_TP06	mg/kg	\N	\N
1386	MAGTOT	TOTAL_TP07	mg/kg	\N	\N
1387	MAGTOT	TOTAL_TP08	mg/kg	\N	\N
1388	MAGTOT	TOTAL_TP09	mg/kg	\N	\N
1389	MAGTOT	TOTAL_TP10	mg/kg	\N	\N
1390	MAGTOT	TOTAL_UNKN	mg/kg	\N	\N
1391	MAGTOT	TOTAL_XRD	mg/kg	\N	\N
1392	MAGTOT	TOTAL_XRF	mg/kg	\N	\N
1393	MAGTOT	TOTAL_XRF-P	mg/kg	\N	\N
1394	MAGTOT	TOTAL_XTF-T	mg/kg	\N	\N
1431	MANTOT	TOTAL_H2SO4	mg/kg	\N	\N
1432	MANTOT	TOTAL_HCL	mg/kg	\N	\N
1433	MANTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1434	MANTOT	TOTAL_HCLO4	mg/kg	\N	\N
1435	MANTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1436	MANTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1437	MANTOT	TOTAL_TP03	mg/kg	\N	\N
1438	MANTOT	TOTAL_TP04	mg/kg	\N	\N
1439	MANTOT	TOTAL_TP05	mg/kg	\N	\N
1440	MANTOT	TOTAL_TP06	mg/kg	\N	\N
1441	MANTOT	TOTAL_TP07	mg/kg	\N	\N
1442	MANTOT	TOTAL_TP08	mg/kg	\N	\N
1443	MANTOT	TOTAL_TP09	mg/kg	\N	\N
1444	MANTOT	TOTAL_TP10	mg/kg	\N	\N
1445	MANTOT	TOTAL_UNKN	mg/kg	\N	\N
1446	MANTOT	TOTAL_XRD	mg/kg	\N	\N
1447	MANTOT	TOTAL_XRF	mg/kg	\N	\N
1538	POTEXC	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1539	POTEXC	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1540	POTEXC	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1541	POTEXC	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1542	POTEXC	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1543	POTEXC	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1544	POTEXC	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1545	POTEXC	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1546	POTEXC	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1547	POTEXC	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1548	POTEXC	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1475	MOL	TOTAL_H2SO4	mg/kg	\N	\N
1476	MOL	TOTAL_HCL	mg/kg	\N	\N
1477	MOL	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1478	MOL	TOTAL_HCLO4	mg/kg	\N	\N
1479	MOL	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1480	MOL	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1481	MOL	TOTAL_TP03	mg/kg	\N	\N
1482	MOL	TOTAL_TP04	mg/kg	\N	\N
1483	MOL	TOTAL_TP05	mg/kg	\N	\N
1484	MOL	TOTAL_TP06	mg/kg	\N	\N
1485	MOL	TOTAL_TP07	mg/kg	\N	\N
1486	MOL	TOTAL_TP08	mg/kg	\N	\N
1487	MOL	TOTAL_TP09	mg/kg	\N	\N
1488	MOL	TOTAL_TP10	mg/kg	\N	\N
1489	MOL	TOTAL_UNKN	mg/kg	\N	\N
1490	MOL	TOTAL_XRD	mg/kg	\N	\N
1491	MOL	TOTAL_XRF	mg/kg	\N	\N
1492	MOL	TOTAL_XRF-P	mg/kg	\N	\N
1493	MOL	TOTAL_XTF-T	mg/kg	\N	\N
1519	PHOTOT	TOTAL_H2SO4	mg/kg	\N	\N
1520	PHOTOT	TOTAL_HCL	mg/kg	\N	\N
1521	PHOTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1522	PHOTOT	TOTAL_HCLO4	mg/kg	\N	\N
1523	PHOTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1524	PHOTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1525	PHOTOT	TOTAL_TP03	mg/kg	\N	\N
1526	PHOTOT	TOTAL_TP04	mg/kg	\N	\N
1527	PHOTOT	TOTAL_TP05	mg/kg	\N	\N
1528	PHOTOT	TOTAL_TP06	mg/kg	\N	\N
1529	PHOTOT	TOTAL_TP07	mg/kg	\N	\N
1530	PHOTOT	TOTAL_TP08	mg/kg	\N	\N
1531	PHOTOT	TOTAL_TP09	mg/kg	\N	\N
1532	PHOTOT	TOTAL_TP10	mg/kg	\N	\N
1533	PHOTOT	TOTAL_UNKN	mg/kg	\N	\N
1534	PHOTOT	TOTAL_XRD	mg/kg	\N	\N
1535	PHOTOT	TOTAL_XRF	mg/kg	\N	\N
1536	PHOTOT	TOTAL_XRF-P	mg/kg	\N	\N
1537	PHOTOT	TOTAL_XTF-T	mg/kg	\N	\N
1574	POTTOT	TOTAL_H2SO4	mg/kg	\N	\N
1593	SODEXP	EXCHBASES_PH-UNKN-EDTA	cmol/kg	\N	\N
1594	SODEXP	EXCHBASES_PH-UNKN-M3	cmol/kg	\N	\N
1595	SODEXP	EXCHBASES_PH-UNKN-M3-SPEC	cmol/kg	\N	\N
1596	SODEXP	EXCHBASES_PH0-COHEX	cmol/kg	\N	\N
1597	SODEXP	EXCHBASES_PH0-NH4CL	cmol/kg	\N	\N
1598	SODEXP	EXCHBASES_PH7-NH4OAC	cmol/kg	\N	\N
1599	SODEXP	EXCHBASES_PH7-NH4OAC-AAS	cmol/kg	\N	\N
1600	SODEXP	EXCHBASES_PH7-NH4OAC-FP	cmol/kg	\N	\N
1601	SODEXP	EXCHBASES_PH7-UNKN	cmol/kg	\N	\N
1602	SODEXP	EXCHBASES_PH8-BACL2TEA	cmol/kg	\N	\N
1603	SODEXP	EXCHBASES_PH8-UNKN	cmol/kg	\N	\N
1575	POTTOT	TOTAL_HCL	mg/kg	\N	\N
1576	POTTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1577	POTTOT	TOTAL_HCLO4	mg/kg	\N	\N
1578	POTTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1579	POTTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1580	POTTOT	TOTAL_TP03	mg/kg	\N	\N
1581	POTTOT	TOTAL_TP04	mg/kg	\N	\N
1582	POTTOT	TOTAL_TP05	mg/kg	\N	\N
1583	POTTOT	TOTAL_TP06	mg/kg	\N	\N
1584	POTTOT	TOTAL_TP07	mg/kg	\N	\N
1585	POTTOT	TOTAL_TP08	mg/kg	\N	\N
1586	POTTOT	TOTAL_TP09	mg/kg	\N	\N
1587	POTTOT	TOTAL_TP10	mg/kg	\N	\N
1588	POTTOT	TOTAL_UNKN	mg/kg	\N	\N
1589	POTTOT	TOTAL_XRD	mg/kg	\N	\N
1590	POTTOT	TOTAL_XRF	mg/kg	\N	\N
1591	POTTOT	TOTAL_XRF-P	mg/kg	\N	\N
1592	POTTOT	TOTAL_XTF-T	mg/kg	\N	\N
1629	SODTOT	TOTAL_H2SO4	mg/kg	\N	\N
1630	SODTOT	TOTAL_HCL	mg/kg	\N	\N
1631	SODTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1632	SODTOT	TOTAL_HCLO4	mg/kg	\N	\N
1633	SODTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1634	SODTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1635	SODTOT	TOTAL_TP03	mg/kg	\N	\N
1636	SODTOT	TOTAL_TP04	mg/kg	\N	\N
1637	SODTOT	TOTAL_TP05	mg/kg	\N	\N
1638	SODTOT	TOTAL_TP06	mg/kg	\N	\N
1639	SODTOT	TOTAL_TP07	mg/kg	\N	\N
1640	SODTOT	TOTAL_TP08	mg/kg	\N	\N
1641	SODTOT	TOTAL_TP09	mg/kg	\N	\N
1642	SODTOT	TOTAL_TP10	mg/kg	\N	\N
1643	SODTOT	TOTAL_UNKN	mg/kg	\N	\N
1644	SODTOT	TOTAL_XRD	mg/kg	\N	\N
1645	SODTOT	TOTAL_XRF	mg/kg	\N	\N
1646	SODTOT	TOTAL_XRF-P	mg/kg	\N	\N
1647	SODTOT	TOTAL_XTF-T	mg/kg	\N	\N
1692	ZINEXT	EXTR_AP14	%	\N	\N
1693	ZINEXT	EXTR_AP15	%	\N	\N
1694	ZINEXT	EXTR_AP20	%	\N	\N
1695	ZINEXT	EXTR_AP21	%	\N	\N
1696	ZINEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1697	ZINEXT	EXTR_CACL2	%	\N	\N
1698	ZINEXT	EXTR_CAPO4	%	\N	\N
1699	ZINEXT	EXTR_DTPA	%	\N	\N
1700	ZINEXT	EXTR_EDTA	%	\N	\N
1717	CARINORG	INORGC_CALCUL-CACO3	g/kg	\N	\N
1718	CARINORG	INORGC_CALCUL-TC-OC	g/kg	\N	\N
1719	CARORG	ORGC_ACID-DC	g/kg	\N	\N
1720	CARORG	ORGC_ACID-DC-HT	g/kg	\N	\N
1721	CARORG	ORGC_ACID-DC-HT-ANALYSER	g/kg	\N	\N
1722	CARORG	ORGC_ACID-DC-LT	g/kg	\N	\N
1723	CARORG	ORGC_ACID-DC-LT-LOI	g/kg	\N	\N
1724	CARORG	ORGC_ACID-DC-MT	g/kg	\N	\N
1725	CARORG	ORGC_ACID-DC-SPEC	g/kg	\N	\N
1726	CARORG	ORGC_CALCUL-TC-IC	g/kg	\N	\N
1727	CARORG	ORGC_DC	g/kg	\N	\N
1728	CARORG	ORGC_DC-HT	g/kg	\N	\N
1729	CARORG	ORGC_DC-HT-ANALYSER	g/kg	\N	\N
1730	CARORG	ORGC_DC-LT	g/kg	\N	\N
1731	CARORG	ORGC_DC-LT-LOI	g/kg	\N	\N
1732	CARORG	ORGC_DC-MT	g/kg	\N	\N
1733	CARORG	ORGC_DC-SPEC	g/kg	\N	\N
1734	CARORG	ORGC_WC	g/kg	\N	\N
1735	CARORG	ORGC_WC-CRO3-JACKSON	g/kg	\N	\N
1736	CARORG	ORGC_WC-CRO3-KALEMBRA	g/kg	\N	\N
1737	CARORG	ORGC_WC-CRO3-KNOPP	g/kg	\N	\N
1738	CARORG	ORGC_WC-CRO3-KURMIES	g/kg	\N	\N
1739	CARORG	ORGC_WC-CRO3-NELSON	g/kg	\N	\N
1740	CARORG	ORGC_WC-CRO3-NRCS6A1C	g/kg	\N	\N
1741	CARORG	ORGC_WC-CRO3-TIURIN	g/kg	\N	\N
1742	CARORG	ORGC_WC-CRO3-WALKLEYBLACK	g/kg	\N	\N
1743	CARTOT	TOTC_CALCUL-IC-OC	g/kg	\N	\N
1744	CARTOT	TOTC_DC-HT	g/kg	\N	\N
1745	CARTOT	TOTC_DC-HT-ANALYSER	g/kg	\N	\N
1746	CARTOT	TOTC_DC-HT-SPEC	g/kg	\N	\N
1780	PH	PHCACL2	pH	\N	\N
1781	PH	PHCACL2_RATIO1-1	pH	\N	\N
1782	PH	PHCACL2_RATIO1-10	pH	\N	\N
1783	PH	PHCACL2_RATIO1-2	pH	\N	\N
1784	PH	PHCACL2_RATIO1-2.5	pH	\N	\N
1785	PH	PHCACL2_RATIO1-5	pH	\N	\N
1786	PH	PHCACL2_SAT	pH	\N	\N
1787	PH	PHH2O	pH	\N	\N
1788	PH	PHH2O_RATIO1-1	pH	\N	\N
1789	PH	PHH2O_RATIO1-10	pH	\N	\N
1790	PH	PHH2O_RATIO1-2	pH	\N	\N
1791	PH	PHH2O_RATIO1-2.5	pH	\N	\N
1792	PH	PHH2O_RATIO1-5	pH	\N	\N
1793	PH	PHH2O_SAT	pH	\N	\N
1794	PH	PHH2O_UNKN-SPEC	pH	\N	\N
1795	PH	PHKCL	pH	\N	\N
1796	PH	PHKCL_RATIO1-1	pH	\N	\N
1797	PH	PHKCL_RATIO1-10	pH	\N	\N
1798	PH	PHKCL_RATIO1-2	pH	\N	\N
1799	PH	PHKCL_RATIO1-2.5	pH	\N	\N
1800	PH	PHKCL_RATIO1-5	pH	\N	\N
1801	PH	PHKCL_SAT	pH	\N	\N
1802	PH	PHNAF	pH	\N	\N
1803	PH	PHNAF_RATIO1-1	pH	\N	\N
1804	PH	PHNAF_RATIO1-10	pH	\N	\N
1805	PH	PHNAF_RATIO1-2	pH	\N	\N
1806	PH	PHNAF_RATIO1-2.5	pH	\N	\N
1807	PH	PHNAF_RATIO1-5	pH	\N	\N
1808	PH	PHNAF_SAT	pH	\N	\N
1688	SULTOT	TOTAL_XRD	mg/kg	\N	\N
1689	SULTOT	TOTAL_XRF	mg/kg	\N	\N
1690	SULTOT	TOTAL_XRF-P	mg/kg	\N	\N
1691	SULTOT	TOTAL_XTF-T	mg/kg	\N	\N
1809	PHORET	RETENTP_BLAKEMORE	g/hg	\N	\N
1814	CCETOT	CACO3_ACID-CH3COOH-DC	g/kg	\N	\N
1815	CCETOT	CACO3_ACID-CH3COOH-NODC	g/kg	\N	\N
1816	CCETOT	CACO3_ACID-CH3COOH-UNKN	g/kg	\N	\N
1817	CCETOT	CACO3_ACID-DC	g/kg	\N	\N
1818	CCETOT	CACO3_ACID-H2SO4-DC	g/kg	\N	\N
1819	CCETOT	CACO3_ACID-H2SO4-NODC	g/kg	\N	\N
1820	CCETOT	CACO3_ACID-H2SO4-UNKN	g/kg	\N	\N
1821	CCETOT	CACO3_ACID-H3PO4-DC	g/kg	\N	\N
1822	CCETOT	CACO3_ACID-H3PO4-NODC	g/kg	\N	\N
1823	CCETOT	CACO3_ACID-H3PO4-UNKN	g/kg	\N	\N
1824	CCETOT	CACO3_ACID-HCL-DC	g/kg	\N	\N
1825	CCETOT	CACO3_ACID-HCL-NODC	g/kg	\N	\N
1826	CCETOT	CACO3_ACID-HCL-UNKN	g/kg	\N	\N
1827	CCETOT	CACO3_ACID-NODC	g/kg	\N	\N
1828	CCETOT	CACO3_ACID-UNKN	g/kg	\N	\N
1829	CCETOT	CACO3_CA01	g/kg	\N	\N
1830	CCETOT	CACO3_CA02	g/kg	\N	\N
1831	CCETOT	CACO3_CA03	g/kg	\N	\N
1832	CCETOT	CACO3_CA04	g/kg	\N	\N
1833	CCETOT	CACO3_CA05	g/kg	\N	\N
1834	CCETOT	CACO3_CA06	g/kg	\N	\N
1835	CCETOT	CACO3_CA07	g/kg	\N	\N
1836	CCETOT	CACO3_CA08	g/kg	\N	\N
1837	CCETOT	CACO3_CA09	g/kg	\N	\N
1838	CCETOT	CACO3_CA10	g/kg	\N	\N
1839	CCETOT	CACO3_CA11	g/kg	\N	\N
1840	CCETOT	CACO3_CA12	g/kg	\N	\N
1841	CCETOT	CACO3_CALCUL-TC-OC	g/kg	\N	\N
1811	POR	POROS_CALCUL-PF0	m³/100 m³	\N	\N
1842	ZIN	TOTAL_H2SO4	mg/kg	\N	\N
1843	ZIN	TOTAL_HCL	mg/kg	\N	\N
1844	ZIN	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1845	ZIN	TOTAL_HCLO4	mg/kg	\N	\N
1846	ZIN	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1847	ZIN	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1848	ZIN	TOTAL_TP03	mg/kg	\N	\N
1849	ZIN	TOTAL_TP04	mg/kg	\N	\N
1850	ZIN	TOTAL_TP05	mg/kg	\N	\N
1851	ZIN	TOTAL_TP06	mg/kg	\N	\N
1852	ZIN	TOTAL_TP07	mg/kg	\N	\N
1853	ZIN	TOTAL_TP08	mg/kg	\N	\N
1854	ZIN	TOTAL_TP09	mg/kg	\N	\N
1855	ZIN	TOTAL_TP10	mg/kg	\N	\N
1856	ZIN	TOTAL_UNKN	mg/kg	\N	\N
1857	ZIN	TOTAL_XRD	mg/kg	\N	\N
1858	ZIN	TOTAL_XRF	mg/kg	\N	\N
1859	ZIN	TOTAL_XRF-P	mg/kg	\N	\N
1860	ZIN	TOTAL_XTF-T	mg/kg	\N	\N
1812	SOLSAL	SLBAN_CALCUL-UNKN	cmol/L	\N	\N
1813	SOLSAL	SLBCAT_CALCUL-UNKN	cmol/L	\N	\N
1810	PHORET	RETENTP_UNKN-SPEC	g/hg	\N	\N
1755	HYDCOND	KSAT_CALCUL-PTF	cm/h	\N	\N
1756	HYDCOND	KSAT_CALCUL-PTF-GENUCHTEN	cm/h	\N	\N
1757	HYDCOND	KSAT_CALCUL-PTF-SAXTON	cm/h	\N	\N
1758	HYDCOND	KSAT_BHOLE	cm/h	\N	\N
1759	HYDCOND	KSAT_COLUMN	cm/h	\N	\N
1760	HYDCOND	KSAT_DBLRING	cm/h	\N	\N
1761	HYDCOND	KSAT_INVBHOLE	cm/h	\N	\N
1059	BOREXT	EXTR_H2SO4-TRUOG	%	\N	\N
1060	BOREXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1061	BOREXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1062	BOREXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1063	BOREXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1064	BOREXT	EXTR_HNO3	%	\N	\N
1065	BOREXT	EXTR_HOTWATER	%	\N	\N
1066	BOREXT	EXTR_M1	%	\N	\N
1067	BOREXT	EXTR_M2	%	\N	\N
1068	BOREXT	EXTR_M3	%	\N	\N
1069	BOREXT	EXTR_M3-SPEC	%	\N	\N
1070	BOREXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1071	BOREXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1072	BOREXT	EXTR_NAOAC-MORGAN	%	\N	\N
1073	BOREXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1074	BOREXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1112	CAD	EXTR_AP14	%	\N	\N
1113	CAD	EXTR_AP15	%	\N	\N
1114	CAD	EXTR_AP20	%	\N	\N
1115	CAD	EXTR_AP21	%	\N	\N
1116	CAD	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1117	CAD	EXTR_CACL2	%	\N	\N
1118	CAD	EXTR_CAPO4	%	\N	\N
1119	CAD	EXTR_DTPA	%	\N	\N
1120	CAD	EXTR_EDTA	%	\N	\N
1121	CAD	EXTR_H2SO4-TRUOG	%	\N	\N
1122	CAD	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1123	CAD	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1124	CAD	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1125	CAD	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1126	CAD	EXTR_HNO3	%	\N	\N
1127	CAD	EXTR_HOTWATER	%	\N	\N
1128	CAD	EXTR_M1	%	\N	\N
1129	CAD	EXTR_M2	%	\N	\N
1130	CAD	EXTR_M3	%	\N	\N
1131	CAD	EXTR_M3-SPEC	%	\N	\N
1132	CAD	EXTR_NAHCO3-OLSEN	%	\N	\N
1133	CAD	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1134	CAD	EXTR_NAOAC-MORGAN	%	\N	\N
1135	CAD	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1136	CAD	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1167	CALEXT	EXTR_AP14	%	\N	\N
1168	CALEXT	EXTR_AP15	%	\N	\N
1169	CALEXT	EXTR_AP20	%	\N	\N
1170	CALEXT	EXTR_AP21	%	\N	\N
1171	CALEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1172	CALEXT	EXTR_CACL2	%	\N	\N
1173	CALEXT	EXTR_CAPO4	%	\N	\N
1174	CALEXT	EXTR_DTPA	%	\N	\N
1175	CALEXT	EXTR_EDTA	%	\N	\N
1176	CALEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1177	CALEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1178	CALEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1179	CALEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1180	CALEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1181	CALEXT	EXTR_HNO3	%	\N	\N
1182	CALEXT	EXTR_HOTWATER	%	\N	\N
1183	CALEXT	EXTR_M1	%	\N	\N
1184	CALEXT	EXTR_M2	%	\N	\N
1185	CALEXT	EXTR_M3	%	\N	\N
1186	CALEXT	EXTR_M3-SPEC	%	\N	\N
1187	CALEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1188	CALEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1189	CALEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1190	CALEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1191	CALEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1230	COAFRA	CRSFRG_FLD	%	\N	\N
1232	COAFRA	CRSFRG_LAB	%	\N	\N
1233	COPEXT	EXTR_AP14	%	\N	\N
1234	COPEXT	EXTR_AP15	%	\N	\N
1235	COPEXT	EXTR_AP20	%	\N	\N
1236	COPEXT	EXTR_AP21	%	\N	\N
1237	COPEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1238	COPEXT	EXTR_CACL2	%	\N	\N
1239	COPEXT	EXTR_CAPO4	%	\N	\N
1240	COPEXT	EXTR_DTPA	%	\N	\N
1241	COPEXT	EXTR_EDTA	%	\N	\N
1242	COPEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1243	COPEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1244	COPEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1245	COPEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1246	COPEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1247	COPEXT	EXTR_HNO3	%	\N	\N
1248	COPEXT	EXTR_HOTWATER	%	\N	\N
1249	COPEXT	EXTR_M1	%	\N	\N
1250	COPEXT	EXTR_M2	%	\N	\N
1251	COPEXT	EXTR_M3	%	\N	\N
1252	COPEXT	EXTR_M3-SPEC	%	\N	\N
1253	COPEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1254	COPEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1255	COPEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1256	COPEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1257	COPEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1296	IROEXT	EXTR_AP14	%	\N	\N
1297	IROEXT	EXTR_AP15	%	\N	\N
1298	IROEXT	EXTR_AP20	%	\N	\N
1299	IROEXT	EXTR_AP21	%	\N	\N
1300	IROEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1301	IROEXT	EXTR_CACL2	%	\N	\N
1302	IROEXT	EXTR_CAPO4	%	\N	\N
1303	IROEXT	EXTR_DTPA	%	\N	\N
1304	IROEXT	EXTR_EDTA	%	\N	\N
1305	IROEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1306	IROEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1307	IROEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1308	IROEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1309	IROEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1104	BULDWHOLE	BLKDENSW_WE-CL-FC	kg/dm³	\N	\N
1105	BULDWHOLE	BLKDENSW_WE-CL-OD	kg/dm³	\N	\N
1106	BULDWHOLE	BLKDENSW_WE-CL-UNKN	kg/dm³	\N	\N
1107	BULDWHOLE	BLKDENSW_WE-CO-FC	kg/dm³	\N	\N
1108	BULDWHOLE	BLKDENSW_WE-CO-OD	kg/dm³	\N	\N
1109	BULDWHOLE	BLKDENSW_WE-CO-UNKN	kg/dm³	\N	\N
1110	BULDWHOLE	BLKDENSW_WE-RPL-UNKN	kg/dm³	\N	\N
1111	BULDWHOLE	BLKDENSW_WE-UNKN	kg/dm³	\N	\N
1310	IROEXT	EXTR_HNO3	%	\N	\N
1311	IROEXT	EXTR_HOTWATER	%	\N	\N
1312	IROEXT	EXTR_M1	%	\N	\N
1313	IROEXT	EXTR_M2	%	\N	\N
1314	IROEXT	EXTR_M3	%	\N	\N
1315	IROEXT	EXTR_M3-SPEC	%	\N	\N
1316	IROEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1317	IROEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1318	IROEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1319	IROEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1320	IROEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1351	MAGEXT	EXTR_AP14	%	\N	\N
1352	MAGEXT	EXTR_AP15	%	\N	\N
1353	MAGEXT	EXTR_AP20	%	\N	\N
1354	MAGEXT	EXTR_AP21	%	\N	\N
1355	MAGEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1356	MAGEXT	EXTR_CACL2	%	\N	\N
1357	MAGEXT	EXTR_CAPO4	%	\N	\N
1358	MAGEXT	EXTR_DTPA	%	\N	\N
1359	MAGEXT	EXTR_EDTA	%	\N	\N
1360	MAGEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1361	MAGEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1362	MAGEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1363	MAGEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1364	MAGEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1365	MAGEXT	EXTR_HNO3	%	\N	\N
1366	MAGEXT	EXTR_HOTWATER	%	\N	\N
1367	MAGEXT	EXTR_M1	%	\N	\N
1368	MAGEXT	EXTR_M2	%	\N	\N
1369	MAGEXT	EXTR_M3	%	\N	\N
1370	MAGEXT	EXTR_M3-SPEC	%	\N	\N
1371	MAGEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1372	MAGEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1373	MAGEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1374	MAGEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1375	MAGEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1406	MANEXT	EXTR_AP14	%	\N	\N
1407	MANEXT	EXTR_AP15	%	\N	\N
1408	MANEXT	EXTR_AP20	%	\N	\N
1409	MANEXT	EXTR_AP21	%	\N	\N
1410	MANEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1411	MANEXT	EXTR_CACL2	%	\N	\N
1412	MANEXT	EXTR_CAPO4	%	\N	\N
1413	MANEXT	EXTR_DTPA	%	\N	\N
1414	MANEXT	EXTR_EDTA	%	\N	\N
1415	MANEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1416	MANEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1417	MANEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1418	MANEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1419	MANEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1420	MANEXT	EXTR_HNO3	%	\N	\N
1421	MANEXT	EXTR_HOTWATER	%	\N	\N
1422	MANEXT	EXTR_M1	%	\N	\N
1423	MANEXT	EXTR_M2	%	\N	\N
1424	MANEXT	EXTR_M3	%	\N	\N
1425	MANEXT	EXTR_M3-SPEC	%	\N	\N
1426	MANEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1427	MANEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1428	MANEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1429	MANEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1430	MANEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1450	MOL	EXTR_AP14	%	\N	\N
1451	MOL	EXTR_AP15	%	\N	\N
1452	MOL	EXTR_AP20	%	\N	\N
1453	MOL	EXTR_AP21	%	\N	\N
1454	MOL	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1455	MOL	EXTR_CACL2	%	\N	\N
1456	MOL	EXTR_CAPO4	%	\N	\N
1457	MOL	EXTR_DTPA	%	\N	\N
1458	MOL	EXTR_EDTA	%	\N	\N
1459	MOL	EXTR_H2SO4-TRUOG	%	\N	\N
1460	MOL	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1461	MOL	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1462	MOL	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1463	MOL	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1464	MOL	EXTR_HNO3	%	\N	\N
1465	MOL	EXTR_HOTWATER	%	\N	\N
1466	MOL	EXTR_M1	%	\N	\N
1467	MOL	EXTR_M2	%	\N	\N
1468	MOL	EXTR_M3	%	\N	\N
1469	MOL	EXTR_M3-SPEC	%	\N	\N
1470	MOL	EXTR_NAHCO3-OLSEN	%	\N	\N
1471	MOL	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1472	MOL	EXTR_NAOAC-MORGAN	%	\N	\N
1473	MOL	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1474	MOL	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1494	PHOEXT	EXTR_AP14	%	\N	\N
1495	PHOEXT	EXTR_AP15	%	\N	\N
1496	PHOEXT	EXTR_AP20	%	\N	\N
1497	PHOEXT	EXTR_AP21	%	\N	\N
1498	PHOEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1499	PHOEXT	EXTR_CACL2	%	\N	\N
1500	PHOEXT	EXTR_CAPO4	%	\N	\N
1501	PHOEXT	EXTR_DTPA	%	\N	\N
1502	PHOEXT	EXTR_EDTA	%	\N	\N
1503	PHOEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1504	PHOEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1505	PHOEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1506	PHOEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1507	PHOEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1508	PHOEXT	EXTR_HNO3	%	\N	\N
1509	PHOEXT	EXTR_HOTWATER	%	\N	\N
1510	PHOEXT	EXTR_M1	%	\N	\N
1511	PHOEXT	EXTR_M2	%	\N	\N
1512	PHOEXT	EXTR_M3	%	\N	\N
1513	PHOEXT	EXTR_M3-SPEC	%	\N	\N
1514	PHOEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1515	PHOEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1516	PHOEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1517	PHOEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1518	PHOEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1549	POTEXT	EXTR_AP14	%	\N	\N
1550	POTEXT	EXTR_AP15	%	\N	\N
1551	POTEXT	EXTR_AP20	%	\N	\N
1552	POTEXT	EXTR_AP21	%	\N	\N
1553	POTEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1554	POTEXT	EXTR_CACL2	%	\N	\N
1555	POTEXT	EXTR_CAPO4	%	\N	\N
1556	POTEXT	EXTR_DTPA	%	\N	\N
1557	POTEXT	EXTR_EDTA	%	\N	\N
1558	POTEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1559	POTEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1560	POTEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1561	POTEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1562	POTEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1563	POTEXT	EXTR_HNO3	%	\N	\N
1564	POTEXT	EXTR_HOTWATER	%	\N	\N
1565	POTEXT	EXTR_M1	%	\N	\N
1566	POTEXT	EXTR_M2	%	\N	\N
1567	POTEXT	EXTR_M3	%	\N	\N
1568	POTEXT	EXTR_M3-SPEC	%	\N	\N
1569	POTEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1570	POTEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1571	POTEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1572	POTEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1573	POTEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1604	SODEXT	EXTR_AP14	%	\N	\N
1605	SODEXT	EXTR_AP15	%	\N	\N
1606	SODEXT	EXTR_AP20	%	\N	\N
1607	SODEXT	EXTR_AP21	%	\N	\N
1608	SODEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1609	SODEXT	EXTR_CACL2	%	\N	\N
1610	SODEXT	EXTR_CAPO4	%	\N	\N
1611	SODEXT	EXTR_DTPA	%	\N	\N
1612	SODEXT	EXTR_EDTA	%	\N	\N
1613	SODEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1614	SODEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1615	SODEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1616	SODEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1617	SODEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1618	SODEXT	EXTR_HNO3	%	\N	\N
1619	SODEXT	EXTR_HOTWATER	%	\N	\N
1620	SODEXT	EXTR_M1	%	\N	\N
1621	SODEXT	EXTR_M2	%	\N	\N
1622	SODEXT	EXTR_M3	%	\N	\N
1623	SODEXT	EXTR_M3-SPEC	%	\N	\N
1624	SODEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1625	SODEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1626	SODEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1627	SODEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1628	SODEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1648	SULEXT	EXTR_AP14	%	\N	\N
1649	SULEXT	EXTR_AP15	%	\N	\N
1650	SULEXT	EXTR_AP20	%	\N	\N
1651	SULEXT	EXTR_AP21	%	\N	\N
1652	SULEXT	EXTR_C6H8O7-REEUWIJK	%	\N	\N
1653	SULEXT	EXTR_CACL2	%	\N	\N
1654	SULEXT	EXTR_CAPO4	%	\N	\N
1655	SULEXT	EXTR_DTPA	%	\N	\N
1656	SULEXT	EXTR_EDTA	%	\N	\N
1657	SULEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1658	SULEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1659	SULEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1660	SULEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1661	SULEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1662	SULEXT	EXTR_HNO3	%	\N	\N
1663	SULEXT	EXTR_HOTWATER	%	\N	\N
1664	SULEXT	EXTR_M1	%	\N	\N
1665	SULEXT	EXTR_M2	%	\N	\N
1666	SULEXT	EXTR_M3	%	\N	\N
1667	SULEXT	EXTR_M3-SPEC	%	\N	\N
1668	SULEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1669	SULEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1670	SULEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1671	SULEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1672	SULEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1701	ZINEXT	EXTR_H2SO4-TRUOG	%	\N	\N
1702	ZINEXT	EXTR_HCL-H2SO4-NELSON	%	\N	\N
1703	ZINEXT	EXTR_HCL-NH4F-BRAY1	%	\N	\N
1704	ZINEXT	EXTR_HCL-NH4F-BRAY2	%	\N	\N
1705	ZINEXT	EXTR_HCL-NH4F-KURTZ-BRAY	%	\N	\N
1706	ZINEXT	EXTR_HNO3	%	\N	\N
1707	ZINEXT	EXTR_HOTWATER	%	\N	\N
1708	ZINEXT	EXTR_M1	%	\N	\N
1709	ZINEXT	EXTR_M2	%	\N	\N
1710	ZINEXT	EXTR_M3	%	\N	\N
1711	ZINEXT	EXTR_M3-SPEC	%	\N	\N
1712	ZINEXT	EXTR_NAHCO3-OLSEN	%	\N	\N
1713	ZINEXT	EXTR_NAHCO3-OLSEN-DABIN	%	\N	\N
1714	ZINEXT	EXTR_NAOAC-MORGAN	%	\N	\N
1715	ZINEXT	EXTR_NH4-CO3-2-AMBIC1	%	\N	\N
1716	ZINEXT	EXTR_NH4CH3CH-OH-COOH-LEUVEN	%	\N	\N
1748	GYP	CASO4_GY01	%	\N	\N
1749	GYP	CASO4_GY02	%	\N	\N
1750	GYP	CASO4_GY03	%	\N	\N
1751	GYP	CASO4_GY04	%	\N	\N
1752	GYP	CASO4_GY05	%	\N	\N
1753	GYP	CASO4_GY06	%	\N	\N
1754	GYP	CASO4_GY07	%	\N	\N
1861	TEXTCLAY	BEAKER-DISP	%	\N	\N
1862	TEXTSAND	BEAKER-DISP	%	\N	\N
1863	TEXTSILT	BEAKER-DISP	%	\N	\N
1864	TEXTCLAY	BEAKER-DISP-SPEC	%	\N	\N
1865	TEXTSAND	BEAKER-DISP-SPEC	%	\N	\N
1866	TEXTSILT	BEAKER-DISP-SPEC	%	\N	\N
1867	TEXTCLAY	BEAKER-NODISP	%	\N	\N
1868	TEXTSAND	BEAKER-NODISP	%	\N	\N
1869	TEXTSILT	BEAKER-NODISP	%	\N	\N
1870	TEXTCLAY	BEAKER-NODISP-SPEC	%	\N	\N
1871	TEXTSAND	BEAKER-NODISP-SPEC	%	\N	\N
1872	TEXTSILT	BEAKER-NODISP-SPEC	%	\N	\N
1873	TEXTCLAY	BEAKER-UNKDISP	%	\N	\N
1874	TEXTSAND	BEAKER-UNKDISP	%	\N	\N
1875	TEXTSILT	BEAKER-UNKDISP	%	\N	\N
1876	TEXTCLAY	BEAKER-UNKDISP-SPEC	%	\N	\N
1877	TEXTSAND	BEAKER-UNKDISP-SPEC	%	\N	\N
1878	TEXTSILT	BEAKER-UNKDISP-SPEC	%	\N	\N
1879	TEXTCLAY	FLDEST	%	\N	\N
1880	TEXTSAND	FLDEST	%	\N	\N
1881	TEXTSILT	FLDEST	%	\N	\N
1882	TEXTCLAY	HYDROMETER-DISP	%	\N	\N
1883	TEXTSAND	HYDROMETER-DISP	%	\N	\N
1884	TEXTSILT	HYDROMETER-DISP	%	\N	\N
1885	TEXTCLAY	HYDROMETER-DISP-SPEC	%	\N	\N
1886	TEXTSAND	HYDROMETER-DISP-SPEC	%	\N	\N
1887	TEXTSILT	HYDROMETER-DISP-SPEC	%	\N	\N
1888	TEXTCLAY	HYDROMETER-NODISP	%	\N	\N
1889	TEXTSAND	HYDROMETER-NODISP	%	\N	\N
1890	TEXTSILT	HYDROMETER-NODISP	%	\N	\N
1891	TEXTCLAY	HYDROMETER-NODISP-SPEC	%	\N	\N
1892	TEXTSAND	HYDROMETER-NODISP-SPEC	%	\N	\N
1893	TEXTSILT	HYDROMETER-NODISP-SPEC	%	\N	\N
1894	TEXTCLAY	HYDROMETER-UNKDISP	%	\N	\N
1895	TEXTSAND	HYDROMETER-UNKDISP	%	\N	\N
1896	TEXTSILT	HYDROMETER-UNKDISP	%	\N	\N
1897	TEXTCLAY	HYDROMETER-UNKDISP-SPEC	%	\N	\N
1898	TEXTSAND	HYDROMETER-UNKDISP-SPEC	%	\N	\N
1899	TEXTSILT	HYDROMETER-UNKDISP-SPEC	%	\N	\N
1900	TEXTCLAY	LASER-DISP	%	\N	\N
1901	TEXTSAND	LASER-DISP	%	\N	\N
1902	TEXTSILT	LASER-DISP	%	\N	\N
1903	TEXTCLAY	LASER-DISP-SPEC	%	\N	\N
1904	TEXTSAND	LASER-DISP-SPEC	%	\N	\N
1905	TEXTSILT	LASER-DISP-SPEC	%	\N	\N
1906	TEXTCLAY	LASER-NODISP	%	\N	\N
1907	TEXTSAND	LASER-NODISP	%	\N	\N
1908	TEXTSILT	LASER-NODISP	%	\N	\N
1909	TEXTCLAY	LASER-NODISP-SPEC	%	\N	\N
1910	TEXTSAND	LASER-NODISP-SPEC	%	\N	\N
1911	TEXTSILT	LASER-NODISP-SPEC	%	\N	\N
1912	TEXTCLAY	LASER-UNKDISP	%	\N	\N
1913	TEXTSAND	LASER-UNKDISP	%	\N	\N
1914	TEXTSILT	LASER-UNKDISP	%	\N	\N
1915	TEXTCLAY	LASER-UNKDISP-SPEC	%	\N	\N
1916	TEXTSAND	LASER-UNKDISP-SPEC	%	\N	\N
1917	TEXTSILT	LASER-UNKDISP-SPEC	%	\N	\N
1918	TEXTCLAY	PIPETTE-DISP	%	\N	\N
1919	TEXTSAND	PIPETTE-DISP	%	\N	\N
1920	TEXTSILT	PIPETTE-DISP	%	\N	\N
1921	TEXTCLAY	PIPETTE-DISP-SPEC	%	\N	\N
1922	TEXTSAND	PIPETTE-DISP-SPEC	%	\N	\N
1923	TEXTSILT	PIPETTE-DISP-SPEC	%	\N	\N
1924	TEXTCLAY	PIPETTE-NODISP	%	\N	\N
1925	TEXTSAND	PIPETTE-NODISP	%	\N	\N
1926	TEXTSILT	PIPETTE-NODISP	%	\N	\N
1927	TEXTCLAY	PIPETTE-NODISP-SPEC	%	\N	\N
1928	TEXTSAND	PIPETTE-NODISP-SPEC	%	\N	\N
1929	TEXTSILT	PIPETTE-NODISP-SPEC	%	\N	\N
1930	TEXTCLAY	PIPETTE-UNKDISP	%	\N	\N
1931	TEXTSAND	PIPETTE-UNKDISP	%	\N	\N
1932	TEXTSILT	PIPETTE-UNKDISP	%	\N	\N
1933	TEXTCLAY	PIPETTE-UNKDISP-SPEC	%	\N	\N
1934	TEXTSAND	PIPETTE-UNKDISP-SPEC	%	\N	\N
1935	TEXTSILT	PIPETTE-UNKDISP-SPEC	%	\N	\N
1747	CARTOT	TOTC_DC-MT	g/kg	\N	\N
1762	NITTOT	TOTALN_BREMNER	g/kg	\N	\N
1763	NITTOT	TOTALN_CALCUL	g/kg	\N	\N
1764	NITTOT	TOTALN_CALCUL-OC10	g/kg	\N	\N
1765	NITTOT	TOTALN_DC	g/kg	\N	\N
1766	NITTOT	TOTALN_DC-HT-DUMAS	g/kg	\N	\N
1767	NITTOT	TOTALN_DC-HT-LECO	g/kg	\N	\N
1768	NITTOT	TOTALN_DC-SPEC	g/kg	\N	\N
1769	NITTOT	TOTALN_H2SO4	g/kg	\N	\N
1770	NITTOT	TOTALN_KJELDAHL	g/kg	\N	\N
1771	NITTOT	TOTALN_KJELDAHL-NH4	g/kg	\N	\N
1772	NITTOT	TOTALN_NELSON	g/kg	\N	\N
1773	NITTOT	TOTALN_TN04	g/kg	\N	\N
1774	NITTOT	TOTALN_TN06	g/kg	\N	\N
1775	NITTOT	TOTALN_TN08	g/kg	\N	\N
1776	ORGMAT	FULACIDC_UNKN	g/kg	\N	\N
1777	ORGMAT	HUMACIDC_UNKN	g/kg	\N	\N
1778	ORGMAT	ORGM_CALCUL-OC1.73	g/kg	\N	\N
1779	ORGMAT	TOTHUMC_UNKN	g/kg	\N	\N
1044	ALUTOT	TOTAL_XTF-T	mg/kg	\N	\N
1075	BORTOT	TOTAL_H2SO4	mg/kg	\N	\N
1076	BORTOT	TOTAL_HCL	mg/kg	\N	\N
1077	BORTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1078	BORTOT	TOTAL_HCLO4	mg/kg	\N	\N
1079	BORTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1080	BORTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1081	BORTOT	TOTAL_TP03	mg/kg	\N	\N
1082	BORTOT	TOTAL_TP04	mg/kg	\N	\N
1083	BORTOT	TOTAL_TP05	mg/kg	\N	\N
1084	BORTOT	TOTAL_TP06	mg/kg	\N	\N
1085	BORTOT	TOTAL_TP07	mg/kg	\N	\N
1086	BORTOT	TOTAL_TP08	mg/kg	\N	\N
1087	BORTOT	TOTAL_TP09	mg/kg	\N	\N
1088	BORTOT	TOTAL_TP10	mg/kg	\N	\N
1089	BORTOT	TOTAL_UNKN	mg/kg	\N	\N
1090	BORTOT	TOTAL_XRD	mg/kg	\N	\N
1091	BORTOT	TOTAL_XRF	mg/kg	\N	\N
1092	BORTOT	TOTAL_XRF-P	mg/kg	\N	\N
1093	BORTOT	TOTAL_XTF-T	mg/kg	\N	\N
1151	CAD	TOTAL_UNKN	mg/kg	\N	\N
1152	CAD	TOTAL_XRD	mg/kg	\N	\N
1153	CAD	TOTAL_XRF	mg/kg	\N	\N
1154	CAD	TOTAL_XRF-P	mg/kg	\N	\N
1155	CAD	TOTAL_XTF-T	mg/kg	\N	\N
1192	CALTOT	TOTAL_H2SO4	mg/kg	\N	\N
1193	CALTOT	TOTAL_HCL	mg/kg	\N	\N
1194	CALTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1195	CALTOT	TOTAL_HCLO4	mg/kg	\N	\N
1196	CALTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1197	CALTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1198	CALTOT	TOTAL_TP03	mg/kg	\N	\N
1199	CALTOT	TOTAL_TP04	mg/kg	\N	\N
1200	CALTOT	TOTAL_TP05	mg/kg	\N	\N
1201	CALTOT	TOTAL_TP06	mg/kg	\N	\N
1202	CALTOT	TOTAL_TP07	mg/kg	\N	\N
1203	CALTOT	TOTAL_TP08	mg/kg	\N	\N
1204	CALTOT	TOTAL_TP09	mg/kg	\N	\N
1205	CALTOT	TOTAL_TP10	mg/kg	\N	\N
1206	CALTOT	TOTAL_UNKN	mg/kg	\N	\N
1207	CALTOT	TOTAL_XRD	mg/kg	\N	\N
1208	CALTOT	TOTAL_XRF	mg/kg	\N	\N
1209	CALTOT	TOTAL_XRF-P	mg/kg	\N	\N
1210	CALTOT	TOTAL_XTF-T	mg/kg	\N	\N
1328	IROTOT	TOTAL_TP04	mg/kg	\N	\N
1329	IROTOT	TOTAL_TP05	mg/kg	\N	\N
1330	IROTOT	TOTAL_TP06	mg/kg	\N	\N
1331	IROTOT	TOTAL_TP07	mg/kg	\N	\N
1332	IROTOT	TOTAL_TP08	mg/kg	\N	\N
1333	IROTOT	TOTAL_TP09	mg/kg	\N	\N
1334	IROTOT	TOTAL_TP10	mg/kg	\N	\N
1335	IROTOT	TOTAL_UNKN	mg/kg	\N	\N
1336	IROTOT	TOTAL_XRD	mg/kg	\N	\N
1337	IROTOT	TOTAL_XRF	mg/kg	\N	\N
1338	IROTOT	TOTAL_XRF-P	mg/kg	\N	\N
1339	IROTOT	TOTAL_XTF-T	mg/kg	\N	\N
1448	MANTOT	TOTAL_XRF-P	mg/kg	\N	\N
1449	MANTOT	TOTAL_XTF-T	mg/kg	\N	\N
1673	SULTOT	TOTAL_H2SO4	mg/kg	\N	\N
1674	SULTOT	TOTAL_HCL	mg/kg	\N	\N
1675	SULTOT	TOTAL_HCL-AQUAREGIA	mg/kg	\N	\N
1676	SULTOT	TOTAL_HCLO4	mg/kg	\N	\N
1677	SULTOT	TOTAL_HNO3-AQUAFORTIS	mg/kg	\N	\N
1678	SULTOT	TOTAL_NH4-6MO7O24	mg/kg	\N	\N
1679	SULTOT	TOTAL_TP03	mg/kg	\N	\N
1680	SULTOT	TOTAL_TP04	mg/kg	\N	\N
1681	SULTOT	TOTAL_TP05	mg/kg	\N	\N
1682	SULTOT	TOTAL_TP06	mg/kg	\N	\N
1683	SULTOT	TOTAL_TP07	mg/kg	\N	\N
1684	SULTOT	TOTAL_TP08	mg/kg	\N	\N
1685	SULTOT	TOTAL_TP09	mg/kg	\N	\N
1686	SULTOT	TOTAL_TP10	mg/kg	\N	\N
1687	SULTOT	TOTAL_UNKN	mg/kg	\N	\N
\.


--
-- TOC entry 5243 (class 0 OID 55548881)
-- Dependencies: 251
-- Data for Name: organisation; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.organisation (organisation_id, url, email, country, city, postal_code, delivery_point, phone, facsimile) FROM stdin;
\.


--
-- TOC entry 5230 (class 0 OID 55548798)
-- Dependencies: 235
-- Data for Name: plot; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.plot (plot_id, site_id, parent_plot_id, type, altitude, sampling_date, positional_accuracy, geom, is_surface) FROM stdin;
\.


--
-- TOC entry 5245 (class 0 OID 55548889)
-- Dependencies: 253
-- Data for Name: procedure_desc; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.procedure_desc (procedure_desc_id, reference, uri) FROM stdin;
FAO GfSD 2006	Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 2006.	https://www.fao.org/publications/card/en/c/903943c7-f56a-521a-8d32-459e7e0cdae9/
FAO GfSD 1990	Food and Agriculture Organisation of the United Nations, Guidelines for Soil Description, Fourth Edition, 1990	FAO GfSD 1990
ISRIC Report 2019/01	ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System	https://www.isric.org/documents/document-type/isric-report-201901-tier-1-and-tier-2-data-context-federated-global-soil
Keys to Soil Taxonomy 13th edition 2022	Keys to Soil Taxonomy, 13th ed.2022	https://nrcspad.sc.egov.usda.gov/DistributionCenter/product.aspx?ProductID=1709
Köppen-Geiger Climate Classification	DOI: 10.1127/0941-2948/2006/0130	https://www.schweizerbart.de/papers/metz/detail/15/55034/World_Map_of_the_Koppen_Geiger_climate_classificat?af=crossref
Soil Survey Manual 2017	Soil Survey Manual 2017	https://www.nrcs.usda.gov/resources/guides-and-instructions/soil-survey-manual
WRB fourth edition 2022	WRB fourth edition 2022	https://www.fao.org/soils-portal/data-hub/soil-classification/world-reference-base/en/
\.


--
-- TOC entry 5246 (class 0 OID 55548895)
-- Dependencies: 254
-- Data for Name: procedure_model; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.procedure_model (procedure_model_id, procedure_name) FROM stdin;
\.


--
-- TOC entry 5247 (class 0 OID 55548901)
-- Dependencies: 255
-- Data for Name: procedure_model_def; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.procedure_model_def (procedure_model_id, key, value) FROM stdin;
\.


--
-- TOC entry 5249 (class 0 OID 55548909)
-- Dependencies: 257
-- Data for Name: procedure_num; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.procedure_num (procedure_num_id, broader_id, procedure_name, reference, citation, uri) FROM stdin;
TOTALN_DC-HT-DUMAS	\N	Dry combustion at 800-1000 C celcius (Dumas method)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_dc-ht-dumas
TOTALN_DC-HT-LECO	\N	Element analyzer (LECO analyzer), Dry Combustion	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_dc-ht-leco
TOTALN_DC-SPEC	\N	Spectrally measured and converted to N by dry combustion	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_dc-spec
PHCACL2_RATIO1-1	\N	pHCaCl2 (soil reaction) in 1:1 soil/1 M CaCl2 solution (1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_ratio1-1
PHCACL2_RATIO1-10	\N	pHCaCl2 (soil reaction) in 1:10 soil/CaCl2 solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_ratio1-10
PHCACL2_RATIO1-2	\N	pHCaCl2 (soil reaction) in 1:2 soil/CaCl2 solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_ratio1-2
PHCACL2_RATIO1-2.5	\N	pHCaCl2 (soil reaction) in 1:2.5 soil/CaCl2 solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_ratio1-2.5
PHCACL2_RATIO1-5	\N	pHCaCl2 (soil reaction) in 1:5 soil/CaCl2 solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_ratio1-5
PHCACL2_SAT	\N	pHCaCl2 (soil reaction) in saturated paste	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2_sat
PHH2O_RATIO1-1	\N	pHH2O (soil reaction) in 1:1 soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_ratio1-1
PHH2O_RATIO1-10	\N	pHH2O (soil reaction) in 1:10 soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_ratio1-10
PHH2O_RATIO1-2	\N	pHH2O (soil reaction) in 1:2 soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_ratio1-2
PHH2O_RATIO1-2.5	\N	pHH2O (soil reaction) in 1:2.5 soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_ratio1-2.5
PHH2O_RATIO1-5	\N	pHH2O (soil reaction) in 1:5 soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_ratio1-5
PHH2O_SAT	\N	pHH2O (soil reaction) in water saturated paste	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_sat
PHH2O_UNKN-SPEC	\N	Spectrally measured and converted to pHH2O (soil reaction) in unknown soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O_unkn-spec
PHKCL_RATIO1-1	\N	pHKCl (soil reaction) in 1:1 soil/KCl solution (1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_ratio1-1
PHKCL_RATIO1-10	\N	pHKCl (soil reaction) in 1:10 soil/KCl solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_ratio1-10
PHKCL_RATIO1-2	\N	pHKCl (soil reaction) in 1:2 soil/KCl solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_ratio1-2
PHKCL_RATIO1-2.5	\N	pHKCl (soil reaction) in 1:2.5 soil/KCl solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_ratio1-2.5
PHKCL_RATIO1-5	\N	pHKCl (soil reaction) in 1:5 soil/KCl solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_ratio1-5
PHNAF_RATIO1-1	\N	pHNaF (soil reaction) in 1:1 soil/NaF solution (1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_ratio1-1
PHNAF_RATIO1-10	\N	pHNaF (soil reaction) in 1:10 soil/NaF solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_ratio1-10
PHNAF_RATIO1-2	\N	pHNaF (soil reaction) in 1:2 soil/NaF solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_ratio1-2
PHNAF_RATIO1-2.5	\N	pHNaF (soil reaction) in 1:2.5 soil/NaF solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_ratio1-2.5
PHNAF_RATIO1-5	\N	pHNaF (soil reaction) in 1:5 soil/NaF solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_ratio1-5
PHNAF_SAT	\N	pHNaF (soil reaction) in saturated paste	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF_sat
EXCHACID_PH0-KCL1M	\N	Exch acidity (H+Al) unbuffered, in 1 M KCl extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph0-kcl1m
EXCHACID_PH0-NH4CL	\N	Exch acidity (H+Al) unbuffered, in 0.05-0.1 M NH4Cl extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph0-nh4cl
EXCHACID_PH0-UNKN	\N	Exch acidity (H+Al) unbuffered, in unknown extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph0-unkn
EXCHACID_PH7-CAOAC	\N	Exch acidity (H+Al) buffered at pH 7, in 1M Ca-acetate extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph7-caoac
EXCHACID_PH7-UNKN	\N	Exch acidity (H+Al) buffered at pH 7, in unknown extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph7-unkn
EXCHACID_PH8-BACL2TEA	\N	Exch (extractable / potential) acidity (Al) buffered at pH 8.0-8.5, in 1 M BaCl2 - TEA	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph8-bacl2tea
EXCHACID_PH8-UNKN	\N	Exch (extractable / potential) acidity (Al) buffered at pH 8.0-8.5, in unknown extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/acidityExchangeableProcedure-ExchAcid_ph8-unkn
PAWHC_CALCUL-FC100WP	\N	Plant available water holding capacity of the soil fine earth fraction, calculated with field capacity defined at 100 cm (pF 2.0)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/availableWaterHoldingCapacityProcedure-PAWHC_calcul-fc100wp
PAWHC_CALCUL-FC200WP	\N	Plant available water holding capacity of the soil fine earth fraction, calculated with field capacity defined at 200 cm (pF 2.3)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/availableWaterHoldingCapacityProcedure-PAWHC_calcul-fc200wp
PAWHC_CALCUL-FC300WP	\N	Plant available water holding capacity of the soil fine earth fraction, calculated with field capacity defined at 300 cm (pF 2.5)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/availableWaterHoldingCapacityProcedure-PAWHC_calcul-fc300wp
BSAT_CALCUL-CEC	\N	Sum of exchangeable bases (Ca++, Mg++, K+, Na+) as percentage of CEC (method specified with CEC and ExchBases)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/baseSaturationProcedure-BSat_calcul-cec
BSAT_CALCUL-ECEC	\N	Sum of exchangeable bases (Ca++, Mg++, K+, Na+) as percentage of EffCEC (method specified with EffCEC and ExchBases)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/baseSaturationProcedure-BSat_calcul-ecec
BLKDENSF_FE-CL-FC	\N	Fine earth. Clod samples (natural clods or reconstituted from < 2mm sample), at field capacity (0.33 bar, 33 kPa, 330 cm, pF 2.5), corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-cl-fc
BLKDENSF_FE-CL-OD	\N	Fine earth. Clod samples (natural clods or reconstituted from < 2mm sample), at oven dry, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-cl-od
BLKDENSF_FE-CL-UNKN	\N	Fine earth. Clod samples (natural clods or reconstituted from < 2mm sample), at unknown humidity, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-cl-unkn
BLKDENSF_FE-CO-FC	\N	Fine earth. Core sampling (pF rings), at field capacity (0.33 bar, 33 kPa, 336 cm, pF 2.5), corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-co-fc
BLKDENSF_FE-CO-OD	\N	Fine earth. Core sampling (pF rings), at oven dry, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-co-od
BLKDENSF_FE-CO-UNKN	\N	Fine earth. Core sampling (pF rings), at unknown humidity, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-co-unkn
BLKDENSF_FE-RPL-UNKN	\N	Fine earth. Excavation and replacement (i.e. soils too fragile to remove a stable sample) e.g. by auger, at unknown humidity, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-rpl-unkn
BLKDENSF_FE-UNKN	\N	Fine earth. Type of sample unknown, at unknown humidity, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-unkn
BLKDENSF_FE-UNKN-FC	\N	Fine earth. Type of sample unknown, at field capacity (0.33 bar, 33 kPa, 330 cm, pF 2.5), corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-unkn-fc
BLKDENSF_FE-UNKN-OD	\N	Fine earth. Type of sample unknown, at oven dry, corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityFineEarthProcedure-BlkDensF_fe-unkn-od
TOTC_DC-HT-ANALYSER	\N	Unacidified dry combustion at high temperature (950-1400 C). Total Carbon (USDA-NRCS method 6A), LECO analyzer at 1140 C	https://www.nrcs.usda.gov/Internet/FSE_DOCUMENTS/stelprdb1253872.pdf		http://w3id.org/glosis/model/procedure/carbonTotalProcedure-TotC_dc-ht-analyser
BLKDENSW_WE-CL-FC	\N	Whole earth. Clod samples (natural clods), at field capacity (0.33 bar, 33 kPa, 330 cm, pF 2.5), not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-cl-fc
BLKDENSW_WE-CL-OD	\N	Whole earth. Clod samples (natural clods), at oven dry, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-cl-od
BLKDENSW_WE-CL-UNKN	\N	Whole earth. Clod samples (natural clods), at unknown humidity, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-cl-unkn
BLKDENSW_WE-CO-FC	\N	Whole earth. Core sampling (pF rings), at field capacity (0.33 bar, 33 kPa, 336 cm, pF 2.5), not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-co-fc
BLKDENSW_WE-CO-OD	\N	Whole earth. Core sampling (pF rings), at oven dry, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-co-od
BLKDENSW_WE-CO-UNKN	\N	Whole earth. Core sampling (pF rings), at unknown humidity, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-co-unkn
BLKDENSW_WE-RPL-UNKN	\N	Whole earth. Excavation and replacement (i.e. soils too fragile to remove a stable sample) e.g. by auger, at unknown humidity, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-rpl-unkn
BLKDENSW_WE-UNKN	\N	Whole earth. Type of sample unknown, at unknown humidity, not corrected for coarse fragments if any	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/bulkDensityWholeSoilProcedure-BlkDensW_we-unkn
INORGC_CALCUL-CACO3	\N	Indirect estimate from total carbonate equivalent, with a factor of 0.12 (molar weights: CaCO3 100g/mol, C 12g/mol)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonInorganicProcedure-InOrgC_calcul-caco3
INORGC_CALCUL-TC-OC	\N	Indirect estimate (total carbon minus organic carbon = inorganic carbon)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonInorganicProcedure-InOrgC_calcul-tc-oc
ORGC_ACID-DC	\N	Acidified dry combustion or dry oxidation methods (after removal of carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc
CEC_PH0-COHEX	\N	CEC unbuffered at pH of the soil, in Cobalt(III) hexamine chloride solution 0,0166M (Cohex) [Co[NH3]6]Cl3 ), ISO 23470 (2007)  exchange solution	https://www.iso.org/standard/36879.html		http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-cohex
ORGC_ACID-DC-HT-ANALYSER	\N	Acidified. Furnace combustion (e.g., LECO combustion analyzer, Dumas method)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-ht-analyser
ORGC_ACID-DC-LT	\N	Acidified. Dry combustion at 500 C	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-lt
ORGC_ACID-DC-LT-LOI	\N	Acidified. Loss on ignition (NL)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-lt-loi
ORGC_ACID-DC-MT	\N	Acidified. Dry combustion at 840 C	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-mt
ORGC_ACID-DC-SPEC	\N	Spectrally measured and converted to Acidified dry combustion or dry oxidation methods (after removal of carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-spec
ORGC_CALCUL-TC-IC	\N	Calculated as total carbon minus inorganic carbon	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_calcul-tc-ic
ORGC_DC	\N	Unacidified. Dry combustion or dry oxidation methods (without prior removal of carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc
ORGC_DC-HT-ANALYSER	\N	Unacidified. Dry combustion by furnace (e.g., LECO combustion analyzer, Dumas method). Is total Carbon?	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-ht-analyser
ORGC_DC-LT	\N	Unacidified. Dry combustion at low temperature e.g. 500 C	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-lt
ORGC_DC-LT-LOI	\N	Unacidified. Loss on ignition (NL) is total Organic Carbon	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-lt-loi
ORGC_DC-MT	\N	Unacidified. Dry combustion at medium temperature e.g. 840 C	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-mt
ORGC_DC-SPEC	\N	Spectrally measured and converted to Unacidified Dry combustion or dry oxidation methods	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-spec
EXCHBASES_PH-UNKN-M3	\N	Exch bases (Ca, Mg, K, Na) unknown buffer, in Mehlich3 solution with extractable ppm assumed exchangeable cmolc/kg	https://doi.org/10.1080/00103628409367568		http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph-unkn-m3
ORGC_WC-CRO3-KNOPP	\N	Wet oxidation according to Knopp with chromic acid and gravimetric determination of CO2	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-knopp
TOTC_CALCUL-IC-OC	\N	Calculated as sum of inorganic carbon and organic carbon	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonTotalProcedure-TotC_calcul-ic-oc
TOTC_DC-HT	\N	Unacidified dry combustion at high temperature (950-1400 C). Total Carbon	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonTotalProcedure-TotC_dc-ht
TOTC_DC-HT-SPEC	\N	Spectrally measured and converted to Unacidified dry combustion at high temperature (950-1400 C).	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonTotalProcedure-TotC_dc-ht-spec
TOTC_DC-MT	\N	Unacidified dry combustion at medium temperature (550-950 C).	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/carbonTotalProcedure-TotC_dc-mt
CEC_PH-UNKN-CACL2	\N	CEC at unknown buffer, in 0.1 M CaCl2 exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph-unkn-cacl2
CEC_PH-UNKN-LIOAC	\N	CEC at unknown buffer, in 0.5 M Li-acetate exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph-unkn-lioac
CEC_PH-UNKN-M3	\N	CEC at unknown buffer, in Mehlich III exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph-unkn-m3
CEC_PH0-AG-THIOURA	\N	CEC unbuffered at pH of the soil, in 0.01 M Ag-thioura exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-ag-thioura
CEC_PH0-BACL2	\N	CEC unbuffered at pH o the soil, in 0.5 M BaCl2 exchange solution (0.1.1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-bacl2
CEC_PH0-KCL	\N	CEC unbuffered at pH of the soil, in 1 M KCl exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-kcl
CEC_PH0-NH4CL	\N	CEC unbuffered at pH of the soil, in 1 M NH4-chloride exchange solution (0.2-1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-nh4cl
EXCHBASES_PH-UNKN-M3-SPEC	\N	Exch bases (Ca, Mg, K, Na) spectrally measured and converted to, unknown buffer, in Mehlich3 solution with extractable ppm assumed exchangeable cmolc/kg	https://doi.org/10.1080/00103628409367568		http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph-unkn-m3-spec
CEC_PH0-NH4OAC	\N	CEC unbuffered at pH of the soil, in 1 M NH4-acetate (NH4OAc) exchange solution (0.25-1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-nh4oac
CEC_PH0-UNKN	\N	CEC unbuffered at pH of the soil, in unknown exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph0-unkn
CEC_PH7-EDTA	\N	CEC buffered at pH 7, in 0.1 M Li-EDTA exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph7-edta
CEC_PH7-NH4OAC	\N	CEC buffered at pH 7, in 1 M NH4-acetate (NH4OAc) exchange solution (0.25-1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph7-nh4oac
CEC_PH7-UNKN	\N	CEC buffered at pH 7, in unknown exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph7-unkn
CEC_PH8-BACL2TEA	\N	CEC buffered at pH 8.0-8.5, in 0.5 M BaCl2-TEA exchange solution (0.1.1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-bacl2tea
CEC_PH8-BAOAC	\N	CEC buffered at pH 8.0-8.5, in 0.5 M Ba-acetate exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-baoac
CEC_PH8-LICL2TEA	\N	CEC buffered at pH 8.0-8.5, in 0.5 M Li-chloride - TEA exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-licl2tea
CEC_PH8-NAOAC	\N	CEC buffered at pH 8.0-8.5, in 1 M Na-acetate exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-naoac
CEC_PH8-NH4OAC	\N	CEC buffered at pH 8.0-8.5, in 1 M NH4-acetate exchange solution (0.25-1.0 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-nh4oac
CEC_PH8-UNKN	\N	CEC buffered at pH 8.0-8.5, in unknown exchange solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/cationExchangeCapacitySoilProcedure-CEC_ph8-unkn
CRSFRG_FLD	\N	Particles > 2 mm observed in the field. May include concretions and very hard aggregates	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/coarseFragmentsProcedure-CrsFrg_fld
EXCHBASES_PH0-COHEX	\N	Exch bases (Ca, Mg, K, Na) unbuffered, in Cobalt(III) hexamine chloride solution 0,0166M (Cohex) [Co[NH3]6]Cl3 ), ISO 23470 (2007)	https://www.iso.org/standard/36879.html		http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph0-cohex
CRSFRG_FLDCLS	\N	Particles > 2 mm observed in the field and calculated from class values. May include concretions and very hard aggregates	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/coarseFragmentsProcedure-CrsFrg_fldcls
CRSFRG_LAB	\N	Particles > 2 mm measured in laboratory (sieved after light pounding). May include concretions and very hard aggregates	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/coarseFragmentsProcedure-CrsFrg_lab
EFFCEC_CALCUL-B	\N	Sum of exchangeable bases (Ca, Mg, K, Na) without exchangeable acidity (H+Al), see ExchBases and ExchAcids for methods	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/effectiveCecProcedure-EffCEC_calcul-b
EFFCEC_CALCUL-BA	\N	Sum of exchangeable bases (Ca, Mg, K, Na) plus exchangeable acidity (H+Al), see ExchBases and ExchAcids for methods	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/effectiveCecProcedure-EffCEC_calcul-ba
EC_RATIO1-1	\N	Elec. conductivity at 1:1 soil/water ratio	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-EC_ratio1-1
EC_RATIO1-10	\N	Elec. conductivity at 1:10 soil/water ratio	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-EC_ratio1-10
EC_RATIO1-2	\N	Elec. conductivity at 1:2 soil/water ratio	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-EC_ratio1-2
EC_RATIO1-2.5	\N	Elec. conductivity at 1:2.5 soil/water ratio	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-EC_ratio1-2.5
EC_RATIO1-5	\N	Elec. conductivity at 1:5 soil/water ratio	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-EC_ratio1-5
ECE_SAT	\N	Elec. conductivity in saturated paste (ECe)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/electricalConductivityProcedure-ECe_sat
EXCHBASES_PH-UNKN-EDTA	\N	Exch bases (Ca, Mg, K, Na) unknown buffer, in EDTA solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph-unkn-edta
EXCHBASES_PH0-NH4CL	\N	Exch bases (Ca, Mg, K, Na) unbuffered, in 1 M NH4Cl (0.05-1.0 m?)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph0-nh4cl
EXCHBASES_PH7-UNKN	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 7, in unknown solution	https://www.isric.org/sites/default/files/WOSISprocedureManual_2020nov17web.pdf#page=70		http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph7-unkn
EXCHBASES_PH7-NH4OAC	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 7, in 1M NH4OAc	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph7-nh4oac
EXCHBASES_PH7-NH4OAC-AAS	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 7, in 1M NH4OAc, Ca and Mg with AAS (Atomic Absorption Spectrometry)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph7-nh4oac-aas
EXCHBASES_PH7-NH4OAC-FP	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 7, in 1M NH4OAc, K and Na with FP (Flame Photometry)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph7-nh4oac-fp
EXCHBASES_PH8-BACL2TEA	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 8.0-8.5, in 0.5 M BaCl2 - TEA solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph8-bacl2tea
EXCHBASES_PH8-UNKN	\N	Exch bases (Ca, Mg, K, Na) buffered at pH 8.0-8.5, in unknown solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/exchangeableBasesProcedure-ExchBases_ph8-unkn
EXTR_AP20	\N	Olsen (not acid soils) resp. Bray I (acid soils). Particularly used for available P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_ap20
EXTR_AP21	\N	Olsen (if pH > 7) resp. Mehlich (if pH < 7). Particularly used for available P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_ap21
EXTR_CACL2	\N	CaCl2. Particularly used for soluble P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_cacl2
EXTR_CAPO4	\N	Ca phosphate. Particularly used for available S.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_capo4
EXTR_HCL-H2SO4-NELSON	\N	Method of Nelson (dilute HCl/H2SO4). Particularly used for available P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hcl-h2so4-nelson
EXTR_HNO3	\N	Nitric acid (HNO3) method	https://www.iso.org/standard/60060.html	ISO. ISO/DIS 17586 Soil Quality - Extraction of Trace Elements Using Dilute Nitric Acid, 2016; p 14	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hno3
EXTR_HOTWATER	\N	Hot water. Particularly used for available B	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hotwater
EXTR_NH4-CO3-2-AMBIC1	\N	Ambic1 method (ammonium bicarbonate) (South Africa). Particularly used for available P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_nh4-co3-2-ambic1
EXTR_NH4CH3CH-OH-COOH-LEUVEN	\N	NH4-lactate extraction method (KU-Leuven). Particularly used for available P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_nh4ch3ch-oh-cooh-leuven
CASO4_GY01	\N	Dissolved in water and precipitated by acetone	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy01
CASO4_GY02	\N	Differ. between Ca-conc. in sat. extr. and Ca-conc. in 1/50 s/w solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy02
CASO4_GY03	\N	Calculated from conductivity of successive dilutions	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy03
CASO4_GY04	\N	In 0.1 M Na3-EDTA-/- turbidimetric (Begheijn, 1993)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy04
CASO4_GY05	\N	Gravimetric after dissolution in 0.2 N HCl (USSR-method)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy05
CASO4_GY06	\N	Total-S, using LECO furnace, minus easily soluble MgSO4 and Na2SO4	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy06
CASO4_GY07	\N	Schleiff method, electrometric	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/gypsumProcedure-CaSO4_gy07
KSAT_CALCUL-PTF	\N	Saturated hydraulic conductivity.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-KSat_calcul-ptf
KSAT_CALCUL-PTF-GENUCHTEN	\N	Saturated and not saturated hydraulic conductivity.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-KSat_calcul-ptf-genuchten
KSAT_CALCUL-PTF-SAXTON	\N	Saturated hydraulic conductivity.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-KSat_calcul-ptf-saxton
KSAT_BHOLE	\N	Saturated hydraulic conductivity. Bore hole method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-Ksat_bhole
KSAT_COLUMN	\N	Saturated hydraulic conductivity. Permeability in cm/hr determined in column filled with fine earth fraction	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-Ksat_column
KSAT_DBLRING	\N	Saturated hydraulic conductivity. Double ring method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-Ksat_dblring
KSAT_INVBHOLE	\N	Saturated hydraulic conductivity. Inverse bore hole method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/hydraulicConductivityProcedure-Ksat_invbhole
VMC_CALCUL-PTF	\N	Calculated by PTF	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_calcul-ptf
VMC_CALCUL-PTF-BROOKSCOREY	\N	Calculated by PTF of brooks - corey	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_calcul-ptf-brookscorey
VMC_D	\N	Volumetric moisture content in disturbed samples	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_d
VMC_D-CL	\N	Pressure-plate extraction, disturbed -clod- samples (wt%) * density	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_d-cl
VMC_D-CL-WW	\N	Pressure-plate extraction, disturbed -clod- samples (wt%) * density on weight/weight basis; to be converted to v/v (with BD at appropriate humidity)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_d-cl-ww
VMC_D-WW	\N	Volumetric moisture content in disturbed samples on weight/weight basis to be converted to v/v (with BD at appropriate humidity)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_d-ww
VMC_UD	\N	Undisturbed samples	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_ud
VMC_UD-CL	\N	Natural clod	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_ud-cl
VMC_UD-CO	\N	Volumetric moisture content in undisturbed samples (pF rings cores)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/moistureContentProcedure-VMC_ud-co
TOTALN_BREMNER	\N	Total N (Bremner, 1965, p. 1162-1164)	https://doi.org/10.2134/agronmonogr9.2.c32	Bremner, J. M. 1965. Total Nitrogen. In: C. A. Black (ed.) Methods of soil analysis. Part 2: Chemical and microbial properties. Number 9 in series Agronomy. American Society of Agronomy, Inc. Publisher, Madison, USA. Pp. 1049-1178	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_bremner
TOTALN_CALCUL	\N	OC * 1.72 / 20 (gives C/N=11.6009)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_calcul
TOTALN_CALCUL-OC10	\N	Calculated from OrgC and C/N ratio of 10	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_calcul-oc10
TOTALN_DC	\N	Dry combustion	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_dc
TOTALN_KJELDAHL	\N	Method of Kjeldahl (digestion)	https://en.wikipedia.org/wiki/Kjeldahl_method	Kjeldahl, J. (1883) ‘Neue Methode zur Bestimmung des Stickstoffs in organischen Körpern’ (New method for the determination of nitrogen in organic substances), Zeitschrift für analytische Chemie, 22 (1) : 366-383.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_kjeldahl
TOTALN_KJELDAHL-NH4	\N	Kjeldahl, and ammonia distillation	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_kjeldahl-nh4
TOTALN_NELSON	\N	Nelson and Sommers, 1980	https://doi.org/10.1093/jaoac/63.4.770	Darrell W Nelson, Lee E Sommers, Total Nitrogen Analysis of Soil and Plant Tissues, Journal of Association of Official Analytical Chemists, Volume 63, Issue 4, 1 July 1980, Pages 770–778,	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_nelson
TOTALN_TN04	\N	Dry combustion using a CN-corder and cobalt oxide or copper oxide as an oxidation accelerator (Tanabe and Araragi, 1970)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_tn04
TOTALN_TN06	\N	Continuous flow analyser after digestion with H2SO4/salicyclic acid/H2O2/Se	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_tn06
TOTALN_TN08	\N	Sample digested by sulphuric acid, distillation of released ammonia, back titration against sulpuric acid	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_tn08
FULACIDC_UNKN	\N	Fulvic acid carbon_unknown method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/organicMatterProcedure-FulAcidC_unkn
HUMACIDC_UNKN	\N	Humic acid carbon_unknown method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/organicMatterProcedure-HumAcidC_unkn
ORGM_CALCUL-OC1.73	\N	Organic carbon * 1,73	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/organicMatterProcedure-OrgM_calcul-oc1.73
TOTHUMC_UNKN	\N	Total humic carbon_unknown method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/organicMatterProcedure-TotHumC_unkn
PHCACL2	\N	pHCaCl2 (soil reaction) in a soil/CaCl2 solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHCaCl2
PHH2O	\N	pHH2O (soil reaction) in a soil/water solution	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHH2O
PHKCL	\N	pHKCl (soil reaction) in a soil/KCl solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl
PHKCL_SAT	\N	pHKCl (soil reaction) in saturated paste	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHKCl_sat
PHNAF	\N	pHNaF (soil reaction) in a soil/NaF solution (0.01-1 M)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pHProcedure-pHNaF
BEAKER-DISP	\N	Particle size analysis with beaker method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-disp
BEAKER-DISP-SPEC	\N	Spectrally predicted based on measurments with the beaker method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-disp-spec
BEAKER-NODISP	\N	Particle size analysis with beaker method with no dispersion of the primary particlesand pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-nodisp
BEAKER-NODISP-SPEC	\N	Spectrally predicted based on measurments with the beaker method with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-nodisp-spec
BEAKER-UNKDISP	\N	Particle size analysis with beaker method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-unkdisp
BEAKER-UNKDISP-SPEC	\N	Spectrally predicted based on measurments with the beaker method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-beaker-unkdisp-spec
FLDEST	\N	Field estimate of the particle size distribution, typically done by hand	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-fldest
HYDROMETER-DISP	\N	Particle size analysis with hydrometer (bouyoucos) method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-disp
EXTR_C6H8O7-REEUWIJK	\N	Complexation with citric acid (van Reeuwijk). Particularly used for available P.	https://www.isric.org/documents/document-type/technical-paper-09-procedures-soil-analysis-6th-edition		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_c6h8o7-reeuwijk
EXTR_DTPA	\N	DiethyneleTriaminePentaAcetic acid (DTPA) method	https://doi.org/10.2136/sssaj1978.03615995004200030009x		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_dtpa
HYDROMETER-DISP-SPEC	\N	Spectrally predicted based on measurments with the hydrometer (bouyoucos) method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-disp-spec
HYDROMETER-NODISP	\N	Particle size analysis with hydrometer (bouyoucos) method with no dispersion of the primary particles and removal of cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-nodisp
HYDROMETER-NODISP-SPEC	\N	Spectrally predicted based on measurments with the hydrometer (bouyoucos) method with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-nodisp-spec
HYDROMETER-UNKDISP	\N	Particle size analysis with hydrometer (bouyoucos) method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-unkdisp
HYDROMETER-UNKDISP-SPEC	\N	Spectrally predicted based on measurments with the hydrometer (bouyoucos) method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-hydrometer-unkdisp-spec
LASER-DISP	\N	Particle size analysis with laser diffraction with appropriate disperson of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-disp
LASER-DISP-SPEC	\N	Spectrally predicted based on measurments with laser diffraction analysis with appropriate disperson of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-disp-spec
LASER-NODISP	\N	Particle size analysis with laser diffraction with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-nodisp
LASER-NODISP-SPEC	\N	Spectrally predicted based on measurments with laser diffraction analysis with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-nodisp-spec
LASER-UNKDISP	\N	Particle size analysis with laser diffraction with unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-unkdisp
SUMTXTR_CALCUL	\N	Calculated sum of sand, silt and clay fractions	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/textureSumProcedure-SumTxtr_calcul
LASER-UNKDISP-SPEC	\N	Spectrally predicted based on measurments with laser diffraction analysis with unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-laser-unkdisp-spec
PIPETTE-DISP	\N	Particle size analysis with pipette method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-disp
PIPETTE-DISP-SPEC	\N	Spectrally predicted based on measurments with the pipette method with appropriate dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-disp-spec
PIPETTE-NODISP	\N	Particle size analysis with pipette method with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-nodisp
PIPETTE-NODISP-SPEC	\N	Spectrally predicted based on measurments with the pipette method with no dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-nodisp-spec
PIPETTE-UNKDISP	\N	Particle size analysis with pipette method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-unkdisp
PIPETTE-UNKDISP-SPEC	\N	Spectrally predicted based on measurments with the pipette method unknown dispersion of the primary particles and pretreatment to remove cementing particles (organic matter, carbonates)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/pSAProcedure-pipette-unkdisp-spec
RETENTP_UNKN-SPEC	\N	Spectrally measured and converted to P retention (P buffer index)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/phosphorusRetentionProcedure-RetentP_unkn-spec
POROS_CALCUL-PF0	\N	Porosity calculated from volumetric moisture content at pF 0 (1 cm)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/porosityProcedure-Poros_calcul-pf0
SLBAN_CALCUL-UNKN	\N	Sum of soluble anions (Cl, SO4, HCO2, CO3, NO3, F)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/solubleSaltsProcedure-SlbAn_calcul-unkn
SLBCAT_CALCUL-UNKN	\N	Sum of soluble cations (Ca, Mg, K, Na)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/solubleSaltsProcedure-SlbCat_calcul-unkn
ORGC_WC-CRO3-KALEMBRA	\N	Wet oxidation according to Kalembra and Jenkinson (1973) with acid dichromate	https://doi.org/10.1002/jsfa.2740240910		http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-kalembra
CACO3_ACID-CH3COOH-DC	\N	Dissolution of carbonates by Acetic acid [CH3COOH], external heat (dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-ch3cooh-dc
CACO3_ACID-CH3COOH-NODC	\N	Dissolution of carbonates by Acetic acid [CH3COOH], no external (no dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-ch3cooh-nodc
CACO3_ACID-CH3COOH-UNKN	\N	Dissolution of carbonates by Acetic acid [CH3COOH], external heat unknown	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-ch3cooh-unkn
CACO3_ACID-DC	\N	Dissolution of carbonates by acid, external heat (dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-dc
CACO3_ACID-H2SO4-DC	\N	Dissolution of carbonates by Sulfuric acid [H2SO4], external heat (dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h2so4-dc
CACO3_ACID-H2SO4-NODC	\N	Dissolution of carbonates by Sulfuric acid [H2SO4], no external (no dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h2so4-nodc
CACO3_ACID-H2SO4-UNKN	\N	Dissolution of carbonates by Sulfuric acid [H2SO4], external heat unknown	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h2so4-unkn
CACO3_ACID-H3PO4-DC	\N	Dissolution of carbonates by Phosphoric acid [H3PO4], external heat (dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h3po4-dc
CACO3_ACID-H3PO4-NODC	\N	Dissolution of carbonates by Phosphoric acid [H3PO4], no external (no dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h3po4-nodc
CACO3_ACID-H3PO4-UNKN	\N	Dissolution of carbonates by Phosphoric acid [H3PO4], external heat unknown	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-h3po4-unkn
CACO3_ACID-HCL-DC	\N	Dissolution of carbonates by Hydrochloric acid [HCl], or Perchloric acid [HClO4], external heat (dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-hcl-dc
CACO3_ACID-HCL-NODC	\N	Dissolution of carbonates by Hydrochloric acid [HCl], or Perchloric acid [HClO4], no external (no dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-hcl-nodc
CACO3_ACID-HCL-UNKN	\N	Dissolution of carbonates by Hydrochloric acid [HCl], or Perchloric acid [HClO4], external heat unknown	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-hcl-unkn
CACO3_ACID-NODC	\N	Dissolution of carbonates by acid, no external (no dry combustion)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-nodc
CACO3_ACID-UNKN	\N	Dissolution of carbonates by acid, external heat unknown	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_acid-unkn
CACO3_CA03	\N	Method of Piper (HCl)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca03
CACO3_CA04	\N	Calcimeter method (volumetric after adition of dilute acid)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca04
CACO3_CA05	\N	Gravimetric (USDA Agr. Hdbk 60-/- method Richards et al., 1954)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca05
CACO3_CA06	\N	H3PO4 acid at 80C, conductometric in NaOH (Schlichting & Blume, 1966)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca06
CACO3_CA07	\N	Pressure calcimeter (Nelson, 1982)	https://acsess.onlinelibrary.wiley.com/doi/book/10.2134/agronmonogr9.2.2ed	Nelson, D.W., and L.E. Sommers. 1982. Total carbon, organic carbon and organic matter. p. 539-579. In A.L. Page (ed.), 1983. Methods of soil analysis. Part 2. 2nd ed. Agron. Monogr. 9. ASA and SSSA, Madison, WI.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca07
CACO3_CA08	\N	Bernard calcimeter (Total CaCO3)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca08
CACO3_CA09	\N	Carbonates: H3PO4 treatment at 80 deg. C and CO2 measurement like TOC (OC13), transformation into CaCO3 (Schlichting et al. 1995)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca09
CACO3_CA10	\N	CaCO3 Equivalent, CO2 evolution after HCl treatment. Gravimetric	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca10
CACO3_CA11	\N	Black, 1965-HCl	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca11
CACO3_CA12	\N	Treatment with H2SO4 N/2 acid followed by titration with NaOH N/2 in presence of an indicator	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca12
CACO3_CALCUL-TC-OC	\N	Indirect estimate: inorganic carbon divided by 0.12 (computed as total carbon minus organic carbon)	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_calcul-tc-oc
TOTAL_H2SO4	\N	Total P-/- colorimetric in H2SO4-Se-Salicylic acid digest( sulfuric acid) Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_h2so4
TOTAL_HCL	\N	HCl extraction. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_hcl
TOTAL_HCL-AQUAREGIA	\N	Hydrocloric (HCl) extraction in nitric/perchloric acid mixture (totals) aqua regia	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_hcl-aquaregia
TOTAL_HCLO4	\N	Perchloric acid percolation. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_hclo4
TOTAL_HNO3-AQUAFORTIS	\N	Nitric acid attack. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_hno3-aquafortis
TOTAL_NH4-6MO7O24	\N	COLORIMETRIC VANADATE MOLYBDATE. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_nh4-6mo7o24
TOTAL_TP03	\N	reagent of Baeyens. Precipitation in form of Phosphomolybdate. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp03
TOTAL_TP04	\N	acid fleischman. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp04
TOTAL_TP05	\N	8 M HCl extraction. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp05
TOTAL_TP06	\N	Molybdenum blue method, using ascorbic acid as reductant after heating of soil to 550 C and extraction with 6M sulphuric acid. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp06
TOTAL_TP07	\N	1:1 H2SO4 : HNO3. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp07
ORGC_WC-CRO3-NRCS6A1C	\N	Wet oxidation according to USDA-NRCS method 6A1c with acid dichromate digestion, FeSO4 titration, automatic titrator	https://www.nrcs.usda.gov/Internet/FSE_DOCUMENTS/stelprdb1253872.pdf		http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-nrcs6a1c
TOTAL_TP08	\N	After Nitric acid attack (boiling with HNO3), colometric determination (method of Duval).. Particularly used for Total P.	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp08
TOTAL_TP10	\N	Colorimetric, unspecified extract	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp10
TOTAL_UNKN	\N	Unspecified method	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_unkn
TOTAL_XRD	\N	XRD	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_xrd
TOTAL_XRF	\N	XRF	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_xrf
TOTAL_XRF-P	\N	PXRF	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_xrf-p
TOTAL_XTF-T	\N	TXRF	https://www.isric.org/sites/default/files/isric_report_2014_01.pdf	Leenaars J.G.B., A.J.M. van Oostrum and M. Ruiperez Gonzalez, 2014. Africa Soil Profiles Database, Version 1.2. A compilation of georeferenced and standardised legacy soil profile data for Sub-Saharan Africa (with dataset). ISRIC Report 2014/01. Africa Soil Information Service (AfSIS) project and ISRIC - World Soil Information, Wageningen, the Netherlands. See Annex 4.	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_xtf-t
ORGC_ACID-DC-HT	\N	Acidified. Dry combustion at 1200 C and colometric CO2 measurement (Schlichting et al. 1995)		Schlichting E, Blume HP, Stahr K (1995) Soils Practical (in German). Blackwell, Berlin	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_acid-dc-ht
ORGC_DC-HT	\N	Unacidified. Dry combustion at high temperature (e.g. 1200 C and colometric CO2 measurement (Schlichting et al. 1995)		Schlichting E, Blume HP, Stahr K (1995) Soils Practical (in German). Blackwell, Berlin	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_dc-ht
ORGC_WC-CRO3-JACKSON	\N	Wet oxidation according to Jackson (1958) with chromic acid digestion		Jackson, M. L. (1958) Soil Chemical Analysis. Prentice-Hall, Englewood Cliffs, New Jersey.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-jackson
ORGC_WC-CRO3-KURMIES	\N	Wet oxidation according to Kurmies with K2Cr2O7+H2SO4		B. KURMIES, Z. Pflanzenernühr. Dung. u Bodenk., 44 (1949) 121	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-kurmies
ORGC_WC-CRO3-NELSON	\N	Wet oxidation according to Nelson and Sommers (1996)		Nelson and Sommers (1996) in: Sparks DL (ed.). Soil Sci. Soc. Am. book series 5, part 3, pp 961-1010.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-nelson
ORGC_WC-CRO3-TIURIN	\N	Wet oxidation according to Tiurin with K-dichromate		I. V. TIURIN, Pochvovodenie (Pedology), (1931) 36.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-tiurin
ORGC_WC-CRO3-WALKLEYBLACK	\N	Walkley-Black method (chromic acid digestion)		Walkley, A. and I. A. Black. 1934. An Examination of Degtjareff Method for Determining Soil Organic Matter and a Proposed Modification of the Chromic Acid Titration Method. Soil Sci. 37:29–37.	http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc-cro3-walkleyblack
EXTR_AP14	\N	Method of Saunders and Metelerkamp (anion-exch. resin). Particularly used for available P.		Saunders and Metelerkamp	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_ap14
EXTR_AP15	\N	Method of Hunter (1975) modified after ISFEI method. Particularly used for available P.		Hunter, A. 1975. New techniques and equipment for routine soil/plant analytical procedures. In: Soil Management in Tropical America. (eds E. Borremiza & A. Alvarado). N.C. State University, Raleigh, NC.	http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_ap15
RETENTP_BLAKEMORE	\N	P retention at ~pH4.6  (acc. Blakemore 1987)		Blakemore L.C. Searle P.L. and Daly, B.K. (1987) Methods for chemical analysis of soils. NZ Soil Bureau, Lower Hutt, New Zealand.	http://w3id.org/glosis/model/procedure/phosphorusRetentionProcedure-RetentP_blakemore
CACO3_CA01	\N	Method of Scheibler (volumetric)		ON L 1084-99 (1999) Chemical analyses of soils—determination of carbonate. In: Austrian Standards Institute (ed) O‹ NORM L 1084. Austrian Standards Institute, Vienna	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca01
CACO3_CA02	\N	Method of Wesemael		Wesemael, J.C., 1955. De bepaling van van calciumcarbonaatgehalte van gronden. Chemisch Weekblad 51, 35-36.	http://w3id.org/glosis/model/procedure/totalCarbonateEquivalentProcedure-CaCO3_ca02
TOTAL_TP09	\N	Walker and Adams, 1958. Particularly used for Total P.		WALKER, T. W., AND A. F. R. ADAMS. 1958. Studies on soil organic matter. I. Soil Sci. 85: 307-318. 	http://w3id.org/glosis/model/procedure/totalElementsProcedure-Total_tp09
EXTR_EDTA	\N	EthyleneDiamineTetraAcetic acid (EDTA) method	https://journals.lww.com/soilsci/Citation/1954/10000/SOIL_AND_PLANT_STUDIES_WITH_CHELATES_OF.8.aspx		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_edta
EXTR_H2SO4-TRUOG	\N	Method of Truog (dilute H2SO4). Particularly used for available P.	https://doi.org/10.2134/agronj1930.00021962002200100008x		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_h2so4-truog
EXTR_HCL-NH4F-BRAY1	\N	Method of Bray I  (dilute HCl/NH4F). Particularly used for available P.	https://doi.org/10.1097/00010694-194501000-00006		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hcl-nh4f-bray1
EXTR_HCL-NH4F-BRAY2	\N	Method of Bray II (dilute HCl/NH4F). Particularly used for available P.	https://doi.org/10.1097/00010694-194501000-00006		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hcl-nh4f-bray2
EXTR_HCL-NH4F-KURTZ-BRAY	\N	Method of Kurtz-Bray I (0.025 M HCl + 0.03 M NH4F). Particularly used for available P.	https://doi.org/10.1097/00010694-194501000-00006		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_hcl-nh4f-kurtz-bray
EXTR_M1	\N	Mehlich1 method	https://www.ncagr.gov/AGRONOMI/pdffiles/mehlich53.pdf		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_m1
EXTR_M2	\N	Mehlich2 method	https://doi.org/10.1080/00103627609366673		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_m2
EXTR_M3	\N	Mehlich3 method (extractant 0.2 N CH3COOH + 0.25 N NH4NO3 + 0.015 N NH4F + 0.013 N HNO3 + 0.001 M EDTA)	https://doi.org/10.1080/00103628409367568		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_m3
EXTR_M3-SPEC	\N	Spectrally measured and converted to Mehlich3 method (extractant 0.2 N CH3COOH + 0.25 N NH4NO3 + 0.015 N NH4F + 0.013 N HNO3 + 0.001 M EDTA)	https://doi.org/10.1080/00103628409367568		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_m3-spec
EXTR_NAHCO3-OLSEN	\N	Method of Olsen (0.5 M Sodium Bicarbonate (NaHCO3) extraction at pH8.5). Particularly used for available P.	https://acsess.onlinelibrary.wiley.com/doi/book/10.2134/agronmonogr9.2		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_nahco3-olsen
EXTR_NAHCO3-OLSEN-DABIN	\N	Method of Olsen, modified by Dabin (ORSTOM). Particularly used for available P.	https://docplayer.fr/81912854-Application-des-dosages-automatiques-a-l-analyse-des-sols-2e-partie-par.html		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_nahco3-olsen-dabin
EXTR_NAOAC-MORGAN	\N	Method of Morgan (Na-acetate/acetic acid). Particularly used for available P.	https://portal.ct.gov/-/media/CAES/DOCUMENTS/Publications/Bulletins/B450pdf.pdf?la=en		http://w3id.org/glosis/model/procedure/extractableElementsProcedure-Extr_naoac-morgan
ORGC_WC	\N	Wet oxidation or wet combustion methods			http://w3id.org/glosis/model/procedure/carbonOrganicProcedure-OrgC_wc
TOTALN_H2SO4	\N	H2SO4			http://w3id.org/glosis/model/procedure/nitrogenTotalProcedure-TotalN_h2so4
\.


--
-- TOC entry 5250 (class 0 OID 55548915)
-- Dependencies: 258
-- Data for Name: procedure_spectrometer; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.procedure_spectrometer (procedure_spectrometer_id, procedure_name) FROM stdin;
\.


--
-- TOC entry 5251 (class 0 OID 55548921)
-- Dependencies: 259
-- Data for Name: procedure_spectrometer_def; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.procedure_spectrometer_def (procedure_spectrometer_id, key, value) FROM stdin;
\.


--
-- TOC entry 5231 (class 0 OID 55548805)
-- Dependencies: 236
-- Data for Name: profile; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.profile (profile_id, plot_id, profile_code) FROM stdin;
\.


--
-- TOC entry 5254 (class 0 OID 55548931)
-- Dependencies: 262
-- Data for Name: proj_x_org_x_ind; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.proj_x_org_x_ind (project_id, organisation_id, individual_id, "position", tag, role) FROM stdin;
\.


--
-- TOC entry 5234 (class 0 OID 55548825)
-- Dependencies: 240
-- Data for Name: project; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.project (project_id, name) FROM stdin;
\.


--
-- TOC entry 5235 (class 0 OID 55548831)
-- Dependencies: 241
-- Data for Name: project_site; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.project_site (project_id, site_id) FROM stdin;
\.


--
-- TOC entry 5255 (class 0 OID 55548939)
-- Dependencies: 263
-- Data for Name: project_soil_map; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.project_soil_map (project_id, soil_map_id, remarks) FROM stdin;
\.


--
-- TOC entry 5256 (class 0 OID 55548945)
-- Dependencies: 264
-- Data for Name: property_desc; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.property_desc (property_desc_id, property_name, definition, uri) FROM stdin;
landformComplexProperty	Landform Complex	Subdivisions for complex landforms. See more in Guidelines for Soil Description issued by the FAO: table 5	http://w3id.org/glosis/model/siteplot/landformComplexProperty
coatingAbundanceProperty	Coating Abundance	Classification of abundance of coatings. See more in Guidelines for Soil Description issued by the FAO: table 64	http://w3id.org/glosis/model/layerhorizon/coatingAbundanceProperty
bleachedSandProperty	Bleached Sand	Classification of bleached sand characteristics based on the percentage of surface covered. See more in Guidelines for Soil Description issued by the FAO: table 23	http://w3id.org/glosis/model/common/bleachedSandProperty
cracksDepthProperty	Cracks Depth	List of suggested classes of surface cracks in shrink–swell clay-rich soils after they dry out. See more in guidelines for Soil Description issued by the FAO: table 21,2	http://w3id.org/glosis/model/common/cracksDepthProperty
cracksDistanceProperty	Cracks Distance	Classification of the surface cracks based on distance between the cracks measured in meters. See more in Guidelines for Soil Description issued by the FAO: table 21,3	http://w3id.org/glosis/model/common/cracksDistanceProperty
cracksWidthProperty	Cracks Width	Classification of surface cracks based on the width. See more in Guidelines for Soil Description issued by the FAO: table 21,1	http://w3id.org/glosis/model/common/cracksWidthProperty
fragmentCoverProperty	Fragment Cover	Coarse surface fragments, including those partially exposed, should be described in terms of percentage of surface coverage and of size of the fragments. See more in Guidelines for Soil Description issued by the FAO: table 15,1	http://w3id.org/glosis/model/common/fragmentCoverProperty
fragmentsSizeProperty	Fragments Size 	Classes of occurrence of coarse surface fragments are correlated with the ones for rock outcrop. See more in guidelines for Soil Description issued by the FAO: table 15,2	http://w3id.org/glosis/model/common/fragmentsSizeProperty
organicMatterClassProperty	Organic Matter Class	Refers to the categorization or classification of soil based on the quality, quantity, and composition of organic matter present, influencing soil properties such as fertility, water retention, and microbial activity. Source: Source: FAO, Soil Organic Matter and Soil Health, Land and Water Development Division.	http://w3id.org/glosis/model/common/organicMatterClassProperty
rockAbundanceProperty	Rock Abundance	Abundance of rock fragments and artefacts, by volume. See more in Guidelines for Soil Description issued by the FAO: table 26	http://w3id.org/glosis/model/common/rockAbundanceProperty
rockShapeProperty	Rock Shape	The general shape or roundness of rock fragments. See more on Guidelines for Soil Description issued by the FAO: table 28	http://w3id.org/glosis/model/common/rockShapeProperty
rockSizeProperty	Rock Size	Classification for rock fragments and artefacts influences the nutrient status, water movement, use and management of the soil. See more in guidelines for Soil Description issued by the FAO: table 27	http://w3id.org/glosis/model/common/rockSizeProperty
weatheringFragmentsProperty	Weathering Fragments	Classification of weathering of coarse fragments. See more in Guidelines for Soil Description issued by the FAO: table 29	http://w3id.org/glosis/model/common/weatheringFragmentsProperty
saltCoverProperty	Salt Cover	The occurrence of salt at the surface may be described in terms of cover, appearance and type of salt. See more in the guidelines for Soil Description issued by the FAO: table 22,1	http://w3id.org/glosis/model/surface/saltCoverProperty
SaltThicknessProperty	Salt Thickness	The occurrence of salt at the surface may be described in terms of cover, appearance and type of salt. See more in the Guidelines for Soil Description issued by the FAO: table 22,2	http://w3id.org/glosis/model/surface/saltThicknessProperty
sealingConsistenceProperty	Sealing Consistence	Classification of the attributes of surface sealing based on consistency. See more in Guidelines for Soil Description issued by the FAO: table 20,2	http://w3id.org/glosis/model/surface/sealingConsistenceProperty
sealingThicknessProperty	Sealing Thickness	Surface sealing is used to describe crusts that develop at the soil surface after the topsoil dries out. See more in Guidelines for Soil Description issued by the FAO: 20,1	http://w3id.org/glosis/model/surface/sealingThicknessProperty
cropClassProperty	Crop Class	Examples for the most common crops with their recommended codes. See more in guidelines for Soil Description issued by the FAO: table 9	http://w3id.org/glosis/model/siteplot/cropClassProperty
erosionActivityPeriodProperty	Erosion Activity Period	The period of activity of accelerated erosion or deposition is described using the recommended classes. See more in Guidelines for Soil Description issued by the FAO: table 19	http://w3id.org/glosis/model/siteplot/erosionActivityPeriodProperty
erosionAreaAffectedProperty	Erosion Area Affected	Classification of total area affected by erosion and deposition. See more in Guidelines for Soil Description issued by the FAO: table 17	http://w3id.org/glosis/model/siteplot/erosionAreaAffectedProperty
erosionCategoryProperty	Erosion Category	Erosion can be classified as water or wind erosion and include off-site effects such as deposition; a third major category is mass movements (landslides and related phenomena). See more in Guidelines for Soil Description issued by the FAO: table 16	http://w3id.org/glosis/model/siteplot/erosionCategoryProperty
erosionDegreeProperty	Erosion Degree	Classification of erosion, by degree. See more in guidelines for Soil Description issued by the FAO: table 18	http://w3id.org/glosis/model/siteplot/erosionDegreeProperty
erosionTotalAreaAffectedProperty	Erosion Total Area Affected	The total area affected by erosion and deposition is estimated following the classes defined by SOTER (FAO, 1995). See more in the Guidelines for Soil Description issued by the FAO: table 17	http://w3id.org/glosis/model/siteplot/erosionTotalAreaAffectedProperty
floodDurationProperty	Flood Duration	Related to the amount of time an area remains inundated by floodwater.  This metric is important because it helps assess the extent of waterlogging and its impact on soil properties, particularly in terms of oxygen availability and soil aeration. Flood duration affects the mobility of nutrients and contaminants within the soil, influencing both agricultural productivity and environmental quality. Longer flood durations can also lead to changes in soil texture and structure due to the continuous movement and deposition of particles during inundation​. Source: Guidance for Flood Risk Analysis and Mapping	http://w3id.org/glosis/model/siteplot/floodDurationProperty
floodFrequencyProperty	Flood Frequency	Refers to the statistical analysis of the occurrence of floods at a particular location over a defined time period. It often involves calculating the recurrence intervals or return periods of flood events, which are typically used to understand how often a specific flood magnitude (like a 100-year flood) is likely to occur. Source: Introduction to Flood Frequency Analysis	http://w3id.org/glosis/model/siteplot/floodFrequencyProperty
geologyProperty	Geology	In order to be able to work in smaller scales, some additional natural and anthropogenic parent materials are used for the identification of rocks  in the field, the keys to the most important rock types are provided in the hierarchical SOTER list. See more in the guidelines for Soil Description issued by the FAO: table 12	http://w3id.org/glosis/model/siteplot/geologyProperty
humanInfluenceClassProperty	Human Influence Class	This item refers to any evidence of human activity that is likely to have affected the landscape or the physical and chemical properties of the soil. See more in the Guidelines for Soil Description issued by the FAO: table 10	http://w3id.org/glosis/model/siteplot/humanInfluenceClassProperty
landUseClassProperty	Land Use Class	Land use applies to the current use of the land, whether agricultural or nonagricultural, in which the soil is located. See more in the guidelines for Soil Description issued by the FAO: table 8	http://w3id.org/glosis/model/siteplot/landUseClassProperty
lithologyProperty	Lithology	In order to be able to work in smaller scales, some additional natural and anthropogenic parent materials are used for the identification of rocks  in the field, the keys to the most important rock types are provided in the hierarchical SOTER list. See more in the guidelines for Soil Description issued by the FAO: table 12	http://w3id.org/glosis/model/siteplot/lithologyProperty
MajorLandFormProperty	Major Land Form	Hierarchy of major landforms. See more in Guidelines for Soil Description issued by the FAO: table 4	http://w3id.org/glosis/model/siteplot/majorLandFormProperty
ParentDepositionProperty	Parent Deposition	Erosion can be classified as water or wind erosion and include off-site effects such as deposition; a third major category is mass movements (landslides and related phenomena). See more in Guidelines for Soil Description issued by the FAO: table 16	http://w3id.org/glosis/model/siteplot/parentDepositionProperty
parentLithologyProperty	Parent Lithology	In order to be able to work in smaller scales, some additional natural and anthropogenic parent materials are used for the identification of rocks  in the field, the keys to the most important rock types are provided in the hierarchical SOTER list. See more in the guidelines for Soil Description issued by the FAO: table 12	http://w3id.org/glosis/model/siteplot/parentLithologyProperty
parentTextureUnconsolidatedProperty	Parent Texture Unconsolidated	Texture of a soil that is unconsolidated or loose, typically not bound into a compact mass. It describes the proportions of sand, silt, and clay in the soil, which directly influences the soil's physical properties such as water retention, aeration, and fertility. This texture classification can impact various soil management practices, such as tillage, irrigation, and erosion control. Source: Canadian Soil Information Service - chapter 17 & Geosciences libretexts - 3.1: Soil Texture and Structure. Possible values include unconsolidated Sand,Silt, Clay, Loam. Silty Sand, Clayey Sand	http://w3id.org/glosis/model/siteplot/parentTextureUnconsolidatedProperty
PhysiographyProperty	Physiography	The relative position of the site within the land should be indicated. The position affects the hydrological conditions of the site. See more in the Guidelines for Soil Description issued by the FAO: figure 2	http://w3id.org/glosis/model/siteplot/physiographyProperty
rockOutcropsCoverProperty	Rock Outcrops Cover	Recommended classes of percentage of surface cover and of average distance between rock outcrops. See more in Guidelines for Soil Description issued by the FAO: table 14,1	http://w3id.org/glosis/model/siteplot/rockOutcropsCoverProperty
rockOutcropsDistanceProperty	Rock Outcrops Distance	Recommended classes of percentage of surface cover and of average distance between rock outcrops. See more in Guidelines for Soil Description issued by the FAO: table 14,2	http://w3id.org/glosis/model/siteplot/rockOutcropsDistanceProperty
slopeFormProperty	Slope Form	The slope form refers to the general shape of the slope in both the vertical and horizontal directions. See more in Guidelines for Soil Description issued by the FAO: table 6	http://w3id.org/glosis/model/siteplot/slopeFormProperty
slopeGradientClassProperty	Slope Gradient Class	Slope gradient classes measured on the percentage of slope. See more in Guidelines for Soil Description issued by the FAO: table 7	http://w3id.org/glosis/model/siteplot/slopeGradientClassProperty
slopePathwaysProperty	Slope Pathways	The slope form refers to the general shape of the slope in both the vertical and horizontal directions. See more in guidelines for Soil Description issued by the FAO: figure 3	http://w3id.org/glosis/model/siteplot/slopePathwaysProperty
surfaceAgeProperty	Surface Age	The age of the landscape is important information from which the possible duration of the occurrence of soil formation processes can be derived. See more in guidelines for Soil Description issued by the FAO: table 13	http://w3id.org/glosis/model/siteplot/surfaceAgeProperty
VegetationClassProperty	Vegetation Class	Classification of vegetation.See more in Guidelines for Soil Description issued by the FAO: table 11	http://w3id.org/glosis/model/siteplot/vegetationClassProperty
weatherConditionsCurrentProperty	Weather Current	Codes for weather conditions.See in Guidelines for Soil Description issued by the FAO: table 2	http://w3id.org/glosis/model/siteplot/weatherConditionsCurrentProperty
weatherConditionsPastProperty	Weather Past	Codes for weather conditions.See in Guidelines for Soil Description issued by the FAO: table 2	http://w3id.org/glosis/model/siteplot/weatherConditionsPastProperty
weatheringRockProperty	Weathering Rock	Classification of weathering of coarse fragments. See more in Guidelines for Soil Description issued by the FAO: table 29	http://w3id.org/glosis/model/siteplot/weatheringRockProperty
profileDescriptionStatusProperty	Profile Description Status	Soil profile description status. See more in Guidelines for Soil Description issued by the FAO: table 1	http://w3id.org/glosis/model/profile/profileDescriptionStatusProperty
biologicalAbundanceProperty	Biological Abundance	Classification of the abundance of biological activity. See more in Guidelines for Soil Description issued by the FAO: table 81	http://w3id.org/glosis/model/layerhorizon/biologicalAbundanceProperty
biologicalFeaturesProperty	Biological Features	Examples of biological features. See more in Guidelines for Soil Description issued by the FAO: table 82	http://w3id.org/glosis/model/layerhorizon/biologicalFeaturesProperty
boundaryDistinctnessProperty	Boundary Distinctness	The distinctness of the boundary refers to the thickness of the zone in which the horizon boundary can be located without being in one of the adjacent horizons. See more in the  Guidelines for Soil Description issued by the FAO: table 24.1	http://w3id.org/glosis/model/layerhorizon/boundaryDistinctnessProperty
boundaryTopographyProperty	Boundary Topography	Classification of horizon boundaries by topography. See more in Guidelines for Soil Description issued by the FAO: table 24,2	http://w3id.org/glosis/model/layerhorizon/boundaryTopographyProperty
bulkDensityMineralProperty	Bulk Density Mineral	Field determinations of bulk density may be obtained by estimating the force required to push a knife into a soil horizon exposed at a field moist pit wall. See more in Guidelines for Soil Description issued by the FAO: table 58	http://w3id.org/glosis/model/layerhorizon/bulkDensityMineralProperty
bulkDensityPeatProperty	Bulk Density Peat	Bulk density and volume of solids of organic soils can be estimated after the decomposition stage or the extent of peat drainage. See more in guidelines for Soil Description issued by the FAO: table 59,3	http://w3id.org/glosis/model/layerhorizon/bulkDensityPeatProperty
carbonatesContentProperty	Carbonates Content	Classes for the reaction of carbonates in the soil matrix. See more in Guidelines for Soil Description issued by the FAO: table 38	http://w3id.org/glosis/model/layerhorizon/carbonatesContentProperty
carbonatesFormsProperty	Carbonates Forms	The forms of secondary carbonates in soils are diverse and are considered to be informative for diagnostics of soil genesis. See more in guidelines for Soil Description issued by the FAO: table 39	http://w3id.org/glosis/model/layerhorizon/carbonatesFormsProperty
cementationContinuityProperty	Cementation Continuity	The occurrence of cementation or compaction in pans or otherwise is described according to its nature, continuity, structure, agent and degree. See more in the guidelines for Soil Description issued by the FAO: table 69	http://w3id.org/glosis/model/layerhorizon/cementationContinuityProperty
cementationDegreeProperty	Cementation Degree	The classification of the degree of cementation/compaction. See more in Guidelines for Soil Description issued by the FAO: table 72	http://w3id.org/glosis/model/layerhorizon/cementationDegreeProperty
cementationFabricProperty	Cementation Fabric	Classification of the fabric of the cemented/compacted layer. See more in Guidelines for Soil Description issued by the FAO: table 70	http://w3id.org/glosis/model/layerhorizon/cementationFabricProperty
cementationNatureProperty	Cementation Nature	Classification of the nature of cementation/compaction. See more in Guidelines for Soil Description issued by the FAO: table 71	http://w3id.org/glosis/model/layerhorizon/cementationNatureProperty
coatingContrastProperty	Coating Contrast	Classification of the contrast of coatings. See more in Guidelines for Soil Description issued by the FAO: table 65	http://w3id.org/glosis/model/layerhorizon/coatingContrastProperty
coatingFormProperty	Coating Form	Classification of the form of coatings. See more in Guidelines for Soil Description issued by the FAO: table 67	http://w3id.org/glosis/model/layerhorizon/coatingFormProperty
coatingLocationProperty	Coating Location	Classification of the location of coatings and clay accumulation. See more in Guidelines for Soil Description issued by the FAO: table 68	http://w3id.org/glosis/model/layerhorizon/coatingLocationProperty
coatingNatureProperty	Coating Nature	Classification of the nature of coatings. See more in Guidelines for Soil Description issued by the FAO: table 66	http://w3id.org/glosis/model/layerhorizon/coatingNatureProperty
consistenceDryProperty	Consistence Dry	The consistence when dry is determined by breaking an air-dried mass of soil between thumb and forefinger or in the hand. See more in the guidelines for Soil Description issued by the FAO: table 53	http://w3id.org/glosis/model/layerhorizon/consistenceDryProperty
consistenceMoistProperty	Consistence Moist	Guidelines for Soil Description issued by the FAO: table 54;Consistence when moist is determined by attempting to crush a mass of moist or slightly moist soil material. See more in Guidelines for Soil Description issued by the FAO: table 54	http://w3id.org/glosis/model/layerhorizon/consistenceMoistProperty
fragmentsClassProperty	Fragments Class	Horizon properties encountered in a global data compilation programme. See more in ISRIC Report 2019/01: Tier 1 and Tier 2 data in the context of the federated Global Soil Information System. Appendix 3	http://w3id.org/glosis/model/layerhorizon/fragmentsClassProperty
gypsumContentProperty	Gypsum Content	Where more readily soluble salts are absent, gypsum can be estimated in the field by measurements of electrical conductivity. More in the guidelines for Soil Description issued by the FAO: table 40	http://w3id.org/glosis/model/layerhorizon/gypsumContentProperty
gypsumFormsProperty	Gypsum Forms	The forms of secondary gypsum in soils are diverse and are considered to be informative for diagnostics of soil genesis. See more information in the Guidelines for Soil Description issued by the FAO: table 41	http://w3id.org/glosis/model/layerhorizon/gypsumFormsProperty
mineralConcColourProperty	Mineral Conc Colour	The general colour names are usually sufficient to describe the colour of the nodules (similar to mottles) or of artefacts. See more in Guidelines for Soil Description issued by the FAO: table 78	http://w3id.org/glosis/model/layerhorizon/mineralConcColourProperty
mineralConcHardnessProperty	Mineral Conc Hardness	Classification of the hardness of mineral concentrations. More in the Guidelines for Soil Description issued by the FAO: table 76	http://w3id.org/glosis/model/layerhorizon/mineralConcHardnessProperty
mineralConcKindProperty	Mineral Conc Kind	Classification of the kinds of mineral concentrations. See more in guidelines for Soil Description issued by the FAO: table 74	http://w3id.org/glosis/model/layerhorizon/mineralConcKindProperty
mineralConcNatureProperty	Mineral Conc Nature	Mineral concentrations are described according to the composition or impregnating substance.See more in Guidelines for Soil Description issued by the FAO: 77	http://w3id.org/glosis/model/layerhorizon/mineralConcNatureProperty
mineralConcShapeProperty	Mineral Conc Shape	Classification of the size and shape of mineral concentrations. See more in Guidelines for Soil Description issued by the FAO: table 75,2	http://w3id.org/glosis/model/layerhorizon/mineralConcShapeProperty
mineralConcSizeeProperty	Mineral Conc Size	Classification of mineral concentrations based on size. See more in Guidelines for Soil Description issued by the FAO: table 75,1	http://w3id.org/glosis/model/layerhorizon/mineralConcSizeProperty
mineralConcVolumeProperty	Mineral Conc Volume	The mineral concentrations are described according to their abundance, kind, size, shape, hardness, nature and colour. See more onGuidelines for Soil Description issued by the FAO: table 73	http://w3id.org/glosis/model/layerhorizon/mineralConcVolumeProperty
mineralFragmentsProperty	Mineral Fragments	Codes for primary mineral fragments. See more in Guidelines for Soil Description issued by the FAO: table 30	http://w3id.org/glosis/model/layerhorizon/mineralFragmentsProperty
mottlesAbundanceProperty	Mottles Abundance	The abundance of mottles is described in terms of classes indicating the percentage of the exposed surface that the mottles occupy. See more in the Guidelines for Soil Description issued by the FAO: table 32	http://w3id.org/glosis/model/layerhorizon/mottlesAbundanceProperty
mottlesBoundaryClassificationProperty	Mottles Boundary Classification	The boundary between mottle and matrix is described as the thickness of the zone within which the colour transition can be located without being in either the mottle or matrix. See more in guidelines for Soil Description issued by the FAO: table 35	http://w3id.org/glosis/model/layerhorizon/mottlesBoundaryClassificationProperty
mottlesContrastProperty	Mottles Contrast	The colour contrast between mottles and soil matrix. See more in Guidelines for Soil Description issued by the FAO: table 34	http://w3id.org/glosis/model/layerhorizon/mottlesContrastProperty
mottlesSizeProperty	Mottles Size	The individual classes of the mottle nodules according to their diameter size. See more in the guidelines for Soil Description issued by the FAO: table 33	http://w3id.org/glosis/model/layerhorizon/mottlesSizeProperty
peatDecompostionProperty	Peat Decompostion	In most organic layers of rocks the determination of the texture class is done by estimating of the degree of decomposition and humification of the organic material.See more in Guidelines for Soil Description issued by the FAO: table 31	http://w3id.org/glosis/model/layerhorizon/peatDecompostionProperty
peatDrainageProperty	Peat Drainage	Bulk density and volume of solids of organic soils may be estimated after the decomposition stage or the extent of peat drainage. More information is in the guidelines for Soil Description issued by the FAO: table 59,1	http://w3id.org/glosis/model/layerhorizon/peatDrainageProperty
peatVolumeProperty	Peat Volume	Field estimation of volume of solids and bulk density of peat soils. See more in Guidelines for Soil Description issued by the FAO: table 59,2	http://w3id.org/glosis/model/layerhorizon/peatVolumeProperty
plasticityProperty	Plasticity	Plasticity is the ability of soil material to change shape continuously under the influence of an applied stress and to retain the compressed shape on removal of stress. See more in Guidelines for Soil Description issued by the FAO: Guidelines for Soil Description issued by the FAO: table 56	http://w3id.org/glosis/model/layerhorizon/plasticityProperty
poresAbundanceProperty	Pores Abundance	Classification of abundance of pores. See more in Guidelines for Soil Description issued by the FAO: table 63	http://w3id.org/glosis/model/layerhorizon/poresAbundanceProperty
poresSizeProperty	Pores Size	Voids include all empty spaces in the soil. They are related to the arrangement of the primary soil constituents, rooting patterns, burrowing of animals or any other soil-forming processes, such as cracking, translocation and leaching. See more in Guidelines for Soil Description issued by the FAO: table 62	http://w3id.org/glosis/model/layerhorizon/poresSizeProperty
porosityClassProperty	Porosity Class	The porosity is an indication of the total volume of voids discernible with a ×10 hand-lens measured by area and recorded as the percentage of the surface occupied by pores. See more in guidelines for Soil Description issued by the FAO: table 60	http://w3id.org/glosis/model/layerhorizon/porosityClassProperty
rootsAbundanceProperty	Roots Abundance	classification of the abundance of roots.. See more in Guidelines for Soil Description issued by the FAO: table 80	http://w3id.org/glosis/model/layerhorizon/rootsAbundanceProperty
saltContentProperty	Salt Content	Classification of salt content of soil. See more in Guidelines for Soil Description issued by the FAO: table 42	http://w3id.org/glosis/model/layerhorizon/saltContentProperty
sandyTextureProperty	Sandy Texture	Relation of constituents of fine earth by size, defining textural classes and sand subclasses. See more in Guidelines for Soil Description issued by the FAO: figure 4,3	http://w3id.org/glosis/model/layerhorizon/sandyTextureProperty
stickinessProperty	Stickiness	Stickiness is the quality of adhesion of the soil material to other objects determined by noting the adherence of soil material when it is pressed between thumb and finger. See more in the Guidelines for Soil Description issued by the FAO: table 55	http://w3id.org/glosis/model/layerhorizon/stickinessProperty
structureGradeProperty	Structure Grade	Guidelines for Soil Description issued by the FAO: table 47; Classification of structure of pedal soil materials. See more in Guidelines for Soil Description issued by the FAO: table 47	http://w3id.org/glosis/model/layerhorizon/structureGradeProperty
structureSizeProperty	Structure Size	Size classes for soil structure types. See more in guidelines for Soil Description issued by the FAO: table 50	http://w3id.org/glosis/model/layerhorizon/structureSizeProperty
VoidsClassificationProperty	Voids Classification	Voids include all empty spaces in the soil. They are related to the arrangement of the primary soil constituents, rooting patterns, burrowing of animals or any other soil-forming processes, such as cracking, translocation and leaching. See more in Guidelines for Soil Description issued by the FAO: table 61	http://w3id.org/glosis/model/layerhorizon/voidsClassificationProperty
voidsDiameterProperty	Voids Diameter	Voids include all empty spaces in the soil. They are related to the arrangement of the primary soil constituents, rooting patterns, burrowing of animals or any other soil-forming processes, such as cracking, translocation and leaching. See more in Guidelines for Soil Description issued by the FAO: table 62	http://w3id.org/glosis/model/layerhorizon/voidsDiameterProperty
\.


--
-- TOC entry 5257 (class 0 OID 55548951)
-- Dependencies: 265
-- Data for Name: property_num; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.property_num (property_num_id, property_name, definition, uri) FROM stdin;
ACIEXC	Acidity - exchangeable	Exchangeable acidity represents the amount of hydrogen (H⁺) and aluminum (Al³⁺) ions adsorbed onto soil particles that can be exchanged with the soil solution. It is a key factor in determining soil liming requirements and improving nutrient availability in acidic soils. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Aciexc
ALUEXC	Aluminium (Al) exchangeable	Aluminium ions bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Aluexc
ALUTOT	Aluminium (Al) total	Total concentration of aluminium in the soil, including both soluble and insoluble forms, typically measured after complete digestion of the soil sample.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Alutot
AVAVOL	Available water capacity - volumetric (FC to WP)	Available water capacity (AWC) measures the volume of water soil can retain between field capacity and the permanent wilting point. It represents the water accessible to plants for uptake. High AWC supports better plant growth, while low AWC may necessitate irrigation. Source: USDA NRCS.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Avavol
BASCAL	Base saturation - calculated	Base saturation represents the percentage of the soil's cation exchange capacity (CEC) occupied by basic cations such as calcium (Ca²⁺), magnesium (Mg²⁺), potassium (K⁺), and sodium (Na⁺). Higher base saturation typically correlates with higher fertility and a greater ability to supply essential nutrients to plants. This parameter also influences soil pH buffering capacity. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Bascal
BOREXT	Boron (B) - extractable	Boron bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Borext
BORTOT	Boron (B) - total	Total boron includes all boron forms in soil, crucial for plant cell wall formation and reproductive processes. Deficiency can impair growth, while toxicity is a risk in arid soils or with excessive irrigation. Source: Havlin et al. (2014).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Bortot
BULDFINE	Bulk Density of the fine earth fraction	This parameter measures the bulk density of the soil fraction smaller than 2 mm (excluding rocks and coarse fragments). It is used to assess the physical properties of soil related to root growth, water movement, and compaction. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-BulDfine
CAD	Cadmium (Cd)	Cadmium is a heavy metal present in trace amounts in soils, often introduced through industrial pollution or phosphate fertilizers. It is toxic to plants, animals, and humans even at low concentrations. Monitoring cadmium levels is crucial to ensure soil safety and reduce contamination risks in the food chain. Source: Sparks, D.L. (2003).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Cad
CALEXC	Calcium (Ca++) - exchangeable	Calcium bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Calexc
CALEXT	Calcium (Ca++) - extractable	Calcium bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Calext
CALTOT	Calcium (Ca++) - total	Total calcium in soil includes all forms, from exchangeable calcium to calcium in minerals. It is essential for plant cell wall structure, enzyme activation, and soil aggregation. Calcium levels influence soil pH and nutrient availability. Source: Havlin et al. (2014).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Caltot
CEC	Cation exchange capacity (CEC)	CEC measures the soil’s ability to hold and exchange positively charged ions (cations). It is a critical indicator of soil fertility, as higher CEC values imply greater capacity to retain essential nutrients like calcium, magnesium, and potassium. Clayey and organic-rich soils typically exhibit higher CEC. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-CEC
COPEXT	Copper (Cu) - extractable	Copper bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Copext
COPTOT	Copper (Cu) - total	Total copper comprises all soil copper, including bound and free forms. Copper is vital for plant enzyme activation and metabolic processes. Deficiencies can lead to reduced growth and yields, while excess copper may inhibit root development. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Coptot
ECEC	Cation exchange capacity effective (ECEC)	ECEC is the sum of exchangeable cations in soil at its natural pH. It provides a measure of the soil’s fertility under acidic conditions, as it considers both base cations and exchangeable aluminum. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-ECEC
ELECCOND	Electrical conductivity	Electrical conductivity (EC) measures the ability of soil to conduct an electrical current, which is directly related to the concentration of soluble salts. It is an essential indicator of soil salinity and is used to assess soil's suitability for crop growth. High EC levels can reduce plant water uptake and affect germination, while low levels indicate low salinity and better soil health. Source: USDA NRCS.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Eleccond
HYDEXC	Hydrogen (H+) - exchangeable	Hydrogen ions bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Hydexc
IROEXT	Iron (Fe) - extractable	Iron bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Iroext
IROTOT	Iron (Fe) - total	Total iron includes all iron forms in the soil, from soluble ferrous iron (Fe²⁺) to insoluble ferric iron (Fe³⁺). Iron is essential for plant chlorophyll synthesis and various enzymatic reactions. Deficiency, often seen in alkaline soils, results in chlorosis, while excessive iron can cause toxicity in acidic soils. Source: Soil Chemistry by Bohn et al.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Irotot
MAGEXC	Magnesium (Mg++) - exchangeable	Magnesium bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Magexc
MAGEXT	Magnesium (Mg) - extractable	Magnesium bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Magext
MAGTOT	Magnesium (Mg) - total	Total magnesium in soil includes exchangeable, soluble, and mineral-bound forms. Magnesium is essential for chlorophyll synthesis, enzyme activation, and nutrient transport in plants. Its availability is influenced by soil pH and texture. Source: Havlin et al. (2014).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Magtot
MANTOT	Manganese (Mn) - total	Total manganese refers to all forms of manganese in the soil, which is critical for photosynthesis, enzyme activation, and nitrogen metabolism in plants. Manganese deficiencies or toxicities are influenced by soil pH, with deficiencies occurring in high-pH soils and toxicities in low-pH, waterlogged soils.  Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Mantot
MANEXT	Manganese (Mn) - extractable	Manganese bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Manext
MOL	Molybdenum	Molybdenum is a micronutrient essential for plant enzymes involved in nitrogen fixation and nitrate reduction. Deficiency, often observed in acidic soils, can lead to stunted growth and poor nitrogen utilization. Its availability increases with higher pH, making liming a common solution for molybdenum deficiencies. Source: Havlin et al. (2014).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Mol
PHOEXT	Phosphorus (P) - extractable	Phosphorus bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Phoext
PHOTOT	Phosphorus (P) - total	Total phosphorus includes all forms of phosphorus in the soil, both organic and inorganic. While only a fraction is plant-available, total phosphorus serves as a long-term reserve for crop nutrition. Adequate phosphorus levels are crucial for energy transfer, photosynthesis, and root development in plants. Source: Soil Chemistry by Bohn et al.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Photot
POTEXC	Potassium (K+) - exchangeable	Potassium bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Potexc
POTEXT	Potassium (K) - extractable	Potassium bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Potext
POTTOT	Potassium (K) - total	Total potassium includes all forms of potassium in soil, such as mineral-bound, exchangeable, and water-soluble potassium. It plays a vital role in plant growth by regulating water balance, enzyme activation, and photosynthesis. While only a fraction of total potassium is readily available to plants, it serves as a reserve to replenish exchangeable potassium over time. Adequate potassium levels improve crop yield, quality, and resistance to stress. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Pottot
SODEXP	Sodium (Na+) - exchangeable	Sodium bound to exchange surfaces in the soil such as clay minerals and organic matter that can be released to the soil solution upon exchange	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Sodexp
SODEXT	Sodium (Na) - extractable	Sodium bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Sodext
SODTOT	Sodium (Na) - total	Total sodium includes all sodium present in soil, both soluble and bound. Excess sodium can lead to sodicity, which disrupts soil structure, reduces permeability, and impairs plant growth. Monitoring sodium levels is crucial for managing soil salinity in arid and irrigated regions. Source: Bohn, H.L., et al. (2001). Soil Chemistry.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Sodtot
SULEXT	Sulfur (S) - extractable	Sulfur bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Sulext
SULTOT	Sulfur (S) - total	Total sulfur in soil includes both organic and inorganic forms, such as sulfates and sulfur in organic matter. Sulfur is essential for protein synthesis and enzyme functions in plants. Deficiency leads to stunted growth and yellowing of leaves. Total sulfur provides insight into the soil's potential to release plant-available sulfur over time, critical for sustaining crop health. Source: Havlin, J.L., et al. (2014). Soil Fertility and Fertilizers.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Sultot
ZINEXT	Zinc (Zn) - extractable	Zinc bound to the soil matrix but that can be released into the soil solution (i.e. become bio-available)	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Zinext
ZIN	Zinc (Zn)	Zinc is a micronutrient essential for plant enzyme systems, protein synthesis, and growth regulation. Deficiency is common in calcareous soils and results in stunted growth and chlorosis. Zinc fertilizers or soil pH adjustments can address deficiencies. Source: Havlin et al. (2014).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Zin
CARINORG	Carbon (C) - inorganic	Inorganic carbon in soil primarily consists of carbonates like calcium carbonate and magnesium carbonate. It contributes to soil pH buffering and is a significant feature of arid and calcareous soils. Excess inorganic carbon can immobilize certain nutrients, requiring careful management in agricultural systems. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Carinorg
CARORG	Carbon (C) - organic	Organic carbon refers to the carbon component of soil organic matter, derived from decomposed plant and microbial residues. It serves as a key energy source for soil microbes and influences nutrient cycling, soil structure, and water retention. Organic carbon is a primary indicator of soil fertility and health. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Carorg
CARTOT	Carbon (C) - total	Total carbon in soil includes both organic carbon (from plant and microbial residues) and inorganic carbon (primarily carbonates). It is a fundamental component of soil organic matter, influencing soil fertility, structure, and water retention. High carbon levels are associated with better soil health and productivity. Source: USDA NRCS.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Cartot
COAFRA	Coarse Fragments		http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-CoaFra
GYP	Gypsum content - weight	The gypsum content, expressed as weight, refers to the soil’s calcium sulfate levels. Gypsum improves soil structure, alleviates sodicity, and enhances water infiltration. It is commonly applied to saline-sodic soils for reclamation. Source: FAO Soil Bulletin.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Gyp
HYDCOND	Hydraulic conductivity	Hydraulic conductivity refers to the rate at which water moves through soil pores under a unit hydraulic gradient. It reflects the soil's ability to transmit water, influenced by texture, structure, and porosity. Soils with high hydraulic conductivity, like sandy soils, allow rapid water movement, while clayey soils exhibit slower water flow. This property is critical for understanding water infiltration, drainage, and irrigation management. Source: Brady, N.C., & Weil, R.R. (2017). The Nature and Properties of Soils.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Hydcond
NITTOT	Nitrogen (N) - total	Total nitrogen encompasses all nitrogen forms in soil, including organic nitrogen in humus and inorganic nitrogen such as ammonium (NH₄⁺) and nitrate (NO₃⁻). Nitrogen is essential for plant growth, being a vital component of amino acids, proteins, and chlorophyll. Total nitrogen is a key indicator of soil fertility and its capacity to sustain long-term crop productivity. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Nittot
ORGMAT	Organic matter	Soil organic matter is composed of decomposed plant and animal residues, living soil organisms, and humus. It improves soil structure, water retention, nutrient supply, and microbial activity, making it critical for sustainable agriculture and soil health. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Orgmat
PH	pH - Hydrogen potential	Soil pH measures the concentration of hydrogen ions (H⁺) in the soil solution, indicating its acidity or alkalinity on a scale from 1 to 14. Neutral soils have a pH of 7, while values below 7 are acidic and above are alkaline. Soil pH significantly affects nutrient availability, microbial activity, and plant growth. For instance, nutrients like phosphorus are most available in a pH range of 6 to 7. Lime or sulfur applications can adjust soil pH to optimize conditions for crops. Source: USDA Natural Resources Conservation Service (NRCS).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-pH
PHORET	Phosphorus (P) - retention	Phosphorus retention measures a soil's capacity to adsorb and hold phosphorus, influenced by soil texture, pH, and mineralogy. While high retention reduces leaching, it may also limit phosphorus availability to plants. Understanding phosphorus retention helps optimize fertilization and minimize environmental impacts. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Phoret
POR	Porosity	Porosity refers to the percentage of soil volume occupied by pores or voids, which hold air and water. It directly impacts water infiltration, drainage, and root growth. Soils with high porosity are better suited for crop cultivation, as they provide good aeration and water availability. Source: Brady & Weil (2017).	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Por
SOLSAL	Soluble salts	Soluble salts refer to dissolved salts in the soil solution, primarily composed of sodium, calcium, magnesium, chloride, and sulfate ions. Excessive soluble salts cause salinity, which can impair plant water uptake and lead to osmotic stress. EC testing helps monitor salinity levels for effective management. Source: Soil Science Society of America.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Solsal
CCETOT	Calcium carbonate equivalent - total	The total calcium carbonate equivalent measures the full capacity of soil to neutralize acidity, considering all forms of carbonate and bicarbonate minerals. It is essential for managing soil pH and nutrient availability in acidic soils. Source: FAO Soil Bulletin.	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Ccetot
TEXTCLAY	Clay texture fraction	\N	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textclay
TEXTSAND	Sand texture fraction	\N	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textsand
TEXTSILT	Silt texture fraction	\N	http://w3id.org/glosis/model/codelists/physioChemicalPropertyCode-Textsilt
BULDWHOLE	Bulk Density whole soil	\N	http://w3id.org/glosis/model/layerhorizon/bulkDensityWholeSoilProperty
\.


--
-- TOC entry 5258 (class 0 OID 55548957)
-- Dependencies: 266
-- Data for Name: result_desc_element; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.result_desc_element (element_id, property_desc_id, category_desc_id) FROM stdin;
\.


--
-- TOC entry 5259 (class 0 OID 55548963)
-- Dependencies: 267
-- Data for Name: result_desc_plot; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.result_desc_plot (plot_id, property_desc_id, category_desc_id) FROM stdin;
\.


--
-- TOC entry 5260 (class 0 OID 55548969)
-- Dependencies: 268
-- Data for Name: result_desc_profile; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.result_desc_profile (profile_id, property_desc_id, category_desc_id) FROM stdin;
\.


--
-- TOC entry 5261 (class 0 OID 55548975)
-- Dependencies: 269
-- Data for Name: result_desc_surface; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.result_desc_surface (surface_id, property_desc_id, category_desc_id) FROM stdin;
\.


--
-- TOC entry 5232 (class 0 OID 55548811)
-- Dependencies: 237
-- Data for Name: result_num; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.result_num (observation_num_id, specimen_id, value) FROM stdin;
\.


--
-- TOC entry 5262 (class 0 OID 55548981)
-- Dependencies: 270
-- Data for Name: result_spectral; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.result_spectral (result_spectral_id, observation_num_id, procedure_model_id, value) FROM stdin;
\.


--
-- TOC entry 5236 (class 0 OID 55548837)
-- Dependencies: 242
-- Data for Name: site; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.site (site_id, geom) FROM stdin;
\.


--
-- TOC entry 5265 (class 0 OID 55548988)
-- Dependencies: 273
-- Data for Name: soil_map; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_map (soil_map_id, name, description, scale_denominator, spatial_resolution_m, publication_date, remarks, geom) FROM stdin;
\.


--
-- TOC entry 5267 (class 0 OID 55548996)
-- Dependencies: 275
-- Data for Name: soil_mapping_unit; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_mapping_unit (mapping_unit_id, category_id, explanation, remarks, geom) FROM stdin;
\.


--
-- TOC entry 5268 (class 0 OID 55549002)
-- Dependencies: 276
-- Data for Name: soil_mapping_unit_category; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_mapping_unit_category (category_id, soil_map_id, parent_category_id, name, description, legend_order, symbol, colour_rgb, remarks) FROM stdin;
\.


--
-- TOC entry 5271 (class 0 OID 55549012)
-- Dependencies: 279
-- Data for Name: soil_mapping_unit_profile; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_mapping_unit_profile (mapping_unit_id, profile_id, is_representative, remarks) FROM stdin;
\.


--
-- TOC entry 5272 (class 0 OID 55549019)
-- Dependencies: 280
-- Data for Name: soil_typological_unit; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_typological_unit (typological_unit_id, name, classification_scheme, classification_version, description, remarks) FROM stdin;
\.


--
-- TOC entry 5273 (class 0 OID 55549025)
-- Dependencies: 281
-- Data for Name: soil_typological_unit_mapping_unit; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_typological_unit_mapping_unit (typological_unit_id, mapping_unit_id, percentage, remarks) FROM stdin;
\.


--
-- TOC entry 5274 (class 0 OID 55549032)
-- Dependencies: 282
-- Data for Name: soil_typological_unit_profile; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.soil_typological_unit_profile (typological_unit_id, profile_id, is_typical, remarks) FROM stdin;
\.


--
-- TOC entry 5233 (class 0 OID 55548814)
-- Dependencies: 238
-- Data for Name: specimen; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.specimen (specimen_id, element_id, specimen_prep_process_id, code) FROM stdin;
\.


--
-- TOC entry 5276 (class 0 OID 55549041)
-- Dependencies: 284
-- Data for Name: specimen_prep_process; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.specimen_prep_process (specimen_prep_process_id, specimen_transport_id, specimen_storage_id, definition) FROM stdin;
\.


--
-- TOC entry 5279 (class 0 OID 55549051)
-- Dependencies: 287
-- Data for Name: specimen_storage; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.specimen_storage (specimen_storage_id, label, definition) FROM stdin;
\.


--
-- TOC entry 5281 (class 0 OID 55549059)
-- Dependencies: 289
-- Data for Name: specimen_transport; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.specimen_transport (specimen_transport_id, label, definition) FROM stdin;
\.


--
-- TOC entry 5283 (class 0 OID 55549067)
-- Dependencies: 291
-- Data for Name: spectral_sample; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.spectral_sample (spectral_sample_id, specimen_id) FROM stdin;
\.


--
-- TOC entry 5284 (class 0 OID 55549073)
-- Dependencies: 292
-- Data for Name: spectrum; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.spectrum (spectrum_id, spectral_sample_id, procedure_spectrometer_id, spectrum) FROM stdin;
\.


--
-- TOC entry 5286 (class 0 OID 55549081)
-- Dependencies: 294
-- Data for Name: spectrum_x_result_spectral; Type: TABLE DATA; Schema: soil_data; Owner: carva014
--

COPY soil_data.spectrum_x_result_spectral (result_spectral_id, spectrum_id) FROM stdin;
\.


--
-- TOC entry 5287 (class 0 OID 55549084)
-- Dependencies: 295
-- Data for Name: translate; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.translate (table_name, column_name, language_code, string, translation) FROM stdin;
\.


--
-- TOC entry 5288 (class 0 OID 55549090)
-- Dependencies: 296
-- Data for Name: unit_of_measure; Type: TABLE DATA; Schema: soil_data; Owner: sis
--

COPY soil_data.unit_of_measure (unit_of_measure_id, unit_name, uri) FROM stdin;
cm/h	Centimetre per hour	http://qudt.org/vocab/unit/CentiM-PER-HR
%	Percent	http://qudt.org/vocab/unit/PERCENT
cmol/kg	Centimole per kilogram	http://qudt.org/vocab/unit/CentiMOL-PER-KiloGM
dS/m	Decisiemens per metre	http://qudt.org/vocab/unit/DeciS-PER-M
g/kg	Gram per kilogram	http://qudt.org/vocab/unit/GM-PER-KiloGM
kg/dm³	Kilogram per cubic decimetre	http://qudt.org/vocab/unit/KiloGM-PER-DeciM3
pH	Acidity	http://qudt.org/vocab/unit/PH
m³/100 m³	Cubic metre per one hundred cubic metre	http://w3id.org/glosis/model/unit/M3-PER-HundredM3
mg/kg	Miligram per kilogram (also ppm)	http://qudt.org/vocab/unit/MilliGM-PER-KiloGM
cmol/L	Centimole per litre	https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/centimolePerLitre
g/hg	Gram per hectogram	https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf/gramPerHectogram
t/(ha·a)	Tonne per hectare per year	https://qudt.org/vocab/unit/TONNE-PER-HA-YR
class	Categorical	https://qudt.org/vocab/unit/class
dimensionless	No dimension	https://qudt.org/vocab/unit/dimensionless
\.


--
-- TOC entry 5289 (class 0 OID 55549096)
-- Dependencies: 297
-- Data for Name: class; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.class (mapset_id, value, code, label, color, opacity, publish) FROM stdin;
\.


--
-- TOC entry 5290 (class 0 OID 55549102)
-- Dependencies: 298
-- Data for Name: country; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.country (country_id, iso3_code, gaul_code, color_code, ar, en, es, fr, pt, ru, zh, status, disp_area, capital, continent, un_reg, unreg_note, continent_custom) FROM stdin;
IN	IND	115	IND	الهند	India	India	Inde	Índia	Индия	印 度	Member State	NO	New Delhi	Asia	Southern Asia		Asia
CU	CUB	63	CUB	كوبا	Cuba	Cuba	Cuba	Cuba	Куба	古 巴	Member State	NO	Havana	Americas	Caribbean		Northern America
ZM	ZMB	270	ZMB	زامبيا	Zambia	Zambia	Zambie	Zâmbia	Замбия	赞比亚	Member State	NO	Lusaka	Africa	Eastern Africa		Africa
KE	KEN	133	KEN	كينيا	Kenya	Kenya	Kenya	Quênia	Кения	肯尼亚	Member State	NO	Nairobi	Africa	Eastern Africa		Africa
MG	MDG	150	MDG	مدغشقر	Madagascar	Madagascar	Madagascar	Madagáscar	Мадагаскар	马达加斯加	Member State	NO	Antananarivo	Africa	Eastern Africa		Africa
SD	SDN	6	   	السودان	Sudan	Sudán	Soudan	Sudão	Судан	苏 丹	Member State	NO	Khartoum	Africa	Northern Africa		Africa
KP	PRK	67	PRK	جمهورية كوريا الديمقراطية الشعبية	Democratic People's Republic of Korea	República Popular Democrática de Corea	République populaire démocratique de Corée	Coreia do Norte	Корейская Народно-Демократическая Республика	朝鲜民主主义人民共和国	Member State	NO	Pyongyang	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
RW	RWA	205	RWA	رواندا	Rwanda	Rwanda	Rwanda	Ruanda	Руанда	卢旺达	Member State	NO	Kigali	Africa	Eastern Africa		Africa
SO	SOM	226	SOM	الصومال	Somalia	Somalia	Somalie	Somália	Сомали	索马里	Member State	NO	Mogadishu	Africa	Eastern Africa		Africa
SC	SYC	220	SYC	سيشيل	Seychelles	Seychelles	Seychelles	Seychelles	Сейшельские Острова	塞舌尔	Member State	NO	Victoria	Africa	Eastern Africa		Africa
TZ	TZA	257	TZA	جمهورية تنزانيا المتحدة	United Republic of Tanzania	República Unida de Tanzanía	République-Unie de Tanzanie	Tanzânia	Объединенная Республика Танзания	坦桑尼亚联合共和国	Member State	NO	Dodoma	Africa	Eastern Africa		Africa
UG	UGA	253	UGA	أوغندا	Uganda	Uganda	Ouganda	Uganda	Уганда	乌干达	Member State	NO	Kampala	Africa	Eastern Africa		Africa
ZW	ZWE	271	ZWE	زمبابوي	Zimbabwe	Zimbabwe	Zimbabwe	Zimbabwe	Зимбабве	津巴布韦	Member State	NO	Harare	Africa	Eastern Africa		Africa
LU	LUX	148	LUX	لكسمبرغ	Luxembourg	Luxemburgo	Luxembourg	Luxemburgo	Люксембург	卢森堡	Member State	NO	Luxembourg	Europe	Western Europe		Europe
GL	GRL	98	DNK	غرينلاند	Greenland	Groenlandia	Groenland	Gronelândia	Гренландия	格陵兰	DK Self-Governing Territory	NO	Nuuk	Americas	Northern America	Not classified in the UN classification 2005	Northern America
MQ	MTQ	158	FRA	مارتينيك	Martinique	Martinica	Martinique	Martinica	Мартиника	马提尼克	FR Territory	NO	Fort-de-France	Americas	Caribbean		Northern America
JM	JAM	123	JAM	جامايكا	Jamaica	Jamaica	Jamaïque	Jamaica	Ямайка	牙买加	Member State	NO	Kingston	Americas	Caribbean		Northern America
VE	VEN	263	VEN	فنزويلا (جمهورية .. البوليفارية)	Venezuela (Bolivarian Republic of)	Venezuela (República Bolivariana de)	Venezuela (République bolivarienne du)	Venezuela	Венесуэла (Боливарианская Республика)	委内瑞拉 (玻利瓦尔共和国)	Member State	NO	Caracas	Americas	South America		South America
NE	NER	181	NER	النيجر	Niger	Níger	Niger	Níger	Нигер	尼日尔	Member State	NO	Niamey	Africa	Western Africa		Africa
IR	IRN	117	IRN	إيران	Iran (Islamic Republic of)	Irán (República Islámica del)	Iran (République islamique d')	Irã	Иран (Исламская Республика)	伊 朗(伊斯兰共和国)	Member State	NO	Tehran	Asia	Southern Asia		Asia
GW	GNB	105	GNB	غينيا - بيساو	Guinea-Bissau	Guinea-Bissau	Guinée-Bissau	Guiné-Bissau	Гвинея-Бисау	几内亚比绍	Member State	NO	Bissau	Africa	Western Africa		Africa
GM	GMB	90	GMB	غامبيا	Gambia	Gambia	Gambie	Gâmbia	Гамбия	冈比亚	Member State	NO	Banjul	Africa	Western Africa		Africa
ET	ETH	79	ETH	إثيوبيا	Ethiopia	Etiopía	Éthiopie	Etiópia	Эфиопия	埃塞俄比亚	Member State	NO	Addis-Ababa	Africa	Eastern Africa		Africa
ER	ERI	77	ERI	إريتريا	Eritrea	Eritrea	Érythrée	Eritreia	Эритрея	厄立特里亚	Member State	NO	Asmara	Africa	Eastern Africa		Africa
DJ	DJI	70	DJI	جيبوتي	Djibouti	Djibouti	Djibouti	Djibouti	Джибути	吉布提	Member State	NO	Djibouti	Africa	Eastern Africa		Africa
KM	COM	58	COM	جزر القمر	Comoros	Comoras	Comores	Comores	Коморские Острова	科摩罗	Member State	NO	Moroni	Africa	Eastern Africa		Africa
IO	IOT	38	GBR	المناطق البريطانية في المحيط الهندي	British Indian Ocean Territory	Territorio Británico del Océano Indico	Territoire britanique de l'Océan Indien	Território Britânico do Oceano Índico	Британская Территория в Индийском Океане	英辖印度洋海域	UK Territory	NO		Africa	Eastern Africa		Africa
NA	NAM	172	NAM	ناميبيا	Namibia	Namibia	Namibie	Namíbia	Намибия	纳米比亚	Member State	NO	Windhoek	Africa	Southern Africa		Africa
MR	MRT	159	MRT	موريتانيا	Mauritania	Mauritania	Mauritanie	Mauritânia	Мавритания	毛里塔尼亚	Member State	NO	Nouakchott	Africa	Western Africa		Africa
LR	LBR	144	LBR	ليبريا	Liberia	Liberia	Libéria	Libéria	Либерия	利比里亚	Member State	NO	Monrovia	Africa	Western Africa		Africa
TJ	TJK	239	TJK	طاجيكستان	Tajikistan	Tayikistán	Tadjikistan	Tajiquistão	Таджикистан	塔吉克斯坦	Member State	NO	Dushanbe	Asia	Central Asia		Asia
LS	LSO	142	LSO	ليسوتو	Lesotho	Lesotho	Lesotho	Lesoto	Лесото	莱索托	Member State	NO	Maseru	Africa	Southern Africa		Africa
ZA	ZAF	227	ZAF	جنوب أفريقيا	South Africa	Sudáfrica	Afrique du Sud	África do Sul	Южная Африка	南 非	Member State	NO	Pretoria (Adm.)	Africa	Southern Africa		Africa
SE	SWE	236	SWE	السويد	Sweden	Suecia	Suède	Suécia	Швеция	瑞 典	Member State	NO	Stockholm	Europe	Northern Europe		Europe
UZ	UZB	261	UZB	أوزبكستان	Uzbekistan	Uzbekistán	Ouzbékistan	Uzbequistão	Узбекистан	乌兹别克斯坦	Member State	NO	Tashkent	Asia	Central Asia		Asia
GE	GEO	92	GEO	جورجيا	Georgia	Georgia	Géorgie	Geórgia	Грузия	格鲁吉亚	Member State	NO	Tbilisi	Asia	Western Asia		Asia
CY	CYP	64	CYP	قبرص	Cyprus	Chipre	Chypre	Chipre	Кипр	塞浦路斯	Member State	NO	Nicosia	Asia	Western Asia		Asia
NP	NPL	175	NPL	نيبال	Nepal	Nepal	Népal	Nepal	Непал	尼泊尔	Member State	NO	Kathmandu	Asia	Southern Asia		Asia
NG	NGA	182	NGA	نيجيريا	Nigeria	Nigeria	Nigéria	Nigéria	Нигерия	尼日利亚	Member State	NO	Abuja	Africa	Western Africa		Africa
FO	FRO	82	DNK	جزر فيرويه	Faroe Islands	Islas Feroe	Îles Féroé	Ilhas Feroé	Фарерские острова	法罗群岛	DK Territory	NO	Tórshavn	Europe	Northern Europe		Europe
SN	SEN	217	SEN	السنغال	Senegal	Senegal	Sénégal	Senegal	Сенегал	塞内加尔	Member State	NO	Dakar	Africa	Western Africa		Africa
VA	VAT	110	VAT	الكرسي الرسولي	Holy See	Santa Sede	Saint-Siège	Vaticano	Святой Престол	教廷	The City of Vatican	NO		Europe	Southern Europe		Europe
HR	HRV	62	HRV	كرواتيا	Croatia	Croacia	Croatie	Croácia	Хорватия	克罗地亚	Member State	NO	Zagreb	Europe	Southern Europe		Europe
MT	MLT	156	MLT	مالطة	Malta	Malta	Malte	Malta	Мальта	马耳他	Member State	NO	Valletta	Europe	Southern Europe		Europe
ME	MNE	2647	MNE	الجبل الأسود	Montenegro	Montenegro	Monténégro	Montenegro	Черногория	黑山	Member State	NO	Podgorica	Europe	Southern Europe		Europe
EE	EST	78	EST	إستونيا	Estonia	Estonia	Estonie	Estónia	Эстония	爱沙尼亚	Member State	NO	Tallinn	Europe	Northern Europe		Europe
MK	MKD	241	MKD	جمهورية مقدونيا اليوغوسلافية السابقة	The former Yugoslav Republic of Macedonia	la ex República Yugoslava de Macedonia	l'ex-République yougoslave de Macédoine	Macedónia	бывшая югославская Республика Македония	前南斯拉夫的马其顿共和国	Member State	NO	Skopje	Europe	Southern Europe		Europe
GR	GRC	97	GRC	اليونان	Greece	Grecia	Grèce	Grécia	Греция	希 腊	Member State	NO	Athens	Europe	Southern Europe		Europe
BY	BLR	26	BLR	بيلاروس	Belarus	Belarús	Bélarus	Bielorrússia	Беларусь	白俄罗斯	Member State	NO	Minsk	Europe	Eastern Europe		Europe
PT	PRT	199	PRT	البرتغال	Portugal	Portugal	Portugal	Portugal	Португалия	葡萄牙	Member State	NO	Lisbon	Europe	Southern Europe		Europe
MW	MWI	152	MWI	ملاوي	Malawi	Malawi	Malawi	Malawi	Малави	马拉维	Member State	NO	Lilongwe	Africa	Eastern Africa		Africa
BN	BRN	40	BRN	برونى دار السلام	Brunei Darussalam	Brunei Darussalam	Brunéi Darussalam	Brunei	Бруней-Даруссалам	文莱达鲁萨兰国	Member State	NO	Bandar Seri Begawan	Asia	South-Eastern Asia		Asia
PH	PHL	196	PHL	الفلبين	Philippines	Filipinas	Philippines	Filipinas	Филиппины	菲律宾	Member State	NO	Manila	Asia	South-Eastern Asia		Asia
ID	IDN	116	IDN	إندونيسيا	Indonesia	Indonesia	Indonésie	Indonésia	Индонезия	印度尼西亚	Member State	NO	Jakarta	Asia	South-Eastern Asia		Asia
LT	LTU	147	LTU	ليتوانيا	Lithuania	Lituania	Lituanie	Lituânia	Литва	立陶宛	Member State	NO	Vilnius	Europe	Northern Europe		Europe
LV	LVA	140	LVA	لاتفيا	Latvia	Letonia	Lettonie	Letônia	Латвия	拉脱维亚	Member State	NO	Riga	Europe	Northern Europe		Europe
IS	ISL	114	ISL	آيسلندا	Iceland	Islandia	Islande	Islândia	Исландия	冰 岛	Member State	NO	Reykjavík	Europe	Northern Europe		Europe
GB	GBR	256	GBR	المملكة المتحدة	United Kingdom	Reino Unido	Royaume-Uni	Reino Unido	Соединенное Королевство	联合王国	Member State	NO	London	Europe	Northern Europe		Europe
FI	FIN	84	FIN	فنلندا	Finland	Finlandia	Finlande	Finlândia	Финляндия	芬 兰	Member State	NO	Helsinki	Europe	Northern Europe		Europe
SM	SMR	213	SMR	سان مارينو	San Marino	San Marino	Saint-Marin	São Marino	Сан-Марино	圣马力诺	Member State	NO	San Marino	Europe	Southern Europe		Europe
IT	ITA	122	ITA	إيطاليا	Italy	Italia	Italie	Itália	Италия	意大利	Member State	NO	Rome	Europe	Southern Europe		Europe
RS	SRB	2648	SRB	صربيا	Serbia	Serbia	Serbie 	Sérvia	Сербия	塞尔维亚	Member State	NO	Belgrade	Europe	Southern Europe		Europe
AD	AND	7	AND	أندورا	Andorra	Andorra	Andorre	Andorra	Андорра	安道尔	Member State	NO	Andorra la Vella	Europe	Southern Europe		Europe
MC	MCO	166	MCO	موناكو	Monaco	Mónaco	Monaco	Mónaco	Монако	摩纳哥	Member State	NO	Monaco	Europe	Western Europe		Europe
RU	RUS	204	RUS	الاتحاد الروسي	Russian Federation	Federación de Rusia	Fédération de Russie	Rússia	Российская Федерация	俄罗斯联邦	Member State	NO	Moskva	Europe	Eastern Europe		Europe
CL	CHL	51	CHL	شيلى	Chile	Chile	Chili	Chile	Чили	智 利	Member State	NO	Santiago	Americas	South America		South America
TM	TKM	250	TKM	تركمانستان	Turkmenistan	Turkmenistán	Turkménistan	Turquemenistão	Туркменистан	土库曼斯坦	Member State	NO	Ashgabat	Asia	Central Asia		Asia
NO	NOR	186	NOR	النرويج	Norway	Noruega	Norvège	Noruega	Норвегия	挪 威	Member State	NO	Oslo	Europe	Northern Europe		Europe
IM	IMN	120	GBR	جزيرة مان	Isle of Man	Isla de Man	Île de Man	Ilha de Man	Остров Мэн	Isle of Man	UK territory	NO		Europe	Northern Europe		Europe
NR	NRU	173	NRU	ناورو	Nauru	Nauru	Nauru	Nauru	Науру	瑙 鲁	Member State	NO		Oceania	Micronesia		Oceania
FM	FSM	163	FSM	ميكرونيزيا	Micronesia (Federated States of)	Micronesia (Estados Federados de)	Micronésie (États fédérés de)	Estados Federados da Micronésia	Микронезия (Федеративные Штаты)	密克罗尼西亚(联邦)	Member State	NO	Palikir	Oceania	Micronesia		Oceania
KI	KIR	135	KIR	كيريباس	Kiribati	Kiribati	Kiribati	Kiribati	Кирибати	基里巴斯	Member State	NO	Tarawa	Oceania	Micronesia		Oceania
WS	WSM	212	WSM	ساموا	Samoa	Samoa	Samoa	Samoa	Самоа	萨摩亚	Member State	NO	Apia	Oceania	Polynesia		Oceania
LK	LKA	231	LKA	سري لانكا	Sri Lanka	Sri Lanka	Sri Lanka	Sri Lanka	Шри-Ланка	斯里兰卡	Member State	NO	Sri Jayewardenepura Ko	Asia	Southern Asia		Asia
BT	BTN	31	BTN	بوتان	Bhutan	Bhután	Bhoutan	Butão	Бутан	不 丹	Member State	NO	Thimphu	Asia	Southern Asia		Asia
BD	BGD	23	BGD	بنغلاديش	Bangladesh	Bangladesh	Bangladesh	Bangladesh	Бангладеш	孟加拉国	Member State	NO	Dhaka	Asia	Southern Asia		Asia
TR	TUR	249	TUR	تركيا	Turkey	Turquía	Turquie	Turquia	Турция	土耳其	Member State	NO	Ankara	Asia	Western Asia		Asia
GI	GIB	95	GBR	جبل طارق	Gibraltar	Gibraltar	Gibraltar	Gibraltar	Гибралтар	直布罗陀	UK Non-Self-Governing Territory	NO	Gibraltar	Europe	Southern Europe		Europe
ES	ESP	229	ESP	إسبانيا	Spain	España	Espagne	Espanha	Испания	西班牙	Member State	NO	Madrid	Europe	Southern Europe		Europe
BA	BIH	34	BIH	البوسنة والهرسك	Bosnia and Herzegovina	Bosnia y Herzegovina	Bosnie-Herzégovine	Bósnia e Herzegovina	Босния и Герцеговина	波斯尼亚－黑塞哥维那	Member State	NO	Sarajevo	Europe	Southern Europe		Europe
SK	SVK	223	SVK	سلوفاكيا	Slovakia	Eslovaquia	Slovaquie	Eslováquia	Словакия	斯洛伐克	Member State	NO	Bratislava	Europe	Eastern Europe		Europe
CZ	CZE	65	CZE	الجمهورية التشيكية	Czech Republic	República Checa	République tchèque	República Checa	Чешская республика	捷克共和国	Member State	NO	Prague	Europe	Eastern Europe		Europe
TO	TON	245	TON	تونغا	Tonga	Tonga	Tonga	Tonga	Тонга	汤 加	Member State	NO	Nuku'alofa	Oceania	Polynesia		Oceania
CK	COK	60	NZL	جزر كوك	Cook Islands	Islas Cook	Îles Cook	Ilhas Cook	Острова Кука	库克群岛	NZ Territory	NO	Avarua	Oceania	Polynesia		Oceania
PN	PCN	197	GBR	جزر بيتكيرن	Pitcairn Islands	Islas Pitcairn	Îles Pitcairn	Pitcairn	Острова Питкэрн	皮特克恩岛	UK Non-Self-Governing Territory	NO	Adamstown	Oceania	Polynesia		Oceania
SZ	SWZ	235	SWZ	سوازيلند	Swaziland	Swazilandia	Swaziland	Suazilândia	Свазиленд	斯威士兰	Member State	NO	Mbabane (adm.)	Africa	Southern Africa		Africa
BW	BWA	35	BWA	بوتسوانا	Botswana	Botswana	Botswana	Botswana	Ботсвана	博茨瓦纳	Member State	NO	Gaborone	Africa	Southern Africa		Africa
SH	SHN	207	GBR	سانت هيلينا	Saint Helena, Ascension and Tristan da Cunha	Santa Elena, Ascension y Tristan da Cunha	Sainte-Hélène, Ascension et Tristan de Cunha	Santa Helena, Ascensão e Tristão da Cunha	острова Святой Елены Вознесения и Тристан-да-Кунья	圣赫勒拿	UK Non-Self-Governing Territory	NO		Africa	Western Africa		Africa
TG	TGO	243	TGO	توغو	Togo	Togo	Togo	Togo	Того	多 哥	Member State	NO	Lomé	Africa	Western Africa		Africa
WF	WLF	266	FRA	جزر واليس وفوتونا	Wallis and Futuna Islands	Islas Wallis y Futuna	Îles Wallis et Futuna	Wallis e Futuna	острова Уоллис и Футуна	瓦利斯和富图纳群岛	FR Territory	NO	Mata-Utu	Oceania	Polynesia		Oceania
SG	SGP	222	SGP	سنغافورة	Singapore	Singapur	Singapour	Singapura	Сингапур	新加坡	Member State	NO	Singapore	Asia	South-Eastern Asia		Asia
BG	BGR	41	BGR	بلغاريا	Bulgaria	Bulgaria	Bulgarie	Bulgária	Болгария	保加利亚	Member State	NO	Sofia	Europe	Eastern Europe		Europe
TV	TUV	252	TUV	توفالو	Tuvalu	Tuvalu	Tuvalu	Tuvalu	Тувалу	图瓦卢	Member State	NO	Funafuti	Oceania	Polynesia		Oceania
13	KEN	61013	KEN		Ilemi triangle						Sovereignty unsettled	YES		Africa	Northern Africa	Not classified in the UN classification 2005	Africa
AF	AFG	1	AFG	أفغانستان	Afghanistan	Afganistán	Afghanistan	Afeganistão	Афганистан	阿富汗	Member State	NO	Kabul	Asia	Southern Asia		Asia
MY	MYS	153	MYS	ماليزيا	Malaysia	Malasia	Malaisie	Malásia	Малайзия	马来西亚	Member State	NO	Kuala Lumpur	Asia	South-Eastern Asia		Asia
KW	KWT	137	KWT	الكويت	Kuwait	Kuwait	Koweït	Kuwait	Кувейт	科威特	Member State	NO	Kuwait	Asia	Western Asia		Asia
BH	BHR	21	BHR	البحرين	Bahrain	Bahrein	Bahreïn	Bahrein	Бахрейн	巴 林	Member State	NO	Manama	Asia	Western Asia		Asia
AZ	AZE	19	AZE	أذربيجان	Azerbaijan	Azerbaiyán	Azerbaïdjan	Azerbaijão	Азербайджан	阿塞拜疆	Member State	NO	Baku	Asia	Western Asia		Asia
AM	ARM	13	ARM	أرمينيا	Armenia	Armenia	Arménie	Arménia	Армения	亚美尼亚	Member State	NO	Yerevan	Asia	Western Asia		Asia
AE	ARE	255	ARE	الإمارات العربية المتحدة	United Arab Emirates	Emiratos Árabes Unidos	Émirats arabes unis	Emirados Árabes Unidos	Объединенные Арабские Эмираты	阿拉伯联合酋长国	Member State	NO	Abu Dhabi	Asia	Western Asia		Asia
MD	MDA	165	MDA	جمهورية مولدوفا	Republic of Moldova	República de Moldova	République de Moldova	Moldávia	Республика Молдова	摩尔多瓦共和国	Member State	NO	Chisinau	Europe	Eastern Europe		Europe
PL	POL	198	POL	بولندا	Poland	Polonia	Pologne	Polónia	Польша	波 兰	Member State	NO	Warsaw	Europe	Eastern Europe		Europe
RO	ROU	203	ROU	رومانيا	Romania	Rumania	Roumanie	Roménia	Румыния	罗马尼亚	Member State	NO	Bucharest	Europe	Eastern Europe		Europe
UA	UKR	254	UKR	أوكرانيا	Ukraine	Ucrania	Ukraine	Ucrânia	Украина	乌克兰	Member State	NO	Kyïv	Europe	Eastern Europe		Europe
NU	NIU	183	NZL	نيوى	Niue	Niue	Nioué	Niue	Ниуэ	纽 埃	NZ Territory	NO	Alofi	Oceania	Polynesia		Oceania
GQ	GNQ	76	GNQ	غينيا الاستوائية	Equatorial Guinea	Guinea Ecuatorial	Guinée équatoriale	Guiné Equatorial	Экваториальная Гвинея	赤道几内亚	Member State	NO	Malabo	Africa	Middle Africa		Africa
CX	CXR	54	AUS	جزر كريسماس	Christmas Island	Isla Christmas	Île Christmas	Ilha do Natal	остров Рождества	圣诞岛	AU Territory	NO	The Settlement	Asia	South-Eastern Asia		Asia
MH	MHL	157	MHL	جزر مارشال	Marshall Islands	Islas Marshall	Îles Marshall	Ilhas Marshall	Маршалловы Острова	马绍尔群岛	Member State	NO	Majuro	Oceania	Micronesia		Oceania
WK	WAK	265	USA	جزيرة ويك	Wake Island	Isla Wake	Îles Wake	País de Gales	остров Уэйк	威克岛（美国）	US Territory	NO		Oceania	Micronesia		Oceania
AS	ASM	5	USA	ساموا الأمريكية	American Samoa	Samoa Americana	Samoa américaines	Samoa Americana	Американское Самоа	美属萨摩亚	US Non-Self-Governing Territory	NO	Pago Pago	Oceania	Polynesia		Oceania
PF	PYF	87	FRA	بولينيزيا الفرنسية	French Polynesia	Polinesia Francesa	Polynésie française	Polinésia Francesa	Французская Полинезия	法属波利尼西亚	FR Territory	NO	Papeete	Oceania	Polynesia		Oceania
TK	TKL	244	GBR	جزر توكيلاو	Tokelau	Tokelau	Tokélaou	Toquelau	Токелау	托克劳	NZ Non-Self-Governing Territory	NO		Oceania	Polynesia		Oceania
OM	OMN	187	OMN	عمان	Oman	Omán	Oman	Omã	Оман	阿 曼	Member State	NO	Muscat	Asia	Western Asia		Asia
HM	HMD	109	HMD		Heard Island and McDonald Islands						AU Territory	NO		Antarctica	Antarctica		Antarctica
BV	BVT	36	NOR		Bouvet Island						NO Territory	NO		Antarctica	Antarctica		Antarctica
AQ	ATA	10	ATA	أنتارتيكا	Antarctica	Antártida	Antarctique	Antártida	Антарктика	南极洲		NO		Antarctica	Antarctica		Antarctica
SJ	SJM	234	NOR	جزر سفالبارد وجان مايين	Svalbard and Jan Mayen Islands	Islas Svalbard y Jan Mayen	Îles Svalbard et Jan Mayen	Svalbard e Jan Mayen	Острова Свальбард и Ян-Майен	斯瓦尔巴特群岛	NO Territory	NO	Longyearbyen	Europe	Northern Europe		Europe
10	XXX	40760	SDN		Hala'ib triangle						Sovereignty unsettled	YES		Africa	Northern Africa	Not classified in the UN classification 2005	Africa
09	XXX	230	XXX		Spratly Islands						Sovereignty unsettled	YES		Asia	South-Eastern Asia		Asia
CG	COG	59	COG	الكونغو	Congo	Congo	Congo	República do Congo	Конго	刚 果	Member State	NO	Brazzaville	Africa	Middle Africa		Africa
BI	BDI	43	BDI	بوروندي	Burundi	Burundi	Burundi	Burundi	Бурунди	布隆迪	Member State	NO	Bujumbura	Africa	Eastern Africa		Africa
DZ	DZA	4	DZA	الجزائر	Algeria	Argelia	Algérie	Argélia	Алжир	阿尔及利亚	Member State	NO	Algiers	Africa	Northern Africa	Not classified in the UN classification 2005	Africa
MM	MMR	171	MMR	ميانمار	Myanmar	Myanmar	Myanmar	Myanmar	Мьянма	缅 甸	Member State	NO	Yangon	Asia	South-Eastern Asia		Asia
KH	KHM	44	KHM	كمبوديا	Cambodia	Camboya	Cambodge	Camboja	Камбоджа	柬埔寨	Member State	NO	Phnom Penh	Asia	South-Eastern Asia		Asia
MP	MNP	185	USA	جزر ماريانا الشمالية	Northern Mariana Islands	Islas Marianas septentrionales	Îles Mariannes du Nord	Marianas Setentrionais	Содружество Северных Марианских островов	北马里亚纳群岛	US Territory	NO	Saipan	Oceania	Micronesia		Oceania
YT	MYT	161	FRA	مايوت	Mayotte	Mayotte	Mayotte	Mayotte	Майотта	Mayotte	FR Territory	NO	Mamoudzou	Africa	Eastern Africa		Africa
SY	SYR	238	SYR	الجمهورية العربية السورية	Syrian Arab Republic	República Árabe Siria	République arabe syrienne	Síria	Сирийская Арабская Республика	阿拉伯叙利亚共和国	Member State	NO	Damascus	Asia	Western Asia		Asia
TD	TCD	50	TCD	تشاد	Chad	Chad	Tchad	Chade	Чад	乍 得	Member State	NO	N'Djamena	Africa	Middle Africa		Africa
MZ	MOZ	170	MOZ	موزامبيق	Mozambique	Mozambique	Mozambique	Moçambique	Мозамбик	莫桑比克	Member State	NO	Maputo	Africa	Eastern Africa		Africa
MO	MAC	149	CHN		Macau						CN Special Administrative Region	NO	Macau	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
LB	LBN	141	LBN	لبنان	Lebanon	Líbano	Liban	Líbano	Ливан	黎巴嫩	Member State	NO	Beirut	Asia	Western Asia		Asia
HK	HKG	33364	CHN		Hong Kong						CN Special Administrative Region	NO	Hong Kong	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
MU	MUS	160	MUS	موريشيوس	Mauritius	Mauricio	Maurice	Maurícia	Маврикий	毛里求斯	Member State	NO	Port Louis	Africa	Eastern Africa		Africa
ST	STP	214	STP	سان تومي وبرنسيبي	Sao Tome and Principe	Santo Tomé y Príncipe	Sao Tomé-et-Principe	São Tomé e Príncipe	Сан-Томе и Принсипи	圣多美和普林西比	Member State	NO	S?o Tomé	Africa	Middle Africa		Africa
EH	ESH	268	XXX	الصحراء الغربية	Western Sahara	Sáhara occidental	Sahara occidental	Saara Ocidental	Западная Сахара	西撒哈拉	Non-Self-Governing Territory	NO		Africa	Northern Africa	Not classified in the UN classification 2005	Africa
IE	IRL	119	IRL	آيرلندا	Ireland	Irlanda	Irlande	Irlanda	Ирландия	爱尔兰	Member State	NO	Dublin	Europe	Northern Europe		Europe
QA	QAT	201	QAT	قطر	Qatar	Qatar	Qatar	Catar	Катар	卡塔尔	Member State	NO	Doha	Asia	Western Asia		Asia
TH	THA	240	THA	تايلند	Thailand	Tailandia	Thaïlande	Tailândia	Таиланд	泰 国	Member State	NO	Bangkok	Asia	South-Eastern Asia		Asia
JO	JOR	130	JOR	الأردن	Jordan	Jordania	Jordanie	Jordânia	Иордания	约 旦	Member State	NO	Amman	Asia	Western Asia		Asia
GA	GAB	89	GAB	غابون	Gabon	Gabón	Gabon	Gabão	Габон	加 蓬	Member State	NO	Libreville	Africa	Middle Africa		Africa
ML	MLI	155	MLI	مالي	Mali	Malí	Mali	Mali	Мали	马 里	Member State	NO	Bamako	Africa	Western Africa		Africa
YE	YEM	269	YEM	اليمن	Yemen	Yemen	Yémen	Iémen/Iêmen	Йемен	也 门	Member State	NO	Sanaa	Asia	Western Asia		Asia
JP	JPN	126	JPN	اليابان	Japan	Japón	Japon	Japão	Япония	日 本	Member State	NO	Tokyo	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
CC	CCK	56	AUS	جزر كوكوس (كيلنغ)	Cocos (Keeling) Islands	Islas Cocos (Keeling)	Îles des Cocos (Keeling)	Ilhas Cocos (Keeling)	Кокосовые острова (Килинг)	可可群岛	AU Territory	NO	West Island	Asia	South-Eastern Asia		Asia
NZ	NZL	179	NZL	نيوزيلندا	New Zealand	Nueva Zelandia	Nouvelle-Zélande	Nova Zelândia	Новая Зеландия	新西兰	Member State	NO	Wellington	Oceania	Australia and New Zealand		Oceania
DK	DNK	69	DNK	الدانمرك	Denmark	Dinamarca	Danemark	Dinamarca	Дания	丹 麦	Member State	NO	Copenhagen	Europe	Northern Europe		Europe
JE	JEY	128	GBR		Jersey						UK Territory	NO	St. Helier	Europe	Northern Europe		Europe
SB	SLB	225	SLB	جزر سليمان	Solomon Islands	Islas Salomón	Îles Salomon	Ilhas Salomão	Соломоновы Острова	所罗门群岛	Member State	NO	Honiara	Oceania	Melanesia		Oceania
NC	NCL	178	FRA	كاليدونيا الجديدة	New Caledonia	Nueva Caledonia	Nouvelle-Calédonie	Nova Caledônia	Новая Каледония	新喀里多尼亚	FR Non-Self-Governing Territory	NO	Nouméa	Oceania	Melanesia		Oceania
FJ	FJI	83	FJI	فيجي	Fiji	Fiji	Fidji	Fiji	Фиджи	斐 济	Member State	NO	Suva	Oceania	Melanesia		Oceania
SA	SAU	215	SAU	المملكة العربية السعودية	Saudi Arabia	Arabia Saudita	Arabie saoudite	Arábia Saudita	Саудовская Аравия	沙特阿拉伯	Member State	NO	Riyadh	Asia	Western Asia		Asia
GU	GUM	101	USA	جوام	Guam	Guam	Guam	Guam	Гуам	关岛	US Non-Self-Governing Territory	NO	Agana	Oceania	Micronesia		Oceania
LY	LBY	145	LBY	الجماهيرية العربية الليبية	Libya	Libia	Libye	Líbia	Ливия	阿拉伯利比亚民众国	Member State	NO	Tripoli	Africa	Northern Africa	Not classified in the UN classification 2005	Africa
EG	EGY	40765	EGY	مصر	Egypt	Egipto	Égypte	Egito	Египет	埃 及	Member State	NO	Cairo	Africa	Northern Africa	Not classified in the UN classification 2005	Africa
TN	TUN	248	TUN	تونس	Tunisia	Túnez	Tunisie	Tunísia	Тунис	突尼斯	Member State	NO	Tunis	Africa	Northern Africa	Not classified in the UN classification 2005	Africa
AU	AUS	17	AUS	أستراليا	Australia	Australia	Australie	Austrália	Австралия	澳大利亚	Member State	NO	Canberra	Oceania	Australia and New Zealand		Oceania
MA	MAR	169	MAR	المغرب	Morocco	Marruecos	Maroc	Marrocos	Марокко	摩洛哥	Member State	NO	Rabat	Africa	Northern Africa	Not classified in the UN classification 2005	Africa
FR	FRA	85	FRA	فرنسا	France	Francia	France	França	Франция	法 国	Member State	NO	Paris	Europe	Western Europe		Europe
RE	REU	206	FRA	رييونيون	Réunion	Reunión	Réunion	Reunião	Реюньон	留尼汪	FR Territory	NO	Saint-Denis	Africa	Eastern Africa		Africa
BJ	BEN	29	BEN	بنن	Benin	Benin	Bénin	Benim	Бенин	贝 宁	Member State	NO	Porto-Novo (constituti	Africa	Western Africa		Africa
SI	SVN	224	SVN	سلوفينيا	Slovenia	Eslovenia	Slovénie	Eslovênia	Словения	斯洛文尼亚	Member State	NO	Ljubljana	Europe	Southern Europe		Europe
LI	LIE	146	LIE	لختنشتاين	Liechtenstein	Liechtenstein	Liechtenstein	Liechtenstein	Лихтенштейн	列支敦士登	Member State	NO	Vaduz	Europe	Western Europe		Europe
DE	DEU	93	DEU	ألمانيا	Germany	Alemania	Allemagne	Alemanha	Германия	德 国	Member State	NO	Berlin	Europe	Western Europe		Europe
CH	CHE	237	CHE	سويسرا	Switzerland	Suiza	Suisse	Suíça	Швейцария	瑞 士	Member State	NO	Bern	Europe	Western Europe		Europe
BE	BEL	27	BEL	بلجيكا	Belgium	Bélgica	Belgique	Bélgica	Бельгия	比利时	Member State	NO	Brussels	Europe	Western Europe		Europe
AT	AUT	18	AUT	النمسا	Austria	Austria	Autriche	Áustria	Австрия	奥地利	Member State	NO	Vienna	Europe	Western Europe		Europe
NF	NFK	184	AUS	جزيرة نورفولك، مناطق تابعة لجزيرة لنورفولك	Norfolk Island	Isla Norfolk	Île Norfolk	Ilha Norfolk	Остров Норфолк	诺福克岛	AU Territory	NO	Kingston	Oceania	Australia and New Zealand		Oceania
CV	CPV	47	CPV	الرأس الأخضر	Cape Verde	Cabo Verde	Cap-Vert	abo Verde Cabo Verde	Кабо-Верде	佛得角	Member State	NO	Praia	Africa	Western Africa		Africa
PG	PNG	192	PNG	بابوا غينيا الجديدة	Papua New Guinea	Papua Nueva Guinea	Papouasie-Nouvelle-Guinée	Papua-Nova Guiné	Папуа-Новая Гвинея	巴布亚新几内亚	Member State	NO	Port Moresby	Oceania	Melanesia		Oceania
VU	VUT	262	VUT	فانواتو	Vanuatu	Vanuatu	Vanuatu	Vanuatu	Вануату	瓦努阿图	Member State	NO	Port-Vila	Oceania	Melanesia		Oceania
HU	HUN	113	HUN	هنغاريا	Hungary	Hungría	Hongrie	Hungria	Венгрия	匈牙利	Member State	NO	Budapest	Europe	Eastern Europe		Europe
CD	COD	68	COD	جمهورية الكونغو الديمقراطية	Democratic Republic of the Congo	República Democrática del Congo	République démocratique du Congo	República Democrática do Congo	Демократическая Республика Конго	刚果民主共和国	Member State	NO	Kinshasa	Africa	Middle Africa		Africa
CM	CMR	45	CMR	الكاميرون	Cameroon	Camerún	Cameroun	Camarões	Камерун	喀麦隆	Member State	NO	Yaoundé	Africa	Middle Africa		Africa
CF	CAF	49	CAF	جمهورية أفريقيا الوسطى	Central African Republic	República Centroafricana	République centrafricaine	República Centro-Africana	Центральноафриканская Республика	中非共和国	Member State	NO	Bangui	Africa	Middle Africa		Africa
AO	AGO	8	AGO	أنغولا	Angola	Angola	Angola	Angola	Ангола	安哥拉	Member State	NO	Luanda	Africa	Middle Africa		Africa
CN	CHN	147295	CHN		China						Member State	NO	Beijing	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
GN	GIN	106	GIN	غينيا	Guinea	Guinea	Guinée	Guiné	Гвинея	几内亚	Member State	NO	Conakry	Africa	Western Africa		Africa
GH	GHA	94	GHA	غانا	Ghana	Ghana	Ghana	Gana	Гана	加 纳	Member State	NO	Accra	Africa	Western Africa		Africa
CI	CIV	66	CIV	كوت ديفوار	Côte d'Ivoire	Côte d'Ivoire	Côte d'Ivoire	Costa do Marfim	Кот-д`Ивуар	科特迪瓦	Member State	NO	Yamoussoukro	Africa	Western Africa		Africa
BF	BFA	42	BFA	بوركينا فاسو	Burkina Faso	Burkina Faso	Burkina Faso	Burkina Faso	Буркина-Фасо	布基纳法索	Member State	NO	Ouagadougou	Africa	Western Africa		Africa
GG	GGY	104	GBR		Guernsey						UK Territory	NO		Europe	Northern Europe		Europe
IQ	IRQ	118	IRQ	العراق	Iraq	Iraq	Iraq	Iraque	Ирак	伊拉克	Member State	NO	Baghdad	Asia	Western Asia		Asia
KZ	KAZ	132	KAZ	كازاخستان	Kazakhstan	Kazajstán	Kazakhstan	Cazaquistão	Казахстан	哈萨克斯坦	Member State	NO	Astana	Asia	Central Asia		Asia
MN	MNG	167	MNG	منغوليا	Mongolia	Mongolia	Mongolie	Mongólia	Монголия	蒙 古	Member State	NO	Ulaanbaatar	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
KR	KOR	202	KOR	جمهورية كوريا	Republic of Korea	República de Corea	République de Corée	Coreia do Sul	Республика Корея	大韩民国	Member State	NO	Seoul	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
IL	ISR	121	ISR	إسرائيل	Israel	Israel	Israël	Israel	Израиль	以色列	Member State	NO		Asia	Western Asia		Asia
SL	SLE	221	SLE	سيراليون	Sierra Leone	Sierra Leona	Sierra Leone	Serra Leoa	Сьерра-Леоне	塞拉利昂	Member State	NO	Freetown	Africa	Western Africa		Africa
AL	ALB	3	ALB	ألبانيا	Albania	Albania	Albanie	Albânia	Албания	阿尔巴尼亚	Member State	NO	Tirana	Europe	Southern Europe		Europe
NL	NLD	177	NLD	هولندا	Netherlands	Países Bajos	Pays-Bas	Países Baixos	Нидерланды	荷 兰	Member State	NO	Amsterdam	Europe	Western Europe		Europe
TL	TLS	242	TLS	تيمور- ليشتى	Timor-Leste	Timor-Leste	Timor-Leste	Timor-Leste	Тимор-Лешти	东帝汶	Member State	NO	Dili	Asia	South-Eastern Asia		Asia
MV	MDV	154	MDV	ملديف	Maldives	Maldivas	Maldives	Maldivas	Мальдивы	马尔代夫	Member State	NO	Male	Asia	Southern Asia		Asia
PK	PAK	188	PAK	باكستان	Pakistan	Pakistán	Pakistan	Paquistão	Пакистан	巴基斯坦	Member State	NO	Islamabad	Asia	Southern Asia		Asia
PW	PLW	189	PLW	بالاو	Palau	Palau	Palaos	Palau	Палау	帕 劳	Member State	NO	Koror	Oceania	Micronesia		Oceania
SS	SSD	74	   		South Sudan	Sudán del Sur	Soudan du Sud	Sudão do Sul	Южный Судан		Member State	NO	Juba	Africa	Eastern Africa		Africa
06	XXX	193	XXX		Paracel Islands						Sovereignty unsettled	YES		Asia	South-Eastern Asia		Asia
KG	KGZ	138	KGZ	قيرغيزستان	Kyrgyzstan	Kirguistán	Kirghizistan	Quirguistão	Кыргызстан	吉尔吉斯斯坦	Member State	NO	Bishkek	Asia	Central Asia		Asia
TW	CHN	147296	CHN		Taiwan						CN Province	NO	Beijing	Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
PS	XXX	267	XXX		Occupied Palestinan Territory			Território Palestino Ocupado			Occupied Palestinian Territory	NO		Asia	Western Asia		Asia
GS	SGS	228	GBR		South Georgia and the South Sandwich Islands						UK Territory	NO		Antarctica	Antarctica		Antarctica
04	   	102	   		Abyei						Sovereignty unsettled	YES		Africa			Africa
11	XXX	40762	EGY		Ma'tan al-Sarra						Sovereignty unsettled	YES		Africa	Northern Africa	Not classified in the UN classification 2005	Africa
TF	ATF	88	FRA	أراضى جنوبى فرنسا	French Southern and Antarctic Territories	Tierras Australes y Antárticas Francesas	Terres australes et antarctiques françaises	Terras Austrais e Antárticas Francesas	Французские южные и антарктические территории	法国南部领	FR Territory	NO		Antarctica	Antarctica		Antarctica
12	XXX	40781	XXX		Jammu and Kashmir						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
03	XXX	52	XXX		China/India						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
05	RUS	136	RUS		Kuril islands						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
07	XXX	216	XXX		Scarborough Reef						Sovereignty unsettled	YES		Asia	South-Eastern Asia		Asia
08	XXX	218	XXX		Senkaku Islands						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
01	XXX	2	XXX		Aksai Chin						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
02	IND	15	IND		Arunachal Pradesh						Sovereignty unsettled	YES		Asia	Eastern Asia	Not classified in the UN classification 2005	Asia
PM	SPM	210	FRA	سان بيير ومكويلون	Saint Pierre and Miquelon	Saint-Pierre y Miquelon	Saint-Pierre-et-Miquelon	Saint-Pierre e Miquelon	Сен-Пьер и Микелон	圣皮埃尔和密克隆	FR Territory	NO	Saint-Pierre	Americas	Northern America	Not classified in the UN classification 2005	Northern America
BM	BMU	30	GBR	برمودا	Bermuda	Bermudas	Bermudes	Bermudas	Бермуды	百慕大	UK Non-Self-Governing Territory	NO	Hamilton	Americas	Northern America	Not classified in the UN classification 2005	Northern America
CA	CAN	46	CAN	كندا	Canada	Canadá	Canada	Canadá	Канада	加拿大	Member State	NO	Ottawa	Americas	Northern America	Not classified in the UN classification 2005	Northern America
US	USA	259	USA	الولايات المتحدة الأمريكية	United States of America	Estados Unidos de América	États-Unis d'Amérique	Estados Unidos	Соединенные Штаты Америки	美 国	Member State	NO	Washington, D.C.	Americas	Northern America	Not classified in the UN classification 2005	Northern America
UM	MID	164	USA		United States Minor Outlying Islands			Ilhas Menores Distantes dos Estados Unidos			US Territory	NO		Americas	Northern America	Not classified in the UN classification 2005	Northern America
CR	CRI	61	CRI	كوستاريكا	Costa Rica	Costa Rica	Costa Rica	Costa Rica	Коста-Рика	哥斯达黎加	Member State	NO	San José	Americas	Central America		Northern America
HN	HND	111	HND	هندوراس	Honduras	Honduras	Honduras	Honduras	Гондурас	洪都拉斯	Member State	NO	Tegucigalpa	Americas	Central America		Northern America
GT	GTM	103	GTM	غواتيمالا	Guatemala	Guatemala	Guatemala	Guatemala	Гватемала	危地马拉	Member State	NO	Guatemala	Americas	Central America		Northern America
NI	NIC	180	NIC	نيكاراغوا	Nicaragua	Nicaragua	Nicaragua	Nicarágua	Никарагуа	尼加拉瓜	Member State	NO	Managua	Americas	Central America		Northern America
MX	MEX	162	MEX	المكسيك	Mexico	México	Mexique	México	Мексика	墨西哥	Member State	NO	México	Americas	Central America		Northern America
PA	PAN	191	PAN	بنما	Panama	Panamá	Panama	Panamá	Панама	巴拿马	Member State	NO	Panamá	Americas	Central America		Northern America
SV	SLV	75	SLV	السلفادور	El Salvador	El Salvador	El Salvador	El Salvador	Сальвадор	萨尔瓦多	Member State	NO	San Salvador	Americas	Central America		Northern America
BZ	BLZ	28	BLZ	بليز	Belize	Belice	Belize	Belize	Белиз	伯利兹	Member State	NO	Belmopan	Americas	Central America		Northern America
CP	FRA	55	FRA		Clipperton Island						FR Territory	NO		Americas	Central America		Northern America
KN	KNA	208	KNA	سانت كيتس ونيفيس	Saint Kitts and Nevis	Saint Kitts y Nevis	Saint-Kitts-et-Nevis	São Cristóvão e Nevis	Сент-Китс и Невис	圣基茨和尼维斯	Member State	NO	Basseterre	Americas	Caribbean		Northern America
DM	DMA	71	DMA	دومينيكا	Dominica	Dominica	Dominique	Dominica	Доминика	多米尼克	Member State	NO	Roseau	Americas	Caribbean		Northern America
DO	DOM	72	DOM	الجمهورية الدومينيكية	Dominican Republic	República Dominicana	République dominicaine	República Dominicana	Доминиканская Республика	多米尼加共和国	Member State	NO	Santo Domingo	Americas	Caribbean		Northern America
VC	VCT	211	VCT	سانت فنسنت وجزر غرينادين	Saint Vincent and the Grenadines	San Vicente y las Granadinas	Saint-Vincent-et-les Grenadines	São Vicente e Granadinas	Сент-Винсент и Гренадины	圣文森特和格林纳丁斯	Member State	NO	Kingstown	Americas	Caribbean		Northern America
VG	VGB	39	GBR	جزر فيرجين البريطانية	British Virgin Islands	Islas Vírgenes Británicas	Îles Vierges britanniques	Ilhas Virgens Britânicas	Британские Виргинские острова	英属维尔京群岛	UK Non-Self-Governing Territory	NO	Road Town	Americas	Caribbean		Northern America
BB	BRB	24	BRB	بربادوس	Barbados	Barbados	Barbade	Barbados	Барбадос	巴巴多斯	Member State	NO	Bridgetown	Americas	Caribbean		Northern America
PR	PRI	200	USA	بورتوريكو	Puerto Rico	Puerto Rico	Porto Rico	Porto Rico	Пуэрто-Рико	波多黎各	US Territory	NO	San Juan	Americas	Caribbean		Northern America
VI	VIR	258	USA	جزر فيرجين التابعة للولايات المتحدة	United States Virgin Islands	Islas Vírgenes (EE.UU.)	Îles Vierges américaines	Ilhas Virgens Americanas	Виргинские острова США	美属维尔京群岛	US Non-Self-Governing Territory	NO	Charlotte Amalie	Americas	Caribbean		Northern America
AW	ABW	14	NLD	أروبا	Aruba	Aruba	Aruba	Aruba	Аруба	阿鲁巴岛	NL Self-Governing Territory	NO	Oranjestad	Americas	Caribbean		Northern America
AI	AIA	9	GBR	أنغويلا	Anguilla	Anguila	Anguilla	Anguilla	Ангилья	安圭拉	UK Non-Self-Governing Territory	NO	The Valley	Americas	Caribbean		Northern America
HT	HTI	108	HTI	هايتي	Haiti	Haití	Haïti	Haiti	Гаити	海 地	Member State	NO	Port-au-Prince	Americas	Caribbean		Northern America
MS	MSR	168	GBR	مونسراط	Montserrat	Montserrat	Montserrat	Montserrat	Монтсеррат	蒙特塞拉	UK Non-Self-Governing Territory	NO	Plymouth	Americas	Caribbean		Northern America
GD	GRD	99	GRD	غرينادا	Grenada	Granada	Grenade	Granada	Гренада	格林纳达	Member State	NO	Saint George's	Americas	Caribbean		Northern America
KY	CYM	48	GBR	جزر كايمان	Cayman Islands	Islas Caimán	Îles Caïmanes	Ilhas Cayman	Каймановы острова	开曼群岛	UK Non-Self-Governing Territory	NO	George Town	Americas	Caribbean		Northern America
AN	ANT	176	NLD	جزر الأنتيل الهولندية	Netherlands Antilles	Antillas Neerlandesas	Antilles néerlandaises	Antilhas Holandesas	Голландские Антиллы	荷属安的列斯	NL Territory	NO	Willemstad	Americas	Caribbean		Northern America
BS	BHS	20	BHS	جزر البهاما	Bahamas	Bahamas	Bahamas	Bahamas	Багамские Острова	巴哈马	Member State	NO	Nassau	Americas	Caribbean		Northern America
TT	TTO	246	TTO	ترينيداد وتوباغو	Trinidad and Tobago	Trinidad y Tabago	Trinité-et-Tobago	Trinidad e Tobago	Тринидад и Тобаго	特立尼达和多巴哥	Member State	NO	Port of Spain	Americas	Caribbean		Northern America
LC	LCA	209	LCA	سانت لوسيا	Saint Lucia	Santa Lucía	Sainte-Lucie	Santa Lúcia	Сент-Люсия	圣卢西亚	Member State	NO	Castries	Americas	Caribbean		Northern America
AG	ATG	11	ATG	أنتيغوا وباربودا	Antigua and Barbuda	Antigua y Barbuda	Antigua-et-Barbuda	Antígua e Barbuda	Антигуа и Барбуда	安提瓜和巴布达	Member State	NO	St John's	Americas	Caribbean		Northern America
TC	TCA	251	GBR	جزر تركس وكايكوس	Turks and Caicos Islands	Islas Turcas y Caicos	Îles Turques et Caïques	Turcas e Caicos	острова Тёркс и Кайкос	特克斯和凯科斯群岛	UK Non-Self-Governing Territory	NO	Cockburn Town	Americas	Caribbean		Northern America
GP	GLP	100	FRA	غوادالوب	Guadeloupe	Guadalupe	Guadeloupe	Guadalupe	Гваделупа	瓜德罗普	FR Territory	NO	Basse-Terre	Americas	Caribbean		Northern America
AR	ARG	12	ARG	الأرجنتين	Argentina	Argentina	Argentine	Argentina	Аргентина	阿根廷	Member State	NO	Buenos Aires	Americas	South America		South America
SR	SUR	233	SUR	سورينام	Suriname	Suriname	Suriname	Suriname	Суринам	苏里南	Member State	NO	Paramaribo	Americas	South America		South America
UY	URY	260	URY	أوروغواي	Uruguay	Uruguay	Uruguay	Uruguai	Уругвай	乌拉圭	Member State	NO	Montevideo	Americas	South America		South America
FK	FLK	81	GBR	جزر فوكلاند (مالفيناس)	Falkland Islands (Malvinas)	Islas Malvinas	Îles Falkland	Ilhas Malvinas	Фолклендские острова	福克兰群岛	UK Non-Self-Governing Territory	NO	Stanley	Americas	South America		South America
BR	BRA	37	BRA	البرازيل	Brazil	Brasil	Brésil	Brasil	Бразилия	巴 西	Member State	NO	Brasília	Americas	South America		South America
BO	BOL	33	BOL	بوليفيا (دولة - المتعددة القوميات)	Bolivia (Plurinational State of)	Bolivia (Estado Plurinacional de)	Bolivie (État plurinational de)	Bolívia	Боливия (Многонациогнальное Государство)	玻利维亚多民族国	Member State	NO	La Paz  (adm.)	Americas	South America		South America
PE	PER	195	PER	بيرو	Peru	Perú	Pérou	Peru	Перу	秘 鲁	Member State	NO	Lima	Americas	South America		South America
CO	COL	57	COL	كولومبيا	Colombia	Colombia	Colombie	Colômbia	Колумбия	哥伦比亚	Member State	NO	Bogotá	Americas	South America		South America
GY	GUY	107	GUY	غيانا	Guyana	Guyana	Guyana	Guiana	Гайана	圭亚那	Member State	NO	Georgetown	Americas	South America		South America
EC	ECU	73	ECU	إكوادور	Ecuador	Ecuador	Équateur	Equador	Эквадор	厄瓜多尔	Member State	NO	Quito	Americas	South America		South America
GF	GUF	86	FRA	غوايانا الفرنسية	French Guiana	Guayana francesa	Guyane française	Guiana Francesa	Французская Гвиана	法属圭亚那	Member State	NO	Cayenne	Americas	South America		South America
PY	PRY	194	PRY	باراغواي	Paraguay	Paraguay	Paraguay	Paraguai	Парагвай	巴拉圭	Member State	NO	Asunción	Americas	South America		South America
VN	VNM	264	VNM	فييت نام	Vietnam	Viet Nam	Viet Nam	Vietname	Вьетнам	越 南	Member State	NO	Hanoi	Asia	South-Eastern Asia		Asia
LA	LAO	139	LAO	جمهورية لاو الديمقراطية الشعبية	Laos	República Democrática Popular Lao	République démocratique populaire lao	Laos	Лаосская Народно-Демократическая Республика	老挝人民民主共和国	Member State	NO	Vientiane	Asia	South-Eastern Asia		Asia
\.


--
-- TOC entry 5291 (class 0 OID 55549108)
-- Dependencies: 299
-- Data for Name: individual; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.individual (individual_id, email) FROM stdin;
\.


--
-- TOC entry 5292 (class 0 OID 55549114)
-- Dependencies: 300
-- Data for Name: layer; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.layer (mapset_id, dimension_depth, dimension_stats, file_path, layer_id, file_extension, file_size, file_size_pretty, reference_layer, reference_system_identifier_code, distance, distance_uom, extent, west_bound_longitude, east_bound_longitude, south_bound_latitude, north_bound_latitude, distribution_format, compression, raster_size_x, raster_size_y, pixel_size_x, pixel_size_y, origin_x, origin_y, spatial_reference, data_type, no_data_value, stats_minimum, stats_maximum, stats_mean, stats_std_dev, scale, n_bands, metadata, map) FROM stdin;
\.


--
-- TOC entry 5293 (class 0 OID 55549123)
-- Dependencies: 301
-- Data for Name: mapset; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.mapset (country_id, project_id, property_id, mapset_id, dimension, parent_identifier, file_identifier, language_code, metadata_standard_name, metadata_standard_version, reference_system_identifier_code_space, title, unit_of_measure_id, creation_date, publication_date, revision_date, edition, citation_md_identifier_code, citation_md_identifier_code_space, abstract, status, update_frequency, md_browse_graphic, keyword_theme, keyword_place, keyword_discipline, access_constraints, use_constraints, other_constraints, spatial_representation_type_code, presentation_form, topic_category, time_period_begin, time_period_end, scope_code, lineage_statement, lineage_source_uuidref, lineage_source_title, xml, sld) FROM stdin;
\.


--
-- TOC entry 5294 (class 0 OID 55549153)
-- Dependencies: 302
-- Data for Name: organisation; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point, phone, facsimile) FROM stdin;
\.


--
-- TOC entry 5295 (class 0 OID 55549159)
-- Dependencies: 303
-- Data for Name: proj_x_org_x_ind; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.proj_x_org_x_ind (country_id, project_id, organisation_id, individual_id, "position", tag, role) FROM stdin;
\.


--
-- TOC entry 5296 (class 0 OID 55549167)
-- Dependencies: 304
-- Data for Name: project; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.project (country_id, project_id, project_name, project_description) FROM stdin;
\.


--
-- TOC entry 5297 (class 0 OID 55549173)
-- Dependencies: 305
-- Data for Name: property; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.property (property_id, name, property_num_id, unit_of_measure_id, min, max, property_type, num_intervals, start_color, end_color, keyword_theme, property_id_old) FROM stdin;
SOLSAL	Soluble salts	SOLSAL	cmol/L	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",salinity}	\N
CARINORG	Carbon (C) - inorganic	CARINORG	g/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","inorganic carbon",carbon}	\N
BULDWHOLE	Bulk Density whole soil	BULDWHOLE	kg/dm³	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","bulk density"}	\N
POR	Porosity	POR	m³/100 m³	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",porosity}	\N
ALUTOT	Aluminium (Al) total	ALUTOT	mg/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",aluminium,nutrient}	\N
CORGASRBAU	Absolute sequestration rate business-as-usual	\N	t/(ha·a)	-49.95	999	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGASRBAU
CORGADSSM1	Absolute difference sustainable soil management 1	\N	t/(ha·a)	-41.437344	35.42143	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGADSSM1
CORGSOCBAU	Final SOC stocks after 20 years business-as-usual	\N	t/(ha·a)	1.9685694	299.9769	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon}	CORGSOCBAU
CARSTK	Carbon (C) - organic stock	\N	t/(ha·a)	5.227511	878.3219	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon}	CORGS
CARORG	Carbon (C) - organic	CARORG	%	0.102681465	32.575752	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon}	CORG
CORGASRSSM2	Absolute sequestration rate sustainable soil management 2	\N	t/(ha·a)	-49.95	999	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGASRSSM2
CAD	Cadmium (Cd)	CAD	mg/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",cadmium,nutrient}	\N
TEXTCLAY	Clay texture fraction	TEXTCLAY	%	7.547785	67.95525	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",clay,texture}	CLAY
GYP	Gypsum content - weight	GYP	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",gypsum}	\N
HYDCOND	Hydraulic conductivity	HYDCOND	cm/h	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","hydraulic conductivity"}	\N
ECEC	Cation exchange capacity effective	ECEC	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","effective cation exchange capacity"}	\N
MOL	Molybdenum (Mo)	MOL	mg/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",molybdenum,nutrient}	\N
CORGRSRSSM2	Relative sequestration rate sustainable soil management 2	\N	t/(ha·a)	0	706.39966	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRSRSSM2
PEAT	Peat	\N	class	0	1	categorical	4	#CA0020	#3F68E2	{soil,"digital soil mapping","organic carbon",carbon}	PEAT
CORGRDSSM1	Relative difference sustainable soil management 1	\N	t/(ha·a)	0	10.117194	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRDSSM1
CORGSOCSSM2	Final SOC stocks after 20 years sustainable soil management 2	\N	t/(ha·a)	2.0859761	299.99915	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGSOCSSM2
CORGSOCSSM1	Final SOC stocks after 20 years sustainable soil management 1	\N	t/(ha·a)	2.027273	299.9997	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGSOCSSM1
CORGADSSM3	Absolute difference sustainable soil management 3	\N	t/(ha·a)	-26.77324	39.72415	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGADSSM3
CORGSOCSSM3	Final SOC stocks after 20 years sustainable soil management 3	\N	t/(ha·a)	2.203362	299.99362	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGSOCSSM3
CORGT0	Initial SOC stocks at year 2020 time zero	\N	t/(ha·a)	0	544.3276	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGT0
CORGASRSSM1	Absolute sequestration rate sustainable soil management 1	\N	t/(ha·a)	-49.95	999	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGASRSSM1
ORGMAT	Organic matter	ORGMAT	%	0.1361388	83.30734	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic matter"}	ORGMAT
CORGRSRSSM3	Relative sequestration rate sustainable soil management 3	\N	t/(ha·a)	0	706.39966	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRSRSSM3
PHO	Phosphorus (P)	\N	mg/kg	1.18992	414.6663	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",phosphorus,nutrient}	PXX
SODEXP	Sodium (Na+) - exchangeable	SODEXP	cmol/kg	0.141	23.825006	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","exchangeable sodium",salinity}	NAEXC
SALT	Salinification	\N	class	0.050008815	8	categorical	4	#CA0020	#3F68E2	{soil,"digital soil mapping","exchangeable sodium",salinity}	SALT
TEXTSAND	Sand texture fraction	TEXTSAND	%	5.075057	74.868645	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",sand,texture}	SAND
CEC	Cation exchange capacity	CEC	cmol/kg	1.1099763	161.03993	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","cation exchange capacity"}	CEC
CORGRDSSM2	Relative difference sustainable soil management 2	\N	t/(ha·a)	0	19.435438	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRDSSM2
CORGADSSM2	Absolute difference sustainable soil management 2	\N	t/(ha·a)	-36.54917	29.71708	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGADSSM2
CORGADBAU	Absolute difference business-as-usual	\N	t/(ha·a)	-46.325394	30.290558	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGADBAU
BULDFINE	Bulk Density of the fine earth fraction	BULDFINE	kg/dm³	0.017327346	1.5635105	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","bulk density"}	BKD
CORGRDSSM3	Relative difference sustainable soil management 3	\N	t/(ha·a)	0	36.01025	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRDSSM3
CORGASRSSM3	Absolute sequestration rate sustainable soil management 3	\N	t/(ha·a)	-49.95	999	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGASRSSM3
PHX	pH - Hydrogen potential	PH	pH	0	37.61572	quantitative	10	#CA0020	#3F68E2	{soil,"digital soil mapping",ph}	PHX
CORGRSRSSM1	Relative sequestration rate sustainable soil management 1	\N	t/(ha·a)	0	706.39966	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon,sequestration}	CORGRSRSSM1
ACIEXC	Exchangeable acidity	ACIEXC	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",acidity}	ACIEXC
CCETOT	Calcium carbonate equivalent - total	CCETOT	g/kg	0.0022378669	9.722537	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",calcium}	CACO3ET
ALUEXC	Aluminium (Al+++) - exchangeable	ALUEXC	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",aluminium,nutrient}	ALUEXC
AVAVOL	Available water capacity - volumetric	AVAVOL	m³/100 m³	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","water capacity"}	AVAVOL
BOREXT	Boron (B) - extractable	BOREXT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",boron,nutrient}	BOREXT
BASCAL	Base saturation	BASCAL	%	3.9748352	310.83453	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","base saturation"}	BASAT
BORTOT	Boron (B) - total	BORTOT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",boron,nutrient}	BORTOT
BASEXC	Exchangeable bases	\N	cmol/kg	1.25032	38.72092	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","exchangeable bases"}	BSEXC
BSATS	Base saturation - sum of cations DELETE!	\N	%	0.5860444	21.523035	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","base saturation"}	BSATS
CALEXT	Calcium (Ca++) - extractable	CALEXT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",calcium}	CALEXT
CALTOT	Calcium (Ca++) - total	CALTOT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",calcium}	CALTOT
CALEXC	Calcium (Ca++) - exchangeable	CALEXC	cmol/kg	0.64788485	31.82854	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",calcium}	CAEXC
COAFRA	Coarse fragments	COAFRA	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","coarse fragments"}	COAFRA
COAFRAF	Coarse fragments - field class	\N	%	6.5923385e-05	47.75318	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","coarse fragments"}	CFRAGF
CLAWRB	World reference base	\N	class	1	7	categorical	7	#F4E7D3	#5C4033	{soil,"digital soil mapping","soil classification",wrb}	CLAWRB
CARNIT	Carbon Nitrogen ratio	\N	dimensionless	1.165	129.77734	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",carbon,nitrogen}	CNRAT
CARTOT	Carbon (C) - total	CARTOT	g/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","organic carbon",carbon}	CARTOT
COPEXT	Copper (Cu) - extractable	COPEXT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",copper,nutrient}	COPEXT
COPTOT	Copper (Cu) - total	COPTOT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",copper,nutrient}	COPTOT
IROEXT	Iron (Fe) - extractable	IROEXT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",iron,nutrient}	IROEXT
IROTOT	Iron (Fe) - total	IROTOT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",iron,nutrient}	IROTOT
ELECCOND	Electrical conductivity	ELECCOND	dS/m	0.00038286045	23.560993	quantitative	10	#CA0020	#3F68E2	{soil,"digital soil mapping","electrical conductivity"}	ECX
POTEXT	Potassium (K) - extractable	POTEXT	cmol/kg	4.5881696	1249.2526	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",potassium,nutrient}	KEXT
POTTOT	Potassium (K) - total	POTTOT	%	0.14559056	2.4445798	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",potassium,nutrient}	KTOT
POTEXC	Potassium (K+) - exchangeable	POTEXC	cmol/kg	0.23427553	478.14163	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",potassium,nutrient}	KEXC
POT	Potassium (K)	\N	mg/kg	0.16248894	756.61646	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",potassium,nutrient}	KXX
HYDEXC	Hydrogen (H+) - exchangeable	HYDEXC	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",hydrogen}	HYDEXC
MAGEXT	Magnesium (Mg) - extractable	MAGEXT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",magnesium,nutrient}	MAGEXT
MAGTOT	Magnesium (Mg) - total	MAGTOT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",magnesium,nutrient}	MAGTOT
MANEXT	Manganese (Mn) - extractable	MANEXT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",manganese,nutrient}	MANEXT
MANTOT	Manganese (Mn) - total	MANTOT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",manganese,nutrient}	MANTOT
MAGEXC	Magnesium (Mg++) - exchangeable	MAGEXC	cmol/kg	0.1713	7.6219	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",magnesium,nutrient}	MGEXC
SODEXT	Sodium (Na) - extractable	SODEXT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","exchangeable sodium",salinity}	SODEXT
SODTOT	Sodium (Na) - total	SODTOT	cmol/kg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping","exchangeable sodium",salinity}	SODTOT
NITTOT	Nitrogen (N) - total	NITTOT	%	132.33414	37738.81	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",nitrogen,nutrient}	NTOT
PHORET	Phosphorus (P) - retention	PHORET	g/hg	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",phosphorus,nutrient}	PHORET
PHOEXT	Phosphorus (P) - extractable	PHOEXT	%	7.6332707	336.86963	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",phosphorus,nutrient}	PEXT
PHOTOT	Phosphorus (P) - total	PHOTOT	%	0.023891324	1.083517	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",phosphorus,nutrient}	PTOT
PHAQ	pH - Hydrogen potential in water DELETE!	\N	pH	3.5527137e-15	38.24991	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",pH}	PHAQ
SULEXT	Sulfur (S) - extractable	SULEXT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",sulfur,nutrient}	SULEXT
SULTOT	Sulfur (S) - total	SULTOT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",sulfur,nutrient}	SULTOT
ZINEXT	Zinc (Zn) - extractable	ZINEXT	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",zinc,nutrient}	ZINEXT
ZNTOT	Zinc (Zn) - total	ZIN	%	\N	\N	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",zinc,nutrient}	ZNTOT
TEXTSILT	Silt texture fraction	TEXTSILT	%	10.622029	65.9113	quantitative	10	#F4E7D3	#5C4033	{soil,"digital soil mapping",silt,texture}	SILT
\.


--
-- TOC entry 5298 (class 0 OID 55549180)
-- Dependencies: 306
-- Data for Name: url; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

COPY spatial_metadata.url (mapset_id, protocol, url, url_name, url_description) FROM stdin;
\.


--
-- TOC entry 5749 (class 0 OID 0)
-- Dependencies: 228
-- Name: audit_audit_id_seq; Type: SEQUENCE SET; Schema: api; Owner: sis
--

SELECT pg_catalog.setval('api.audit_audit_id_seq', 1, false);


--
-- TOC entry 5750 (class 0 OID 0)
-- Dependencies: 246
-- Name: element_element_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.element_element_id_seq', 1, false);


--
-- TOC entry 5751 (class 0 OID 0)
-- Dependencies: 250
-- Name: observation_phys_chem_element_observation_phys_chem_element_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.observation_phys_chem_element_observation_phys_chem_element_seq', 1935, true);


--
-- TOC entry 5752 (class 0 OID 0)
-- Dependencies: 252
-- Name: plot_plot_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.plot_plot_id_seq', 1, false);


--
-- TOC entry 5753 (class 0 OID 0)
-- Dependencies: 256
-- Name: procedure_model_procedure_model_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: carva014
--

SELECT pg_catalog.setval('soil_data.procedure_model_procedure_model_id_seq', 1, false);


--
-- TOC entry 5754 (class 0 OID 0)
-- Dependencies: 260
-- Name: procedure_spectrometer_procedure_spectrometer_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: carva014
--

SELECT pg_catalog.setval('soil_data.procedure_spectrometer_procedure_spectrometer_id_seq', 1, false);


--
-- TOC entry 5755 (class 0 OID 0)
-- Dependencies: 261
-- Name: profile_profile_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.profile_profile_id_seq', 1, false);


--
-- TOC entry 5756 (class 0 OID 0)
-- Dependencies: 271
-- Name: result_spectral_result_spectral_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: carva014
--

SELECT pg_catalog.setval('soil_data.result_spectral_result_spectral_id_seq', 1, false);


--
-- TOC entry 5757 (class 0 OID 0)
-- Dependencies: 272
-- Name: site_site_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.site_site_id_seq', 1, false);


--
-- TOC entry 5758 (class 0 OID 0)
-- Dependencies: 274
-- Name: soil_map_soil_map_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.soil_map_soil_map_id_seq', 1, false);


--
-- TOC entry 5759 (class 0 OID 0)
-- Dependencies: 277
-- Name: soil_mapping_unit_category_category_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.soil_mapping_unit_category_category_id_seq', 1, false);


--
-- TOC entry 5760 (class 0 OID 0)
-- Dependencies: 278
-- Name: soil_mapping_unit_mapping_unit_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.soil_mapping_unit_mapping_unit_id_seq', 1, false);


--
-- TOC entry 5761 (class 0 OID 0)
-- Dependencies: 283
-- Name: soil_typological_unit_typological_unit_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.soil_typological_unit_typological_unit_id_seq', 1, false);


--
-- TOC entry 5762 (class 0 OID 0)
-- Dependencies: 285
-- Name: specimen_prep_process_specimen_prep_process_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.specimen_prep_process_specimen_prep_process_id_seq', 1, false);


--
-- TOC entry 5763 (class 0 OID 0)
-- Dependencies: 286
-- Name: specimen_specimen_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.specimen_specimen_id_seq', 1, false);


--
-- TOC entry 5764 (class 0 OID 0)
-- Dependencies: 288
-- Name: specimen_storage_specimen_storage_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.specimen_storage_specimen_storage_id_seq', 1, false);


--
-- TOC entry 5765 (class 0 OID 0)
-- Dependencies: 290
-- Name: specimen_transport_specimen_transport_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: sis
--

SELECT pg_catalog.setval('soil_data.specimen_transport_specimen_transport_id_seq', 1, false);


--
-- TOC entry 5766 (class 0 OID 0)
-- Dependencies: 293
-- Name: spectrum_spectrum_id_seq; Type: SEQUENCE SET; Schema: soil_data; Owner: carva014
--

SELECT pg_catalog.setval('soil_data.spectrum_spectrum_id_seq', 1, false);


--
-- TOC entry 4857 (class 2606 OID 55549188)
-- Name: api_client api_client_api_key_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_api_key_key UNIQUE (api_key);


--
-- TOC entry 4859 (class 2606 OID 55549190)
-- Name: api_client api_client_id_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_id_pkey PRIMARY KEY (api_client_id);


--
-- TOC entry 4861 (class 2606 OID 55549192)
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 4863 (class 2606 OID 55549194)
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (key);


--
-- TOC entry 4869 (class 2606 OID 55549196)
-- Name: uploaded_dataset_column uploaded_dataset_column_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name);


--
-- TOC entry 4865 (class 2606 OID 55549198)
-- Name: uploaded_dataset uploaded_dataset_file_name_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_file_name_key UNIQUE (file_name);


--
-- TOC entry 4867 (class 2606 OID 55549200)
-- Name: uploaded_dataset uploaded_dataset_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_pkey PRIMARY KEY (table_name);


--
-- TOC entry 4871 (class 2606 OID 55549202)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4901 (class 2606 OID 55549204)
-- Name: category_desc category_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.category_desc
    ADD CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id);


--
-- TOC entry 4873 (class 2606 OID 55549206)
-- Name: element element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT element_pkey PRIMARY KEY (element_id);


--
-- TOC entry 4903 (class 2606 OID 55549208)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4905 (class 2606 OID 55549210)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_code);


--
-- TOC entry 4907 (class 2606 OID 55549212)
-- Name: observation_desc observation_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.observation_desc
    ADD CONSTRAINT observation_desc_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4877 (class 2606 OID 55549214)
-- Name: observation_num observation_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_pkey PRIMARY KEY (observation_num_id);


--
-- TOC entry 4879 (class 2606 OID 55549216)
-- Name: observation_num observation_num_property_num_id_procedure_num_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_procedure_num_key UNIQUE (property_num_id, procedure_num_id);


--
-- TOC entry 4909 (class 2606 OID 55549218)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4881 (class 2606 OID 55549220)
-- Name: plot plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (plot_id);


--
-- TOC entry 4911 (class 2606 OID 55549222)
-- Name: procedure_desc procedure_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_pkey PRIMARY KEY (procedure_desc_id);


--
-- TOC entry 4913 (class 2606 OID 55549224)
-- Name: procedure_desc procedure_desc_uri_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_uri_key UNIQUE (uri);


--
-- TOC entry 4917 (class 2606 OID 55549226)
-- Name: procedure_model_def procedure_model_def_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_model_def
    ADD CONSTRAINT procedure_model_def_pkey PRIMARY KEY (procedure_model_id, key);


--
-- TOC entry 4915 (class 2606 OID 55549228)
-- Name: procedure_model procedure_model_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_model
    ADD CONSTRAINT procedure_model_pkey PRIMARY KEY (procedure_model_id);


--
-- TOC entry 4919 (class 2606 OID 55549230)
-- Name: procedure_num procedure_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_pkey PRIMARY KEY (procedure_num_id);


--
-- TOC entry 4923 (class 2606 OID 55549232)
-- Name: procedure_spectrometer_def procedure_spectrometer_def_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_spectrometer_def
    ADD CONSTRAINT procedure_spectrometer_def_pkey PRIMARY KEY (procedure_spectrometer_id, key);


--
-- TOC entry 4921 (class 2606 OID 55549234)
-- Name: procedure_spectrometer procedure_spectrometer_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_spectrometer
    ADD CONSTRAINT procedure_spectrometer_pkey PRIMARY KEY (procedure_spectrometer_id);


--
-- TOC entry 4883 (class 2606 OID 55549236)
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 4925 (class 2606 OID 55549238)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4893 (class 2606 OID 55549240)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 4897 (class 2606 OID 55549242)
-- Name: project_site project_site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id);


--
-- TOC entry 4927 (class 2606 OID 55549244)
-- Name: project_soil_map project_soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_pkey PRIMARY KEY (project_id, soil_map_id);


--
-- TOC entry 4929 (class 2606 OID 55549246)
-- Name: property_desc property_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_desc
    ADD CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id);


--
-- TOC entry 4931 (class 2606 OID 55549248)
-- Name: property_num property_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT property_num_pkey PRIMARY KEY (property_num_id);


--
-- TOC entry 4933 (class 2606 OID 55549250)
-- Name: result_desc_element result_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_pkey PRIMARY KEY (element_id, property_desc_id);


--
-- TOC entry 4935 (class 2606 OID 55549252)
-- Name: result_desc_plot result_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_pkey PRIMARY KEY (plot_id, property_desc_id);


--
-- TOC entry 4937 (class 2606 OID 55549254)
-- Name: result_desc_profile result_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_pkey PRIMARY KEY (profile_id, property_desc_id);


--
-- TOC entry 4939 (class 2606 OID 55549256)
-- Name: result_desc_surface result_desc_surface_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT result_desc_surface_pkey PRIMARY KEY (surface_id, property_desc_id);


--
-- TOC entry 4887 (class 2606 OID 55549258)
-- Name: result_num result_num_specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_specimen_pkey PRIMARY KEY (observation_num_id, specimen_id);


--
-- TOC entry 4941 (class 2606 OID 55549260)
-- Name: result_spectral result_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_pkey PRIMARY KEY (result_spectral_id);


--
-- TOC entry 4899 (class 2606 OID 55549262)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (site_id);


--
-- TOC entry 4944 (class 2606 OID 55549264)
-- Name: soil_map soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_map
    ADD CONSTRAINT soil_map_pkey PRIMARY KEY (soil_map_id);


--
-- TOC entry 4952 (class 2606 OID 55549266)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4948 (class 2606 OID 55549268)
-- Name: soil_mapping_unit soil_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_pkey PRIMARY KEY (mapping_unit_id);


--
-- TOC entry 4954 (class 2606 OID 55549270)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_pkey PRIMARY KEY (mapping_unit_id, profile_id);


--
-- TOC entry 4958 (class 2606 OID 55549272)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_pkey PRIMARY KEY (typological_unit_id, mapping_unit_id);


--
-- TOC entry 4956 (class 2606 OID 55549274)
-- Name: soil_typological_unit soil_typological_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit
    ADD CONSTRAINT soil_typological_unit_pkey PRIMARY KEY (typological_unit_id);


--
-- TOC entry 4960 (class 2606 OID 55549276)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_pkey PRIMARY KEY (typological_unit_id, profile_id);


--
-- TOC entry 4889 (class 2606 OID 55549278)
-- Name: specimen specimen_code_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_code_key UNIQUE (code);


--
-- TOC entry 4891 (class 2606 OID 55549280)
-- Name: specimen specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_pkey PRIMARY KEY (specimen_id);


--
-- TOC entry 4962 (class 2606 OID 55549282)
-- Name: specimen_prep_process specimen_prep_process_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_definition_key UNIQUE (definition);


--
-- TOC entry 4964 (class 2606 OID 55549284)
-- Name: specimen_prep_process specimen_prep_process_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_pkey PRIMARY KEY (specimen_prep_process_id);


--
-- TOC entry 4966 (class 2606 OID 55549286)
-- Name: specimen_storage specimen_storage_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_definition_key UNIQUE (definition);


--
-- TOC entry 4968 (class 2606 OID 55549288)
-- Name: specimen_storage specimen_storage_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_pkey PRIMARY KEY (specimen_storage_id);


--
-- TOC entry 4972 (class 2606 OID 55549290)
-- Name: specimen_transport specimen_transport_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_definition_key UNIQUE (definition);


--
-- TOC entry 4974 (class 2606 OID 55549292)
-- Name: specimen_transport specimen_transport_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_pkey PRIMARY KEY (specimen_transport_id);


--
-- TOC entry 4978 (class 2606 OID 55549294)
-- Name: spectral_sample spectral_sample_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectral_sample
    ADD CONSTRAINT spectral_sample_pkey PRIMARY KEY (spectral_sample_id);


--
-- TOC entry 4980 (class 2606 OID 55549296)
-- Name: spectrum spectrum_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectrum
    ADD CONSTRAINT spectrum_pkey PRIMARY KEY (spectrum_id);


--
-- TOC entry 4982 (class 2606 OID 55549298)
-- Name: spectrum_x_result_spectral spectrum_x_result_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectrum_x_result_spectral
    ADD CONSTRAINT spectrum_x_result_spectral_pkey PRIMARY KEY (result_spectral_id, spectrum_id);


--
-- TOC entry 4984 (class 2606 OID 55549300)
-- Name: translate translate_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_pkey PRIMARY KEY (table_name, column_name, language_code, string);


--
-- TOC entry 4986 (class 2606 OID 55549302)
-- Name: unit_of_measure unit_of_measure_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unit_of_measure_pkey PRIMARY KEY (unit_of_measure_id);


--
-- TOC entry 4875 (class 2606 OID 55549304)
-- Name: element unq_element_profile_order_element; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT unq_element_profile_order_element UNIQUE (profile_id, order_element);


--
-- TOC entry 4885 (class 2606 OID 55549306)
-- Name: profile unq_profile_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT unq_profile_code UNIQUE (profile_code);


--
-- TOC entry 4895 (class 2606 OID 55549308)
-- Name: project unq_project_name; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT unq_project_name UNIQUE (name);


--
-- TOC entry 4970 (class 2606 OID 55549310)
-- Name: specimen_storage unq_specimen_storage_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT unq_specimen_storage_label UNIQUE (label);


--
-- TOC entry 4976 (class 2606 OID 55549312)
-- Name: specimen_transport unq_specimen_transport_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT unq_specimen_transport_label UNIQUE (label);


--
-- TOC entry 4988 (class 2606 OID 55549314)
-- Name: unit_of_measure unq_unit_of_measure_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unq_unit_of_measure_uri UNIQUE (uri);


--
-- TOC entry 4990 (class 2606 OID 55549316)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (mapset_id, value);


--
-- TOC entry 4992 (class 2606 OID 55549318)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 4994 (class 2606 OID 55549320)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4996 (class 2606 OID 55549322)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4998 (class 2606 OID 55549324)
-- Name: mapset mapset_file_identifier_key; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_file_identifier_key UNIQUE (file_identifier);


--
-- TOC entry 5000 (class 2606 OID 55549326)
-- Name: mapset mapset_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_pkey PRIMARY KEY (mapset_id);


--
-- TOC entry 5002 (class 2606 OID 55549328)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 5004 (class 2606 OID 55549330)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (country_id, project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 5006 (class 2606 OID 55549332)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (country_id, project_id);


--
-- TOC entry 5008 (class 2606 OID 55549334)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 5010 (class 2606 OID 55549336)
-- Name: url url_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (mapset_id, protocol, url);


--
-- TOC entry 4949 (class 1259 OID 55549337)
-- Name: idx_category_map; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_map ON soil_data.soil_mapping_unit_category USING btree (soil_map_id);


--
-- TOC entry 5767 (class 0 OID 0)
-- Dependencies: 4949
-- Name: INDEX idx_category_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_map IS 'Index on soil map for root categories';


--
-- TOC entry 4950 (class 1259 OID 55549338)
-- Name: idx_category_parent; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_parent ON soil_data.soil_mapping_unit_category USING btree (parent_category_id);


--
-- TOC entry 5768 (class 0 OID 0)
-- Dependencies: 4950
-- Name: INDEX idx_category_parent; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_parent IS 'Index on parent category for hierarchy traversal';


--
-- TOC entry 4945 (class 1259 OID 55549339)
-- Name: idx_mapping_unit_category; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_category ON soil_data.soil_mapping_unit USING btree (category_id);


--
-- TOC entry 5769 (class 0 OID 0)
-- Dependencies: 4945
-- Name: INDEX idx_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_category IS 'Index on category for joining with category table';


--
-- TOC entry 4946 (class 1259 OID 55549340)
-- Name: idx_mapping_unit_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_geom ON soil_data.soil_mapping_unit USING gist (geom);


--
-- TOC entry 5770 (class 0 OID 0)
-- Dependencies: 4946
-- Name: INDEX idx_mapping_unit_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_geom IS 'Spatial index on mapping unit geometry';


--
-- TOC entry 4942 (class 1259 OID 55549341)
-- Name: idx_soil_map_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_soil_map_geom ON soil_data.soil_map USING gist (geom);


--
-- TOC entry 5771 (class 0 OID 0)
-- Dependencies: 4942
-- Name: INDEX idx_soil_map_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_soil_map_geom IS 'Spatial index on soil map extent geometry';


--
-- TOC entry 5081 (class 2620 OID 55549342)
-- Name: result_num trg_check_result_value; Type: TRIGGER; Schema: soil_data; Owner: carva014
--

CREATE TRIGGER trg_check_result_value BEFORE INSERT OR UPDATE ON soil_data.result_num FOR EACH ROW EXECUTE FUNCTION soil_data.check_result_value();


--
-- TOC entry 5083 (class 2620 OID 55549343)
-- Name: layer class_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER class_func_on_layer_table AFTER UPDATE OF stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.class();


--
-- TOC entry 5084 (class 2620 OID 55549344)
-- Name: layer map_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER map_func_on_layer_table AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.map();


--
-- TOC entry 5082 (class 2620 OID 55549345)
-- Name: class sld_func_on_class_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER sld_func_on_class_table AFTER INSERT OR UPDATE ON spatial_metadata.class FOR EACH ROW EXECUTE FUNCTION spatial_metadata.sld();


--
-- TOC entry 5011 (class 2606 OID 55549346)
-- Name: audit audit_api_client_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_api_client_id_fkey FOREIGN KEY (api_client_id) REFERENCES api.api_client(api_client_id) ON UPDATE CASCADE;


--
-- TOC entry 5012 (class 2606 OID 55549351)
-- Name: audit audit_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5015 (class 2606 OID 55549356)
-- Name: uploaded_dataset_column uploaded_dataset_column_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5016 (class 2606 OID 55549361)
-- Name: uploaded_dataset_column uploaded_dataset_column_property_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5017 (class 2606 OID 55549366)
-- Name: uploaded_dataset_column uploaded_dataset_column_table_name_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name) REFERENCES api.uploaded_dataset(table_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5018 (class 2606 OID 55549371)
-- Name: uploaded_dataset_column uploaded_dataset_column_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5013 (class 2606 OID 55549376)
-- Name: uploaded_dataset uploaded_dataset_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 5014 (class 2606 OID 55549381)
-- Name: uploaded_dataset uploaded_dataset_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5043 (class 2606 OID 55549386)
-- Name: result_desc_element fk_element; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT fk_element FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id);


--
-- TOC entry 5025 (class 2606 OID 55549391)
-- Name: profile fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5045 (class 2606 OID 55549396)
-- Name: result_desc_plot fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5019 (class 2606 OID 55549401)
-- Name: element fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5047 (class 2606 OID 55549406)
-- Name: result_desc_profile fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5030 (class 2606 OID 55549411)
-- Name: project_site fk_project; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id);


--
-- TOC entry 5023 (class 2606 OID 55549416)
-- Name: plot fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5031 (class 2606 OID 55549421)
-- Name: project_site fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5026 (class 2606 OID 55549426)
-- Name: result_num fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 5028 (class 2606 OID 55549431)
-- Name: specimen fk_specimen_prep_process; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT fk_specimen_prep_process FOREIGN KEY (specimen_prep_process_id) REFERENCES soil_data.specimen_prep_process(specimen_prep_process_id);


--
-- TOC entry 5062 (class 2606 OID 55549436)
-- Name: specimen_prep_process fk_specimen_storage; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_storage FOREIGN KEY (specimen_storage_id) REFERENCES soil_data.specimen_storage(specimen_storage_id);


--
-- TOC entry 5063 (class 2606 OID 55549441)
-- Name: specimen_prep_process fk_specimen_transport; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_transport FOREIGN KEY (specimen_transport_id) REFERENCES soil_data.specimen_transport(specimen_transport_id);


--
-- TOC entry 5049 (class 2606 OID 55549446)
-- Name: result_desc_surface fk_surface; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT fk_surface FOREIGN KEY (surface_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5020 (class 2606 OID 55549451)
-- Name: observation_num observation_bum_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_bum_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5032 (class 2606 OID 55549456)
-- Name: observation_desc observation_desc_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.observation_desc
    ADD CONSTRAINT observation_desc_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5033 (class 2606 OID 55549461)
-- Name: observation_desc observation_desc_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.observation_desc
    ADD CONSTRAINT observation_desc_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5034 (class 2606 OID 55549466)
-- Name: observation_desc observation_desc_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.observation_desc
    ADD CONSTRAINT observation_desc_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5021 (class 2606 OID 55549471)
-- Name: observation_num observation_num_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 55549476)
-- Name: observation_num observation_num_property_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5024 (class 2606 OID 55549481)
-- Name: plot plot_parent_plot_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_parent_plot_id_fkey FOREIGN KEY (parent_plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5035 (class 2606 OID 55549486)
-- Name: procedure_model_def procedure_model_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_model_def
    ADD CONSTRAINT procedure_model_id_fkey FOREIGN KEY (procedure_model_id) REFERENCES soil_data.procedure_model(procedure_model_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5036 (class 2606 OID 55549491)
-- Name: procedure_num procedure_num_broader_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_broader_id_fkey FOREIGN KEY (broader_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5037 (class 2606 OID 55549496)
-- Name: procedure_spectrometer_def procedure_spectrometer_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.procedure_spectrometer_def
    ADD CONSTRAINT procedure_spectrometer_id_fkey FOREIGN KEY (procedure_spectrometer_id) REFERENCES soil_data.procedure_spectrometer(procedure_spectrometer_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5038 (class 2606 OID 55549501)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5039 (class 2606 OID 55549506)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5040 (class 2606 OID 55549511)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5041 (class 2606 OID 55549516)
-- Name: project_soil_map project_soil_map_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON DELETE CASCADE;


--
-- TOC entry 5042 (class 2606 OID 55549521)
-- Name: project_soil_map project_soil_map_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 55549526)
-- Name: result_desc_element result_desc_element_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5046 (class 2606 OID 55549531)
-- Name: result_desc_plot result_desc_plot_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5048 (class 2606 OID 55549536)
-- Name: result_desc_profile result_desc_profile_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5050 (class 2606 OID 55549541)
-- Name: result_desc_surface result_desc_surface_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT result_desc_surface_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5027 (class 2606 OID 55549546)
-- Name: result_num result_num_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id);


--
-- TOC entry 5051 (class 2606 OID 55549551)
-- Name: result_spectral result_spectral_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id);


--
-- TOC entry 5052 (class 2606 OID 55549556)
-- Name: result_spectral result_spectral_procedure_model_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_procedure_model_id_fkey FOREIGN KEY (procedure_model_id) REFERENCES soil_data.procedure_model(procedure_model_id) ON UPDATE CASCADE;


--
-- TOC entry 5053 (class 2606 OID 55549561)
-- Name: soil_mapping_unit soil_mapping_unit_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_category_id_fkey FOREIGN KEY (category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 55549566)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 55549571)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 55549576)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5057 (class 2606 OID 55549581)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5058 (class 2606 OID 55549586)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 55549591)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5060 (class 2606 OID 55549596)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5061 (class 2606 OID 55549601)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5029 (class 2606 OID 55549606)
-- Name: specimen specimen_element_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_element_id_fkey FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5064 (class 2606 OID 55549611)
-- Name: spectral_sample spectral_sample_specimen_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectral_sample
    ADD CONSTRAINT spectral_sample_specimen_id_fkey FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5065 (class 2606 OID 55549616)
-- Name: spectrum spectrum_procedure_spectrometer_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectrum
    ADD CONSTRAINT spectrum_procedure_spectrometer_id_fkey FOREIGN KEY (procedure_spectrometer_id) REFERENCES soil_data.procedure_spectrometer(procedure_spectrometer_id) ON UPDATE CASCADE;


--
-- TOC entry 5066 (class 2606 OID 55549621)
-- Name: spectrum spectrum_spectral_sample_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectrum
    ADD CONSTRAINT spectrum_spectral_sample_id_fkey FOREIGN KEY (spectral_sample_id) REFERENCES soil_data.spectral_sample(spectral_sample_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5067 (class 2606 OID 55549626)
-- Name: spectrum_x_result_spectral spectrum_x_result_spectral_result_spectral_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: carva014
--

ALTER TABLE ONLY soil_data.spectrum_x_result_spectral
    ADD CONSTRAINT spectrum_x_result_spectral_result_spectral_id_fkey FOREIGN KEY (result_spectral_id) REFERENCES soil_data.result_spectral(result_spectral_id) ON UPDATE CASCADE;


--
-- TOC entry 5068 (class 2606 OID 55549631)
-- Name: translate translate_language_code_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_language_code_fkey FOREIGN KEY (language_code) REFERENCES soil_data.languages(language_code);


--
-- TOC entry 5069 (class 2606 OID 55549636)
-- Name: class class_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5070 (class 2606 OID 55549641)
-- Name: layer layer_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5071 (class 2606 OID 55549646)
-- Name: mapset mapset_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5072 (class 2606 OID 55549651)
-- Name: mapset mapset_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE;


--
-- TOC entry 5073 (class 2606 OID 55549656)
-- Name: mapset mapset_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5074 (class 2606 OID 55549661)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5075 (class 2606 OID 55549666)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5076 (class 2606 OID 55549671)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5077 (class 2606 OID 55549676)
-- Name: project project_country_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_country_id_fkey FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE;


--
-- TOC entry 5078 (class 2606 OID 55549681)
-- Name: property property_property_num_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5079 (class 2606 OID 55549686)
-- Name: property property_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5080 (class 2606 OID 55549691)
-- Name: url url_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA api TO sis_r;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA kobo; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA kobo TO sis_r;
GRANT ALL ON SCHEMA kobo TO kobo;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sis
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data TO sis_r;


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA soil_data_upload; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data_upload TO sis_r;


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA spatial_metadata; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA spatial_metadata TO sis_r;


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 1641
-- Name: FUNCTION check_result_value(); Type: ACL; Schema: soil_data; Owner: sis
--

GRANT ALL ON FUNCTION soil_data.check_result_value() TO sis_r;


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 1643
-- Name: FUNCTION class(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.class() TO sis_r;


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 1644
-- Name: FUNCTION map(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.map() TO sis_r;


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 1645
-- Name: FUNCTION sld(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.sld() TO sis_r;


--
-- TOC entry 5335 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE api_client; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.api_client TO sis_r;


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE audit; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.audit TO sis_r;


--
-- TOC entry 5348 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE setting; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.setting TO sis_r;


--
-- TOC entry 5364 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE uploaded_dataset; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


--
-- TOC entry 5373 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE uploaded_dataset_column; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;


--
-- TOC entry 5382 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "user"; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api."user" TO sis_r;


--
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.element TO sis_r;


--
-- TOC entry 5398 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE observation_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_num TO sis_r;


--
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot TO sis_r;


--
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profile TO sis_r;


--
-- TOC entry 5413 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE specimen; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen TO sis_r;


--
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE project; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project TO sis_r;


--
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE project_site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.site TO sis_r;


--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE category_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.category_desc TO sis_r;


--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 246
-- Name: SEQUENCE element_element_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.element_element_id_seq TO sis_r;


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.individual TO sis_r;


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE languages; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.languages TO sis_r;


--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 250
-- Name: SEQUENCE observation_phys_chem_element_observation_phys_chem_element_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.observation_phys_chem_element_observation_phys_chem_element_seq TO sis_r;


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE organisation; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.organisation TO sis_r;


--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 252
-- Name: SEQUENCE plot_plot_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.plot_plot_id_seq TO sis_r;


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE procedure_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_desc TO sis_r;


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE procedure_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_num TO sis_r;


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 261
-- Name: SEQUENCE profile_profile_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.profile_profile_id_seq TO sis_r;


--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_soil_map TO sis_r;


--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE property_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_desc TO sis_r;


--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE property_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_num TO sis_r;


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE result_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_element TO sis_r;


--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE result_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_plot TO sis_r;


--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE result_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_profile TO sis_r;


--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 272
-- Name: SEQUENCE site_site_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.site_site_id_seq TO sis_r;


--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_map TO sis_r;


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 274
-- Name: SEQUENCE soil_map_soil_map_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_map_soil_map_id_seq TO sis_r;


--
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE soil_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit TO sis_r;


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_category TO sis_r;


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 277
-- Name: SEQUENCE soil_mapping_unit_category_category_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_category_category_id_seq TO sis_r;


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 278
-- Name: SEQUENCE soil_mapping_unit_mapping_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_mapping_unit_id_seq TO sis_r;


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE soil_mapping_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_profile TO sis_r;


--
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit TO sis_r;


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_mapping_unit TO sis_r;


--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_profile TO sis_r;


--
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 283
-- Name: SEQUENCE soil_typological_unit_typological_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_typological_unit_typological_unit_id_seq TO sis_r;


--
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE specimen_prep_process; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_prep_process TO sis_r;


--
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 285
-- Name: SEQUENCE specimen_prep_process_specimen_prep_process_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_prep_process_specimen_prep_process_id_seq TO sis_r;


--
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 286
-- Name: SEQUENCE specimen_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_specimen_id_seq TO sis_r;


--
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE specimen_storage; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_storage TO sis_r;


--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 288
-- Name: SEQUENCE specimen_storage_specimen_storage_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_storage_specimen_storage_id_seq TO sis_r;


--
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE specimen_transport; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_transport TO sis_r;


--
-- TOC entry 5577 (class 0 OID 0)
-- Dependencies: 290
-- Name: SEQUENCE specimen_transport_specimen_transport_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_transport_specimen_transport_id_seq TO sis_r;


--
-- TOC entry 5584 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE translate; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.translate TO sis_r;


--
-- TOC entry 5589 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE unit_of_measure; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.unit_of_measure TO sis_r;


--
-- TOC entry 5598 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE class; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


--
-- TOC entry 5618 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE country; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


--
-- TOC entry 5622 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE individual; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


--
-- TOC entry 5660 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE layer; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


--
-- TOC entry 5702 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE mapset; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;


--
-- TOC entry 5713 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE organisation; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


--
-- TOC entry 5722 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5728 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE project; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


--
-- TOC entry 5741 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE property; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


--
-- TOC entry 5748 (class 0 OID 0)
-- Dependencies: 306
-- Name: TABLE url; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--
-- TOC entry 3588 (class 826 OID 55549696)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: api; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3589 (class 826 OID 55549697)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3590 (class 826 OID 55549698)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data_upload; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;


-- Completed on 2026-04-01 14:45:07 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict epgGUAy2V2FKhYOL7ndefyUxmdcSemClNPyYxS6kgSUiwBhf1l7uMsgbzkeakng

