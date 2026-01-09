--
-- PostgreSQL database dump
--

\restrict 9rSHThmMfaMKB7KafrFjRn2AcUoX9BXcr55xHREjI3vfi9nWB5lpBhhHrekyXoK

-- Dumped from database version 12.22 (Ubuntu 12.22-3.pgdg22.04+1)
-- Dumped by pg_dump version 18.1 (Ubuntu 18.1-1.pgdg22.04+2)

-- Started on 2026-01-09 19:07:13 CET

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
-- TOC entry 12 (class 2615 OID 55208531)
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
-- TOC entry 16 (class 2615 OID 55208350)
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
-- TOC entry 14 (class 2615 OID 55206518)
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
-- TOC entry 13 (class 2615 OID 55208616)
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
-- TOC entry 15 (class 2615 OID 55208351)
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
-- TOC entry 5 (class 3079 OID 55204783)
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
-- TOC entry 4 (class 3079 OID 55205869)
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
-- TOC entry 3 (class 3079 OID 55206430)
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
-- TOC entry 2 (class 3079 OID 55206507)
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
-- TOC entry 1639 (class 1255 OID 55208085)
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
-- TOC entry 1640 (class 1255 OID 55208352)
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
-- TOC entry 1641 (class 1255 OID 55208353)
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
-- TOC entry 1642 (class 1255 OID 55208354)
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
-- TOC entry 295 (class 1259 OID 55208545)
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
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE api_client; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.api_client IS 'For server-to-server authentication';


--
-- TOC entry 297 (class 1259 OID 55208560)
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
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE audit; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api.audit IS 'Track authentication attempts and API usage';


--
-- TOC entry 296 (class 1259 OID 55208558)
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
-- TOC entry 299 (class 1259 OID 55208587)
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
-- TOC entry 298 (class 1259 OID 55208579)
-- Name: setting; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.setting (
    key text NOT NULL,
    value text
);


ALTER TABLE api.setting OWNER TO sis;

--
-- TOC entry 303 (class 1259 OID 55208618)
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
-- TOC entry 304 (class 1259 OID 55208641)
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
-- TOC entry 294 (class 1259 OID 55208533)
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
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE "user"; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON TABLE api."user" IS 'For human users who log in through the web application';


--
-- TOC entry 226 (class 1259 OID 55206527)
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
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.element IS 'ProfileElement is the super-class of Horizon and Layer, which share the same basic properties. Horizons develop in a layer, which in turn have been developed throught geogenesis or anthropogenic action. Layers can be used to describe common characteristics of a set of adjoining horizons. For the time being no assocation is previewed between Horizon and Layer.';


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.element_id IS 'Synthetic primary key.';


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.profile_id IS 'Reference to the Profile to which this element belongs';


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.order_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.order_element IS 'Order of this element within the Profile';


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.upper_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.upper_depth IS 'Upper depth of this profile element in centimetres.';


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.lower_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.lower_depth IS 'Lower depth of this profile element in centimetres.';


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.type IS 'Type of profile element, Horizon or Layer';


--
-- TOC entry 231 (class 1259 OID 55206558)
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
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_num IS 'Physio-chemical observations for the Element feature of interest';


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.observation_num_id IS 'Synthetic primary key for the observation';


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.property_num_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.procedure_num_id IS 'Foreign key to the corresponding procedure';


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.unit_of_measure_id IS 'Foreign key to the corresponding unit of measure (if applicable)';


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_min; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_min IS 'Minimum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_num.value_max; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_num.value_max IS 'Maximum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 232 (class 1259 OID 55206566)
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
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot IS 'Elementary area or location where individual observations are made and/or samples are taken. Plot is the main spatial feature of interest in ISO-28258. Plot has three sub-classes: Borehole, Pit and Surface. Surface features its own table since it has its own properties and a different geometry.';


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_id IS 'Synthetic primary key.';


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.site_id IS 'Foreign key to Site table.';


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_code IS 'Natural key, can be null.';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.map_sheet_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.map_sheet_code IS 'Code identifying the map sheet where the plot may be positioned. Property re-used from GloSIS.';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.geom IS 'Geodetic coordinates of the spatial position of the plot. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 236 (class 1259 OID 55206596)
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
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.profile IS 'An abstract, ordered set of soil horizons and/or layers.';


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_id IS 'Synthetic primary key.';


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.plot_id IS 'Foreign key to Plot feature of interest';


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN profile.profile_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_code IS 'Natural primary key, if existing';


--
-- TOC entry 243 (class 1259 OID 55206685)
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
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_num IS 'Numerical results for the Specimen feature interest.';


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.result_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.result_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.observation_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.observation_num_id IS 'Foreign key to the corresponding numerical observation.';


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.specimen_id IS 'Foreign key to the corresponding Specimen instance.';


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_num.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_num.value IS 'Numerical value resulting from applying the refered observation to the refered specimen.';


--
-- TOC entry 246 (class 1259 OID 55206713)
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
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen IS 'Soil Specimen is defined in ISO-28258 as: "a subtype of SF_Specimen. Soil Specimen may be taken in the Site, Plot, Profile, or ProfileElement including their subtypes." In this database Specimen is for now only associated to Plot for simplification.';


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_id IS 'Synthetic primary key.';


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.element_id IS 'Foreign key to the associated soil Plot';


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_prep_process_id IS 'Foreign key to the preparation process used on this soil Specimen.';


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN specimen.code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.code IS 'External code used to identify the soil Specimen (if used).';


--
-- TOC entry 300 (class 1259 OID 55208601)
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
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 300
-- Name: VIEW vw_api_manifest; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_manifest IS 'View to expose the list of soil properties and geographical extent';


--
-- TOC entry 238 (class 1259 OID 55206605)
-- Name: project; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project (
    project_id text NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE soil_data.project OWNER TO sis;

--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project IS 'Provides the context of the data collection as a prerequisite for the proper use or reuse of these data.';


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.project_id IS 'Synthetic primary key.';


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN project.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.name IS 'Natural key with project name.';


--
-- TOC entry 263 (class 1259 OID 55208097)
-- Name: project_site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_site (
    project_id text NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE soil_data.project_site OWNER TO sis;

--
-- TOC entry 244 (class 1259 OID 55206701)
-- Name: site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.site (
    site_id integer NOT NULL,
    site_code character varying,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.site OWNER TO sis;

--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.site IS 'Defined area which is subject to a soil quality investigation. Site is not a spatial feature of interest, but provides the link between the spatial features of interest (Plot) to the Project. The geometry can either be a location (point) or extent (polygon) but not both at the same time.';


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_id IS 'Synthetic primary key.';


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.site_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_code IS 'Natural key, can be null.';


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN site.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.geom IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 302 (class 1259 OID 55208611)
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
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 302
-- Name: VIEW vw_api_observation; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_observation IS 'View to expose the observational data';


--
-- TOC entry 301 (class 1259 OID 55208606)
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
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 301
-- Name: VIEW vw_api_profile; Type: COMMENT; Schema: api; Owner: sis
--

COMMENT ON VIEW api.vw_api_profile IS 'View to expose the list of profiles';


--
-- TOC entry 260 (class 1259 OID 55207945)
-- Name: category_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.category_desc (
    category_desc_id text NOT NULL,
    uri text
);


ALTER TABLE soil_data.category_desc OWNER TO sis;

--
-- TOC entry 227 (class 1259 OID 55206533)
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
-- TOC entry 265 (class 1259 OID 55208123)
-- Name: individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE soil_data.individual OWNER TO sis;

--
-- TOC entry 261 (class 1259 OID 55208064)
-- Name: languages; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.languages (
    language_code text NOT NULL,
    language_name text NOT NULL
);


ALTER TABLE soil_data.languages OWNER TO sis;

--
-- TOC entry 228 (class 1259 OID 55206535)
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
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_element IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 229 (class 1259 OID 55206538)
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
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_plot IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 230 (class 1259 OID 55206541)
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
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_profile IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5333 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5334 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5335 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 255 (class 1259 OID 55207506)
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
-- TOC entry 264 (class 1259 OID 55208115)
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
-- TOC entry 233 (class 1259 OID 55206578)
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
-- TOC entry 234 (class 1259 OID 55206580)
-- Name: procedure_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_desc (
    procedure_desc_id text NOT NULL,
    reference character varying,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.procedure_desc OWNER TO sis;

--
-- TOC entry 5340 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_desc IS 'Descriptive Procedures for all features of interest. In most cases the procedure is described in a document such as the FAO Guidelines for Soil Description or the World Reference Base of Soil Resources.';


--
-- TOC entry 5341 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.procedure_desc_id IS 'Synthetic primary key.';


--
-- TOC entry 5342 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.reference IS 'Long and human readable reference to the publication.';


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN procedure_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.uri IS 'URI to the corresponding publication, optimally a DOI. Follow this URI for the full definition of the procedure.';


--
-- TOC entry 235 (class 1259 OID 55206588)
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
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_num IS 'Physio-chemical Procedures for the Profile Element feature of interest';


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.procedure_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.procedure_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5347 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.broader_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.broader_id IS 'Foreign key to brader procedure in the hierarchy';


--
-- TOC entry 5348 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_num.uri IS 'URI to the corresponding in a controlled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this procedure';


--
-- TOC entry 271 (class 1259 OID 55208202)
-- Name: procedure_spectral; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_spectral (
    spectral_data_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE soil_data.procedure_spectral OWNER TO sis;

--
-- TOC entry 237 (class 1259 OID 55206603)
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
-- TOC entry 266 (class 1259 OID 55208131)
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
-- TOC entry 274 (class 1259 OID 55208226)
-- Name: project_soil_map; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_soil_map (
    project_id text NOT NULL,
    soil_map_id integer NOT NULL,
    remarks text
);


ALTER TABLE soil_data.project_soil_map OWNER TO sis;

--
-- TOC entry 5353 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE project_soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project_soil_map IS 'Links soil maps to projects (relatedMap many-to-many)';


--
-- TOC entry 5354 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.project_id IS 'Reference to the project';


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.soil_map_id IS 'Reference to the soil map (relatedMap)';


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN project_soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project_soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 259 (class 1259 OID 55207937)
-- Name: property_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_desc (
    property_desc_id text NOT NULL,
    property_pretty_name text,
    uri text
);


ALTER TABLE soil_data.property_desc OWNER TO sis;

--
-- TOC entry 239 (class 1259 OID 55206662)
-- Name: property_num; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_num (
    property_num_id text NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.property_num OWNER TO sis;

--
-- TOC entry 5359 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_num IS 'Physio-chemical properties for the Element feature of interest';


--
-- TOC entry 5360 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.property_num_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.property_num_id IS 'Synthetic primary key.';


--
-- TOC entry 5361 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN property_num.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_num.uri IS 'URI to the corresponding code in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this property';


--
-- TOC entry 240 (class 1259 OID 55206670)
-- Name: result_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_element (
    element_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_element OWNER TO sis;

--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_element IS 'Descriptive results for the Element feature interest.';


--
-- TOC entry 5364 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.element_id IS 'Foreign key to the corresponding Element feature of interest.';


--
-- TOC entry 5365 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.property_desc_id IS 'Foreign key to property_desc_element table.';


--
-- TOC entry 5366 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN result_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.category_desc_id IS 'Foreign key to thesaurus_desc_element table.';


--
-- TOC entry 241 (class 1259 OID 55206673)
-- Name: result_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_plot (
    plot_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_plot OWNER TO sis;

--
-- TOC entry 5368 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_plot IS 'Descriptive results for the Plot feature interest.';


--
-- TOC entry 5369 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.plot_id IS 'Foreign key to the corresponding Plot feature of interest.';


--
-- TOC entry 5370 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.property_desc_id IS 'Foreign key to property_desc_plot table.';


--
-- TOC entry 5371 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.category_desc_id IS 'Foreign key to thesaurus_desc_plot table.';


--
-- TOC entry 242 (class 1259 OID 55206676)
-- Name: result_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_profile (
    profile_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_profile OWNER TO sis;

--
-- TOC entry 5373 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_profile IS 'Descriptive results for the Profile feature interest.';


--
-- TOC entry 5374 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.profile_id IS 'Foreign key to the corresponding Profile feature of interest.';


--
-- TOC entry 5375 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.property_desc_id IS 'Foreign key to property_desc_profile table.';


--
-- TOC entry 5376 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.category_desc_id IS 'Foreign key to thesaurus_desc_profile table.';


--
-- TOC entry 256 (class 1259 OID 55207512)
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
-- TOC entry 270 (class 1259 OID 55208187)
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
-- TOC entry 269 (class 1259 OID 55208185)
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
-- TOC entry 258 (class 1259 OID 55207879)
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
-- TOC entry 257 (class 1259 OID 55207877)
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
-- TOC entry 245 (class 1259 OID 55206711)
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
-- TOC entry 273 (class 1259 OID 55208217)
-- Name: soil_map; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.soil_map (
    soil_map_id integer NOT NULL,
    name text NOT NULL,
    description text,
    scale_denominator integer,
    spatial_resolution_m numeric(10,2),
    publication_date date,
    survey_start_date date,
    survey_end_date date,
    classification_system text,
    classification_version text,
    source_organization text,
    source_citation text,
    remarks text,
    geom public.geometry(Polygon,4326)
);


ALTER TABLE soil_data.soil_map OWNER TO sis;

--
-- TOC entry 5384 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_map IS 'A soil map containing delineated mapping units (ISO 28258 SoilMap feature)';


--
-- TOC entry 5385 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.soil_map_id IS 'Unique identifier for the soil map';


--
-- TOC entry 5386 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.name IS 'Name of the soil map';


--
-- TOC entry 5387 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.description IS 'Detailed description of the soil map';


--
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.scale_denominator; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.scale_denominator IS 'Map scale denominator (e.g., 50000 for 1:50,000)';


--
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.spatial_resolution_m; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.spatial_resolution_m IS 'Spatial resolution in meters';


--
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.publication_date; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.publication_date IS 'Date when the map was published';


--
-- TOC entry 5391 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.survey_start_date; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.survey_start_date IS 'Start date of the soil survey';


--
-- TOC entry 5392 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.survey_end_date; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.survey_end_date IS 'End date of the soil survey';


--
-- TOC entry 5393 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.classification_system; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.classification_system IS 'Soil classification system used (e.g., WRB 2022, Soil Taxonomy)';


--
-- TOC entry 5394 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.classification_version; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.classification_version IS 'Version of the Soil classification system used';


--
-- TOC entry 5395 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.source_organization; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.source_organization IS 'Organization that produced the map';


--
-- TOC entry 5396 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.source_citation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.source_citation IS 'Full citation for the map source';


--
-- TOC entry 5397 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5398 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN soil_map.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_map.geom IS 'Polygon geometry representing the map extent (EPSG:4326)';


--
-- TOC entry 272 (class 1259 OID 55208215)
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
-- TOC entry 278 (class 1259 OID 55208268)
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
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE soil_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit IS 'Delineated polygon on a soil map (ISO 28258 SoilMappingUnit feature)';


--
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.mapping_unit_id IS 'Unique identifier for the mapping unit';


--
-- TOC entry 5403 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.category_id IS 'Reference to the mapping unit category (required, many-to-one)';


--
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.explanation; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.explanation IS 'Explanation or description of the mapping unit';


--
-- TOC entry 5405 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN soil_mapping_unit.geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit.geom IS 'MultiPolygon geometry of the mapping unit (EPSG:4326)';


--
-- TOC entry 276 (class 1259 OID 55208246)
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
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_category IS 'Legend category describing soil types in a map with hierarchical subcategories (ISO 28258 SoilMappingUnitCategory)';


--
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.category_id IS 'Unique identifier for the category';


--
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.soil_map_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.soil_map_id IS 'Reference to soil map - only set for root categories (rootCategory relationship)';


--
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.parent_category_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.parent_category_id IS 'Reference to parent category for subcategory hierarchy';


--
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.name IS 'Name of the mapping unit category';


--
-- TOC entry 5413 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.description IS 'Detailed description of the category';


--
-- TOC entry 5414 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.legend_order; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.legend_order IS 'Order in the map legend';


--
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.symbol; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.symbol IS 'Symbol used in the map legend';


--
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.colour_rgb; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.colour_rgb IS 'RGB colour code for map display (e.g., #A52A2A)';


--
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN soil_mapping_unit_category.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_category.remarks IS 'Additional remarks or notes';


--
-- TOC entry 275 (class 1259 OID 55208244)
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
-- TOC entry 277 (class 1259 OID 55208266)
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
-- TOC entry 283 (class 1259 OID 55208331)
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
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE soil_mapping_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_mapping_unit_profile IS 'Links profiles to mapping units (profile relationship 0..*)';


--
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.profile_id IS 'Reference to the soil profile';


--
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.is_representative; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.is_representative IS 'Whether this profile is representative for the mapping unit';


--
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 283
-- Name: COLUMN soil_mapping_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_mapping_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 280 (class 1259 OID 55208285)
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
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit IS 'Soil type classification unit (ISO 28258 SoilTypologicalUnit feature)';


--
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.typological_unit_id IS 'Unique identifier for the typological unit';


--
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.name IS 'Name of the soil typological unit';


--
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_scheme; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_scheme IS 'Classification scheme used (e.g., WRB, Soil Taxonomy)';


--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.classification_version; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.classification_version IS 'Version of the Classification scheme used';


--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.description; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.description IS 'Detailed description of the typological unit';


--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN soil_typological_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 281 (class 1259 OID 55208293)
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
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_mapping_unit IS 'Links typological units to mapping units with percentage composition (representedUnit/mapRepresentation). Percentages per SMU should sum to 100%.';


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.typological_unit_id IS 'Reference to the soil typological unit (STU)';


--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.mapping_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.mapping_unit_id IS 'Reference to the soil mapping unit (SMU)';


--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.percentage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.percentage IS 'Percentage of the STU within the SMU (sum per SMU should equal 100)';


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN soil_typological_unit_mapping_unit.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_mapping_unit.remarks IS 'Additional remarks or notes';


--
-- TOC entry 282 (class 1259 OID 55208312)
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
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.soil_typological_unit_profile IS 'Links profiles to typological units as typical profiles (typicalProfile relationship)';


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.typological_unit_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.typological_unit_id IS 'Reference to the typological unit';


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.profile_id IS 'Reference to the profile (typicalProfile)';


--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.is_typical; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.is_typical IS 'Whether this is a typical profile for the typological unit';


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN soil_typological_unit_profile.remarks; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.soil_typological_unit_profile.remarks IS 'Additional remarks or notes';


--
-- TOC entry 279 (class 1259 OID 55208283)
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
-- TOC entry 247 (class 1259 OID 55206719)
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
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_prep_process IS 'Describes the preparation process of a soil Specimen. Contains information that does not result from observation(s).';


--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_prep_process_id IS 'Synthetic primary key.';


--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_transport_id IS 'Foreign key for the corresponding mode of transport';


--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_storage_id IS 'Foreign key for the corresponding mode of storage';


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN specimen_prep_process.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.definition IS 'Further details necessary to define the preparation process.';


--
-- TOC entry 248 (class 1259 OID 55206725)
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
-- TOC entry 249 (class 1259 OID 55206727)
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
-- TOC entry 250 (class 1259 OID 55206729)
-- Name: specimen_storage; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_storage (
    specimen_storage_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_storage OWNER TO sis;

--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_storage IS 'Modes of storage of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.specimen_storage_id IS 'Synthetic primary key.';


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.label IS 'Short label for the storage mode.';


--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN specimen_storage.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.definition IS 'Long definition providing all the necessary details for the storage mode.';


--
-- TOC entry 251 (class 1259 OID 55206735)
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
-- TOC entry 252 (class 1259 OID 55206737)
-- Name: specimen_transport; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_transport (
    specimen_transport_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_transport OWNER TO sis;

--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_transport IS 'Modes of transport of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.specimen_transport_id IS 'Synthetic primary key.';


--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.label IS 'Short label for the transport mode.';


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_transport.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.definition IS 'Long definition providing all the necessary details for the transport mode.';


--
-- TOC entry 253 (class 1259 OID 55206743)
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
-- TOC entry 268 (class 1259 OID 55208170)
-- Name: spectral_data; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.spectral_data (
    spectral_data_id integer NOT NULL,
    specimen_id integer NOT NULL,
    spectrum jsonb
);


ALTER TABLE soil_data.spectral_data OWNER TO sis;

--
-- TOC entry 267 (class 1259 OID 55208168)
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
-- TOC entry 262 (class 1259 OID 55208072)
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
-- TOC entry 254 (class 1259 OID 55206796)
-- Name: unit_of_measure; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.unit_of_measure (
    unit_of_measure_id text NOT NULL,
    label character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.unit_of_measure OWNER TO sis;

--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.unit_of_measure IS 'Unit of measure';


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_of_measure_id IS 'Synthetic primary key.';


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.label IS 'Short label for this unit of measure';


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN unit_of_measure.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.uri IS 'URI to the corresponding unit of measuree in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this unit of measure';


--
-- TOC entry 289 (class 1259 OID 55208413)
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
-- TOC entry 284 (class 1259 OID 55208355)
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
-- TOC entry 292 (class 1259 OID 55208433)
-- Name: individual; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE spatial_metadata.individual OWNER TO sis;

--
-- TOC entry 288 (class 1259 OID 55208404)
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
-- TOC entry 286 (class 1259 OID 55208367)
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
-- TOC entry 291 (class 1259 OID 55208427)
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
-- TOC entry 290 (class 1259 OID 55208419)
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
-- TOC entry 285 (class 1259 OID 55208361)
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
-- TOC entry 287 (class 1259 OID 55208397)
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
-- TOC entry 293 (class 1259 OID 55208439)
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
-- TOC entry 5000 (class 2606 OID 55208557)
-- Name: api_client api_client_api_key_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_api_key_key UNIQUE (api_key);


--
-- TOC entry 5002 (class 2606 OID 55208555)
-- Name: api_client api_client_id_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.api_client
    ADD CONSTRAINT api_client_id_pkey PRIMARY KEY (api_client_id);


--
-- TOC entry 5004 (class 2606 OID 55208568)
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 5008 (class 2606 OID 55208595)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 5006 (class 2606 OID 55208586)
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (key);


--
-- TOC entry 5014 (class 2606 OID 55208649)
-- Name: uploaded_dataset_column uploaded_dataset_column_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name);


--
-- TOC entry 5010 (class 2606 OID 55208630)
-- Name: uploaded_dataset uploaded_dataset_file_name_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_file_name_key UNIQUE (file_name);


--
-- TOC entry 5012 (class 2606 OID 55208628)
-- Name: uploaded_dataset uploaded_dataset_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_pkey PRIMARY KEY (table_name);


--
-- TOC entry 4998 (class 2606 OID 55208544)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4933 (class 2606 OID 55207952)
-- Name: category_desc category_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.category_desc
    ADD CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id);


--
-- TOC entry 4851 (class 2606 OID 55206871)
-- Name: element element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT element_pkey PRIMARY KEY (element_id);


--
-- TOC entry 4943 (class 2606 OID 55208130)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4935 (class 2606 OID 55208071)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_code);


--
-- TOC entry 4855 (class 2606 OID 55208000)
-- Name: observation_desc_element observation_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4857 (class 2606 OID 55207982)
-- Name: observation_desc_plot observation_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4859 (class 2606 OID 55207991)
-- Name: observation_desc_profile observation_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4861 (class 2606 OID 55206893)
-- Name: observation_num observation_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_pkey PRIMARY KEY (observation_num_id);


--
-- TOC entry 4863 (class 2606 OID 55207830)
-- Name: observation_num observation_num_property_num_id_procedure_num_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_procedure_num_key UNIQUE (property_num_id, procedure_num_id);


--
-- TOC entry 4941 (class 2606 OID 55208122)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4865 (class 2606 OID 55206901)
-- Name: plot plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (plot_id);


--
-- TOC entry 4869 (class 2606 OID 55207706)
-- Name: procedure_desc procedure_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_pkey PRIMARY KEY (procedure_desc_id);


--
-- TOC entry 4871 (class 2606 OID 55206905)
-- Name: procedure_desc procedure_desc_uri_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_uri_key UNIQUE (uri);


--
-- TOC entry 4873 (class 2606 OID 55207805)
-- Name: procedure_num procedure_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_pkey PRIMARY KEY (procedure_num_id);


--
-- TOC entry 4953 (class 2606 OID 55208209)
-- Name: procedure_spectral procedure_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT procedure_spectral_pkey PRIMARY KEY (spectral_data_id, key);


--
-- TOC entry 4877 (class 2606 OID 55206909)
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 4945 (class 2606 OID 55208140)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4881 (class 2606 OID 55208088)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 4939 (class 2606 OID 55208104)
-- Name: project_site project_site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id);


--
-- TOC entry 4958 (class 2606 OID 55208233)
-- Name: project_soil_map project_soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_pkey PRIMARY KEY (project_id, soil_map_id);


--
-- TOC entry 4931 (class 2606 OID 55207944)
-- Name: property_desc property_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_desc
    ADD CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id);


--
-- TOC entry 4885 (class 2606 OID 55207779)
-- Name: property_num property_num_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT property_num_pkey PRIMARY KEY (property_num_id);


--
-- TOC entry 4889 (class 2606 OID 55207618)
-- Name: result_desc_element result_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_pkey PRIMARY KEY (element_id, property_desc_id);


--
-- TOC entry 4891 (class 2606 OID 55207630)
-- Name: result_desc_plot result_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_pkey PRIMARY KEY (plot_id, property_desc_id);


--
-- TOC entry 4893 (class 2606 OID 55207654)
-- Name: result_desc_profile result_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_pkey PRIMARY KEY (profile_id, property_desc_id);


--
-- TOC entry 4895 (class 2606 OID 55207520)
-- Name: result_num result_num_observation_num_id_specimen_id_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_specimen_id_key UNIQUE (observation_num_id, specimen_id);


--
-- TOC entry 4897 (class 2606 OID 55206933)
-- Name: result_num result_num_specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_specimen_pkey PRIMARY KEY (result_num_id);


--
-- TOC entry 4951 (class 2606 OID 55208191)
-- Name: result_spectral result_spectral_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_pkey PRIMARY KEY (result_spectral_id);


--
-- TOC entry 4927 (class 2606 OID 55207886)
-- Name: result_spectrum result_spectrum_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT result_spectrum_pkey PRIMARY KEY (result_spectrum_id);


--
-- TOC entry 4899 (class 2606 OID 55206945)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (site_id);


--
-- TOC entry 4956 (class 2606 OID 55208224)
-- Name: soil_map soil_map_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_map
    ADD CONSTRAINT soil_map_pkey PRIMARY KEY (soil_map_id);


--
-- TOC entry 4962 (class 2606 OID 55208253)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4966 (class 2606 OID 55208275)
-- Name: soil_mapping_unit soil_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_pkey PRIMARY KEY (mapping_unit_id);


--
-- TOC entry 4974 (class 2606 OID 55208339)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_pkey PRIMARY KEY (mapping_unit_id, profile_id);


--
-- TOC entry 4970 (class 2606 OID 55208301)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_pkey PRIMARY KEY (typological_unit_id, mapping_unit_id);


--
-- TOC entry 4968 (class 2606 OID 55208292)
-- Name: soil_typological_unit soil_typological_unit_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit
    ADD CONSTRAINT soil_typological_unit_pkey PRIMARY KEY (typological_unit_id);


--
-- TOC entry 4972 (class 2606 OID 55208320)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_pkey PRIMARY KEY (typological_unit_id, profile_id);


--
-- TOC entry 4903 (class 2606 OID 55206949)
-- Name: specimen specimen_code_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_code_key UNIQUE (code);


--
-- TOC entry 4905 (class 2606 OID 55206951)
-- Name: specimen specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_pkey PRIMARY KEY (specimen_id);


--
-- TOC entry 4907 (class 2606 OID 55206953)
-- Name: specimen_prep_process specimen_prep_process_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_definition_key UNIQUE (definition);


--
-- TOC entry 4909 (class 2606 OID 55206955)
-- Name: specimen_prep_process specimen_prep_process_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_pkey PRIMARY KEY (specimen_prep_process_id);


--
-- TOC entry 4911 (class 2606 OID 55206957)
-- Name: specimen_storage specimen_storage_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_definition_key UNIQUE (definition);


--
-- TOC entry 4913 (class 2606 OID 55206959)
-- Name: specimen_storage specimen_storage_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_pkey PRIMARY KEY (specimen_storage_id);


--
-- TOC entry 4917 (class 2606 OID 55206961)
-- Name: specimen_transport specimen_transport_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_definition_key UNIQUE (definition);


--
-- TOC entry 4919 (class 2606 OID 55206963)
-- Name: specimen_transport specimen_transport_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_pkey PRIMARY KEY (specimen_transport_id);


--
-- TOC entry 4947 (class 2606 OID 55208177)
-- Name: spectral_data spectral_data_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT spectral_data_pkey PRIMARY KEY (spectral_data_id);


--
-- TOC entry 4937 (class 2606 OID 55208079)
-- Name: translate translate_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_pkey PRIMARY KEY (table_name, column_name, language_code, string);


--
-- TOC entry 4923 (class 2606 OID 55207753)
-- Name: unit_of_measure unit_of_measure_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unit_of_measure_pkey PRIMARY KEY (unit_of_measure_id);


--
-- TOC entry 4853 (class 2606 OID 55206981)
-- Name: element unq_element_profile_order_element; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT unq_element_profile_order_element UNIQUE (profile_id, order_element);


--
-- TOC entry 4867 (class 2606 OID 55206983)
-- Name: plot unq_plot_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT unq_plot_code UNIQUE (plot_code);


--
-- TOC entry 4875 (class 2606 OID 55206989)
-- Name: procedure_num unq_procedure_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT unq_procedure_num_uri UNIQUE (uri);


--
-- TOC entry 4879 (class 2606 OID 55206991)
-- Name: profile unq_profile_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT unq_profile_code UNIQUE (profile_code);


--
-- TOC entry 4883 (class 2606 OID 55206993)
-- Name: project unq_project_name; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT unq_project_name UNIQUE (name);


--
-- TOC entry 4887 (class 2606 OID 55207015)
-- Name: property_num unq_property_num_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_num
    ADD CONSTRAINT unq_property_num_uri UNIQUE (uri);


--
-- TOC entry 4901 (class 2606 OID 55207025)
-- Name: site unq_site_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT unq_site_code UNIQUE (site_code);


--
-- TOC entry 4915 (class 2606 OID 55207027)
-- Name: specimen_storage unq_specimen_storage_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT unq_specimen_storage_label UNIQUE (label);


--
-- TOC entry 4921 (class 2606 OID 55207029)
-- Name: specimen_transport unq_specimen_transport_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT unq_specimen_transport_label UNIQUE (label);


--
-- TOC entry 4925 (class 2606 OID 55207043)
-- Name: unit_of_measure unq_unit_of_measure_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unq_unit_of_measure_uri UNIQUE (uri);


--
-- TOC entry 4988 (class 2606 OID 55208459)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (mapset_id, value);


--
-- TOC entry 4976 (class 2606 OID 55208447)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 4994 (class 2606 OID 55208465)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4986 (class 2606 OID 55208457)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4980 (class 2606 OID 55208453)
-- Name: mapset mapset_file_identifier_key; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_file_identifier_key UNIQUE (file_identifier);


--
-- TOC entry 4982 (class 2606 OID 55208451)
-- Name: mapset mapset_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_pkey PRIMARY KEY (mapset_id);


--
-- TOC entry 4992 (class 2606 OID 55208463)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4990 (class 2606 OID 55208461)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (country_id, project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4978 (class 2606 OID 55208449)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (country_id, project_id);


--
-- TOC entry 4984 (class 2606 OID 55208455)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 4996 (class 2606 OID 55208467)
-- Name: url url_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (mapset_id, protocol, url);


--
-- TOC entry 4959 (class 1259 OID 55208264)
-- Name: idx_category_map; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_map ON soil_data.soil_mapping_unit_category USING btree (soil_map_id);


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 4959
-- Name: INDEX idx_category_map; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_map IS 'Index on soil map for root categories';


--
-- TOC entry 4960 (class 1259 OID 55208265)
-- Name: idx_category_parent; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_category_parent ON soil_data.soil_mapping_unit_category USING btree (parent_category_id);


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 4960
-- Name: INDEX idx_category_parent; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_category_parent IS 'Index on parent category for hierarchy traversal';


--
-- TOC entry 4963 (class 1259 OID 55208281)
-- Name: idx_mapping_unit_category; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_category ON soil_data.soil_mapping_unit USING btree (category_id);


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 4963
-- Name: INDEX idx_mapping_unit_category; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_category IS 'Index on category for joining with category table';


--
-- TOC entry 4964 (class 1259 OID 55208282)
-- Name: idx_mapping_unit_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_mapping_unit_geom ON soil_data.soil_mapping_unit USING gist (geom);


--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 4964
-- Name: INDEX idx_mapping_unit_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_mapping_unit_geom IS 'Spatial index on mapping unit geometry';


--
-- TOC entry 4954 (class 1259 OID 55208225)
-- Name: idx_soil_map_geom; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX idx_soil_map_geom ON soil_data.soil_map USING gist (geom);


--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 4954
-- Name: INDEX idx_soil_map_geom; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON INDEX soil_data.idx_soil_map_geom IS 'Spatial index on soil map extent geometry';


--
-- TOC entry 4928 (class 1259 OID 55207897)
-- Name: result_spectrum_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_specimen_id_idx ON soil_data.result_spectrum USING btree (specimen_id);


--
-- TOC entry 4929 (class 1259 OID 55207898)
-- Name: result_spectrum_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_spectrum_idx ON soil_data.result_spectrum USING gin (spectrum);


--
-- TOC entry 4948 (class 1259 OID 55208183)
-- Name: spectral_data_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_specimen_id_idx ON soil_data.spectral_data USING btree (specimen_id) WITH (fillfactor='100');


--
-- TOC entry 4949 (class 1259 OID 55208184)
-- Name: spectral_data_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX spectral_data_spectrum_idx ON soil_data.spectral_data USING gin (spectrum) WITH (fastupdate='true', gin_pending_list_limit='4194304');


--
-- TOC entry 5086 (class 2620 OID 55208086)
-- Name: result_num trg_check_result_value; Type: TRIGGER; Schema: soil_data; Owner: sis
--

CREATE TRIGGER trg_check_result_value BEFORE INSERT OR UPDATE ON soil_data.result_num FOR EACH ROW EXECUTE FUNCTION soil_data.check_result_value();


--
-- TOC entry 5087 (class 2620 OID 55208528)
-- Name: layer class_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER class_func_on_layer_table AFTER UPDATE OF stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.class();


--
-- TOC entry 5088 (class 2620 OID 55208529)
-- Name: layer map_func_on_layer_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER map_func_on_layer_table AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.map();


--
-- TOC entry 5089 (class 2620 OID 55208530)
-- Name: class sld_func_on_class_table; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER sld_func_on_class_table AFTER INSERT OR UPDATE ON spatial_metadata.class FOR EACH ROW EXECUTE FUNCTION spatial_metadata.sld();


--
-- TOC entry 5077 (class 2606 OID 55208574)
-- Name: audit audit_api_client_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_api_client_id_fkey FOREIGN KEY (api_client_id) REFERENCES api.api_client(api_client_id) ON UPDATE CASCADE;


--
-- TOC entry 5078 (class 2606 OID 55208569)
-- Name: audit audit_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.audit
    ADD CONSTRAINT audit_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5079 (class 2606 OID 55208596)
-- Name: layer layer_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id);


--
-- TOC entry 5082 (class 2606 OID 55208660)
-- Name: uploaded_dataset_column uploaded_dataset_column_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5083 (class 2606 OID 55208655)
-- Name: uploaded_dataset_column uploaded_dataset_column_property_num_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5084 (class 2606 OID 55208650)
-- Name: uploaded_dataset_column uploaded_dataset_column_table_name_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name) REFERENCES api.uploaded_dataset(table_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5085 (class 2606 OID 55208665)
-- Name: uploaded_dataset_column uploaded_dataset_column_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5080 (class 2606 OID 55208631)
-- Name: uploaded_dataset uploaded_dataset_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 5081 (class 2606 OID 55208636)
-- Name: uploaded_dataset uploaded_dataset_user_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_user_id_fkey FOREIGN KEY (user_id) REFERENCES api."user"(user_id) ON UPDATE CASCADE;


--
-- TOC entry 5031 (class 2606 OID 55207068)
-- Name: result_desc_element fk_element; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT fk_element FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id);


--
-- TOC entry 5030 (class 2606 OID 55207123)
-- Name: profile fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5033 (class 2606 OID 55207128)
-- Name: result_desc_plot fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 5015 (class 2606 OID 55207168)
-- Name: element fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5035 (class 2606 OID 55207173)
-- Name: result_desc_profile fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 5045 (class 2606 OID 55208105)
-- Name: project_site fk_project; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id);


--
-- TOC entry 5028 (class 2606 OID 55207243)
-- Name: plot fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5046 (class 2606 OID 55208110)
-- Name: project_site fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 5037 (class 2606 OID 55207258)
-- Name: result_num fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 5043 (class 2606 OID 55207887)
-- Name: result_spectrum fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 5050 (class 2606 OID 55208178)
-- Name: spectral_data fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.spectral_data
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id) ON UPDATE CASCADE;


--
-- TOC entry 5039 (class 2606 OID 55207263)
-- Name: specimen fk_specimen_prep_process; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT fk_specimen_prep_process FOREIGN KEY (specimen_prep_process_id) REFERENCES soil_data.specimen_prep_process(specimen_prep_process_id);


--
-- TOC entry 5041 (class 2606 OID 55207268)
-- Name: specimen_prep_process fk_specimen_storage; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_storage FOREIGN KEY (specimen_storage_id) REFERENCES soil_data.specimen_storage(specimen_storage_id);


--
-- TOC entry 5042 (class 2606 OID 55207273)
-- Name: specimen_prep_process fk_specimen_transport; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_transport FOREIGN KEY (specimen_transport_id) REFERENCES soil_data.specimen_transport(specimen_transport_id);


--
-- TOC entry 5053 (class 2606 OID 55208210)
-- Name: procedure_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5051 (class 2606 OID 55208197)
-- Name: result_spectral fk_spectral_data; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT fk_spectral_data FOREIGN KEY (spectral_data_id) REFERENCES soil_data.spectral_data(spectral_data_id) ON UPDATE CASCADE;


--
-- TOC entry 5025 (class 2606 OID 55207773)
-- Name: observation_num observation_bum_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_bum_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5016 (class 2606 OID 55208053)
-- Name: observation_desc_element observation_desc_element_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5017 (class 2606 OID 55207737)
-- Name: observation_desc_element observation_desc_element_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5018 (class 2606 OID 55208048)
-- Name: observation_desc_element observation_desc_element_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5019 (class 2606 OID 55208033)
-- Name: observation_desc_plot observation_desc_plot_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5020 (class 2606 OID 55207742)
-- Name: observation_desc_plot observation_desc_plot_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5021 (class 2606 OID 55208028)
-- Name: observation_desc_plot observation_desc_plot_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 55208043)
-- Name: observation_desc_profile observation_desc_profile_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5023 (class 2606 OID 55207747)
-- Name: observation_desc_profile observation_desc_profile_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 5024 (class 2606 OID 55208038)
-- Name: observation_desc_profile observation_desc_profile_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5026 (class 2606 OID 55207839)
-- Name: observation_num observation_num_procedure_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_procedure_num_id_fkey FOREIGN KEY (procedure_num_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5027 (class 2606 OID 55207799)
-- Name: observation_num observation_num_property_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_num
    ADD CONSTRAINT observation_num_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5029 (class 2606 OID 55207824)
-- Name: procedure_num procedure_num_broader_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_num
    ADD CONSTRAINT procedure_num_broader_id_fkey FOREIGN KEY (broader_id) REFERENCES soil_data.procedure_num(procedure_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 55208141)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5048 (class 2606 OID 55208146)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5049 (class 2606 OID 55208151)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 55208234)
-- Name: project_soil_map project_soil_map_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 55208239)
-- Name: project_soil_map project_soil_map_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_soil_map
    ADD CONSTRAINT project_soil_map_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5032 (class 2606 OID 55208023)
-- Name: result_desc_element result_desc_element_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_element(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5034 (class 2606 OID 55208008)
-- Name: result_desc_plot result_desc_plot_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_plot(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5036 (class 2606 OID 55208018)
-- Name: result_desc_profile result_desc_profile_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_profile(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5038 (class 2606 OID 55207521)
-- Name: result_num result_num_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_num
    ADD CONSTRAINT result_num_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id);


--
-- TOC entry 5052 (class 2606 OID 55208192)
-- Name: result_spectral result_spectral_observation_num_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectral
    ADD CONSTRAINT result_spectral_observation_num_id_fkey FOREIGN KEY (observation_num_id) REFERENCES soil_data.observation_num(observation_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5058 (class 2606 OID 55208276)
-- Name: soil_mapping_unit soil_mapping_unit_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit
    ADD CONSTRAINT soil_mapping_unit_category_id_fkey FOREIGN KEY (category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 55208259)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES soil_data.soil_mapping_unit_category(category_id) ON DELETE CASCADE;


--
-- TOC entry 5057 (class 2606 OID 55208254)
-- Name: soil_mapping_unit_category soil_mapping_unit_category_soil_map_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_category
    ADD CONSTRAINT soil_mapping_unit_category_soil_map_id_fkey FOREIGN KEY (soil_map_id) REFERENCES soil_data.soil_map(soil_map_id) ON DELETE CASCADE;


--
-- TOC entry 5063 (class 2606 OID 55208340)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5064 (class 2606 OID 55208345)
-- Name: soil_mapping_unit_profile soil_mapping_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_mapping_unit_profile
    ADD CONSTRAINT soil_mapping_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 55208307)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_mapping_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_mapping_unit_id_fkey FOREIGN KEY (mapping_unit_id) REFERENCES soil_data.soil_mapping_unit(mapping_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5060 (class 2606 OID 55208302)
-- Name: soil_typological_unit_mapping_unit soil_typological_unit_mapping_unit_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_mapping_unit
    ADD CONSTRAINT soil_typological_unit_mapping_unit_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5061 (class 2606 OID 55208326)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id) ON DELETE CASCADE;


--
-- TOC entry 5062 (class 2606 OID 55208321)
-- Name: soil_typological_unit_profile soil_typological_unit_profile_typological_unit_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.soil_typological_unit_profile
    ADD CONSTRAINT soil_typological_unit_profile_typological_unit_id_fkey FOREIGN KEY (typological_unit_id) REFERENCES soil_data.soil_typological_unit(typological_unit_id) ON DELETE CASCADE;


--
-- TOC entry 5040 (class 2606 OID 55207844)
-- Name: specimen specimen_element_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_element_id_fkey FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 55208080)
-- Name: translate translate_language_code_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_language_code_fkey FOREIGN KEY (language_code) REFERENCES soil_data.languages(language_code);


--
-- TOC entry 5072 (class 2606 OID 55208488)
-- Name: class class_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5071 (class 2606 OID 55208493)
-- Name: layer layer_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5066 (class 2606 OID 55208498)
-- Name: mapset mapset_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5067 (class 2606 OID 55208503)
-- Name: mapset mapset_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE;


--
-- TOC entry 5068 (class 2606 OID 55208508)
-- Name: mapset mapset_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5073 (class 2606 OID 55208468)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5074 (class 2606 OID 55208478)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5075 (class 2606 OID 55208473)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5065 (class 2606 OID 55208513)
-- Name: project project_country_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_country_id_fkey FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE;


--
-- TOC entry 5069 (class 2606 OID 55208518)
-- Name: property property_property_num_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_property_num_id_fkey FOREIGN KEY (property_num_id) REFERENCES soil_data.property_num(property_num_id) ON UPDATE CASCADE;


--
-- TOC entry 5070 (class 2606 OID 55208523)
-- Name: property property_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 5076 (class 2606 OID 55208483)
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
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 1640
-- Name: FUNCTION class(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.class() TO sis_r;


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 1641
-- Name: FUNCTION map(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.map() TO sis_r;


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 1642
-- Name: FUNCTION sld(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.sld() TO sis_r;


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE api_client; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.api_client TO sis_r;


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE audit; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.audit TO sis_r;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE layer; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.layer TO sis_r;


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE setting; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.setting TO sis_r;


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE uploaded_dataset; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE uploaded_dataset_column; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE "user"; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api."user" TO sis_r;


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.element TO sis_r;


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_num TO sis_r;


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot TO sis_r;


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profile TO sis_r;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_num TO sis_r;


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE specimen; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen TO sis_r;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE vw_api_manifest; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_manifest TO sis_r;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE project; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project TO sis_r;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE project_site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.site TO sis_r;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE vw_api_observation; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_observation TO sis_r;


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE vw_api_profile; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.vw_api_profile TO sis_r;


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE category_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.category_desc TO sis_r;


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE element_element_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.element_element_id_seq TO sis_r;


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.individual TO sis_r;


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE languages; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.languages TO sis_r;


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_element TO sis_r;


--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_plot TO sis_r;


--
-- TOC entry 5336 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_profile TO sis_r;


--
-- TOC entry 5337 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE observation_phys_chem_element_observation_phys_chem_element_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.observation_phys_chem_element_observation_phys_chem_element_seq TO sis_r;


--
-- TOC entry 5338 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE organisation; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.organisation TO sis_r;


--
-- TOC entry 5339 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE plot_plot_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.plot_plot_id_seq TO sis_r;


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE procedure_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_desc TO sis_r;


--
-- TOC entry 5349 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_num TO sis_r;


--
-- TOC entry 5350 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE procedure_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_spectral TO sis_r;


--
-- TOC entry 5351 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE profile_profile_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.profile_profile_id_seq TO sis_r;


--
-- TOC entry 5352 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5357 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE project_soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_soil_map TO sis_r;


--
-- TOC entry 5358 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE property_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_desc TO sis_r;


--
-- TOC entry 5362 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE property_num; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_num TO sis_r;


--
-- TOC entry 5367 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE result_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_element TO sis_r;


--
-- TOC entry 5372 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_plot TO sis_r;


--
-- TOC entry 5377 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_profile TO sis_r;


--
-- TOC entry 5378 (class 0 OID 0)
-- Dependencies: 256
-- Name: SEQUENCE result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq TO sis_r;


--
-- TOC entry 5379 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE result_spectral; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectral TO sis_r;


--
-- TOC entry 5380 (class 0 OID 0)
-- Dependencies: 269
-- Name: SEQUENCE result_spectral_result_spectral_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectral_result_spectral_id_seq TO sis_r;


--
-- TOC entry 5381 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE result_spectrum; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectrum TO sis_r;


--
-- TOC entry 5382 (class 0 OID 0)
-- Dependencies: 257
-- Name: SEQUENCE result_spectrum_result_spectrum_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectrum_result_spectrum_id_seq TO sis_r;


--
-- TOC entry 5383 (class 0 OID 0)
-- Dependencies: 245
-- Name: SEQUENCE site_site_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.site_site_id_seq TO sis_r;


--
-- TOC entry 5399 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE soil_map; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_map TO sis_r;


--
-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 272
-- Name: SEQUENCE soil_map_soil_map_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_map_soil_map_id_seq TO sis_r;


--
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE soil_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit TO sis_r;


--
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE soil_mapping_unit_category; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_category TO sis_r;


--
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 275
-- Name: SEQUENCE soil_mapping_unit_category_category_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_category_category_id_seq TO sis_r;


--
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 277
-- Name: SEQUENCE soil_mapping_unit_mapping_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_mapping_unit_mapping_unit_id_seq TO sis_r;


--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE soil_mapping_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_mapping_unit_profile TO sis_r;


--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE soil_typological_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit TO sis_r;


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE soil_typological_unit_mapping_unit; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_mapping_unit TO sis_r;


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE soil_typological_unit_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.soil_typological_unit_profile TO sis_r;


--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 279
-- Name: SEQUENCE soil_typological_unit_typological_unit_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.soil_typological_unit_typological_unit_id_seq TO sis_r;


--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE specimen_prep_process; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_prep_process TO sis_r;


--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 248
-- Name: SEQUENCE specimen_prep_process_specimen_prep_process_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_prep_process_specimen_prep_process_id_seq TO sis_r;


--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 249
-- Name: SEQUENCE specimen_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_specimen_id_seq TO sis_r;


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE specimen_storage; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_storage TO sis_r;


--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 251
-- Name: SEQUENCE specimen_storage_specimen_storage_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_storage_specimen_storage_id_seq TO sis_r;


--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_transport; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_transport TO sis_r;


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 253
-- Name: SEQUENCE specimen_transport_specimen_transport_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_transport_specimen_transport_id_seq TO sis_r;


--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE spectral_data; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.spectral_data TO sis_r;


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 267
-- Name: SEQUENCE spectral_data_spectral_data_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.spectral_data_spectral_data_id_seq TO sis_r;


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE translate; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.translate TO sis_r;


--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE unit_of_measure; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.unit_of_measure TO sis_r;


--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE class; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE country; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE individual; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE layer; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE mapset; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;


--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE organisation; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE project; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE property; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE url; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--
-- TOC entry 3579 (class 826 OID 55208532)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: api; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3578 (class 826 OID 55207875)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3580 (class 826 OID 55208617)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data_upload; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;


-- Completed on 2026-01-09 19:07:13 CET

--
-- PostgreSQL database dump complete
--

\unrestrict 9rSHThmMfaMKB7KafrFjRn2AcUoX9BXcr55xHREjI3vfi9nWB5lpBhhHrekyXoK

