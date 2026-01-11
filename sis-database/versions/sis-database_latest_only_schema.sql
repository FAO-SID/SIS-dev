--
-- PostgreSQL database dump
--

\restrict F8tQHTcCZclFx3tTgC8DGwNWggdtb3DdDbnYOUf05I4wqfb0yHh841kvF5nnGhE

-- Dumped from database version 12.22 (Ubuntu 12.22-3.pgdg22.04+1)
-- Dumped by pg_dump version 18.1 (Ubuntu 18.1-1.pgdg22.04+2)

-- Started on 2026-01-11 10:09:46 CET

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
-- TOC entry 12 (class 2615 OID 55216397)
-- Name: api; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO sis;

--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA api IS 'REST API tables';


--
-- TOC entry 16 (class 2615 OID 55216216)
-- Name: kobo; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA kobo;


ALTER SCHEMA kobo OWNER TO sis;

--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA kobo; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA kobo IS 'GloSIS data collection database schema';


--
-- TOC entry 11 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: sis
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO sis;

--
-- TOC entry 14 (class 2615 OID 55214372)
-- Name: soil_data; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data;


ALTER SCHEMA soil_data OWNER TO sis;

--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data IS 'Core entities and relations from the ISO-28258 domain model';


--
-- TOC entry 13 (class 2615 OID 55216482)
-- Name: soil_data_upload; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data_upload;


ALTER SCHEMA soil_data_upload OWNER TO sis;

--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA soil_data_upload; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data_upload IS 'Schema to upload soil data';


--
-- TOC entry 15 (class 2615 OID 55216217)
-- Name: spatial_metadata; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA spatial_metadata;


ALTER SCHEMA spatial_metadata OWNER TO sis;

--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA spatial_metadata IS 'Schema for spatial metadata';


--
-- TOC entry 5 (class 3079 OID 55212637)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 4 (class 3079 OID 55213723)
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- TOC entry 3 (class 3079 OID 55214284)
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- TOC entry 2 (class 3079 OID 55214361)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1639 (class 1255 OID 55215951)
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
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 1639
-- Name: FUNCTION check_result_value(); Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON FUNCTION soil_data.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';


--
-- TOC entry 1640 (class 1255 OID 55216218)
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
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 1640
-- Name: FUNCTION class(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.class() IS 'Trigger function that automatically generates classification intervals and colors for quantitative properties in mapsets based on layer statistics. Creates class entries with interpolated colors between start and end colors.';


--
-- TOC entry 1641 (class 1255 OID 55216219)
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
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 1641
-- Name: FUNCTION map(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.map() IS 'Trigger function that generates MapServer MAP file content for raster layers. Creates the complete MAP configuration including projection, WMS metadata, and styling based on property colors and layer statistics.';


--
-- TOC entry 1642 (class 1255 OID 55216220)
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
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 1642
-- Name: FUNCTION sld(); Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON FUNCTION spatial_metadata.sld() IS 'Trigger function that generates Styled Layer Descriptor (SLD) XML for mapsets. Creates OGC-compliant SLD documents with ColorMap entries based on the class table for map styling.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 295 (class 1259 OID 55216411)
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
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE api_client; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.api_client IS 'For server-to-server authentication';


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.api_client_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.api_client_id IS 'Unique identifier for the API client';


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.api_key; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.api_key IS 'Secret API key for authentication';


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.is_active; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.is_active IS 'Flag indicating whether the client is active';


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.created_at IS 'Date when the client was created';


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.expires_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.expires_at IS 'Date when the API key expires';


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.last_login; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.last_login IS 'Timestamp of the last successful authentication';


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 295
-- Name: COLUMN api_client.description; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.api_client.description IS 'Description of the API client purpose';


--
-- TOC entry 297 (class 1259 OID 55216426)
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
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE audit; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.audit IS 'Track authentication attempts and API usage';


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.audit_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.audit_id IS 'Synthetic primary key for the audit record';


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.user_id IS 'Reference to the user who performed the action';


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.api_client_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.api_client_id IS 'Reference to the API client that performed the action';


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.action; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.action IS 'Type of action performed';


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.details; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.details IS 'JSON object with action details';


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.ip_address; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.ip_address IS 'IP address from which the action was performed';


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 297
-- Name: COLUMN audit.created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.audit.created_at IS 'Timestamp when the action occurred';


--
-- TOC entry 296 (class 1259 OID 55216424)
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
-- TOC entry 299 (class 1259 OID 55216453)
-- Name: layer; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.layer (
    project_id text,
    project_name text,
    layer_id text NOT NULL,
    publish boolean DEFAULT true,
    property_name text,
    dimension text,
    version text,
    unit_of_measure_id text,
    metadata_url text,
    download_url text,
    get_map_url text,
    get_legend_url text,
    get_feature_info_url text
);


ALTER TABLE api.layer OWNER TO sis;

--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE layer; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.layer IS 'API layer for exposing spatial data layers through the REST API';


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.project_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.project_id IS 'Reference to the project this layer belongs to';


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.project_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.project_name IS 'Human-readable name of the project';


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.layer_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.layer_id IS 'Unique identifier for the layer';


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.publish; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.publish IS 'Flag indicating whether the layer is published and accessible via API';


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.property_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.property_name IS 'Name of the soil property this layer represents';


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.dimension; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.dimension IS 'Dimension type (e.g., depth, time)';


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.version; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.version IS 'Version identifier of the layer';


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.unit_of_measure_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.unit_of_measure_id IS 'Reference to the unit of measure for layer values';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.metadata_url; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.metadata_url IS 'URL to the layer metadata document';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.download_url; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.download_url IS 'URL for downloading the layer data';


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.get_map_url; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.get_map_url IS 'WMS GetMap URL for the layer';


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.get_legend_url; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.get_legend_url IS 'WMS GetLegendGraphic URL for the layer';


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN layer.get_feature_info_url; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.layer.get_feature_info_url IS 'WMS GetFeatureInfo URL for the layer';


--
-- TOC entry 298 (class 1259 OID 55216445)
-- Name: setting; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.setting (
    key text NOT NULL,
    value text
);


ALTER TABLE api.setting OWNER TO sis;

--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE setting; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.setting IS 'Key-value store for API configuration settings';


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN setting.key; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.setting.key IS 'Setting identifier key';


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN setting.value; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.setting.value IS 'Setting value';


--
-- TOC entry 303 (class 1259 OID 55216484)
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
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE uploaded_dataset; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.uploaded_dataset IS 'Tracks datasets uploaded by users for ingestion into the soil data schema';


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.user_id IS 'Reference to the user who uploaded the dataset';


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.project_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.project_id IS 'Reference to the project this dataset belongs to';


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.table_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.table_name IS 'Name of the staging table containing the uploaded data';


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.file_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.file_name IS 'Original filename of the uploaded file';


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.upload_date; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.upload_date IS 'Date when the file was uploaded';


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.ingestion_date; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.ingestion_date IS 'Date when the data was ingested into the main schema';


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.status; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.status IS 'Current status: Uploaded, Ingested, or Removed';


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.depth_if_topsoil; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.depth_if_topsoil IS 'Depth in cm if this is topsoil data';


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.n_rows; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.n_rows IS 'Number of rows in the uploaded dataset';


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.n_col; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.n_col IS 'Number of columns in the uploaded dataset';


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.has_cords; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.has_cords IS 'Flag indicating whether the dataset contains coordinates';


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.cords_epsg; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.cords_epsg IS 'EPSG code of the coordinate reference system';


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.cords_check; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.cords_check IS 'Flag indicating whether coordinates have been validated';


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN uploaded_dataset.note; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset.note IS 'Additional notes about the dataset';


--
-- TOC entry 304 (class 1259 OID 55216507)
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
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE uploaded_dataset_column; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.uploaded_dataset_column IS 'Column mapping configuration for uploaded datasets';


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.table_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.table_name IS 'Reference to the uploaded dataset table';


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.column_name; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.column_name IS 'Name of the column in the uploaded dataset';


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.property_num_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.property_num_id IS 'Mapped soil property identifier';


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.procedure_num_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.procedure_num_id IS 'Mapped analytical procedure identifier';


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.unit_of_measure_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.unit_of_measure_id IS 'Mapped unit of measure identifier';


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.ignore_column; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.ignore_column IS 'Flag to ignore this column during ingestion';


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 304
-- Name: COLUMN uploaded_dataset_column.note; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api.uploaded_dataset_column.note IS 'Additional notes about the column mapping';


--
-- TOC entry 294 (class 1259 OID 55216399)
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
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE "user"; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api."user" IS 'For human users who log in through the web application';


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".user_id; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".user_id IS 'Unique identifier for the user (typically email or username)';


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".password_hash; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".password_hash IS 'Bcrypt hash of the user password';


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".is_active; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".is_active IS 'Flag indicating whether the user account is active';


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".is_admin; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".is_admin IS 'Flag indicating whether the user has administrator privileges';


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".created_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".created_at IS 'Timestamp when the user was created';


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".updated_at; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".updated_at IS 'Timestamp of the last update to the user record';


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 294
-- Name: COLUMN "user".last_login; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON COLUMN api."user".last_login IS 'Timestamp of the last successful login';


--
-- TOC entry 226 (class 1259 OID 55214381)
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
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.element IS 'ProfileElement is the super-class of Horizon and Layer, which share the same basic properties. Horizons develop in a layer, which in turn have been developed throught geogenesis or anthropogenic action. Layers can be used to describe common characteristics of a set of adjoining horizons. For the time being no assocation is previewed between Horizon and Layer.';


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.element_id IS 'Synthetic primary key.';


--
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.profile_id IS 'Reference to the Profile to which this element belongs';


--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.order_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.order_element IS 'Order of this element within the Profile';


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.upper_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.upper_depth IS 'Upper depth of this profile element in centimetres.';


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.lower_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.lower_depth IS 'Lower depth of this profile element in centimetres.';


--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.type IS 'Type of profile element, Horizon or Layer';


--
-- TOC entry 231 (class 1259 OID 55214412)
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
-- TOC entry 5333 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_num IS 'Physio-chemical observations for the Element feature of interest';


--
-- TOC entry 5334 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.observation_num_id IS 'Synthetic primary key for the observation';


--
-- TOC entry 5335 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.property_num_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5336 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.procedure_num_id IS 'Foreign key to the corresponding procedure';


--
-- TOC entry 5337 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.unit_of_measure_id IS 'Foreign key to the corresponding unit of measure (if applicable)';


--
-- TOC entry 5338 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_min; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_min IS 'Minimum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 5339 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_max; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_max IS 'Maximum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 232 (class 1259 OID 55214420)
-- Name: plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.plot (
    plot_id integer NOT NULL,
    site_id integer NOT NULL,
    plot_code character varying,
    map_sheet_code character varying,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.plot OWNER TO sis;

--
-- TOC entry 5341 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot IS 'Elementary area or location where individual observations are made and/or samples are taken. Plot is the main spatial feature of interest in ISO-28258. Plot has three sub-classes: Borehole, Pit and Surface. Surface features its own table since it has its own properties and a different geometry.';


--
-- TOC entry 5342 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_id IS 'Synthetic primary key.';


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.site_id IS 'Foreign key to Site table.';


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_code IS 'Natural key, can be null.';


--
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.map_sheet_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.map_sheet_code IS 'Code identifying the map sheet where the plot may be positioned. Property re-used from GloSIS.';


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.geom IS 'Geodetic coordinates of the spatial position of the plot. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 236 (class 1259 OID 55214450)
-- Name: profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.profile (
    profile_id integer NOT NULL,
    plot_id integer,
    profile_code character varying,
    altitude smallint,
    time_stamp date,
    positional_accuracy smallint,
    geom public.geometry(Point,4326),
    type text,
    CONSTRAINT profile_altitude_check CHECK (((altitude)::numeric > ('-100'::integer)::numeric)),
    CONSTRAINT profile_altitude_check1 CHECK (((altitude)::numeric < (8000)::numeric)),
    CONSTRAINT profile_time_stamp_check CHECK ((time_stamp > '1900-01-01'::date)),
    CONSTRAINT profile_type_check CHECK ((type = ANY (ARRAY['TrialPit'::text, 'Borehole'::text])))
);


ALTER TABLE soil_data.profile OWNER TO sis;

--
-- TOC entry 5348 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.profile IS 'An abstract, ordered set of soil horizons and/or layers.';


--
-- TOC entry 5349 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_id IS 'Synthetic primary key.';


--
-- TOC entry 5350 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.plot_id IS 'Foreign key to Plot feature of interest';


--
-- TOC entry 5351 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_code IS 'Natural primary key, if existing';


--
-- TOC entry 5352 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.altitude; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.altitude IS 'Altitude/elevation of the profile location in meters above sea level';


--
-- TOC entry 5353 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.time_stamp; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.time_stamp IS 'Date when the profile was described or sampled';


--
-- TOC entry 5354 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.positional_accuracy; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.positional_accuracy IS 'Positional accuracy of the coordinates in meters';


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.geom IS 'Point geometry representing the profile location (EPSG:4326)';


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.type IS 'Type of profile: TrialPit or Borehole';


--
-- TOC entry 243 (class 1259 OID 55214539)
-- Name: result_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_num (
    result_num_id integer NOT NULL,
    observation_num_id integer NOT NULL,
    specimen_id integer NOT NULL,
    individual_id integer,
    value real NOT NULL
);


ALTER TABLE soil_data.result_num OWNER TO sis;

--
-- TOC entry 5358 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_num IS 'Numerical results for the Specimen feature interest.';


--
-- TOC entry 5359 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.result_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.result_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5360 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.observation_num_id IS 'Foreign key to the corresponding numerical observation.';


--
-- TOC entry 5361 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.specimen_id IS 'Foreign key to the corresponding Specimen instance.';


--
-- TOC entry 5362 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';


--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.value IS 'Numerical value resulting from applying the refered observation to the refered specimen.';


--
-- TOC entry 246 (class 1259 OID 55214567)
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
-- TOC entry 5365 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen IS 'Soil Specimen is defined in ISO-28258 as: "a subtype of SF_Specimen. Soil Specimen may be taken in the Site, Plot, Profile, or ProfileElement including their subtypes." In this database Specimen is for now only associated to Plot for simplification.';


--
-- TOC entry 5366 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_id IS 'Synthetic primary key.';


--
-- TOC entry 5367 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.element_id IS 'Foreign key to the associated soil Plot';


--
-- TOC entry 5368 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_prep_process_id IS 'Foreign key to the preparation process used on this soil Specimen.';


--
-- TOC entry 5369 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.code IS 'External code used to identify the soil Specimen (if used).';


--
-- TOC entry 300 (class 1259 OID 55216467)
-- Name: vw_api_manifest; Type: VIEW; Schema: api; Owner: sis
--

CREATE VIEW api.vw_api_manifest AS
 SELECT opc.property_num_id AS property,
    count(DISTINCT p.profile_id) AS profiles,
    count(rpc.result_num_id) AS observations,
    public.st_envelope(public.st_collect(p.geom)) AS geom
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
-- TOC entry 5371 (class 0 OID 0)
-- Dependencies: 300
-- Name: VIEW vw_api_manifest; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_manifest IS 'View to expose the list of soil properties and geographical extent';


--
-- TOC entry 238 (class 1259 OID 55214459)
-- Name: project; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project (
    project_id text NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE soil_data.project OWNER TO sis;

--
-- TOC entry 5373 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project IS 'Provides the context of the data collection as a prerequisite for the proper use or reuse of these data.';


--
-- TOC entry 5374 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.project_id IS 'Synthetic primary key.';


--
-- TOC entry 5375 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.name IS 'Natural key with project name.';


--
-- TOC entry 263 (class 1259 OID 55215963)
-- Name: project_site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_site (
    project_id text NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE soil_data.project_site OWNER TO sis;

--
-- TOC entry 5377 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project_site IS 'Junction table linking projects to sites (many-to-many relationship)';


--
-- TOC entry 5378 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN project_site.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_site.project_id IS 'Reference to the project';


--
-- TOC entry 5379 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN project_site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_site.site_id IS 'Reference to the site';


--
-- TOC entry 244 (class 1259 OID 55214555)
-- Name: site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.site (
    site_id integer NOT NULL,
    site_code character varying,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.site OWNER TO sis;

--
-- TOC entry 5381 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.site IS 'Defined area which is subject to a soil quality investigation. Site is not a spatial feature of interest, but provides the link between the spatial features of interest (Plot) to the Project. The geometry can either be a location (point) or extent (polygon) but not both at the same time.';


--
-- TOC entry 5382 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_id IS 'Synthetic primary key.';


--
-- TOC entry 5383 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_code IS 'Natural key, can be null.';


--
-- TOC entry 5384 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.geom IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 302 (class 1259 OID 55216477)
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
-- TOC entry 5386 (class 0 OID 0)
-- Dependencies: 302
-- Name: VIEW vw_api_observation; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';


--
-- TOC entry 301 (class 1259 OID 55216472)
-- Name: vw_api_profile; Type: VIEW; Schema: api; Owner: sis
--

CREATE VIEW api.vw_api_profile AS
 SELECT p.profile_id AS gid,
    p.profile_code,
    proj.name AS project_name,
    p.altitude,
    p.time_stamp AS date,
    p.geom,
    (public.st_asgeojson(plt.geom))::json AS geometry
   FROM ((((soil_data.profile p
     JOIN soil_data.plot plt ON ((p.plot_id = plt.plot_id)))
     JOIN soil_data.site s ON ((plt.site_id = s.site_id)))
     LEFT JOIN soil_data.project_site ps ON ((s.site_id = ps.site_id)))
     LEFT JOIN soil_data.project proj ON ((ps.project_id = proj.project_id)))
  WHERE (p.geom IS NOT NULL)
  ORDER BY p.profile_id;


ALTER VIEW api.vw_api_profile OWNER TO sis;

--
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 301
-- Name: VIEW vw_api_profile; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_profile IS 'View to expose the list of profiles';


--
-- TOC entry 260 (class 1259 OID 55215811)
-- Name: category_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.category_desc (
    category_desc_id text NOT NULL,
    uri text
);


ALTER TABLE soil_data.category_desc OWNER TO sis;

--
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE category_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.category_desc IS 'Controlled vocabulary categories for descriptive properties. Contains thesaurus entries from GloSIS or other vocabularies.';


--
-- TOC entry 5391 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN category_desc.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.category_desc.category_desc_id IS 'Primary key identifier for the category';


--
-- TOC entry 5392 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN category_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.category_desc.uri IS 'URI to the corresponding entry in a controlled vocabulary (e.g., GloSIS thesaurus)';


--
-- TOC entry 227 (class 1259 OID 55214387)
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
-- TOC entry 265 (class 1259 OID 55215989)
-- Name: individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE soil_data.individual OWNER TO sis;

--
-- TOC entry 5395 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE individual; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.individual IS 'Individuals associated with soil data collection, analysis, or project management';


--
-- TOC entry 5396 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN individual.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.individual.individual_id IS 'Unique identifier for the individual (typically name)';


--
-- TOC entry 5397 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN individual.email; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.individual.email IS 'Email address of the individual';


--
-- TOC entry 261 (class 1259 OID 55215930)
-- Name: languages; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.languages (
    language_code text NOT NULL,
    language_name text NOT NULL
);


ALTER TABLE soil_data.languages OWNER TO sis;

--
-- TOC entry 5399 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE languages; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.languages IS 'Reference table of supported languages for translations';


--
-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN languages.language_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.languages.language_code IS 'ISO 639-1 two-letter language code';


--
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN languages.language_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.languages.language_name IS 'Full name of the language in English';


--
-- TOC entry 228 (class 1259 OID 55214389)
-- Name: observation_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.observation_desc_element (
    procedure_desc_id text NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL,
    category_order smallint
);


ALTER TABLE soil_data.observation_desc_element OWNER TO sis;

--
-- TOC entry 5403 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_element IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5405 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.category_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.category_order IS 'Display order of categories for this property';


--
-- TOC entry 229 (class 1259 OID 55214392)
-- Name: observation_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.observation_desc_plot (
    procedure_desc_id text NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL,
    category_order smallint
);


ALTER TABLE soil_data.observation_desc_plot OWNER TO sis;

--
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_plot IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 5413 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.category_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.category_order IS 'Display order of categories for this property';


--
-- TOC entry 230 (class 1259 OID 55214395)
-- Name: observation_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.observation_desc_profile (
    procedure_desc_id text NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL,
    category_order smallint
);


ALTER TABLE soil_data.observation_desc_profile OWNER TO sis;

--
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_profile IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.category_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.category_order IS 'Display order of categories for this property';


--
-- TOC entry 255 (class 1259 OID 55215372)
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
-- TOC entry 264 (class 1259 OID 55215981)
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
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE organisation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.organisation IS 'Organizations involved in soil data projects and surveys';


--
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.organisation_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.organisation_id IS 'Unique identifier for the organization (typically name)';


--
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.url; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.url IS 'Website URL of the organization';


--
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.email; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.email IS 'Contact email for the organization';


--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.country; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.country IS 'Country where the organization is located';


--
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.city; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.city IS 'City where the organization is located';


--
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.postal_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.postal_code IS 'Postal code of the organization address';


--
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.delivery_point; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.delivery_point IS 'Street address of the organization';


--
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.phone; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.phone IS 'Phone number of the organization';


--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN organisation.facsimile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.organisation.facsimile IS 'Fax number of the organization';


--
-- TOC entry 233 (class 1259 OID 55214432)
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
-- TOC entry 234 (class 1259 OID 55214434)
-- Name: procedure_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_desc (
    procedure_desc_id text NOT NULL,
    reference character varying,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.procedure_desc OWNER TO sis;

--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_desc IS 'Descriptive Procedures for all features of interest. In most cases the procedure is described in a document such as the FAO Guidelines for Soil Description or the World Reference Base of Soil Resources.';


--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.procedure_desc_id IS 'Synthetic primary key.';


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.reference IS 'Long and human readable reference to the publication.';


--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.uri IS 'URI to the corresponding publication, optimally a DOI. Follow this URI for the full definition of the procedure.';


--
-- TOC entry 235 (class 1259 OID 55214442)
-- Name: procedure_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_num (
    procedure_num_id text NOT NULL,
    broader_id text,
    uri character varying NOT NULL,
    definition text,
    reference text,
    citation text
);


ALTER TABLE soil_data.procedure_num OWNER TO sis;

--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_num IS 'Physio-chemical Procedures for the Profile Element feature of interest';


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.procedure_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.broader_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.broader_id IS 'Foreign key to brader procedure in the hierarchy';


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.uri IS 'URI to the corresponding in a controlled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this procedure';


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.definition IS 'Text definition of the procedure';


--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.reference IS 'Reference citation for the procedure';


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.citation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.citation IS 'Full bibliographic citation for the procedure';


--
-- TOC entry 271 (class 1259 OID 55216068)
-- Name: procedure_spectral; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_spectral (
    spectral_data_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE soil_data.procedure_spectral OWNER TO sis;

--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE procedure_spectral; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_spectral IS 'Metadata key-value pairs describing spectral measurement procedures';


--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN procedure_spectral.spectral_data_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_spectral.spectral_data_id IS 'Reference to the spectral data record';


--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN procedure_spectral.key; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_spectral.key IS 'Metadata key (e.g., instrument, wavelength_range, resolution)';


--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN procedure_spectral.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_spectral.value IS 'Metadata value';


--
-- TOC entry 237 (class 1259 OID 55214457)
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
-- TOC entry 266 (class 1259 OID 55215997)
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
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE proj_x_org_x_ind; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.proj_x_org_x_ind IS 'Junction table linking projects, organizations, and individuals with their roles';


--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.project_id IS 'Reference to the project';


--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind.organisation_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.organisation_id IS 'Reference to the organization';


--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.individual_id IS 'Reference to the individual';


--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind."position"; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind."position" IS 'Position or job title of the individual within the organization';


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind.tag; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.tag IS 'Contact type: contact or pointOfContact';


--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN proj_x_org_x_ind.role; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.proj_x_org_x_ind.role IS 'ISO 19115 CI_RoleCode: author, custodian, distributor, etc.';


--
-- TOC entry 274 (class 1259 OID 55216092)
-- Name: project_soil_map; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_soil_map (
    project_id text NOT NULL,
    soil_map_id integer NOT NULL,
    remarks text
);


ALTER TABLE soil_data.project_soil_map OWNER TO sis;

--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE project_soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project_soil_map IS 'Links soil maps to projects (relatedMap many-to-many)';


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.project_id IS 'Reference to the project';


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.soil_map_id IS 'Reference to the soil map (relatedMap)';


--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 259 (class 1259 OID 55215803)
-- Name: property_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_desc (
    property_desc_id text NOT NULL,
    property_pretty_name text,
    uri text
);


ALTER TABLE soil_data.property_desc OWNER TO sis;

--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE property_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_desc IS 'Descriptive soil properties used for categorical observations';


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN property_desc.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_desc.property_desc_id IS 'Primary key identifier for the property';


--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN property_desc.property_pretty_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_desc.property_pretty_name IS 'Human-readable display name for the property';


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN property_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_desc.uri IS 'URI to the corresponding code in a controlled vocabulary';


--
-- TOC entry 239 (class 1259 OID 55214516)
-- Name: property_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_num (
    property_num_id text NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.property_num OWNER TO sis;

--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_num IS 'Physio-chemical properties for the Element feature of interest';


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.property_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.uri IS 'URI to the corresponding code in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this property';


--
-- TOC entry 240 (class 1259 OID 55214524)
-- Name: result_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_element (
    element_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_element OWNER TO sis;

--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_element IS 'Descriptive results for the Element feature interest.';


--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.element_id IS 'Foreign key to the corresponding Element feature of interest.';


--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.property_desc_id IS 'Foreign key to property_desc_element table.';


--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.category_desc_id IS 'Foreign key to thesaurus_desc_element table.';


--
-- TOC entry 241 (class 1259 OID 55214527)
-- Name: result_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_plot (
    plot_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_plot OWNER TO sis;

--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_plot IS 'Descriptive results for the Plot feature interest.';


--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.plot_id IS 'Foreign key to the corresponding Plot feature of interest.';


--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.property_desc_id IS 'Foreign key to property_desc_plot table.';


--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.category_desc_id IS 'Foreign key to thesaurus_desc_plot table.';


--
-- TOC entry 242 (class 1259 OID 55214530)
-- Name: result_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_profile (
    profile_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_profile OWNER TO sis;

--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_profile IS 'Descriptive results for the Profile feature interest.';


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.profile_id IS 'Foreign key to the corresponding Profile feature of interest.';


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.property_desc_id IS 'Foreign key to property_desc_profile table.';


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.category_desc_id IS 'Foreign key to thesaurus_desc_profile table.';


--
-- TOC entry 256 (class 1259 OID 55215378)
-- Name: result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.result_num ALTER COLUMN result_num_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 270 (class 1259 OID 55216053)
-- Name: result_spectral; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_spectral (
    result_spectral_id integer NOT NULL,
    observation_num_id integer,
    spectral_data_id integer NOT NULL,
    value real NOT NULL
);


ALTER TABLE soil_data.result_spectral OWNER TO sis;

--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE result_spectral; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_spectral IS 'Individual spectral measurement values at specific wavelengths';


--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN result_spectral.result_spectral_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectral.result_spectral_id IS 'Synthetic primary key';


--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN result_spectral.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectral.observation_num_id IS 'Optional reference to a numerical observation for derived properties';


--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN result_spectral.spectral_data_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectral.spectral_data_id IS 'Reference to the spectral data record';


--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN result_spectral.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectral.value IS 'Spectral measurement value (reflectance, absorbance, etc.)';


--
-- TOC entry 269 (class 1259 OID 55216051)
-- Name: result_spectral_result_spectral_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
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
-- TOC entry 258 (class 1259 OID 55215745)
-- Name: result_spectrum; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_spectrum (
    result_spectrum_id integer NOT NULL,
    specimen_id integer NOT NULL,
    individual_id integer,
    spectrum jsonb
);


ALTER TABLE soil_data.result_spectrum OWNER TO sis;

--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE result_spectrum; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_spectrum IS 'Complete spectral signatures stored as JSON for soil specimens';


--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN result_spectrum.result_spectrum_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectrum.result_spectrum_id IS 'Synthetic primary key';


--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN result_spectrum.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectrum.specimen_id IS 'Reference to the specimen';


--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN result_spectrum.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectrum.individual_id IS 'Individual who performed the spectral measurement';


--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN result_spectrum.spectrum; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_spectrum.spectrum IS 'JSON object containing the full spectral data (wavelengths and values)';


--
-- TOC entry 257 (class 1259 OID 55215743)
-- Name: result_spectrum_result_spectrum_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.result_spectrum ALTER COLUMN result_spectrum_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.result_spectrum_result_spectrum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 55214565)
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
-- TOC entry 273 (class 1259 OID 55216083)
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
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_map IS 'A soil map containing delineated mapping units (ISO 28258 SoilMap feature)';


--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.soil_map_id IS 'Unique identifier for the soil map';


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.name IS 'Name of the soil map';


--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.description IS 'Detailed description of the soil map';


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.scale_denominator; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.scale_denominator IS 'Map scale denominator (e.g., 50000 for 1:50,000)';


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.spatial_resolution_m; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.spatial_resolution_m IS 'Spatial resolution in meters';


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.publication_date; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.publication_date IS 'Date when the map was published';


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.geom IS 'Polygon geometry representing the map extent (EPSG:4326)';


--
-- TOC entry 272 (class 1259 OID 55216081)
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
-- TOC entry 278 (class 1259 OID 55216134)
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
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE soil_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit IS 'Delineated polygon on a soil map (ISO 28258 SoilMappingUnit feature)';


--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.mapping_unit_id IS 'Unique identifier for the mapping unit';


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.category_id IS 'Reference to the mapping unit category (required, many-to-one)';


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.explanation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.explanation IS 'Explanation or description of the mapping unit';


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.geom IS 'MultiPolygon geometry of the mapping unit (EPSG:4326)';


--
-- TOC entry 276 (class 1259 OID 55216112)
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
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_category IS 'Legend category describing soil types in a map with hierarchical subcategories (ISO 28258 SoilMappingUnitCategory)';


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.category_id IS 'Unique identifier for the category';


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.soil_map_id IS 'Reference to soil map - only set for root categories (rootCategory relationship)';


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.parent_category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.parent_category_id IS 'Reference to parent category for subcategory hierarchy';


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.name IS 'Name of the mapping unit category';


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.description IS 'Detailed description of the category';


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.legend_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.legend_order IS 'Order in the map legend';


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.symbol; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.symbol IS 'Symbol used in the map legend';


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.colour_rgb; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.colour_rgb IS 'RGB colour code for map display (e.g., #A52A2A)';


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.remarks IS 'Additional remarks or notes';


--
-- TOC entry 275 (class 1259 OID 55216110)
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
-- TOC entry 277 (class 1259 OID 55216132)
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
-- TOC entry 283 (class 1259 OID 55216197)
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
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE soil_mapping_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_profile IS 'Links profiles to mapping units (profile relationship 0..*)';


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5539 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.profile_id IS 'Reference to the soil profile';


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.is_representative; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.is_representative IS 'Whether this profile is representative for the mapping unit';


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 280 (class 1259 OID 55216151)
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
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit IS 'Soil type classification unit (ISO 28258 SoilTypologicalUnit feature)';


--
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.typological_unit_id IS 'Unique identifier for the typological unit';


--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.name IS 'Name of the soil typological unit';


--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_scheme; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_scheme IS 'Classification scheme used (e.g., WRB, Soil Taxonomy)';


--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_version; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_version IS 'Version of the Classification scheme used';


--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.description IS 'Detailed description of the typological unit';


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 281 (class 1259 OID 55216159)
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
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_mapping_unit IS 'Links typological units to mapping units with percentage composition (representedUnit/mapRepresentation). Percentages per SMU should sum to 100%.';


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.typological_unit_id IS 'Reference to the soil typological unit (STU)';


--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.percentage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.percentage IS 'Percentage of the STU within the SMU (sum per SMU should equal 100)';


--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 282 (class 1259 OID 55216178)
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
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_profile IS 'Links profiles to typological units as typical profiles (typicalProfile relationship)';


--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.typological_unit_id IS 'Reference to the typological unit';


--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.profile_id IS 'Reference to the profile (typicalProfile)';


--
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.is_typical; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.is_typical IS 'Whether this is a typical profile for the typological unit';


--
-- TOC entry 5561 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 279 (class 1259 OID 55216149)
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
-- TOC entry 247 (class 1259 OID 55214573)
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
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_prep_process IS 'Describes the preparation process of a soil Specimen. Contains information that does not result from observation(s).';


--
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_prep_process_id IS 'Synthetic primary key.';


--
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_transport_id IS 'Foreign key for the corresponding mode of transport';


--
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_storage_id IS 'Foreign key for the corresponding mode of storage';


--
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.definition IS 'Further details necessary to define the preparation process.';


--
-- TOC entry 248 (class 1259 OID 55214579)
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
-- TOC entry 249 (class 1259 OID 55214581)
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
-- TOC entry 250 (class 1259 OID 55214583)
-- Name: specimen_storage; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_storage (
    specimen_storage_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_storage OWNER TO sis;

--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_storage IS 'Modes of storage of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.specimen_storage_id IS 'Synthetic primary key.';


--
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.label IS 'Short label for the storage mode.';


--
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.definition IS 'Long definition providing all the necessary details for the storage mode.';


--
-- TOC entry 251 (class 1259 OID 55214589)
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
-- TOC entry 252 (class 1259 OID 55214591)
-- Name: specimen_transport; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_transport (
    specimen_transport_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_transport OWNER TO sis;

--
-- TOC entry 5578 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_transport IS 'Modes of transport of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5579 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.specimen_transport_id IS 'Synthetic primary key.';


--
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.label IS 'Short label for the transport mode.';


--
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.definition IS 'Long definition providing all the necessary details for the transport mode.';


--
-- TOC entry 253 (class 1259 OID 55214597)
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
-- TOC entry 268 (class 1259 OID 55216036)
-- Name: spectral_data; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.spectral_data (
    spectral_data_id integer NOT NULL,
    specimen_id integer NOT NULL,
    spectrum jsonb
);


ALTER TABLE soil_data.spectral_data OWNER TO sis;

--
-- TOC entry 5584 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE spectral_data; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.spectral_data IS 'Spectral data records linked to specimens, containing full spectra as JSON';


--
-- TOC entry 5585 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN spectral_data.spectral_data_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.spectral_data.spectral_data_id IS 'Synthetic primary key';


--
-- TOC entry 5586 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN spectral_data.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.spectral_data.specimen_id IS 'Reference to the specimen';


--
-- TOC entry 5587 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN spectral_data.spectrum; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.spectral_data.spectrum IS 'JSON object containing spectral measurement data';


--
-- TOC entry 267 (class 1259 OID 55216034)
-- Name: spectral_data_spectral_data_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.spectral_data ALTER COLUMN spectral_data_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.spectral_data_spectral_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 262 (class 1259 OID 55215938)
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
-- TOC entry 5590 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE translate; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.translate IS 'Multilingual translations for database content';


--
-- TOC entry 5591 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN translate.table_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.table_name IS 'Name of the source table containing the translatable content';


--
-- TOC entry 5592 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN translate.column_name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.column_name IS 'Name of the column containing the translatable content';


--
-- TOC entry 5593 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN translate.language_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.language_code IS 'Target language code (ISO 639-1)';


--
-- TOC entry 5594 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN translate.string; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.string IS 'Original string to be translated';


--
-- TOC entry 5595 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN translate.translation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.translate.translation IS 'Translated string in the target language';


--
-- TOC entry 254 (class 1259 OID 55214650)
-- Name: unit_of_measure; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.unit_of_measure (
    unit_of_measure_id text NOT NULL,
    label character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.unit_of_measure OWNER TO sis;

--
-- TOC entry 5597 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.unit_of_measure IS 'Unit of measure';


--
-- TOC entry 5598 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_of_measure_id IS 'Synthetic primary key.';


--
-- TOC entry 5599 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.label IS 'Short label for this unit of measure';


--
-- TOC entry 5600 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.uri IS 'URI to the corresponding unit of measuree in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this unit of measure';


--
-- TOC entry 289 (class 1259 OID 55216279)
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
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE class; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.class IS 'Legend classes for mapsets defining color and label for value ranges or categories';


--
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.mapset_id IS 'Reference to the mapset this class belongs to';


--
-- TOC entry 5604 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.value; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.value IS 'Numeric value (for quantitative) or category code (for categorical)';


--
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.code IS 'Short code for the class';


--
-- TOC entry 5606 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.label; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.label IS 'Display label for the class in legends';


--
-- TOC entry 5607 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.color IS 'Hex color code for map display (e.g., #FF5733)';


--
-- TOC entry 5608 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.opacity; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.opacity IS 'Opacity value from 0 to 1';


--
-- TOC entry 5609 (class 0 OID 0)
-- Dependencies: 289
-- Name: COLUMN class.publish; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.class.publish IS 'Flag indicating whether this class should be published';


--
-- TOC entry 284 (class 1259 OID 55216221)
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
-- TOC entry 5611 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE country; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.country IS 'Reference table of countries with ISO codes and multilingual names';


--
-- TOC entry 5612 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.country_id IS 'ISO 3166-1 alpha-2 country code (primary key)';


--
-- TOC entry 5613 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.iso3_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.iso3_code IS 'ISO 3166-1 alpha-3 country code';


--
-- TOC entry 5614 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.gaul_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.gaul_code IS 'FAO GAUL country code';


--
-- TOC entry 5615 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.color_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.color_code IS 'Color code for map display';


--
-- TOC entry 5616 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.ar; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.ar IS 'Country name in Arabic';


--
-- TOC entry 5617 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.en; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.en IS 'Country name in English';


--
-- TOC entry 5618 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.es; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.es IS 'Country name in Spanish';


--
-- TOC entry 5619 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.fr; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.fr IS 'Country name in French';


--
-- TOC entry 5620 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.pt; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.pt IS 'Country name in Portuguese';


--
-- TOC entry 5621 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.ru; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.ru IS 'Country name in Russian';


--
-- TOC entry 5622 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.zh; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.zh IS 'Country name in Chinese';


--
-- TOC entry 5623 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.status; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.status IS 'Country status (e.g., Member State, Territory)';


--
-- TOC entry 5624 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.disp_area; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.disp_area IS 'Disputed area indicator';


--
-- TOC entry 5625 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.capital; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.capital IS 'Capital city name';


--
-- TOC entry 5626 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.continent; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.continent IS 'Continent name';


--
-- TOC entry 5627 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.un_reg; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.un_reg IS 'UN region classification';


--
-- TOC entry 5628 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.unreg_note; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.unreg_note IS 'Notes about UN region classification';


--
-- TOC entry 5629 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN country.continent_custom; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.country.continent_custom IS 'Custom continent grouping for specific applications';


--
-- TOC entry 292 (class 1259 OID 55216299)
-- Name: individual; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE spatial_metadata.individual OWNER TO sis;

--
-- TOC entry 5631 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE individual; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.individual IS 'Individuals associated with spatial data projects';


--
-- TOC entry 5632 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN individual.individual_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.individual.individual_id IS 'Unique identifier for the individual';


--
-- TOC entry 5633 (class 0 OID 0)
-- Dependencies: 292
-- Name: COLUMN individual.email; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.individual.email IS 'Email address of the individual';


--
-- TOC entry 288 (class 1259 OID 55216270)
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
-- TOC entry 5635 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE layer; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.layer IS 'Raster layer metadata and file information for spatial data';


--
-- TOC entry 5636 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.mapset_id IS 'Reference to the parent mapset';


--
-- TOC entry 5637 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.dimension_depth; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.dimension_depth IS 'Depth dimension value (e.g., 0-5cm, 5-15cm)';


--
-- TOC entry 5638 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.dimension_stats; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.dimension_stats IS 'Statistical dimension: MEAN, SDEV, UNCT, or X';


--
-- TOC entry 5639 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.file_path; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_path IS 'File system path to the raster file';


--
-- TOC entry 5640 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.layer_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.layer_id IS 'Unique identifier for the layer';


--
-- TOC entry 5641 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.file_extension; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_extension IS 'File extension (e.g., tif, nc)';


--
-- TOC entry 5642 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.file_size; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_size IS 'File size in bytes';


--
-- TOC entry 5643 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.file_size_pretty; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.file_size_pretty IS 'Human-readable file size';


--
-- TOC entry 5644 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.reference_layer; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.reference_layer IS 'Flag indicating if this is the reference layer for the mapset';


--
-- TOC entry 5645 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.reference_system_identifier_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.reference_system_identifier_code IS 'EPSG code of the coordinate reference system';


--
-- TOC entry 5646 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.distance; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distance IS 'Spatial resolution value';


--
-- TOC entry 5647 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.distance_uom; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distance_uom IS 'Unit of measure for distance: m, km, or deg';


--
-- TOC entry 5648 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.extent; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.extent IS 'Bounding box extent as text';


--
-- TOC entry 5649 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.west_bound_longitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.west_bound_longitude IS 'Western boundary longitude';


--
-- TOC entry 5650 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.east_bound_longitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.east_bound_longitude IS 'Eastern boundary longitude';


--
-- TOC entry 5651 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.south_bound_latitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.south_bound_latitude IS 'Southern boundary latitude';


--
-- TOC entry 5652 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.north_bound_latitude; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.north_bound_latitude IS 'Northern boundary latitude';


--
-- TOC entry 5653 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.distribution_format; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.distribution_format IS 'Data distribution format';


--
-- TOC entry 5654 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.compression; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.compression IS 'Compression type used';


--
-- TOC entry 5655 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.raster_size_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.raster_size_x IS 'Number of columns in the raster';


--
-- TOC entry 5656 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.raster_size_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.raster_size_y IS 'Number of rows in the raster';


--
-- TOC entry 5657 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.pixel_size_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.pixel_size_x IS 'Pixel width in map units';


--
-- TOC entry 5658 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.pixel_size_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.pixel_size_y IS 'Pixel height in map units';


--
-- TOC entry 5659 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.origin_x; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.origin_x IS 'X coordinate of the raster origin';


--
-- TOC entry 5660 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.origin_y; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.origin_y IS 'Y coordinate of the raster origin';


--
-- TOC entry 5661 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.spatial_reference; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.spatial_reference IS 'Full spatial reference definition';


--
-- TOC entry 5662 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.data_type; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.data_type IS 'Raster data type (e.g., Float32, Int16)';


--
-- TOC entry 5663 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.no_data_value; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.no_data_value IS 'NoData value for the raster';


--
-- TOC entry 5664 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.stats_minimum; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_minimum IS 'Minimum value in the raster';


--
-- TOC entry 5665 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.stats_maximum; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_maximum IS 'Maximum value in the raster';


--
-- TOC entry 5666 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.stats_mean; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_mean IS 'Mean value in the raster';


--
-- TOC entry 5667 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.stats_std_dev; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.stats_std_dev IS 'Standard deviation of values in the raster';


--
-- TOC entry 5668 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.scale; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.scale IS 'Map scale (e.g., 1:250000)';


--
-- TOC entry 5669 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.n_bands; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.n_bands IS 'Number of bands in the raster';


--
-- TOC entry 5670 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.metadata; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.metadata IS 'Array of additional metadata strings';


--
-- TOC entry 5671 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN layer.map; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.layer.map IS 'Generated MapServer MAP file content';


--
-- TOC entry 286 (class 1259 OID 55216233)
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
-- TOC entry 5673 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE mapset; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.mapset IS 'Mapset metadata container for organizing related spatial layers with ISO 19139 compliant metadata';


--
-- TOC entry 5674 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.country_id IS 'Reference to the country';


--
-- TOC entry 5675 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.project_id IS 'Reference to the project';


--
-- TOC entry 5676 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.property_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.property_id IS 'Reference to the soil property';


--
-- TOC entry 5677 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.mapset_id IS 'Unique identifier for the mapset';


--
-- TOC entry 5678 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.dimension; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.dimension IS 'Dimension type: depth or time';


--
-- TOC entry 5679 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.parent_identifier; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.parent_identifier IS 'UUID of a parent mapset for hierarchical relationships';


--
-- TOC entry 5680 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.file_identifier; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.file_identifier IS 'UUID for ISO 19139 metadata identification';


--
-- TOC entry 5681 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.language_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.language_code IS 'ISO 639-2 language code for metadata';


--
-- TOC entry 5682 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.metadata_standard_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.metadata_standard_name IS 'Name of the metadata standard used';


--
-- TOC entry 5683 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.metadata_standard_version; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.metadata_standard_version IS 'Version of the metadata standard';


--
-- TOC entry 5684 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.reference_system_identifier_code_space; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.reference_system_identifier_code_space IS 'Code space for CRS (typically EPSG)';


--
-- TOC entry 5685 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.title; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.title IS 'Title of the mapset for display';


--
-- TOC entry 5686 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.unit_of_measure_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.unit_of_measure_id IS 'Reference to the unit of measure';


--
-- TOC entry 5687 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.creation_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.creation_date IS 'Date when the mapset was created';


--
-- TOC entry 5688 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.publication_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.publication_date IS 'Date when the mapset was published';


--
-- TOC entry 5689 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.revision_date; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.revision_date IS 'Date of the last revision';


--
-- TOC entry 5690 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.edition; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.edition IS 'Edition or version identifier';


--
-- TOC entry 5691 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.citation_md_identifier_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.citation_md_identifier_code IS 'DOI or other persistent identifier';


--
-- TOC entry 5692 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.citation_md_identifier_code_space; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.citation_md_identifier_code_space IS 'Code space for identifier: doi or uuid';


--
-- TOC entry 5693 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.abstract; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.abstract IS 'Abstract describing the mapset content';


--
-- TOC entry 5694 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.status; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.status IS 'ISO 19115 MD_ProgressCode: completed, onGoing, etc.';


--
-- TOC entry 5695 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.update_frequency; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.update_frequency IS 'ISO 19115 MD_MaintenanceFrequencyCode';


--
-- TOC entry 5696 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.md_browse_graphic; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.md_browse_graphic IS 'URL to a browse graphic/thumbnail';


--
-- TOC entry 5697 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.keyword_theme; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_theme IS 'Array of thematic keywords';


--
-- TOC entry 5698 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.keyword_place; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_place IS 'Array of place keywords';


--
-- TOC entry 5699 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.keyword_discipline; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.keyword_discipline IS 'Array of discipline keywords';


--
-- TOC entry 5700 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.access_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.access_constraints IS 'ISO 19115 MD_RestrictionCode for access';


--
-- TOC entry 5701 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.use_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.use_constraints IS 'ISO 19115 MD_RestrictionCode for use';


--
-- TOC entry 5702 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.other_constraints; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.other_constraints IS 'Text description of other constraints';


--
-- TOC entry 5703 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.spatial_representation_type_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.spatial_representation_type_code IS 'ISO 19115 MD_SpatialRepresentationTypeCode';


--
-- TOC entry 5704 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.presentation_form; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.presentation_form IS 'ISO 19115 CI_PresentationFormCode';


--
-- TOC entry 5705 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.topic_category; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.topic_category IS 'Array of ISO 19115 MD_TopicCategoryCode values';


--
-- TOC entry 5706 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.time_period_begin; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.time_period_begin IS 'Start date of the temporal extent';


--
-- TOC entry 5707 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.time_period_end; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.time_period_end IS 'End date of the temporal extent';


--
-- TOC entry 5708 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.scope_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.scope_code IS 'ISO 19115 MD_ScopeCode';


--
-- TOC entry 5709 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.lineage_statement; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_statement IS 'Statement describing data lineage';


--
-- TOC entry 5710 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.lineage_source_uuidref; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_source_uuidref IS 'UUID reference to source data';


--
-- TOC entry 5711 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.lineage_source_title; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.lineage_source_title IS 'Title of source data';


--
-- TOC entry 5712 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.xml; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.xml IS 'Generated ISO 19139 XML metadata';


--
-- TOC entry 5713 (class 0 OID 0)
-- Dependencies: 286
-- Name: COLUMN mapset.sld; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.mapset.sld IS 'Generated SLD XML for styling';


--
-- TOC entry 291 (class 1259 OID 55216293)
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
-- TOC entry 5715 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE organisation; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.organisation IS 'Organizations associated with spatial data projects';


--
-- TOC entry 5716 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.organisation_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.organisation_id IS 'Unique identifier for the organization';


--
-- TOC entry 5717 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.url IS 'Website URL of the organization';


--
-- TOC entry 5718 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.email; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.email IS 'Contact email for the organization';


--
-- TOC entry 5719 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.country; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.country IS 'Country where the organization is located';


--
-- TOC entry 5720 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.city; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.city IS 'City where the organization is located';


--
-- TOC entry 5721 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.postal_code; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.postal_code IS 'Postal code of the organization address';


--
-- TOC entry 5722 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.delivery_point; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.delivery_point IS 'Street address of the organization';


--
-- TOC entry 5723 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.phone; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.phone IS 'Phone number of the organization';


--
-- TOC entry 5724 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN organisation.facsimile; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.organisation.facsimile IS 'Fax number of the organization';


--
-- TOC entry 290 (class 1259 OID 55216285)
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
-- TOC entry 5726 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE proj_x_org_x_ind; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.proj_x_org_x_ind IS 'Junction table linking spatial projects, organizations, and individuals with their roles';


--
-- TOC entry 5727 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.country_id IS 'Reference to the country (part of project key)';


--
-- TOC entry 5728 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.project_id IS 'Reference to the project';


--
-- TOC entry 5729 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.organisation_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.organisation_id IS 'Reference to the organization';


--
-- TOC entry 5730 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.individual_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.individual_id IS 'Reference to the individual';


--
-- TOC entry 5731 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind."position"; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind."position" IS 'Position or job title of the individual';


--
-- TOC entry 5732 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.tag; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.tag IS 'Contact type: contact or pointOfContact';


--
-- TOC entry 5733 (class 0 OID 0)
-- Dependencies: 290
-- Name: COLUMN proj_x_org_x_ind.role; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.proj_x_org_x_ind.role IS 'ISO 19115 CI_RoleCode';


--
-- TOC entry 285 (class 1259 OID 55216227)
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
-- TOC entry 5735 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE project; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.project IS 'Spatial data projects organized by country';


--
-- TOC entry 5736 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN project.country_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.country_id IS 'Reference to the country (part of primary key)';


--
-- TOC entry 5737 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_id IS 'Unique identifier for the project within the country';


--
-- TOC entry 5738 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN project.project_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_name IS 'Human-readable name of the project';


--
-- TOC entry 5739 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN project.project_description; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.project.project_description IS 'Description of the project scope and objectives';


--
-- TOC entry 287 (class 1259 OID 55216263)
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
    CONSTRAINT property_property_type_check CHECK ((property_type = ANY (ARRAY['quantitative'::text, 'categorical'::text])))
);


ALTER TABLE spatial_metadata.property OWNER TO sis;

--
-- TOC entry 5741 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE property; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.property IS 'Soil properties for spatial data layers with visualization settings';


--
-- TOC entry 5742 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.property_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_id IS 'Unique identifier for the property';


--
-- TOC entry 5743 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.name IS 'Human-readable name of the property';


--
-- TOC entry 5744 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.property_num_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_num_id IS 'Reference to the numerical property definition';


--
-- TOC entry 5745 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.unit_of_measure_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.unit_of_measure_id IS 'Reference to the unit of measure';


--
-- TOC entry 5746 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.min; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.min IS 'Expected minimum value for the property';


--
-- TOC entry 5747 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.max; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.max IS 'Expected maximum value for the property';


--
-- TOC entry 5748 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.property_type; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.property_type IS 'Type: quantitative or categorical';


--
-- TOC entry 5749 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.num_intervals; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.num_intervals IS 'Number of classification intervals for legends';


--
-- TOC entry 5750 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.start_color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.start_color IS 'Start color for gradient (hex format)';


--
-- TOC entry 5751 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.end_color; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.end_color IS 'End color for gradient (hex format)';


--
-- TOC entry 5752 (class 0 OID 0)
-- Dependencies: 287
-- Name: COLUMN property.keyword_theme; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.property.keyword_theme IS 'Array of thematic keywords for this property';


--
-- TOC entry 293 (class 1259 OID 55216305)
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
-- TOC entry 5754 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON TABLE spatial_metadata.url IS 'Online resource URLs for mapsets (download, WMS, WFS, etc.)';


--
-- TOC entry 5755 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN url.mapset_id; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.mapset_id IS 'Reference to the mapset';


--
-- TOC entry 5756 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN url.protocol; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.protocol IS 'OGC or WWW protocol identifier';


--
-- TOC entry 5757 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN url.url; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url IS 'Full URL to the resource';


--
-- TOC entry 5758 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN url.url_name; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url_name IS 'Display name for the URL';


--
-- TOC entry 5759 (class 0 OID 0)
-- Dependencies: 293
-- Name: COLUMN url.url_description; Type: COMMENT; Schema: spatial_metadata; Owner: sis
--

COMMENT ON COLUMN spatial_metadata.url.url_description IS 'Description of what the URL provides';


--
-- TOC entry 5000 (class 2606 OID 55216423)
-- Name: api_client api_client_api_key_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_api_key_key UNIQUE (api_key);


--
-- TOC entry 5002 (class 2606 OID 55216421)
-- Name: api_client api_client_id_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_id_pkey PRIMARY KEY (api_client_id);


--
-- TOC entry 5004 (class 2606 OID 55216434)
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 5008 (class 2606 OID 55216461)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 5006 (class 2606 OID 55216452)
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (key);


--
-- TOC entry 5014 (class 2606 OID 55216515)
-- Name: uploaded_dataset_column uploaded_dataset_column_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name);


--
-- TOC entry 5010 (class 2606 OID 55216496)
-- Name: uploaded_dataset uploaded_dataset_file_name_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_file_name_key UNIQUE (file_name);


--
-- TOC entry 5012 (class 2606 OID 55216494)
-- Name: uploaded_dataset uploaded_dataset_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_pkey PRIMARY KEY (table_name);


--
-- TOC entry 4998 (class 2606 OID 55216410)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4933 (class 2606 OID 55215818)
-- Name: category_desc category_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.category_desc
    ADD CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id);


--
-- TOC entry 4851 (class 2606 OID 55214736)
-- Name: element element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT element_pkey PRIMARY KEY (element_id);


--
-- TOC entry 4943 (class 2606 OID 55215996)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4935 (class 2606 OID 55215937)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_code);


--
-- TOC entry 4855 (class 2606 OID 55215866)
-- Name: observation_desc_element observation_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4857 (class 2606 OID 55215848)
-- Name: observation_desc_plot observation_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4859 (class 2606 OID 55215857)
-- Name: observation_desc_profile observation_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4861 (class 2606 OID 55214759)
-- Name: observation_num observation_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_pkey PRIMARY KEY (observation_num_id);


--
-- TOC entry 4863 (class 2606 OID 55215696)
-- Name: observation_num observation_num_property_num_id_procedure_num_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_procedure_num_key UNIQUE (property_num_id, procedure_num_id);


--
-- TOC entry 4941 (class 2606 OID 55215988)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4865 (class 2606 OID 55214767)
-- Name: plot plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (plot_id);


--
-- TOC entry 4869 (class 2606 OID 55215572)
-- Name: procedure_desc procedure_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_pkey PRIMARY KEY (procedure_desc_id);


--
-- TOC entry 4871 (class 2606 OID 55214771)
-- Name: procedure_desc procedure_desc_uri_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_uri_key UNIQUE (uri);


--
-- TOC entry 4873 (class 2606 OID 55215671)
-- Name: procedure_num procedure_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_pkey PRIMARY KEY (procedure_num_id);


--
-- TOC entry 4953 (class 2606 OID 55216075)
-- Name: procedure_spectral procedure_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT procedure_spectral_pkey PRIMARY KEY (spectral_data_id, key);


--
-- TOC entry 4877 (class 2606 OID 55214775)
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 4945 (class 2606 OID 55216006)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4881 (class 2606 OID 55215954)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 4939 (class 2606 OID 55215970)
-- Name: project_site project_site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id);


--
-- TOC entry 4958 (class 2606 OID 55216099)
-- Name: project_soil_map project_soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_pkey PRIMARY KEY (project_id, soil_map_id);


--
-- TOC entry 4931 (class 2606 OID 55215810)
-- Name: property_desc property_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_desc
    ADD CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id);


--
-- TOC entry 4885 (class 2606 OID 55215645)
-- Name: property_num property_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT property_num_pkey PRIMARY KEY (property_num_id);


--
-- TOC entry 4889 (class 2606 OID 55215484)
-- Name: result_desc_element result_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_pkey PRIMARY KEY (element_id, property_desc_id);


--
-- TOC entry 4891 (class 2606 OID 55215496)
-- Name: result_desc_plot result_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_pkey PRIMARY KEY (plot_id, property_desc_id);


--
-- TOC entry 4893 (class 2606 OID 55215520)
-- Name: result_desc_profile result_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_pkey PRIMARY KEY (profile_id, property_desc_id);


--
-- TOC entry 4895 (class 2606 OID 55215386)
-- Name: result_num result_num_observation_num_id_specimen_id_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_specimen_id_key UNIQUE (observation_num_id, specimen_id);


--
-- TOC entry 4897 (class 2606 OID 55214799)
-- Name: result_num result_num_specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_specimen_pkey PRIMARY KEY (result_num_id);


--
-- TOC entry 4951 (class 2606 OID 55216057)
-- Name: result_spectral result_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_pkey PRIMARY KEY (result_spectral_id);


--
-- TOC entry 4927 (class 2606 OID 55215752)
-- Name: result_spectrum result_spectrum_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT result_spectrum_pkey PRIMARY KEY (result_spectrum_id);


--
-- TOC entry 4899 (class 2606 OID 55214811)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (site_id);


--
-- TOC entry 4956 (class 2606 OID 55216090)
-- Name: soil_map soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_map
    ADD CONSTRAINT soil_map_pkey PRIMARY KEY (soil_map_id);


--
-- TOC entry 4962 (class 2606 OID 55216119)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4966 (class 2606 OID 55216141)
-- Name: soil_mapping_unit soil_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_pkey PRIMARY KEY (mapping_unit_id);


--
-- TOC entry 4974 (class 2606 OID 55216205)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_pkey PRIMARY KEY (mapping_unit_id, profile_id);


--
-- TOC entry 4970 (class 2606 OID 55216167)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_pkey PRIMARY KEY (typological_unit_id, mapping_unit_id);


--
-- TOC entry 4968 (class 2606 OID 55216158)
-- Name: soil_typological_unit soil_typological_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit
    ADD CONSTRAINT soil_typological_unit_pkey PRIMARY KEY (typological_unit_id);


--
-- TOC entry 4972 (class 2606 OID 55216186)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_pkey PRIMARY KEY (typological_unit_id, profile_id);


--
-- TOC entry 4903 (class 2606 OID 55214815)
-- Name: specimen specimen_code_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_code_key UNIQUE (code);


--
-- TOC entry 4905 (class 2606 OID 55214817)
-- Name: specimen specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_pkey PRIMARY KEY (specimen_id);


--
-- TOC entry 4907 (class 2606 OID 55214819)
-- Name: specimen_prep_process specimen_prep_process_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_definition_key UNIQUE (definition);


--
-- TOC entry 4909 (class 2606 OID 55214821)
-- Name: specimen_prep_process specimen_prep_process_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_pkey PRIMARY KEY (specimen_prep_process_id);


--
-- TOC entry 4911 (class 2606 OID 55214823)
-- Name: specimen_storage specimen_storage_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_definition_key UNIQUE (definition);


--
-- TOC entry 4913 (class 2606 OID 55214825)
-- Name: specimen_storage specimen_storage_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_pkey PRIMARY KEY (specimen_storage_id);


--
-- TOC entry 4917 (class 2606 OID 55214827)
-- Name: specimen_transport specimen_transport_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_definition_key UNIQUE (definition);


--
-- TOC entry 4919 (class 2606 OID 55214829)
-- Name: specimen_transport specimen_transport_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_pkey PRIMARY KEY (specimen_transport_id);


--
-- TOC entry 4947 (class 2606 OID 55216043)
-- Name: spectral_data spectral_data_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT spectral_data_pkey PRIMARY KEY (spectral_data_id);


--
-- TOC entry 4937 (class 2606 OID 55215945)
-- Name: translate translate_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_pkey PRIMARY KEY (table_name, column_name, language_code, string);


--
-- TOC entry 4923 (class 2606 OID 55215619)
-- Name: unit_of_measure unit_of_measure_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unit_of_measure_pkey PRIMARY KEY (unit_of_measure_id);


--
-- TOC entry 4853 (class 2606 OID 55214847)
-- Name: element unq_element_profile_order_element; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT unq_element_profile_order_element UNIQUE (profile_id, order_element);


--
-- TOC entry 4867 (class 2606 OID 55214849)
-- Name: plot unq_plot_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT unq_plot_code UNIQUE (plot_code);


--
-- TOC entry 4875 (class 2606 OID 55214855)
-- Name: procedure_num unq_procedure_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT unq_procedure_num_uri UNIQUE (uri);


--
-- TOC entry 4879 (class 2606 OID 55214857)
-- Name: profile unq_profile_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT unq_profile_code UNIQUE (profile_code);


--
-- TOC entry 4883 (class 2606 OID 55214859)
-- Name: project unq_project_name; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT unq_project_name UNIQUE (name);


--
-- TOC entry 4887 (class 2606 OID 55214881)
-- Name: property_num unq_property_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT unq_property_num_uri UNIQUE (uri);


--
-- TOC entry 4901 (class 2606 OID 55214891)
-- Name: site unq_site_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT unq_site_code UNIQUE (site_code);


--
-- TOC entry 4915 (class 2606 OID 55214893)
-- Name: specimen_storage unq_specimen_storage_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT unq_specimen_storage_label UNIQUE (label);


--
-- TOC entry 4921 (class 2606 OID 55214895)
-- Name: specimen_transport unq_specimen_transport_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT unq_specimen_transport_label UNIQUE (label);


--
-- TOC entry 4925 (class 2606 OID 55214909)
-- Name: unit_of_measure unq_unit_of_measure_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unq_unit_of_measure_uri UNIQUE (uri);


--
-- TOC entry 4988 (class 2606 OID 55216325)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (mapset_id, value);


--
-- TOC entry 4976 (class 2606 OID 55216313)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 4994 (class 2606 OID 55216331)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4986 (class 2606 OID 55216323)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4980 (class 2606 OID 55216319)
-- Name: mapset mapset_file_identifier_key; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_file_identifier_key UNIQUE (file_identifier);


--
-- TOC entry 4982 (class 2606 OID 55216317)
-- Name: mapset mapset_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_pkey PRIMARY KEY (mapset_id);


--
-- TOC entry 4992 (class 2606 OID 55216329)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4990 (class 2606 OID 55216327)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (country_id, project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4978 (class 2606 OID 55216315)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (country_id, project_id);


--
-- TOC entry 4984 (class 2606 OID 55216321)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 4996 (class 2606 OID 55216333)
-- Name: url url_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (mapset_id, protocol, url);


--
-- TOC entry 4959 (class 1259 OID 55216130)
-- Name: idx_category_map; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_map ON soil_data.soil_mapping_unit_category USING btree (soil_map_id);


--
-- TOC entry 5761 (class 0 OID 0)
-- Dependencies: 4959
-- Name: INDEX idx_category_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_map IS 'Index on soil map for root categories';


--
-- TOC entry 4960 (class 1259 OID 55216131)
-- Name: idx_category_parent; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_parent ON soil_data.soil_mapping_unit_category USING btree (parent_category_id);


--
-- TOC entry 5762 (class 0 OID 0)
-- Dependencies: 4960
-- Name: INDEX idx_category_parent; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_parent IS 'Index on parent category for hierarchy traversal';


--
-- TOC entry 4963 (class 1259 OID 55216147)
-- Name: idx_mapping_unit_category; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_category ON soil_data.soil_mapping_unit USING btree (category_id);


--
-- TOC entry 5763 (class 0 OID 0)
-- Dependencies: 4963
-- Name: INDEX idx_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_category IS 'Index on category for joining with category table';


--
-- TOC entry 4964 (class 1259 OID 55216148)
-- Name: idx_mapping_unit_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_geom ON soil_data.soil_mapping_unit USING gist (geom);


--
-- TOC entry 5764 (class 0 OID 0)
-- Dependencies: 4964
-- Name: INDEX idx_mapping_unit_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_geom IS 'Spatial index on mapping unit geometry';


--
-- TOC entry 4954 (class 1259 OID 55216091)
-- Name: idx_soil_map_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_soil_map_geom ON soil_data.soil_map USING gist (geom);


--
-- TOC entry 5765 (class 0 OID 0)
-- Dependencies: 4954
-- Name: INDEX idx_soil_map_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_soil_map_geom IS 'Spatial index on soil map extent geometry';


--
-- TOC entry 4928 (class 1259 OID 55215763)
-- Name: result_spectrum_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_specimen_id_idx ON soil_data.result_spectrum USING btree (specimen_id);


--
-- TOC entry 5766 (class 0 OID 0)
-- Dependencies: 4928
-- Name: INDEX result_spectrum_specimen_id_idx; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.result_spectrum_specimen_id_idx IS 'Index on specimen_id for efficient lookup of spectral data by specimen';


--
-- TOC entry 4929 (class 1259 OID 55215764)
-- Name: result_spectrum_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_spectrum_idx ON soil_data.result_spectrum USING gin (spectrum);


--
-- TOC entry 4948 (class 1259 OID 55216049)
-- Name: spectral_data_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_specimen_id_idx ON soil_data.spectral_data USING btree (specimen_id) WITH (fillfactor='100');


--
-- TOC entry 4949 (class 1259 OID 55216050)
-- Name: spectral_data_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_spectrum_idx ON soil_data.spectral_data USING gin (spectrum) WITH (fastupdate='true', gin_pending_list_limit='4194304');


--
-- TOC entry 5086 (class 2620 OID 55215952)
-- Name: result_num trg_check_result_value; Type: TRIGGER; Schema: soil_data; Owner: sis
--

CREATE TRIGGER trg_check_result_value BEFORE INSERT OR UPDATE ON soil_data.result_num FOR EACH ROW EXECUTE FUNCTION soil_data.check_result_value();


--
-- TOC entry 5087 (class 2620 OID 55216394)
-- Name: layer class_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER class_func_on_layer_table AFTER UPDATE OF stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.class();


--
-- TOC entry 5088 (class 2620 OID 55216395)
-- Name: layer map_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER map_func_on_layer_table AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.map();


--
-- TOC entry 5089 (class 2620 OID 55216396)
-- Name: class sld_func_on_class_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER sld_func_on_class_table AFTER INSERT OR UPDATE ON spatial_metadata.class FOR EACH ROW EXECUTE FUNCTION spatial_metadata.sld();


--
-- TOC entry 5077 (class 2606 OID 55216440)
-- Name: audit audit_api_client_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_api_client_id_fkey FOREIGN KEY (api_client_id) REFERENCES api.api_client(api_client_id) ON UPDATE CASCADE;


--
-- TOC entry 5078 (class 2606 OID 55216435)
-- Name: audit audit_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5079 (class 2606 OID 55216462)
-- Name: layer layer_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id);


--
-- TOC entry 5082 (class 2606 OID 55216526)
-- Name: uploaded_dataset_column uploaded_dataset_column_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5083 (class 2606 OID 55216521)
-- Name: uploaded_dataset_column uploaded_dataset_column_property_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5084 (class 2606 OID 55216516)
-- Name: uploaded_dataset_column uploaded_dataset_column_table_name_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name) REFERENCES api.uploaded_dataset(table_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5085 (class 2606 OID 55216531)
-- Name: uploaded_dataset_column uploaded_dataset_column_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5080 (class 2606 OID 55216497)
-- Name: uploaded_dataset uploaded_dataset_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 5081 (class 2606 OID 55216502)
-- Name: uploaded_dataset uploaded_dataset_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5031 (class 2606 OID 55214934)
-- Name: result_desc_element fk_element; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT fk_element FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id);


--
-- TOC entry 5030 (class 2606 OID 55214989)
-- Name: profile fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5033 (class 2606 OID 55214994)
-- Name: result_desc_plot fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5015 (class 2606 OID 55215034)
-- Name: element fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5035 (class 2606 OID 55215039)
-- Name: result_desc_profile fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5045 (class 2606 OID 55215971)
-- Name: project_site fk_project; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id);


--
-- TOC entry 5028 (class 2606 OID 55215109)
-- Name: plot fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5046 (class 2606 OID 55215976)
-- Name: project_site fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5037 (class 2606 OID 55215124)
-- Name: result_num fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 5043 (class 2606 OID 55215753)
-- Name: result_spectrum fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 5050 (class 2606 OID 55216044)
-- Name: spectral_data fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id) ON UPDATE CASCADE;


--
-- TOC entry 5039 (class 2606 OID 55215129)
-- Name: specimen fk_specimen_prep_process; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT fk_specimen_prep_process FOREIGN KEY (specimen_prep_process_id) REFERENCES soil_data.specimen_prep_process(specimen_prep_process_id);


--
-- TOC entry 5041 (class 2606 OID 55215134)
-- Name: specimen_prep_process fk_specimen_storage; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_storage FOREIGN KEY (specimen_storage_id) REFERENCES soil_data.specimen_storage(specimen_storage_id);


--
-- TOC entry 5042 (class 2606 OID 55215139)
-- Name: specimen_prep_process fk_specimen_transport; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_transport FOREIGN KEY (specimen_transport_id) REFERENCES soil_data.specimen_transport(specimen_transport_id);


--
-- TOC entry 5053 (class 2606 OID 55216076)
-- Name: procedure_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5051 (class 2606 OID 55216063)
-- Name: result_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE;


--
-- TOC entry 5025 (class 2606 OID 55215639)
-- Name: observation_num observation_bum_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_bum_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5016 (class 2606 OID 55215919)
-- Name: observation_desc_element observation_desc_element_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5017 (class 2606 OID 55215603)
-- Name: observation_desc_element observation_desc_element_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5018 (class 2606 OID 55215914)
-- Name: observation_desc_element observation_desc_element_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5019 (class 2606 OID 55215899)
-- Name: observation_desc_plot observation_desc_plot_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5020 (class 2606 OID 55215608)
-- Name: observation_desc_plot observation_desc_plot_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5021 (class 2606 OID 55215894)
-- Name: observation_desc_plot observation_desc_plot_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 55215909)
-- Name: observation_desc_profile observation_desc_profile_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5023 (class 2606 OID 55215613)
-- Name: observation_desc_profile observation_desc_profile_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5024 (class 2606 OID 55215904)
-- Name: observation_desc_profile observation_desc_profile_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5026 (class 2606 OID 55215705)
-- Name: observation_num observation_num_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5027 (class 2606 OID 55215665)
-- Name: observation_num observation_num_property_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5029 (class 2606 OID 55215690)
-- Name: procedure_num procedure_num_broader_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_broader_id_fkey FOREIGN KEY (broader_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 55216007)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5048 (class 2606 OID 55216012)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5049 (class 2606 OID 55216017)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 55216100)
-- Name: project_soil_map project_soil_map_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 55216105)
-- Name: project_soil_map project_soil_map_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5032 (class 2606 OID 55215889)
-- Name: result_desc_element result_desc_element_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_element(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5034 (class 2606 OID 55215874)
-- Name: result_desc_plot result_desc_plot_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_plot(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5036 (class 2606 OID 55215884)
-- Name: result_desc_profile result_desc_profile_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_profile(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5038 (class 2606 OID 55215387)
-- Name: result_num result_num_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id);


--
-- TOC entry 5052 (class 2606 OID 55216058)
-- Name: result_spectral result_spectral_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5058 (class 2606 OID 55216142)
-- Name: soil_mapping_unit soil_mapping_unit_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_category_id_fkey FOREIGN KEY (category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 55216125)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5057 (class 2606 OID 55216120)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5063 (class 2606 OID 55216206)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5064 (class 2606 OID 55216211)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 55216173)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5060 (class 2606 OID 55216168)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5061 (class 2606 OID 55216192)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5062 (class 2606 OID 55216187)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5040 (class 2606 OID 55215710)
-- Name: specimen specimen_element_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_element_id_fkey FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 55215946)
-- Name: translate translate_language_code_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_language_code_fkey FOREIGN KEY (language_code) REFERENCES soil_data.languages(language_code);


--
-- TOC entry 5072 (class 2606 OID 55216354)
-- Name: class class_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5071 (class 2606 OID 55216359)
-- Name: layer layer_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5066 (class 2606 OID 55216364)
-- Name: mapset mapset_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5067 (class 2606 OID 55216369)
-- Name: mapset mapset_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE;


--
-- TOC entry 5068 (class 2606 OID 55216374)
-- Name: mapset mapset_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5073 (class 2606 OID 55216334)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5074 (class 2606 OID 55216344)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5075 (class 2606 OID 55216339)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5065 (class 2606 OID 55216379)
-- Name: project project_country_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_country_id_fkey FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE;


--
-- TOC entry 5069 (class 2606 OID 55216384)
-- Name: property property_property_num_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5070 (class 2606 OID 55216389)
-- Name: property property_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5076 (class 2606 OID 55216349)
-- Name: url url_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA api TO sis_r;


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA kobo; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA kobo TO sis_r;
GRANT ALL ON SCHEMA kobo TO kobo;


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sis
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data TO sis_r;


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA soil_data_upload; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data_upload TO sis_r;


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA spatial_metadata TO sis_r;


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 1639
-- Name: FUNCTION check_result_value(); Type: ACL; Schema: soil_data; Owner: sis
--

GRANT ALL ON FUNCTION soil_data.check_result_value() TO sis_r;


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 1640
-- Name: FUNCTION class(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.class() TO sis_r;


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 1641
-- Name: FUNCTION map(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.map() TO sis_r;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 1642
-- Name: FUNCTION sld(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.sld() TO sis_r;


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE api_client; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.api_client TO sis_r;


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE audit; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.audit TO sis_r;


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE layer; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.layer TO sis_r;


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE setting; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.setting TO sis_r;


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE uploaded_dataset; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE uploaded_dataset_column; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE "user"; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api."user" TO sis_r;


--
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.element TO sis_r;


--
-- TOC entry 5340 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_num TO sis_r;


--
-- TOC entry 5347 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot TO sis_r;


--
-- TOC entry 5357 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profile TO sis_r;


--
-- TOC entry 5364 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_num TO sis_r;


--
-- TOC entry 5370 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen TO sis_r;


--
-- TOC entry 5372 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE vw_api_manifest; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_manifest TO sis_r;


--
-- TOC entry 5376 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project TO sis_r;


--
-- TOC entry 5380 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


--
-- TOC entry 5385 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.site TO sis_r;


--
-- TOC entry 5387 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE vw_api_observation; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_observation TO sis_r;


--
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE vw_api_profile; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_profile TO sis_r;


--
-- TOC entry 5393 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE category_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.category_desc TO sis_r;


--
-- TOC entry 5394 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE element_element_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.element_element_id_seq TO sis_r;


--
-- TOC entry 5398 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.individual TO sis_r;


--
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE languages; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.languages TO sis_r;


--
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_element TO sis_r;


--
-- TOC entry 5414 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_plot TO sis_r;


--
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_profile TO sis_r;


--
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE observation_phys_chem_element_observation_phys_chem_element_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.observation_phys_chem_element_observation_phys_chem_element_seq TO sis_r;


--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE organisation; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.organisation TO sis_r;


--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE plot_plot_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.plot_plot_id_seq TO sis_r;


--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_desc TO sis_r;


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_num TO sis_r;


--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE procedure_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_spectral TO sis_r;


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE profile_profile_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.profile_profile_id_seq TO sis_r;


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE project_soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_soil_map TO sis_r;


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE property_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_desc TO sis_r;


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_num TO sis_r;


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_element TO sis_r;


--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_plot TO sis_r;


--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_profile TO sis_r;


--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 256
-- Name: SEQUENCE result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq TO sis_r;


--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE result_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectral TO sis_r;


--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 269
-- Name: SEQUENCE result_spectral_result_spectral_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectral_result_spectral_id_seq TO sis_r;


--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE result_spectrum; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectrum TO sis_r;


--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 257
-- Name: SEQUENCE result_spectrum_result_spectrum_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectrum_result_spectrum_id_seq TO sis_r;


--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 245
-- Name: SEQUENCE site_site_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.site_site_id_seq TO sis_r;


--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_map TO sis_r;


--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 272
-- Name: SEQUENCE soil_map_soil_map_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_map_soil_map_id_seq TO sis_r;


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE soil_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit TO sis_r;


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_category TO sis_r;


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 275
-- Name: SEQUENCE soil_mapping_unit_category_category_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_category_category_id_seq TO sis_r;


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 277
-- Name: SEQUENCE soil_mapping_unit_mapping_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_mapping_unit_id_seq TO sis_r;


--
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE soil_mapping_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_profile TO sis_r;


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit TO sis_r;


--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_mapping_unit TO sis_r;


--
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_profile TO sis_r;


--
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 279
-- Name: SEQUENCE soil_typological_unit_typological_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_typological_unit_typological_unit_id_seq TO sis_r;


--
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_prep_process TO sis_r;


--
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 248
-- Name: SEQUENCE specimen_prep_process_specimen_prep_process_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_prep_process_specimen_prep_process_id_seq TO sis_r;


--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 249
-- Name: SEQUENCE specimen_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_specimen_id_seq TO sis_r;


--
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_storage TO sis_r;


--
-- TOC entry 5577 (class 0 OID 0)
-- Dependencies: 251
-- Name: SEQUENCE specimen_storage_specimen_storage_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_storage_specimen_storage_id_seq TO sis_r;


--
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_transport TO sis_r;


--
-- TOC entry 5583 (class 0 OID 0)
-- Dependencies: 253
-- Name: SEQUENCE specimen_transport_specimen_transport_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_transport_specimen_transport_id_seq TO sis_r;


--
-- TOC entry 5588 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE spectral_data; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.spectral_data TO sis_r;


--
-- TOC entry 5589 (class 0 OID 0)
-- Dependencies: 267
-- Name: SEQUENCE spectral_data_spectral_data_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.spectral_data_spectral_data_id_seq TO sis_r;


--
-- TOC entry 5596 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE translate; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.translate TO sis_r;


--
-- TOC entry 5601 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.unit_of_measure TO sis_r;


--
-- TOC entry 5610 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE class; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


--
-- TOC entry 5630 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE country; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


--
-- TOC entry 5634 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE individual; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


--
-- TOC entry 5672 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE layer; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


--
-- TOC entry 5714 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE mapset; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;


--
-- TOC entry 5725 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE organisation; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


--
-- TOC entry 5734 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5740 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE project; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


--
-- TOC entry 5753 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE property; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


--
-- TOC entry 5760 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE url; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--
-- TOC entry 3579 (class 826 OID 55216398)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: api; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3578 (class 826 OID 55215741)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3580 (class 826 OID 55216483)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data_upload; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;


-- Completed on 2026-01-11 10:09:46 CET

--
-- PostgreSQL database dump complete
--

\unrestrict F8tQHTcCZclFx3tTgC8DGwNWggdtb3DdDbnYOUf05I4wqfb0yHh841kvF5nnGhE

