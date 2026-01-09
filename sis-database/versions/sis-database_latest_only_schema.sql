--
-- PostgreSQL database dump
--

\restrict bTDA1kcrJZS46EwvkKhPwl4rOpzGfJYPFP0gorspQzIQThr8aYkXV8N6ExAzEa6

-- Dumped from database version 12.22 (Ubuntu 12.22-3.pgdg22.04+1)
-- Dumped by pg_dump version 18.1 (Ubuntu 18.1-1.pgdg22.04+2)

-- Started on 2026-01-09 15:41:55 CET

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
-- TOC entry 12 (class 2615 OID 55187640)
-- Name: api; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO sis;

--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA api IS 'REST API tables';


--
-- TOC entry 16 (class 2615 OID 55187459)
-- Name: kobo; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA kobo;


ALTER SCHEMA kobo OWNER TO sis;

--
-- TOC entry 5150 (class 0 OID 0)
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
-- TOC entry 14 (class 2615 OID 55185753)
-- Name: soil_data; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data;


ALTER SCHEMA soil_data OWNER TO sis;

--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data IS 'Core entities and relations from the ISO-28258 domain model';


--
-- TOC entry 13 (class 2615 OID 55187725)
-- Name: soil_data_upload; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data_upload;


ALTER SCHEMA soil_data_upload OWNER TO sis;

--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA soil_data_upload; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data_upload IS 'Schema to upload soil data';


--
-- TOC entry 15 (class 2615 OID 55187460)
-- Name: spatial_metadata; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA spatial_metadata;


ALTER SCHEMA spatial_metadata OWNER TO sis;

--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA spatial_metadata IS 'Schema for spatial metadata';


--
-- TOC entry 5 (class 3079 OID 55184018)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 4 (class 3079 OID 55185104)
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- TOC entry 3 (class 3079 OID 55185665)
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- TOC entry 2 (class 3079 OID 55185742)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1627 (class 1255 OID 55187329)
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
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 1627
-- Name: FUNCTION check_result_value(); Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON FUNCTION soil_data.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';


--
-- TOC entry 1628 (class 1255 OID 55187461)
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
-- TOC entry 1629 (class 1255 OID 55187462)
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
-- TOC entry 1630 (class 1255 OID 55187463)
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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 283 (class 1259 OID 55187654)
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
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE api_client; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.api_client IS 'For server-to-server authentication';


--
-- TOC entry 285 (class 1259 OID 55187669)
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
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE audit; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.audit IS 'Track authentication attempts and API usage';


--
-- TOC entry 284 (class 1259 OID 55187667)
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
-- TOC entry 287 (class 1259 OID 55187696)
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
-- TOC entry 286 (class 1259 OID 55187688)
-- Name: setting; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.setting (
    key text NOT NULL,
    value text
);


ALTER TABLE api.setting OWNER TO sis;

--
-- TOC entry 291 (class 1259 OID 55187727)
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
-- TOC entry 292 (class 1259 OID 55187750)
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
-- TOC entry 282 (class 1259 OID 55187642)
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
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE "user"; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api."user" IS 'For human users who log in through the web application';


--
-- TOC entry 226 (class 1259 OID 55185763)
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
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.element IS 'ProfileElement is the super-class of Horizon and Layer, which share the same basic properties. Horizons develop in a layer, which in turn have been developed throught geogenesis or anthropogenic action. Layers can be used to describe common characteristics of a set of adjoining horizons. For the time being no assocation is previewed between Horizon and Layer.';


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.element_id IS 'Synthetic primary key.';


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.profile_id IS 'Reference to the Profile to which this element belongs';


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.order_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.order_element IS 'Order of this element within the Profile';


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.upper_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.upper_depth IS 'Upper depth of this profile element in centimetres.';


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.lower_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.lower_depth IS 'Lower depth of this profile element in centimetres.';


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.type IS 'Type of profile element, Horizon or Layer';


--
-- TOC entry 231 (class 1259 OID 55185794)
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
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_num IS 'Physio-chemical observations for the Element feature of interest';


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.observation_num_id IS 'Synthetic primary key for the observation';


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.property_num_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.procedure_num_id IS 'Foreign key to the corresponding procedure';


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.unit_of_measure_id IS 'Foreign key to the corresponding unit of measure (if applicable)';


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_min; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_min IS 'Minimum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_max; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_max IS 'Maximum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 232 (class 1259 OID 55185802)
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
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot IS 'Elementary area or location where individual observations are made and/or samples are taken. Plot is the main spatial feature of interest in ISO-28258. Plot has three sub-classes: Borehole, Pit and Surface. Surface features its own table since it has its own properties and a different geometry.';


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_id IS 'Synthetic primary key.';


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.site_id IS 'Foreign key to Site table.';


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_code IS 'Natural key, can be null.';


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.map_sheet_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.map_sheet_code IS 'Code identifying the map sheet where the plot may be positioned. Property re-used from GloSIS.';


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.geom IS 'Geodetic coordinates of the spatial position of the plot. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 236 (class 1259 OID 55185832)
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
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.profile IS 'An abstract, ordered set of soil horizons and/or layers.';


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_id IS 'Synthetic primary key.';


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.plot_id IS 'Foreign key to Plot feature of interest';


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_code IS 'Natural primary key, if existing';


--
-- TOC entry 243 (class 1259 OID 55185921)
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
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_num IS 'Numerical results for the Specimen feature interest.';


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.result_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.result_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.observation_num_id IS 'Foreign key to the corresponding numerical observation.';


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.specimen_id IS 'Foreign key to the corresponding Specimen instance.';


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.value IS 'Numerical value resulting from applying the refered observation to the refered specimen.';


--
-- TOC entry 246 (class 1259 OID 55185949)
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
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen IS 'Soil Specimen is defined in ISO-28258 as: "a subtype of SF_Specimen. Soil Specimen may be taken in the Site, Plot, Profile, or ProfileElement including their subtypes." In this database Specimen is for now only associated to Plot for simplification.';


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_id IS 'Synthetic primary key.';


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.element_id IS 'Foreign key to the associated soil Plot';


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_prep_process_id IS 'Foreign key to the preparation process used on this soil Specimen.';


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.code IS 'External code used to identify the soil Specimen (if used).';


--
-- TOC entry 288 (class 1259 OID 55187710)
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
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 288
-- Name: VIEW vw_api_manifest; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_manifest IS 'View to expose the list of soil properties and geographical extent';


--
-- TOC entry 238 (class 1259 OID 55185841)
-- Name: project; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project (
    project_id text NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE soil_data.project OWNER TO sis;

--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project IS 'Provides the context of the data collection as a prerequisite for the proper use or reuse of these data.';


--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.project_id IS 'Synthetic primary key.';


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.name IS 'Natural key with project name.';


--
-- TOC entry 263 (class 1259 OID 55187341)
-- Name: project_site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_site (
    project_id text NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE soil_data.project_site OWNER TO sis;

--
-- TOC entry 244 (class 1259 OID 55185937)
-- Name: site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.site (
    site_id integer NOT NULL,
    site_code character varying,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.site OWNER TO sis;

--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.site IS 'Defined area which is subject to a soil quality investigation. Site is not a spatial feature of interest, but provides the link between the spatial features of interest (Plot) to the Project. The geometry can either be a location (point) or extent (polygon) but not both at the same time.';


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_id IS 'Synthetic primary key.';


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_code IS 'Natural key, can be null.';


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.geom IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 290 (class 1259 OID 55187720)
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
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 290
-- Name: VIEW vw_api_observation; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';


--
-- TOC entry 289 (class 1259 OID 55187715)
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
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 289
-- Name: VIEW vw_api_profile; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_profile IS 'View to expose the list of profiles';


--
-- TOC entry 260 (class 1259 OID 55187189)
-- Name: category_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.category_desc (
    category_desc_id text NOT NULL,
    uri text
);


ALTER TABLE soil_data.category_desc OWNER TO sis;

--
-- TOC entry 227 (class 1259 OID 55185769)
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
-- TOC entry 265 (class 1259 OID 55187367)
-- Name: individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE soil_data.individual OWNER TO sis;

--
-- TOC entry 261 (class 1259 OID 55187308)
-- Name: languages; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.languages (
    language_code text NOT NULL,
    language_name text NOT NULL
);


ALTER TABLE soil_data.languages OWNER TO sis;

--
-- TOC entry 228 (class 1259 OID 55185771)
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
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_element IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 229 (class 1259 OID 55185774)
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
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_plot IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 230 (class 1259 OID 55185777)
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
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_profile IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 255 (class 1259 OID 55186750)
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
-- TOC entry 264 (class 1259 OID 55187359)
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
-- TOC entry 233 (class 1259 OID 55185814)
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
-- TOC entry 234 (class 1259 OID 55185816)
-- Name: procedure_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_desc (
    procedure_desc_id text NOT NULL,
    reference character varying,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.procedure_desc OWNER TO sis;

--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_desc IS 'Descriptive Procedures for all features of interest. In most cases the procedure is described in a document such as the FAO Guidelines for Soil Description or the World Reference Base of Soil Resources.';


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.procedure_desc_id IS 'Synthetic primary key.';


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.reference IS 'Long and human readable reference to the publication.';


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.uri IS 'URI to the corresponding publication, optimally a DOI. Follow this URI for the full definition of the procedure.';


--
-- TOC entry 235 (class 1259 OID 55185824)
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
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_num IS 'Physio-chemical Procedures for the Profile Element feature of interest';


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.procedure_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.broader_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.broader_id IS 'Foreign key to brader procedure in the hierarchy';


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.uri IS 'URI to the corresponding in a controlled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this procedure';


--
-- TOC entry 271 (class 1259 OID 55187446)
-- Name: procedure_spectral; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_spectral (
    spectral_data_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE soil_data.procedure_spectral OWNER TO sis;

--
-- TOC entry 237 (class 1259 OID 55185839)
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
-- TOC entry 266 (class 1259 OID 55187375)
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
-- TOC entry 259 (class 1259 OID 55187181)
-- Name: property_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_desc (
    property_desc_id text NOT NULL,
    property_pretty_name text,
    uri text
);


ALTER TABLE soil_data.property_desc OWNER TO sis;

--
-- TOC entry 239 (class 1259 OID 55185898)
-- Name: property_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_num (
    property_num_id text NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.property_num OWNER TO sis;

--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_num IS 'Physio-chemical properties for the Element feature of interest';


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.property_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.uri IS 'URI to the corresponding code in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this property';


--
-- TOC entry 240 (class 1259 OID 55185906)
-- Name: result_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_element (
    element_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_element OWNER TO sis;

--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_element IS 'Descriptive results for the Element feature interest.';


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.element_id IS 'Foreign key to the corresponding Element feature of interest.';


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.property_desc_id IS 'Foreign key to property_desc_element table.';


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.category_desc_id IS 'Foreign key to thesaurus_desc_element table.';


--
-- TOC entry 241 (class 1259 OID 55185909)
-- Name: result_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_plot (
    plot_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_plot OWNER TO sis;

--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_plot IS 'Descriptive results for the Plot feature interest.';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.plot_id IS 'Foreign key to the corresponding Plot feature of interest.';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.property_desc_id IS 'Foreign key to property_desc_plot table.';


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.category_desc_id IS 'Foreign key to thesaurus_desc_plot table.';


--
-- TOC entry 242 (class 1259 OID 55185912)
-- Name: result_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_profile (
    profile_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_profile OWNER TO sis;

--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_profile IS 'Descriptive results for the Profile feature interest.';


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.profile_id IS 'Foreign key to the corresponding Profile feature of interest.';


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.property_desc_id IS 'Foreign key to property_desc_profile table.';


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.category_desc_id IS 'Foreign key to thesaurus_desc_profile table.';


--
-- TOC entry 256 (class 1259 OID 55186756)
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
-- TOC entry 270 (class 1259 OID 55187431)
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
-- TOC entry 269 (class 1259 OID 55187429)
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
-- TOC entry 258 (class 1259 OID 55187123)
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
-- TOC entry 257 (class 1259 OID 55187121)
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
-- TOC entry 245 (class 1259 OID 55185947)
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
-- TOC entry 247 (class 1259 OID 55185955)
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
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_prep_process IS 'Describes the preparation process of a soil Specimen. Contains information that does not result from observation(s).';


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_prep_process_id IS 'Synthetic primary key.';


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_transport_id IS 'Foreign key for the corresponding mode of transport';


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_storage_id IS 'Foreign key for the corresponding mode of storage';


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.definition IS 'Further details necessary to define the preparation process.';


--
-- TOC entry 248 (class 1259 OID 55185961)
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
-- TOC entry 249 (class 1259 OID 55185963)
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
-- TOC entry 250 (class 1259 OID 55185965)
-- Name: specimen_storage; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_storage (
    specimen_storage_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_storage OWNER TO sis;

--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_storage IS 'Modes of storage of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.specimen_storage_id IS 'Synthetic primary key.';


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.label IS 'Short label for the storage mode.';


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.definition IS 'Long definition providing all the necessary details for the storage mode.';


--
-- TOC entry 251 (class 1259 OID 55185971)
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
-- TOC entry 252 (class 1259 OID 55185973)
-- Name: specimen_transport; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_transport (
    specimen_transport_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_transport OWNER TO sis;

--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_transport IS 'Modes of transport of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.specimen_transport_id IS 'Synthetic primary key.';


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.label IS 'Short label for the transport mode.';


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.definition IS 'Long definition providing all the necessary details for the transport mode.';


--
-- TOC entry 253 (class 1259 OID 55185979)
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
-- TOC entry 268 (class 1259 OID 55187414)
-- Name: spectral_data; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.spectral_data (
    spectral_data_id integer NOT NULL,
    specimen_id integer NOT NULL,
    spectrum jsonb
);


ALTER TABLE soil_data.spectral_data OWNER TO sis;

--
-- TOC entry 267 (class 1259 OID 55187412)
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
-- TOC entry 262 (class 1259 OID 55187316)
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
-- TOC entry 254 (class 1259 OID 55186032)
-- Name: unit_of_measure; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.unit_of_measure (
    unit_of_measure_id text NOT NULL,
    label character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.unit_of_measure OWNER TO sis;

--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.unit_of_measure IS 'Unit of measure';


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_of_measure_id IS 'Synthetic primary key.';


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.label IS 'Short label for this unit of measure';


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.uri IS 'URI to the corresponding unit of measuree in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this unit of measure';


--
-- TOC entry 277 (class 1259 OID 55187522)
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
-- TOC entry 272 (class 1259 OID 55187464)
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
-- TOC entry 280 (class 1259 OID 55187542)
-- Name: individual; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE spatial_metadata.individual OWNER TO sis;

--
-- TOC entry 276 (class 1259 OID 55187513)
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
-- TOC entry 274 (class 1259 OID 55187476)
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
-- TOC entry 279 (class 1259 OID 55187536)
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
-- TOC entry 278 (class 1259 OID 55187528)
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
-- TOC entry 273 (class 1259 OID 55187470)
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
-- TOC entry 275 (class 1259 OID 55187506)
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
-- TOC entry 281 (class 1259 OID 55187548)
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
-- TOC entry 4928 (class 2606 OID 55187666)
-- Name: api_client api_client_api_key_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_api_key_key UNIQUE (api_key);


--
-- TOC entry 4930 (class 2606 OID 55187664)
-- Name: api_client api_client_id_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_id_pkey PRIMARY KEY (api_client_id);


--
-- TOC entry 4932 (class 2606 OID 55187677)
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 4936 (class 2606 OID 55187704)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4934 (class 2606 OID 55187695)
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (key);


--
-- TOC entry 4942 (class 2606 OID 55187758)
-- Name: uploaded_dataset_column uploaded_dataset_column_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name);


--
-- TOC entry 4938 (class 2606 OID 55187739)
-- Name: uploaded_dataset uploaded_dataset_file_name_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_file_name_key UNIQUE (file_name);


--
-- TOC entry 4940 (class 2606 OID 55187737)
-- Name: uploaded_dataset uploaded_dataset_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_pkey PRIMARY KEY (table_name);


--
-- TOC entry 4926 (class 2606 OID 55187653)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4882 (class 2606 OID 55187196)
-- Name: category_desc category_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.category_desc
    ADD CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id);


--
-- TOC entry 4800 (class 2606 OID 55186115)
-- Name: element element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT element_pkey PRIMARY KEY (element_id);


--
-- TOC entry 4892 (class 2606 OID 55187374)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4884 (class 2606 OID 55187315)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_code);


--
-- TOC entry 4804 (class 2606 OID 55187244)
-- Name: observation_desc_element observation_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4806 (class 2606 OID 55187226)
-- Name: observation_desc_plot observation_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4808 (class 2606 OID 55187235)
-- Name: observation_desc_profile observation_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4810 (class 2606 OID 55186137)
-- Name: observation_num observation_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_pkey PRIMARY KEY (observation_num_id);


--
-- TOC entry 4812 (class 2606 OID 55187074)
-- Name: observation_num observation_num_property_num_id_procedure_num_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_procedure_num_key UNIQUE (property_num_id, procedure_num_id);


--
-- TOC entry 4890 (class 2606 OID 55187366)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4814 (class 2606 OID 55186145)
-- Name: plot plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (plot_id);


--
-- TOC entry 4818 (class 2606 OID 55186950)
-- Name: procedure_desc procedure_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_pkey PRIMARY KEY (procedure_desc_id);


--
-- TOC entry 4820 (class 2606 OID 55186149)
-- Name: procedure_desc procedure_desc_uri_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_uri_key UNIQUE (uri);


--
-- TOC entry 4822 (class 2606 OID 55187049)
-- Name: procedure_num procedure_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_pkey PRIMARY KEY (procedure_num_id);


--
-- TOC entry 4902 (class 2606 OID 55187453)
-- Name: procedure_spectral procedure_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT procedure_spectral_pkey PRIMARY KEY (spectral_data_id, key);


--
-- TOC entry 4826 (class 2606 OID 55186153)
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 4894 (class 2606 OID 55187384)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4830 (class 2606 OID 55187332)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 4888 (class 2606 OID 55187348)
-- Name: project_site project_site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id);


--
-- TOC entry 4880 (class 2606 OID 55187188)
-- Name: property_desc property_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_desc
    ADD CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id);


--
-- TOC entry 4834 (class 2606 OID 55187023)
-- Name: property_num property_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT property_num_pkey PRIMARY KEY (property_num_id);


--
-- TOC entry 4838 (class 2606 OID 55186862)
-- Name: result_desc_element result_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_pkey PRIMARY KEY (element_id, property_desc_id);


--
-- TOC entry 4840 (class 2606 OID 55186874)
-- Name: result_desc_plot result_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_pkey PRIMARY KEY (plot_id, property_desc_id);


--
-- TOC entry 4842 (class 2606 OID 55186898)
-- Name: result_desc_profile result_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_pkey PRIMARY KEY (profile_id, property_desc_id);


--
-- TOC entry 4844 (class 2606 OID 55186764)
-- Name: result_num result_num_observation_num_id_specimen_id_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_specimen_id_key UNIQUE (observation_num_id, specimen_id);


--
-- TOC entry 4846 (class 2606 OID 55186177)
-- Name: result_num result_num_specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_specimen_pkey PRIMARY KEY (result_num_id);


--
-- TOC entry 4900 (class 2606 OID 55187435)
-- Name: result_spectral result_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_pkey PRIMARY KEY (result_spectral_id);


--
-- TOC entry 4876 (class 2606 OID 55187130)
-- Name: result_spectrum result_spectrum_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT result_spectrum_pkey PRIMARY KEY (result_spectrum_id);


--
-- TOC entry 4848 (class 2606 OID 55186189)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (site_id);


--
-- TOC entry 4852 (class 2606 OID 55186193)
-- Name: specimen specimen_code_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_code_key UNIQUE (code);


--
-- TOC entry 4854 (class 2606 OID 55186195)
-- Name: specimen specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_pkey PRIMARY KEY (specimen_id);


--
-- TOC entry 4856 (class 2606 OID 55186197)
-- Name: specimen_prep_process specimen_prep_process_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_definition_key UNIQUE (definition);


--
-- TOC entry 4858 (class 2606 OID 55186199)
-- Name: specimen_prep_process specimen_prep_process_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_pkey PRIMARY KEY (specimen_prep_process_id);


--
-- TOC entry 4860 (class 2606 OID 55186201)
-- Name: specimen_storage specimen_storage_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_definition_key UNIQUE (definition);


--
-- TOC entry 4862 (class 2606 OID 55186203)
-- Name: specimen_storage specimen_storage_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_pkey PRIMARY KEY (specimen_storage_id);


--
-- TOC entry 4866 (class 2606 OID 55186205)
-- Name: specimen_transport specimen_transport_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_definition_key UNIQUE (definition);


--
-- TOC entry 4868 (class 2606 OID 55186207)
-- Name: specimen_transport specimen_transport_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_pkey PRIMARY KEY (specimen_transport_id);


--
-- TOC entry 4896 (class 2606 OID 55187421)
-- Name: spectral_data spectral_data_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT spectral_data_pkey PRIMARY KEY (spectral_data_id);


--
-- TOC entry 4886 (class 2606 OID 55187323)
-- Name: translate translate_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_pkey PRIMARY KEY (table_name, column_name, language_code, string);


--
-- TOC entry 4872 (class 2606 OID 55186997)
-- Name: unit_of_measure unit_of_measure_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unit_of_measure_pkey PRIMARY KEY (unit_of_measure_id);


--
-- TOC entry 4802 (class 2606 OID 55186225)
-- Name: element unq_element_profile_order_element; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT unq_element_profile_order_element UNIQUE (profile_id, order_element);


--
-- TOC entry 4816 (class 2606 OID 55186227)
-- Name: plot unq_plot_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT unq_plot_code UNIQUE (plot_code);


--
-- TOC entry 4824 (class 2606 OID 55186233)
-- Name: procedure_num unq_procedure_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT unq_procedure_num_uri UNIQUE (uri);


--
-- TOC entry 4828 (class 2606 OID 55186235)
-- Name: profile unq_profile_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT unq_profile_code UNIQUE (profile_code);


--
-- TOC entry 4832 (class 2606 OID 55186237)
-- Name: project unq_project_name; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT unq_project_name UNIQUE (name);


--
-- TOC entry 4836 (class 2606 OID 55186259)
-- Name: property_num unq_property_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT unq_property_num_uri UNIQUE (uri);


--
-- TOC entry 4850 (class 2606 OID 55186269)
-- Name: site unq_site_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT unq_site_code UNIQUE (site_code);


--
-- TOC entry 4864 (class 2606 OID 55186271)
-- Name: specimen_storage unq_specimen_storage_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT unq_specimen_storage_label UNIQUE (label);


--
-- TOC entry 4870 (class 2606 OID 55186273)
-- Name: specimen_transport unq_specimen_transport_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT unq_specimen_transport_label UNIQUE (label);


--
-- TOC entry 4874 (class 2606 OID 55186287)
-- Name: unit_of_measure unq_unit_of_measure_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unq_unit_of_measure_uri UNIQUE (uri);


--
-- TOC entry 4916 (class 2606 OID 55187568)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (mapset_id, value);


--
-- TOC entry 4904 (class 2606 OID 55187556)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 4922 (class 2606 OID 55187574)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4914 (class 2606 OID 55187566)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4908 (class 2606 OID 55187562)
-- Name: mapset mapset_file_identifier_key; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_file_identifier_key UNIQUE (file_identifier);


--
-- TOC entry 4910 (class 2606 OID 55187560)
-- Name: mapset mapset_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_pkey PRIMARY KEY (mapset_id);


--
-- TOC entry 4920 (class 2606 OID 55187572)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4918 (class 2606 OID 55187570)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (country_id, project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4906 (class 2606 OID 55187558)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (country_id, project_id);


--
-- TOC entry 4912 (class 2606 OID 55187564)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 4924 (class 2606 OID 55187576)
-- Name: url url_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (mapset_id, protocol, url);


--
-- TOC entry 4877 (class 1259 OID 55187141)
-- Name: result_spectrum_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_specimen_id_idx ON soil_data.result_spectrum USING btree (specimen_id);


--
-- TOC entry 4878 (class 1259 OID 55187142)
-- Name: result_spectrum_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_spectrum_idx ON soil_data.result_spectrum USING gin (spectrum);


--
-- TOC entry 4897 (class 1259 OID 55187427)
-- Name: spectral_data_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_specimen_id_idx ON soil_data.spectral_data USING btree (specimen_id) WITH (fillfactor='100');


--
-- TOC entry 4898 (class 1259 OID 55187428)
-- Name: spectral_data_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_spectrum_idx ON soil_data.spectral_data USING gin (spectrum) WITH (fastupdate='true', gin_pending_list_limit='4194304');


--
-- TOC entry 5003 (class 2620 OID 55187330)
-- Name: result_num trg_check_result_value; Type: TRIGGER; Schema: soil_data; Owner: sis
--

CREATE TRIGGER trg_check_result_value BEFORE INSERT OR UPDATE ON soil_data.result_num FOR EACH ROW EXECUTE FUNCTION soil_data.check_result_value();


--
-- TOC entry 5004 (class 2620 OID 55187637)
-- Name: layer class_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER class_func_on_layer_table AFTER UPDATE OF stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.class();


--
-- TOC entry 5005 (class 2620 OID 55187638)
-- Name: layer map_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER map_func_on_layer_table AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.map();


--
-- TOC entry 5006 (class 2620 OID 55187639)
-- Name: class sld_func_on_class_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER sld_func_on_class_table AFTER INSERT OR UPDATE ON spatial_metadata.class FOR EACH ROW EXECUTE FUNCTION spatial_metadata.sld();


--
-- TOC entry 4994 (class 2606 OID 55187683)
-- Name: audit audit_api_client_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_api_client_id_fkey FOREIGN KEY (api_client_id) REFERENCES api.api_client(api_client_id) ON UPDATE CASCADE;


--
-- TOC entry 4995 (class 2606 OID 55187678)
-- Name: audit audit_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 4996 (class 2606 OID 55187705)
-- Name: layer layer_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id);


--
-- TOC entry 4999 (class 2606 OID 55187769)
-- Name: uploaded_dataset_column uploaded_dataset_column_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5000 (class 2606 OID 55187764)
-- Name: uploaded_dataset_column uploaded_dataset_column_property_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5001 (class 2606 OID 55187759)
-- Name: uploaded_dataset_column uploaded_dataset_column_table_name_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name) REFERENCES api.uploaded_dataset(table_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5002 (class 2606 OID 55187774)
-- Name: uploaded_dataset_column uploaded_dataset_column_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4997 (class 2606 OID 55187740)
-- Name: uploaded_dataset uploaded_dataset_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 4998 (class 2606 OID 55187745)
-- Name: uploaded_dataset uploaded_dataset_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 4959 (class 2606 OID 55186312)
-- Name: result_desc_element fk_element; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT fk_element FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id);


--
-- TOC entry 4958 (class 2606 OID 55186367)
-- Name: profile fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 4961 (class 2606 OID 55186372)
-- Name: result_desc_plot fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 4943 (class 2606 OID 55186412)
-- Name: element fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 4963 (class 2606 OID 55186417)
-- Name: result_desc_profile fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 4973 (class 2606 OID 55187349)
-- Name: project_site fk_project; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id);


--
-- TOC entry 4956 (class 2606 OID 55186487)
-- Name: plot fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 4974 (class 2606 OID 55187354)
-- Name: project_site fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 4965 (class 2606 OID 55186502)
-- Name: result_num fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 4971 (class 2606 OID 55187131)
-- Name: result_spectrum fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 4978 (class 2606 OID 55187422)
-- Name: spectral_data fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id) ON UPDATE CASCADE;


--
-- TOC entry 4967 (class 2606 OID 55186507)
-- Name: specimen fk_specimen_prep_process; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT fk_specimen_prep_process FOREIGN KEY (specimen_prep_process_id) REFERENCES soil_data.specimen_prep_process(specimen_prep_process_id);


--
-- TOC entry 4969 (class 2606 OID 55186512)
-- Name: specimen_prep_process fk_specimen_storage; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_storage FOREIGN KEY (specimen_storage_id) REFERENCES soil_data.specimen_storage(specimen_storage_id);


--
-- TOC entry 4970 (class 2606 OID 55186517)
-- Name: specimen_prep_process fk_specimen_transport; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_transport FOREIGN KEY (specimen_transport_id) REFERENCES soil_data.specimen_transport(specimen_transport_id);


--
-- TOC entry 4981 (class 2606 OID 55187454)
-- Name: procedure_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4979 (class 2606 OID 55187441)
-- Name: result_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE;


--
-- TOC entry 4953 (class 2606 OID 55187017)
-- Name: observation_num observation_bum_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_bum_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4944 (class 2606 OID 55187297)
-- Name: observation_desc_element observation_desc_element_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4945 (class 2606 OID 55186981)
-- Name: observation_desc_element observation_desc_element_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 55187292)
-- Name: observation_desc_element observation_desc_element_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4947 (class 2606 OID 55187277)
-- Name: observation_desc_plot observation_desc_plot_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4948 (class 2606 OID 55186986)
-- Name: observation_desc_plot observation_desc_plot_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4949 (class 2606 OID 55187272)
-- Name: observation_desc_plot observation_desc_plot_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4950 (class 2606 OID 55187287)
-- Name: observation_desc_profile observation_desc_profile_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4951 (class 2606 OID 55186991)
-- Name: observation_desc_profile observation_desc_profile_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4952 (class 2606 OID 55187282)
-- Name: observation_desc_profile observation_desc_profile_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4954 (class 2606 OID 55187083)
-- Name: observation_num observation_num_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 4955 (class 2606 OID 55187043)
-- Name: observation_num observation_num_property_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 4957 (class 2606 OID 55187068)
-- Name: procedure_num procedure_num_broader_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_broader_id_fkey FOREIGN KEY (broader_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 4975 (class 2606 OID 55187385)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4976 (class 2606 OID 55187390)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4977 (class 2606 OID 55187395)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4960 (class 2606 OID 55187267)
-- Name: result_desc_element result_desc_element_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_element(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4962 (class 2606 OID 55187252)
-- Name: result_desc_plot result_desc_plot_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_plot(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4964 (class 2606 OID 55187262)
-- Name: result_desc_profile result_desc_profile_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_profile(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4966 (class 2606 OID 55186765)
-- Name: result_num result_num_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id);


--
-- TOC entry 4980 (class 2606 OID 55187436)
-- Name: result_spectral result_spectral_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id) ON UPDATE CASCADE;


--
-- TOC entry 4968 (class 2606 OID 55187088)
-- Name: specimen specimen_element_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_element_id_fkey FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4972 (class 2606 OID 55187324)
-- Name: translate translate_language_code_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_language_code_fkey FOREIGN KEY (language_code) REFERENCES soil_data.languages(language_code);


--
-- TOC entry 4989 (class 2606 OID 55187597)
-- Name: class class_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4988 (class 2606 OID 55187602)
-- Name: layer layer_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4983 (class 2606 OID 55187607)
-- Name: mapset mapset_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4984 (class 2606 OID 55187612)
-- Name: mapset mapset_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE;


--
-- TOC entry 4985 (class 2606 OID 55187617)
-- Name: mapset mapset_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4990 (class 2606 OID 55187577)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4991 (class 2606 OID 55187587)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4992 (class 2606 OID 55187582)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4982 (class 2606 OID 55187622)
-- Name: project project_country_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_country_id_fkey FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE;


--
-- TOC entry 4986 (class 2606 OID 55187627)
-- Name: property property_property_num_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 4987 (class 2606 OID 55187632)
-- Name: property property_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4993 (class 2606 OID 55187592)
-- Name: url url_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA api TO sis_r;


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA kobo; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA kobo TO sis_r;
GRANT ALL ON SCHEMA kobo TO kobo;


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sis
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data TO sis_r;


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA soil_data_upload; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data_upload TO sis_r;


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA spatial_metadata TO sis_r;


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 1627
-- Name: FUNCTION check_result_value(); Type: ACL; Schema: soil_data; Owner: sis
--

GRANT ALL ON FUNCTION soil_data.check_result_value() TO sis_r;


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 1628
-- Name: FUNCTION class(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.class() TO sis_r;


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 1629
-- Name: FUNCTION map(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.map() TO sis_r;


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 1630
-- Name: FUNCTION sld(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.sld() TO sis_r;


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE api_client; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.api_client TO sis_r;


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE audit; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.audit TO sis_r;


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE layer; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.layer TO sis_r;


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE setting; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.setting TO sis_r;


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE uploaded_dataset; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE uploaded_dataset_column; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE "user"; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api."user" TO sis_r;


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.element TO sis_r;


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_num TO sis_r;


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot TO sis_r;


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profile TO sis_r;


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_num TO sis_r;


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen TO sis_r;


--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE vw_api_manifest; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_manifest TO sis_r;


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project TO sis_r;


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.site TO sis_r;


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE vw_api_observation; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_observation TO sis_r;


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE vw_api_profile; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_profile TO sis_r;


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE category_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.category_desc TO sis_r;


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE element_element_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.element_element_id_seq TO sis_r;


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.individual TO sis_r;


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE languages; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.languages TO sis_r;


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_element TO sis_r;


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_plot TO sis_r;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_profile TO sis_r;


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE observation_phys_chem_element_observation_phys_chem_element_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.observation_phys_chem_element_observation_phys_chem_element_seq TO sis_r;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE organisation; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.organisation TO sis_r;


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE plot_plot_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.plot_plot_id_seq TO sis_r;


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_desc TO sis_r;


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_num TO sis_r;


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE procedure_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_spectral TO sis_r;


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE profile_profile_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.profile_profile_id_seq TO sis_r;


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE property_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_desc TO sis_r;


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_num TO sis_r;


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_element TO sis_r;


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_plot TO sis_r;


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_profile TO sis_r;


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 256
-- Name: SEQUENCE result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq TO sis_r;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE result_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectral TO sis_r;


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 269
-- Name: SEQUENCE result_spectral_result_spectral_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectral_result_spectral_id_seq TO sis_r;


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE result_spectrum; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectrum TO sis_r;


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 257
-- Name: SEQUENCE result_spectrum_result_spectrum_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectrum_result_spectrum_id_seq TO sis_r;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 245
-- Name: SEQUENCE site_site_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.site_site_id_seq TO sis_r;


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_prep_process TO sis_r;


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 248
-- Name: SEQUENCE specimen_prep_process_specimen_prep_process_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_prep_process_specimen_prep_process_id_seq TO sis_r;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 249
-- Name: SEQUENCE specimen_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_specimen_id_seq TO sis_r;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_storage TO sis_r;


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 251
-- Name: SEQUENCE specimen_storage_specimen_storage_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_storage_specimen_storage_id_seq TO sis_r;


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_transport TO sis_r;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 253
-- Name: SEQUENCE specimen_transport_specimen_transport_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_transport_specimen_transport_id_seq TO sis_r;


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE spectral_data; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.spectral_data TO sis_r;


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 267
-- Name: SEQUENCE spectral_data_spectral_data_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.spectral_data_spectral_data_id_seq TO sis_r;


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE translate; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.translate TO sis_r;


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.unit_of_measure TO sis_r;


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE class; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


--
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE country; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE individual; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


--
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE layer; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE mapset; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE organisation; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE project; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


--
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE property; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


--
-- TOC entry 5333 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE url; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--
-- TOC entry 3531 (class 826 OID 55187641)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: api; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3530 (class 826 OID 55187119)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3532 (class 826 OID 55187726)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data_upload; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;


-- Completed on 2026-01-09 15:41:55 CET

--
-- PostgreSQL database dump complete
--

\unrestrict bTDA1kcrJZS46EwvkKhPwl4rOpzGfJYPFP0gorspQzIQThr8aYkXV8N6ExAzEa6

