--
-- PostgreSQL database dump
--

\restrict 0lB8PtiLtajfVtCnUYFuqXQ9ss9cX58JojPYYVXx95KsgwdSoFvVJg55ctzeaa7

-- Dumped from database version 12.22 (Ubuntu 12.22-2.pgdg22.04+1)
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-1.pgdg22.04+1)

-- Started on 2025-08-22 17:28:38 CEST

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
-- TOC entry 12 (class 2615 OID 54931635)
-- Name: api; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO sis;

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA api IS 'API tables';


--
-- TOC entry 16 (class 2615 OID 54931455)
-- Name: kobo; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA kobo;


ALTER SCHEMA kobo OWNER TO sis;

--
-- TOC entry 5115 (class 0 OID 0)
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
-- TOC entry 14 (class 2615 OID 54929806)
-- Name: soil_data; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data;


ALTER SCHEMA soil_data OWNER TO sis;

--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data IS 'Core entities and relations from the ISO-28258 domain model';


--
-- TOC entry 13 (class 2615 OID 54931637)
-- Name: soil_data_upload; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA soil_data_upload;


ALTER SCHEMA soil_data_upload OWNER TO sis;

--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA soil_data_upload; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA soil_data_upload IS 'Schema to upload soil data';


--
-- TOC entry 15 (class 2615 OID 54931456)
-- Name: spatial_metadata; Type: SCHEMA; Schema: -; Owner: sis
--

CREATE SCHEMA spatial_metadata;


ALTER SCHEMA spatial_metadata OWNER TO sis;

--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: COMMENT; Schema: -; Owner: sis
--

COMMENT ON SCHEMA spatial_metadata IS 'Schema for spatial metadata';


--
-- TOC entry 5 (class 3079 OID 54928091)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 4 (class 3079 OID 54929176)
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- TOC entry 3 (class 3079 OID 54929733)
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- TOC entry 2 (class 3079 OID 54929795)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1604 (class 1255 OID 54931195)
-- Name: check_result_value(); Type: FUNCTION; Schema: soil_data; Owner: sis
--

CREATE FUNCTION soil_data.check_result_value() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    observation core.observation_phys_chem%ROWTYPE;
BEGIN
    SELECT * 
      INTO observation
      FROM core.observation_phys_chem
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
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 1604
-- Name: FUNCTION check_result_value(); Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON FUNCTION soil_data.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';


--
-- TOC entry 1605 (class 1255 OID 54931457)
-- Name: class(); Type: FUNCTION; Schema: spatial_metadata; Owner: sis
--

CREATE FUNCTION spatial_metadata.class() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
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

  -- Only when property_type is quantitative
  IF NEW.property_type = 'quantitative' THEN

    -- Validate num_intervals
    IF NEW.num_intervals <= 0 THEN
        RAISE EXCEPTION 'Number of intervals must be greater than 0.';
    END IF;

    -- Validate start_color and end_color
    IF NEW.start_color NOT LIKE '#______' OR NEW.end_color NOT LIKE '#______' THEN
        RAISE EXCEPTION 'Colors must be in HEX format (e.g., #F4E7D3).';
    END IF;

    -- Check if stats_minimum and max are valid
    IF NEW.min IS NULL OR NEW.max IS NULL THEN
        RAISE EXCEPTION 'min and max must not be NULL.';
    END IF;

    -- Calculate the range and interval size
    range := NEW.max - NEW.min;
    IF range = 0 THEN
        RAISE EXCEPTION 'Range is 0. Cannot create intervals for layer_id %.', NEW.layer_id;
    END IF;
    interval_size := range / NEW.num_intervals;
    current_min := NEW.min;
    current_max := NEW.min + interval_size;

    -- Delete existing rows for this property_id
    DELETE FROM spatial_metadata.class WHERE property_id = NEW.property_id;

    -- Extract RGB components from start_color and end_color
    start_r := ('x' || SUBSTRING(NEW.start_color FROM 2 FOR 2))::BIT(8)::INT;
    start_g := ('x' || SUBSTRING(NEW.start_color FROM 4 FOR 2))::BIT(8)::INT;
    start_b := ('x' || SUBSTRING(NEW.start_color FROM 6 FOR 2))::BIT(8)::INT;
    end_r := ('x' || SUBSTRING(NEW.end_color FROM 2 FOR 2))::BIT(8)::INT;
    end_g := ('x' || SUBSTRING(NEW.end_color FROM 4 FOR 2))::BIT(8)::INT;
    end_b := ('x' || SUBSTRING(NEW.end_color FROM 6 FOR 2))::BIT(8)::INT;

    -- Loop to create intervals
    WHILE i <= NEW.num_intervals LOOP
        -- Interpolate the color based on the interval index
        color := '#' || 
                LPAD(TO_HEX(start_r + (end_r - start_r) * (i - 1) / (NEW.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_g + (end_g - start_g) * (i - 1) / (NEW.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_b + (end_b - start_b) * (i - 1) / (NEW.num_intervals - 1)), 2, '0');

        -- Insert the class interval and color into the categories table
        INSERT INTO spatial_metadata.class (property_id, value, code, "label", color, opacity, publish)
        VALUES (NEW.property_id, current_min::numeric(20,2), 
              current_min::numeric(20,2) || ' - ' || current_max::numeric(20,2), 
              current_min::numeric(20,2) || ' - ' || current_max::numeric(20,2), 
              color, 1, 't')
        ON CONFLICT (property_id, value)
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
-- TOC entry 1606 (class 1255 OID 54931458)
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
-- TOC entry 1607 (class 1255 OID 54931459)
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
    FOR rec IN SELECT property_id, 
                CASE WHEN property_type='categorical'  THEN 'values'
                    WHEN property_type='quantitative' THEN 'intervals'
                    END property_type
                FROM spatial_metadata.property ORDER BY property_id
    LOOP
	
      FOR sub_rec IN SELECT code, value, color, opacity, label FROM spatial_metadata.class WHERE property_id = rec.property_id AND publish IS TRUE ORDER BY value
    	LOOP
		
			SELECT E'\n             <sld:ColorMapEntry quantity="' ||sub_rec.value|| '" color="' ||sub_rec.color|| '" opacity="' ||sub_rec.opacity|| '" label="' ||sub_rec.label|| '"/>' INTO new_row;

			SELECT part_2 || new_row INTO part_2;
		
		END LOOP;
		
		  UPDATE spatial_metadata.property SET sld = replace(replace(part_1,'LAYER_NAME',rec.property_id),'property_type',rec.property_type) || part_2 || part_3 WHERE property_id = rec.property_id;
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
-- TOC entry 286 (class 1259 OID 54931686)
-- Name: layer; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.layer (
    individual_id text,
    project_id text,
    layer_id text NOT NULL,
    publish boolean DEFAULT true,
    property_id text,
    property_name text,
    version text,
    unit_of_measure_id text,
    dimension_des text,
    metadata_url text,
    download_url text,
    get_map_url text,
    get_legend_url text,
    get_feature_info_url text
);


ALTER TABLE api.layer OWNER TO sis;

--
-- TOC entry 284 (class 1259 OID 54931660)
-- Name: setting; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.setting (
    key text NOT NULL,
    value text,
    display_order smallint
);


ALTER TABLE api.setting OWNER TO sis;

--
-- TOC entry 287 (class 1259 OID 54931705)
-- Name: uploaded_dataset; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.uploaded_dataset (
    individual_id text,
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
-- TOC entry 288 (class 1259 OID 54931728)
-- Name: uploaded_dataset_column; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.uploaded_dataset_column (
    table_name text NOT NULL,
    column_name text NOT NULL,
    property_phys_chem_id text,
    procedure_phys_chem_id text,
    unit_of_measure_id text,
    ignore_column boolean DEFAULT false,
    note text
);


ALTER TABLE api.uploaded_dataset_column OWNER TO sis;

--
-- TOC entry 283 (class 1259 OID 54931639)
-- Name: user; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api."user" (
    individual_id text NOT NULL,
    organisation_id text,
    password_hash text NOT NULL,
    created_at date DEFAULT CURRENT_DATE,
    last_login date,
    is_active boolean DEFAULT true,
    is_admin boolean DEFAULT false
);


ALTER TABLE api."user" OWNER TO sis;

--
-- TOC entry 285 (class 1259 OID 54931668)
-- Name: user_layer; Type: TABLE; Schema: api; Owner: sis
--

CREATE TABLE api.user_layer (
    individual_id text NOT NULL,
    project_id text NOT NULL
);


ALTER TABLE api.user_layer OWNER TO sis;

--
-- TOC entry 265 (class 1259 OID 54931241)
-- Name: category_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.category_desc (
    category_desc_id text NOT NULL,
    uri text
);


ALTER TABLE soil_data.category_desc OWNER TO sis;

--
-- TOC entry 226 (class 1259 OID 54929815)
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
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.element IS 'ProfileElement is the super-class of Horizon and Layer, which share the same basic properties. Horizons develop in a layer, which in turn have been developed throught geogenesis or anthropogenic action. Layers can be used to describe common characteristics of a set of adjoining horizons. For the time being no assocation is previewed between Horizon and Layer.';


--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.element_id IS 'Synthetic primary key.';


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.profile_id IS 'Reference to the Profile to which this element belongs';


--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.order_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.order_element IS 'Order of this element within the Profile';


--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.upper_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.upper_depth IS 'Upper depth of this profile element in centimetres.';


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.lower_depth; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.lower_depth IS 'Lower depth of this profile element in centimetres.';


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN element.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.element.type IS 'Type of profile element, Horizon or Layer';


--
-- TOC entry 227 (class 1259 OID 54929821)
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
-- TOC entry 270 (class 1259 OID 54931417)
-- Name: individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE soil_data.individual OWNER TO sis;

--
-- TOC entry 266 (class 1259 OID 54931360)
-- Name: languages; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.languages (
    language_code text NOT NULL,
    language_name text NOT NULL
);


ALTER TABLE soil_data.languages OWNER TO sis;

--
-- TOC entry 228 (class 1259 OID 54929823)
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
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_element IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_element.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 229 (class 1259 OID 54929826)
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
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_plot IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN observation_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_plot.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 230 (class 1259 OID 54929829)
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
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_desc_profile IS 'Descriptive properties for the Surface feature of interest';


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.procedure_desc_id IS 'Foreign key to the corresponding procedure.';


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.property_desc_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN observation_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_desc_profile.category_desc_id IS 'Foreign key to the corresponding thesaurus entry';


--
-- TOC entry 231 (class 1259 OID 54929846)
-- Name: observation_phys_chem; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.observation_phys_chem (
    observation_phys_chem_id integer NOT NULL,
    property_phys_chem_id text NOT NULL,
    procedure_phys_chem_id text NOT NULL,
    unit_of_measure_id text NOT NULL,
    value_min real,
    value_max real
);


ALTER TABLE soil_data.observation_phys_chem OWNER TO sis;

--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_phys_chem; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.observation_phys_chem IS 'Physio-chemical observations for the Element feature of interest';


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.observation_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.observation_phys_chem_id IS 'Synthetic primary key for the observation';


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.property_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.property_phys_chem_id IS 'Foreign key to the corresponding property';


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.procedure_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.procedure_phys_chem_id IS 'Foreign key to the corresponding procedure';


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.unit_of_measure_id IS 'Foreign key to the corresponding unit of measure (if applicable)';


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.value_min; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.value_min IS 'Minimum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN observation_phys_chem.value_max; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.observation_phys_chem.value_max IS 'Maximum admissable value for this combination of property, procedure and unit of measure';


--
-- TOC entry 260 (class 1259 OID 54930802)
-- Name: observation_phys_chem_element_observation_phys_chem_element_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.observation_phys_chem ALTER COLUMN observation_phys_chem_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.observation_phys_chem_element_observation_phys_chem_element_seq
    START WITH 1008
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 54931409)
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
-- TOC entry 232 (class 1259 OID 54929854)
-- Name: plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.plot (
    plot_id integer NOT NULL,
    site_id integer NOT NULL,
    plot_code character varying,
    altitude smallint,
    time_stamp date,
    map_sheet_code character varying,
    positional_accuracy smallint,
    "position" public.geometry(Point,4326),
    type text,
    CONSTRAINT plot_altitude_check CHECK (((altitude)::numeric > ('-100'::integer)::numeric)),
    CONSTRAINT plot_altitude_check1 CHECK (((altitude)::numeric < (8000)::numeric)),
    CONSTRAINT plot_time_stamp_check CHECK ((time_stamp > '1900-01-01'::date)),
    CONSTRAINT plot_type_check CHECK ((type = ANY (ARRAY['TrialPit'::text, 'Borehole'::text])))
);


ALTER TABLE soil_data.plot OWNER TO sis;

--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot IS 'Elementary area or location where individual observations are made and/or samples are taken. Plot is the main spatial feature of interest in ISO-28258. Plot has three sub-classes: Borehole, Pit and Surface. Surface features its own table since it has its own properties and a different geometry.';


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_id IS 'Synthetic primary key.';


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.site_id IS 'Foreign key to Site table.';


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.plot_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.plot_code IS 'Natural key, can be null.';


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.altitude; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.altitude IS 'Altitude at the plot in metres, if known. Property re-used from GloSIS.';


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.time_stamp; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.time_stamp IS 'Time stamp of the plot, if known. Property re-used from GloSIS.';


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.map_sheet_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.map_sheet_code IS 'Code identifying the map sheet where the plot may be positioned. Property re-used from GloSIS.';


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.positional_accuracy; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.positional_accuracy IS 'Accuracy in meters of the GPS position.';


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot."position"; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot."position" IS 'Geodetic coordinates of the spatial position of the plot. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN plot.type; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot.type IS 'Type of plot, TrialPit or Borehole.';


--
-- TOC entry 233 (class 1259 OID 54929863)
-- Name: plot_individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.plot_individual (
    plot_id integer NOT NULL,
    individual_id integer NOT NULL
);


ALTER TABLE soil_data.plot_individual OWNER TO sis;

--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE plot_individual; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.plot_individual IS 'Identifies the individual(s) responsible for surveying a plot';


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN plot_individual.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot_individual.plot_id IS 'Foreign key to the plot table, identifies the plot surveyed';


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN plot_individual.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.plot_individual.individual_id IS 'Foreign key to the individual table, indicates the individual responsible for surveying the plot.';


--
-- TOC entry 234 (class 1259 OID 54929866)
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
-- TOC entry 235 (class 1259 OID 54929868)
-- Name: procedure_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_desc (
    procedure_desc_id text NOT NULL,
    reference character varying,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.procedure_desc OWNER TO sis;

--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_desc; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_desc IS 'Descriptive Procedures for all features of interest. In most cases the procedure is described in a document such as the FAO Guidelines for Soil Description or the World Reference Base of Soil Resources.';


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_desc.procedure_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.procedure_desc_id IS 'Synthetic primary key.';


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_desc.reference; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.reference IS 'Long and human readable reference to the publication.';


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN procedure_desc.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_desc.uri IS 'URI to the corresponding publication, optimally a DOI. Follow this URI for the full definition of the procedure.';


--
-- TOC entry 236 (class 1259 OID 54929876)
-- Name: procedure_phys_chem; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.procedure_phys_chem (
    procedure_phys_chem_id text NOT NULL,
    broader_id text,
    uri character varying NOT NULL,
    definition text,
    reference text,
    citation text
);


ALTER TABLE soil_data.procedure_phys_chem OWNER TO sis;

--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE procedure_phys_chem; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.procedure_phys_chem IS 'Physio-chemical Procedures for the Profile Element feature of interest';


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN procedure_phys_chem.procedure_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_phys_chem.procedure_phys_chem_id IS 'Synthetic primary key.';


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN procedure_phys_chem.broader_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_phys_chem.broader_id IS 'Foreign key to brader procedure in the hierarchy';


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN procedure_phys_chem.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.procedure_phys_chem.uri IS 'URI to the corresponding in a controlled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this procedure';


--
-- TOC entry 237 (class 1259 OID 54929884)
-- Name: profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.profile (
    profile_id integer NOT NULL,
    plot_id integer,
    surface_id integer,
    profile_code character varying,
    CONSTRAINT site_mandatory_foi CHECK ((((plot_id IS NOT NULL) OR (surface_id IS NOT NULL)) AND (NOT ((plot_id IS NOT NULL) AND (surface_id IS NOT NULL)))))
);


ALTER TABLE soil_data.profile OWNER TO sis;

--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.profile IS 'An abstract, ordered set of soil horizons and/or layers.';


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_id IS 'Synthetic primary key.';


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN profile.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.plot_id IS 'Foreign key to Plot feature of interest';


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN profile.surface_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.surface_id IS 'Foreign key to Surface feature of interest';


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN profile.profile_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.profile.profile_code IS 'Natural primary key, if existing';


--
-- TOC entry 238 (class 1259 OID 54929891)
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
-- TOC entry 239 (class 1259 OID 54929893)
-- Name: project; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project (
    project_id text NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE soil_data.project OWNER TO sis;

--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE project; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.project IS 'Provides the context of the data collection as a prerequisite for the proper use or reuse of these data.';


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN project.project_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.project_id IS 'Synthetic primary key.';


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN project.name; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.project.name IS 'Natural key with project name.';


--
-- TOC entry 268 (class 1259 OID 54931391)
-- Name: project_site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.project_site (
    project_id text NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE soil_data.project_site OWNER TO sis;

--
-- TOC entry 245 (class 1259 OID 54929973)
-- Name: result_phys_chem; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_phys_chem (
    result_phys_chem_id integer NOT NULL,
    observation_phys_chem_id integer NOT NULL,
    specimen_id integer NOT NULL,
    individual_id integer,
    value real NOT NULL
);


ALTER TABLE soil_data.result_phys_chem OWNER TO sis;

--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE result_phys_chem; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_phys_chem IS 'Numerical results for the Specimen feature interest.';


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN result_phys_chem.result_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_phys_chem.result_phys_chem_id IS 'Synthetic primary key.';


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN result_phys_chem.observation_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_phys_chem.observation_phys_chem_id IS 'Foreign key to the corresponding numerical observation.';


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN result_phys_chem.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_phys_chem.specimen_id IS 'Foreign key to the corresponding Specimen instance.';


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN result_phys_chem.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_phys_chem.individual_id IS 'Individual that is responsible for, or carried out, the process that produced this result.';


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN result_phys_chem.value; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_phys_chem.value IS 'Numerical value resulting from applying the refered observation to the refered specimen.';


--
-- TOC entry 246 (class 1259 OID 54929989)
-- Name: site; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.site (
    site_id integer NOT NULL,
    site_code character varying,
    typical_profile integer,
    "position" public.geometry(Point,4326),
    extent public.geometry(Polygon,4326),
    CONSTRAINT site_mandatory_geometry CHECK (((("position" IS NOT NULL) OR (extent IS NOT NULL)) AND (NOT (("position" IS NOT NULL) AND (extent IS NOT NULL)))))
);


ALTER TABLE soil_data.site OWNER TO sis;

--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE site; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.site IS 'Defined area which is subject to a soil quality investigation. Site is not a spatial feature of interest, but provides the link between the spatial features of interest (Plot) to the Project. The geometry can either be a location (point) or extent (polygon) but not both at the same time.';


--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN site.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_id IS 'Synthetic primary key.';


--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN site.site_code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.site_code IS 'Natural key, can be null.';


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN site.typical_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.typical_profile IS 'Foreign key to a profile providing a typical characterisation of this site.';


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN site."position"; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site."position" IS 'Geodetic coordinates of the spatial position of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN site.extent; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.site.extent IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 248 (class 1259 OID 54930001)
-- Name: specimen; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen (
    specimen_id integer NOT NULL,
    element_id integer NOT NULL,
    specimen_prep_process_id integer,
    organisation_id integer,
    code character varying
);


ALTER TABLE soil_data.specimen OWNER TO sis;

--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE specimen; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen IS 'Soil Specimen is defined in ISO-28258 as: "a subtype of SF_Specimen. Soil Specimen may be taken in the Site, Plot, Profile, or ProfileElement including their subtypes." In this database Specimen is for now only associated to Plot for simplification.';


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN specimen.specimen_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_id IS 'Synthetic primary key.';


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN specimen.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.element_id IS 'Foreign key to the associated soil Plot';


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN specimen.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.specimen_prep_process_id IS 'Foreign key to the preparation process used on this soil Specimen.';


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN specimen.organisation_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.organisation_id IS 'Organisation that is responsible for, or carried out, the process that produced this result.';


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN specimen.code; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen.code IS 'External code used to identify the soil Specimen (if used).';


--
-- TOC entry 272 (class 1259 OID 54931450)
-- Name: profiles; Type: VIEW; Schema: soil_data; Owner: sis
--

CREATE VIEW soil_data.profiles AS
 SELECT r.result_phys_chem_id AS gid,
    p.name AS project_name,
    s.site_id,
    p3.profile_id,
    r.specimen_id,
    e.upper_depth,
    e.lower_depth,
    o.property_phys_chem_id,
    o.procedure_phys_chem_id,
    r.value,
    o.unit_of_measure_id,
    p2."position" AS geom
   FROM ((((((((soil_data.project p
     LEFT JOIN soil_data.project_site sp ON ((sp.project_id = p.project_id)))
     LEFT JOIN soil_data.site s ON ((s.site_id = sp.site_id)))
     LEFT JOIN soil_data.plot p2 ON ((p2.site_id = s.site_id)))
     LEFT JOIN soil_data.profile p3 ON ((p3.plot_id = p2.plot_id)))
     LEFT JOIN soil_data.element e ON ((e.profile_id = p3.profile_id)))
     LEFT JOIN soil_data.specimen s2 ON ((s2.element_id = e.element_id)))
     LEFT JOIN soil_data.result_phys_chem r ON ((r.specimen_id = s2.specimen_id)))
     LEFT JOIN soil_data.observation_phys_chem o ON ((o.observation_phys_chem_id = r.observation_phys_chem_id)))
  ORDER BY p.name, s.site_id, p3.profile_id, e.upper_depth, o.property_phys_chem_id;


ALTER VIEW soil_data.profiles OWNER TO sis;

--
-- TOC entry 271 (class 1259 OID 54931425)
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
-- TOC entry 264 (class 1259 OID 54931233)
-- Name: property_desc; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_desc (
    property_desc_id text NOT NULL,
    property_pretty_name text,
    uri text
);


ALTER TABLE soil_data.property_desc OWNER TO sis;

--
-- TOC entry 240 (class 1259 OID 54929950)
-- Name: property_phys_chem; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.property_phys_chem (
    property_phys_chem_id text NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.property_phys_chem OWNER TO sis;

--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE property_phys_chem; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.property_phys_chem IS 'Physio-chemical properties for the Element feature of interest';


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN property_phys_chem.property_phys_chem_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_phys_chem.property_phys_chem_id IS 'Synthetic primary key.';


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN property_phys_chem.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.property_phys_chem.uri IS 'URI to the corresponding code in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this property';


--
-- TOC entry 241 (class 1259 OID 54929958)
-- Name: result_desc_element; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_element (
    element_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_element OWNER TO sis;

--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_element; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_element IS 'Descriptive results for the Element feature interest.';


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_element.element_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.element_id IS 'Foreign key to the corresponding Element feature of interest.';


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_element.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.property_desc_id IS 'Foreign key to property_desc_element table.';


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN result_desc_element.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_element.category_desc_id IS 'Foreign key to thesaurus_desc_element table.';


--
-- TOC entry 242 (class 1259 OID 54929961)
-- Name: result_desc_plot; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_plot (
    plot_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_plot OWNER TO sis;

--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_plot; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_plot IS 'Descriptive results for the Plot feature interest.';


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_plot.plot_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.plot_id IS 'Foreign key to the corresponding Plot feature of interest.';


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_plot.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.property_desc_id IS 'Foreign key to property_desc_plot table.';


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN result_desc_plot.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_plot.category_desc_id IS 'Foreign key to thesaurus_desc_plot table.';


--
-- TOC entry 243 (class 1259 OID 54929964)
-- Name: result_desc_profile; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_profile (
    profile_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_profile OWNER TO sis;

--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_desc_profile; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_profile IS 'Descriptive results for the Profile feature interest.';


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_desc_profile.profile_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.profile_id IS 'Foreign key to the corresponding Profile feature of interest.';


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_desc_profile.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.property_desc_id IS 'Foreign key to property_desc_profile table.';


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN result_desc_profile.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_profile.category_desc_id IS 'Foreign key to thesaurus_desc_profile table.';


--
-- TOC entry 244 (class 1259 OID 54929970)
-- Name: result_desc_surface; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.result_desc_surface (
    surface_id integer NOT NULL,
    property_desc_id text NOT NULL,
    category_desc_id text NOT NULL
);


ALTER TABLE soil_data.result_desc_surface OWNER TO sis;

--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE result_desc_surface; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.result_desc_surface IS 'Descriptive results for the Surface feature interest.';


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN result_desc_surface.surface_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_surface.surface_id IS 'Foreign key to the corresponding Surface feature of interest.';


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN result_desc_surface.property_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_surface.property_desc_id IS 'Foreign key to property_desc_surface table.';


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN result_desc_surface.category_desc_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.result_desc_surface.category_desc_id IS 'Foreign key to thesaurus_desc_surface table.';


--
-- TOC entry 261 (class 1259 OID 54930808)
-- Name: result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.result_phys_chem ALTER COLUMN result_phys_chem_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 263 (class 1259 OID 54931175)
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
-- TOC entry 262 (class 1259 OID 54931173)
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
-- TOC entry 247 (class 1259 OID 54929999)
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
-- TOC entry 249 (class 1259 OID 54930007)
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
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE specimen_prep_process; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_prep_process IS 'Describes the preparation process of a soil Specimen. Contains information that does not result from observation(s).';


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN specimen_prep_process.specimen_prep_process_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_prep_process_id IS 'Synthetic primary key.';


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN specimen_prep_process.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_transport_id IS 'Foreign key for the corresponding mode of transport';


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN specimen_prep_process.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.specimen_storage_id IS 'Foreign key for the corresponding mode of storage';


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN specimen_prep_process.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_prep_process.definition IS 'Further details necessary to define the preparation process.';


--
-- TOC entry 250 (class 1259 OID 54930013)
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
-- TOC entry 251 (class 1259 OID 54930015)
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
-- TOC entry 252 (class 1259 OID 54930017)
-- Name: specimen_storage; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_storage (
    specimen_storage_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_storage OWNER TO sis;

--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_storage; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_storage IS 'Modes of storage of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_storage.specimen_storage_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.specimen_storage_id IS 'Synthetic primary key.';


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_storage.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.label IS 'Short label for the storage mode.';


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN specimen_storage.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_storage.definition IS 'Long definition providing all the necessary details for the storage mode.';


--
-- TOC entry 253 (class 1259 OID 54930023)
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
-- TOC entry 254 (class 1259 OID 54930025)
-- Name: specimen_transport; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.specimen_transport (
    specimen_transport_id integer NOT NULL,
    label character varying NOT NULL,
    definition character varying
);


ALTER TABLE soil_data.specimen_transport OWNER TO sis;

--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE specimen_transport; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.specimen_transport IS 'Modes of transport of a soil Specimen, part of the Specimen preparation process.';


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN specimen_transport.specimen_transport_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.specimen_transport_id IS 'Synthetic primary key.';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN specimen_transport.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.label IS 'Short label for the transport mode.';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN specimen_transport.definition; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.specimen_transport.definition IS 'Long definition providing all the necessary details for the transport mode.';


--
-- TOC entry 255 (class 1259 OID 54930031)
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
-- TOC entry 256 (class 1259 OID 54930033)
-- Name: surface; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.surface (
    surface_id integer NOT NULL,
    super_surface_id integer,
    site_id integer NOT NULL,
    shape public.geometry(Polygon,4326),
    time_stamp date
);


ALTER TABLE soil_data.surface OWNER TO sis;

--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE surface; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.surface IS 'Surface is a subtype of Plot with a shape geometry. Surfaces may be located within other
surfaces.';


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN surface.surface_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface.surface_id IS 'Synthetic primary key.';


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN surface.super_surface_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface.super_surface_id IS 'Hierarchical relation between surfaces.';


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN surface.site_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface.site_id IS 'Foreign key to Site table';


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN surface.shape; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface.shape IS 'Site extent expressed with geodetic coordinates of the site. Note the uncertainty associated with the WGS84 datum ensemble.';


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN surface.time_stamp; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface.time_stamp IS 'Time stamp of the plot, if known. Property re-used from GloSIS.';


--
-- TOC entry 257 (class 1259 OID 54930039)
-- Name: surface_individual; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.surface_individual (
    surface_id integer NOT NULL,
    individual_id integer NOT NULL
);


ALTER TABLE soil_data.surface_individual OWNER TO sis;

--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE surface_individual; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.surface_individual IS 'Identifies the individual(s) responsible for surveying a surface';


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN surface_individual.surface_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface_individual.surface_id IS 'Foreign key to the surface table, identifies the surface surveyed';


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN surface_individual.individual_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.surface_individual.individual_id IS 'Foreign key to the individual table, indicates the individual responsible for surveying the surface.';


--
-- TOC entry 258 (class 1259 OID 54930042)
-- Name: surface_surface_id_seq; Type: SEQUENCE; Schema: soil_data; Owner: sis
--

ALTER TABLE soil_data.surface ALTER COLUMN surface_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME soil_data.surface_surface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 267 (class 1259 OID 54931368)
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
-- TOC entry 259 (class 1259 OID 54930084)
-- Name: unit_of_measure; Type: TABLE; Schema: soil_data; Owner: sis
--

CREATE TABLE soil_data.unit_of_measure (
    unit_of_measure_id text NOT NULL,
    label character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE soil_data.unit_of_measure OWNER TO sis;

--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE unit_of_measure; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TABLE soil_data.unit_of_measure IS 'Unit of measure';


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN unit_of_measure.unit_of_measure_id; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.unit_of_measure_id IS 'Synthetic primary key.';


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN unit_of_measure.label; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.label IS 'Short label for this unit of measure';


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN unit_of_measure.uri; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON COLUMN soil_data.unit_of_measure.uri IS 'URI to the corresponding unit of measuree in a controled vocabulary (e.g. GloSIS). Follow this URI for the full definition and semantics of this unit of measure';


--
-- TOC entry 278 (class 1259 OID 54931517)
-- Name: class; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.class (
    property_id text NOT NULL,
    value real NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    color text NOT NULL,
    opacity real NOT NULL,
    publish boolean NOT NULL
);


ALTER TABLE spatial_metadata.class OWNER TO sis;

--
-- TOC entry 273 (class 1259 OID 54931460)
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
-- TOC entry 281 (class 1259 OID 54931537)
-- Name: individual; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.individual (
    individual_id text NOT NULL,
    email text
);


ALTER TABLE spatial_metadata.individual OWNER TO sis;

--
-- TOC entry 277 (class 1259 OID 54931509)
-- Name: layer; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.layer (
    mapset_id text NOT NULL,
    dimension_des text,
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
    CONSTRAINT layer_distance_uom_check CHECK ((distance_uom = ANY (ARRAY['m'::text, 'km'::text, 'deg'::text])))
);


ALTER TABLE spatial_metadata.layer OWNER TO sis;

--
-- TOC entry 275 (class 1259 OID 54931472)
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
-- TOC entry 280 (class 1259 OID 54931531)
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
-- TOC entry 279 (class 1259 OID 54931523)
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
-- TOC entry 274 (class 1259 OID 54931466)
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
-- TOC entry 276 (class 1259 OID 54931502)
-- Name: property; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.property (
    property_id text NOT NULL,
    name text,
    property_phys_chem_id text,
    unit_of_measure_id text,
    min real,
    max real,
    property_type text NOT NULL,
    num_intervals smallint NOT NULL,
    start_color text NOT NULL,
    end_color text NOT NULL,
    sld text,
    CONSTRAINT property_property_type_check CHECK ((property_type = ANY (ARRAY['quantitative'::text, 'categorical'::text])))
);


ALTER TABLE spatial_metadata.property OWNER TO sis;

--
-- TOC entry 282 (class 1259 OID 54931543)
-- Name: url; Type: TABLE; Schema: spatial_metadata; Owner: sis
--

CREATE TABLE spatial_metadata.url (
    mapset_id text NOT NULL,
    protocol text NOT NULL,
    url text NOT NULL,
    url_name text NOT NULL,
    CONSTRAINT url_protocol_check CHECK ((protocol = ANY (ARRAY['OGC:WMS'::text, 'OGC:WMTS'::text, 'WWW:LINK-1.0-http--link'::text, 'WWW:LINK-1.0-http--related'::text])))
);


ALTER TABLE spatial_metadata.url OWNER TO sis;

--
-- TOC entry 4897 (class 2606 OID 54931694)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4893 (class 2606 OID 54931667)
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (key);


--
-- TOC entry 4903 (class 2606 OID 54931736)
-- Name: uploaded_dataset_column uploaded_dataset_column_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_pkey PRIMARY KEY (table_name, column_name);


--
-- TOC entry 4899 (class 2606 OID 54931717)
-- Name: uploaded_dataset uploaded_dataset_file_name_key; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_file_name_key UNIQUE (file_name);


--
-- TOC entry 4901 (class 2606 OID 54931715)
-- Name: uploaded_dataset uploaded_dataset_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_pkey PRIMARY KEY (table_name);


--
-- TOC entry 4895 (class 2606 OID 54931675)
-- Name: user_layer user_layer_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.user_layer
    ADD CONSTRAINT user_layer_pkey PRIMARY KEY (individual_id, project_id);


--
-- TOC entry 4891 (class 2606 OID 54931649)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4855 (class 2606 OID 54931248)
-- Name: category_desc category_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.category_desc
    ADD CONSTRAINT category_desc_pkey PRIMARY KEY (category_desc_id);


--
-- TOC entry 4763 (class 2606 OID 54930167)
-- Name: element element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT element_pkey PRIMARY KEY (element_id);


--
-- TOC entry 4865 (class 2606 OID 54931424)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4857 (class 2606 OID 54931367)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_code);


--
-- TOC entry 4767 (class 2606 OID 54931296)
-- Name: observation_desc_element observation_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4769 (class 2606 OID 54931278)
-- Name: observation_desc_plot observation_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4771 (class 2606 OID 54931287)
-- Name: observation_desc_profile observation_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_pkey PRIMARY KEY (property_desc_id, category_desc_id);


--
-- TOC entry 4773 (class 2606 OID 54930189)
-- Name: observation_phys_chem observation_phys_chem_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_phys_chem
    ADD CONSTRAINT observation_phys_chem_pkey PRIMARY KEY (observation_phys_chem_id);


--
-- TOC entry 4775 (class 2606 OID 54931126)
-- Name: observation_phys_chem observation_phys_chem_property_phys_chem_id_procedure_phys__key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_phys_chem
    ADD CONSTRAINT observation_phys_chem_property_phys_chem_id_procedure_phys__key UNIQUE (property_phys_chem_id, procedure_phys_chem_id);


--
-- TOC entry 4863 (class 2606 OID 54931416)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4781 (class 2606 OID 54930774)
-- Name: plot_individual plot_individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot_individual
    ADD CONSTRAINT plot_individual_pkey PRIMARY KEY (plot_id, individual_id);


--
-- TOC entry 4777 (class 2606 OID 54930197)
-- Name: plot plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT plot_pkey PRIMARY KEY (plot_id);


--
-- TOC entry 4783 (class 2606 OID 54931002)
-- Name: procedure_desc procedure_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_pkey PRIMARY KEY (procedure_desc_id);


--
-- TOC entry 4785 (class 2606 OID 54930201)
-- Name: procedure_desc procedure_desc_uri_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_desc
    ADD CONSTRAINT procedure_desc_uri_key UNIQUE (uri);


--
-- TOC entry 4787 (class 2606 OID 54931101)
-- Name: procedure_phys_chem procedure_phys_chem_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_phys_chem
    ADD CONSTRAINT procedure_phys_chem_pkey PRIMARY KEY (procedure_phys_chem_id);


--
-- TOC entry 4791 (class 2606 OID 54930205)
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 4867 (class 2606 OID 54931434)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4795 (class 2606 OID 54931382)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 4861 (class 2606 OID 54931398)
-- Name: project_site project_site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT project_site_pkey PRIMARY KEY (project_id, site_id);


--
-- TOC entry 4853 (class 2606 OID 54931240)
-- Name: property_desc property_desc_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_desc
    ADD CONSTRAINT property_desc_pkey PRIMARY KEY (property_desc_id);


--
-- TOC entry 4799 (class 2606 OID 54931075)
-- Name: property_phys_chem property_phys_chem_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_phys_chem
    ADD CONSTRAINT property_phys_chem_pkey PRIMARY KEY (property_phys_chem_id);


--
-- TOC entry 4803 (class 2606 OID 54930914)
-- Name: result_desc_element result_desc_element_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_pkey PRIMARY KEY (element_id, property_desc_id);


--
-- TOC entry 4805 (class 2606 OID 54930926)
-- Name: result_desc_plot result_desc_plot_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_pkey PRIMARY KEY (plot_id, property_desc_id);


--
-- TOC entry 4807 (class 2606 OID 54930950)
-- Name: result_desc_profile result_desc_profile_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_pkey PRIMARY KEY (profile_id, property_desc_id);


--
-- TOC entry 4809 (class 2606 OID 54930938)
-- Name: result_desc_surface result_desc_surface_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT result_desc_surface_pkey PRIMARY KEY (surface_id, property_desc_id);


--
-- TOC entry 4811 (class 2606 OID 54930229)
-- Name: result_phys_chem result_numerical_specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_phys_chem
    ADD CONSTRAINT result_numerical_specimen_pkey PRIMARY KEY (result_phys_chem_id);


--
-- TOC entry 4813 (class 2606 OID 54930816)
-- Name: result_phys_chem result_phys_chem_specimen_observation_phys_chem_id_specimen_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_phys_chem
    ADD CONSTRAINT result_phys_chem_specimen_observation_phys_chem_id_specimen_key UNIQUE (observation_phys_chem_id, specimen_id);


--
-- TOC entry 4849 (class 2606 OID 54931182)
-- Name: result_spectrum result_spectrum_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT result_spectrum_pkey PRIMARY KEY (result_spectrum_id);


--
-- TOC entry 4815 (class 2606 OID 54930241)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (site_id);


--
-- TOC entry 4819 (class 2606 OID 54930245)
-- Name: specimen specimen_code_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_code_key UNIQUE (code);


--
-- TOC entry 4821 (class 2606 OID 54930247)
-- Name: specimen specimen_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_pkey PRIMARY KEY (specimen_id);


--
-- TOC entry 4823 (class 2606 OID 54930249)
-- Name: specimen_prep_process specimen_prep_process_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_definition_key UNIQUE (definition);


--
-- TOC entry 4825 (class 2606 OID 54930251)
-- Name: specimen_prep_process specimen_prep_process_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT specimen_prep_process_pkey PRIMARY KEY (specimen_prep_process_id);


--
-- TOC entry 4827 (class 2606 OID 54930253)
-- Name: specimen_storage specimen_storage_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_definition_key UNIQUE (definition);


--
-- TOC entry 4829 (class 2606 OID 54930255)
-- Name: specimen_storage specimen_storage_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT specimen_storage_pkey PRIMARY KEY (specimen_storage_id);


--
-- TOC entry 4833 (class 2606 OID 54930257)
-- Name: specimen_transport specimen_transport_definition_key; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_definition_key UNIQUE (definition);


--
-- TOC entry 4835 (class 2606 OID 54930259)
-- Name: specimen_transport specimen_transport_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT specimen_transport_pkey PRIMARY KEY (specimen_transport_id);


--
-- TOC entry 4843 (class 2606 OID 54930788)
-- Name: surface_individual surface_individual_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface_individual
    ADD CONSTRAINT surface_individual_pkey PRIMARY KEY (surface_id, individual_id);


--
-- TOC entry 4839 (class 2606 OID 54930263)
-- Name: surface surface_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface
    ADD CONSTRAINT surface_pkey PRIMARY KEY (surface_id);


--
-- TOC entry 4859 (class 2606 OID 54931375)
-- Name: translate translate_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_pkey PRIMARY KEY (table_name, column_name, language_code, string);


--
-- TOC entry 4845 (class 2606 OID 54931049)
-- Name: unit_of_measure unit_of_measure_pkey; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unit_of_measure_pkey PRIMARY KEY (unit_of_measure_id);


--
-- TOC entry 4765 (class 2606 OID 54930277)
-- Name: element unq_element_profile_order_element; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT unq_element_profile_order_element UNIQUE (profile_id, order_element);


--
-- TOC entry 4779 (class 2606 OID 54930279)
-- Name: plot unq_plot_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT unq_plot_code UNIQUE (plot_code);


--
-- TOC entry 4789 (class 2606 OID 54930285)
-- Name: procedure_phys_chem unq_procedure_phys_chem_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_phys_chem
    ADD CONSTRAINT unq_procedure_phys_chem_uri UNIQUE (uri);


--
-- TOC entry 4793 (class 2606 OID 54930287)
-- Name: profile unq_profile_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT unq_profile_code UNIQUE (profile_code);


--
-- TOC entry 4797 (class 2606 OID 54930289)
-- Name: project unq_project_name; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project
    ADD CONSTRAINT unq_project_name UNIQUE (name);


--
-- TOC entry 4801 (class 2606 OID 54930311)
-- Name: property_phys_chem unq_property_phys_chem_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.property_phys_chem
    ADD CONSTRAINT unq_property_phys_chem_uri UNIQUE (uri);


--
-- TOC entry 4817 (class 2606 OID 54930321)
-- Name: site unq_site_code; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT unq_site_code UNIQUE (site_code);


--
-- TOC entry 4831 (class 2606 OID 54930323)
-- Name: specimen_storage unq_specimen_storage_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_storage
    ADD CONSTRAINT unq_specimen_storage_label UNIQUE (label);


--
-- TOC entry 4837 (class 2606 OID 54930325)
-- Name: specimen_transport unq_specimen_transport_label; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_transport
    ADD CONSTRAINT unq_specimen_transport_label UNIQUE (label);


--
-- TOC entry 4841 (class 2606 OID 54930327)
-- Name: surface unq_surface_super; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface
    ADD CONSTRAINT unq_surface_super UNIQUE (surface_id, super_surface_id);


--
-- TOC entry 4847 (class 2606 OID 54930339)
-- Name: unit_of_measure unq_unit_of_measure_uri; Type: CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.unit_of_measure
    ADD CONSTRAINT unq_unit_of_measure_uri UNIQUE (uri);


--
-- TOC entry 4881 (class 2606 OID 54931563)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (property_id, value);


--
-- TOC entry 4869 (class 2606 OID 54931551)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 4887 (class 2606 OID 54931569)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (individual_id);


--
-- TOC entry 4879 (class 2606 OID 54931561)
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (layer_id);


--
-- TOC entry 4873 (class 2606 OID 54931557)
-- Name: mapset mapset_file_identifier_key; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_file_identifier_key UNIQUE (file_identifier);


--
-- TOC entry 4875 (class 2606 OID 54931555)
-- Name: mapset mapset_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_pkey PRIMARY KEY (mapset_id);


--
-- TOC entry 4885 (class 2606 OID 54931567)
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (organisation_id);


--
-- TOC entry 4883 (class 2606 OID 54931565)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_pkey PRIMARY KEY (country_id, project_id, organisation_id, individual_id, "position", tag, role);


--
-- TOC entry 4871 (class 2606 OID 54931553)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (country_id, project_id);


--
-- TOC entry 4877 (class 2606 OID 54931559)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 4889 (class 2606 OID 54931571)
-- Name: url url_pkey; Type: CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (mapset_id, protocol, url);


--
-- TOC entry 4850 (class 1259 OID 54931193)
-- Name: result_spectrum_specimen_id_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_specimen_id_idx ON soil_data.result_spectrum USING btree (specimen_id);


--
-- TOC entry 4851 (class 1259 OID 54931194)
-- Name: result_spectrum_spectrum_idx; Type: INDEX; Schema: soil_data; Owner: sis
--

CREATE INDEX result_spectrum_spectrum_idx ON soil_data.result_spectrum USING gin (spectrum);


--
-- TOC entry 4971 (class 2620 OID 54931196)
-- Name: result_phys_chem trg_check_result_value; Type: TRIGGER; Schema: soil_data; Owner: sis
--

CREATE TRIGGER trg_check_result_value BEFORE INSERT OR UPDATE ON soil_data.result_phys_chem FOR EACH ROW EXECUTE FUNCTION soil_data.check_result_value();


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 4971
-- Name: TRIGGER trg_check_result_value ON result_phys_chem; Type: COMMENT; Schema: soil_data; Owner: sis
--

COMMENT ON TRIGGER trg_check_result_value ON soil_data.result_phys_chem IS 'Verifies if the value assigned to the result is valid. See the function core.ceck_result_value function for implementation.';


--
-- TOC entry 4972 (class 2620 OID 54931632)
-- Name: property class; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER class AFTER UPDATE OF property_type, num_intervals, start_color, end_color, min, max ON spatial_metadata.property FOR EACH ROW EXECUTE FUNCTION spatial_metadata.class();


--
-- TOC entry 4973 (class 2620 OID 54931634)
-- Name: layer map_layer; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER map_layer AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum ON spatial_metadata.layer FOR EACH ROW EXECUTE FUNCTION spatial_metadata.map();


--
-- TOC entry 4974 (class 2620 OID 54931633)
-- Name: class sld; Type: TRIGGER; Schema: spatial_metadata; Owner: sis
--

CREATE TRIGGER sld AFTER INSERT OR UPDATE ON spatial_metadata.class FOR EACH STATEMENT EXECUTE FUNCTION spatial_metadata.sld();


--
-- TOC entry 4963 (class 2606 OID 54931700)
-- Name: layer layer_individual_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_individual_project_id_fkey FOREIGN KEY (individual_id, project_id) REFERENCES api.user_layer(individual_id, project_id) ON UPDATE CASCADE;


--
-- TOC entry 4964 (class 2606 OID 54931695)
-- Name: layer layer_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.layer
    ADD CONSTRAINT layer_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id);


--
-- TOC entry 4967 (class 2606 OID 54931747)
-- Name: uploaded_dataset_column uploaded_dataset_column_procedure_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_procedure_phys_chem_id_fkey FOREIGN KEY (procedure_phys_chem_id) REFERENCES soil_data.procedure_phys_chem(procedure_phys_chem_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4968 (class 2606 OID 54931742)
-- Name: uploaded_dataset_column uploaded_dataset_column_property_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_property_phys_chem_id_fkey FOREIGN KEY (property_phys_chem_id) REFERENCES soil_data.property_phys_chem(property_phys_chem_id) ON UPDATE CASCADE;


--
-- TOC entry 4969 (class 2606 OID 54931737)
-- Name: uploaded_dataset_column uploaded_dataset_column_table_name_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_table_name_fkey FOREIGN KEY (table_name) REFERENCES api.uploaded_dataset(table_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4970 (class 2606 OID 54931752)
-- Name: uploaded_dataset_column uploaded_dataset_column_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset_column
    ADD CONSTRAINT uploaded_dataset_column_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4965 (class 2606 OID 54931723)
-- Name: uploaded_dataset uploaded_dataset_individual_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES api."user"(individual_id) ON UPDATE CASCADE;


--
-- TOC entry 4966 (class 2606 OID 54931718)
-- Name: uploaded_dataset uploaded_dataset_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.uploaded_dataset
    ADD CONSTRAINT uploaded_dataset_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 4959 (class 2606 OID 54931655)
-- Name: user user_individual_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE;


--
-- TOC entry 4961 (class 2606 OID 54931676)
-- Name: user_layer user_layer_individual_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.user_layer
    ADD CONSTRAINT user_layer_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES api."user"(individual_id) ON UPDATE CASCADE;


--
-- TOC entry 4962 (class 2606 OID 54931681)
-- Name: user_layer user_layer_project_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api.user_layer
    ADD CONSTRAINT user_layer_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE;


--
-- TOC entry 4960 (class 2606 OID 54931650)
-- Name: user user_organisation_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: sis
--

ALTER TABLE ONLY api."user"
    ADD CONSTRAINT user_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE;


--
-- TOC entry 4922 (class 2606 OID 54930364)
-- Name: result_desc_element fk_element; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT fk_element FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id);


--
-- TOC entry 4918 (class 2606 OID 54930414)
-- Name: plot_individual fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot_individual
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 4920 (class 2606 OID 54930419)
-- Name: profile fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 4924 (class 2606 OID 54930424)
-- Name: result_desc_plot fk_plot; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT fk_plot FOREIGN KEY (plot_id) REFERENCES soil_data.plot(plot_id);


--
-- TOC entry 4904 (class 2606 OID 54930464)
-- Name: element fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.element
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 4926 (class 2606 OID 54930469)
-- Name: result_desc_profile fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 4932 (class 2606 OID 54930474)
-- Name: site fk_profile; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.site
    ADD CONSTRAINT fk_profile FOREIGN KEY (typical_profile) REFERENCES soil_data.profile(profile_id);


--
-- TOC entry 4942 (class 2606 OID 54931399)
-- Name: project_site fk_project; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id);


--
-- TOC entry 4937 (class 2606 OID 54930534)
-- Name: surface fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 4917 (class 2606 OID 54930539)
-- Name: plot fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.plot
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 4943 (class 2606 OID 54931404)
-- Name: project_site fk_site; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.project_site
    ADD CONSTRAINT fk_site FOREIGN KEY (site_id) REFERENCES soil_data.site(site_id);


--
-- TOC entry 4930 (class 2606 OID 54930554)
-- Name: result_phys_chem fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_phys_chem
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 4940 (class 2606 OID 54931183)
-- Name: result_spectrum fk_specimen; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_spectrum
    ADD CONSTRAINT fk_specimen FOREIGN KEY (specimen_id) REFERENCES soil_data.specimen(specimen_id);


--
-- TOC entry 4933 (class 2606 OID 54930559)
-- Name: specimen fk_specimen_prep_process; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT fk_specimen_prep_process FOREIGN KEY (specimen_prep_process_id) REFERENCES soil_data.specimen_prep_process(specimen_prep_process_id);


--
-- TOC entry 4935 (class 2606 OID 54930564)
-- Name: specimen_prep_process fk_specimen_storage; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_storage FOREIGN KEY (specimen_storage_id) REFERENCES soil_data.specimen_storage(specimen_storage_id);


--
-- TOC entry 4936 (class 2606 OID 54930569)
-- Name: specimen_prep_process fk_specimen_transport; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen_prep_process
    ADD CONSTRAINT fk_specimen_transport FOREIGN KEY (specimen_transport_id) REFERENCES soil_data.specimen_transport(specimen_transport_id);


--
-- TOC entry 4921 (class 2606 OID 54930574)
-- Name: profile fk_surface; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.profile
    ADD CONSTRAINT fk_surface FOREIGN KEY (surface_id) REFERENCES soil_data.surface(surface_id);


--
-- TOC entry 4928 (class 2606 OID 54930579)
-- Name: result_desc_surface fk_surface; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT fk_surface FOREIGN KEY (surface_id) REFERENCES soil_data.surface(surface_id);


--
-- TOC entry 4939 (class 2606 OID 54930584)
-- Name: surface_individual fk_surface; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface_individual
    ADD CONSTRAINT fk_surface FOREIGN KEY (surface_id) REFERENCES soil_data.surface(surface_id);


--
-- TOC entry 4938 (class 2606 OID 54930589)
-- Name: surface fk_surface; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.surface
    ADD CONSTRAINT fk_surface FOREIGN KEY (super_surface_id) REFERENCES soil_data.surface(surface_id);


--
-- TOC entry 4905 (class 2606 OID 54931349)
-- Name: observation_desc_element observation_desc_element_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4906 (class 2606 OID 54931033)
-- Name: observation_desc_element observation_desc_element_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4907 (class 2606 OID 54931344)
-- Name: observation_desc_element observation_desc_element_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_element
    ADD CONSTRAINT observation_desc_element_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4908 (class 2606 OID 54931329)
-- Name: observation_desc_plot observation_desc_plot_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4909 (class 2606 OID 54931038)
-- Name: observation_desc_plot observation_desc_plot_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4910 (class 2606 OID 54931324)
-- Name: observation_desc_plot observation_desc_plot_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_plot
    ADD CONSTRAINT observation_desc_plot_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4911 (class 2606 OID 54931339)
-- Name: observation_desc_profile observation_desc_profile_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_category_desc_id_fkey FOREIGN KEY (category_desc_id) REFERENCES soil_data.category_desc(category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4912 (class 2606 OID 54931043)
-- Name: observation_desc_profile observation_desc_profile_procedure_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_procedure_desc_id_fkey FOREIGN KEY (procedure_desc_id) REFERENCES soil_data.procedure_desc(procedure_desc_id) ON UPDATE CASCADE;


--
-- TOC entry 4913 (class 2606 OID 54931334)
-- Name: observation_desc_profile observation_desc_profile_property_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_desc_profile
    ADD CONSTRAINT observation_desc_profile_property_desc_id_fkey FOREIGN KEY (property_desc_id) REFERENCES soil_data.property_desc(property_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4914 (class 2606 OID 54931135)
-- Name: observation_phys_chem observation_phys_chem_procedure_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_phys_chem
    ADD CONSTRAINT observation_phys_chem_procedure_phys_chem_id_fkey FOREIGN KEY (procedure_phys_chem_id) REFERENCES soil_data.procedure_phys_chem(procedure_phys_chem_id) ON UPDATE CASCADE;


--
-- TOC entry 4915 (class 2606 OID 54931095)
-- Name: observation_phys_chem observation_phys_chem_property_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_phys_chem
    ADD CONSTRAINT observation_phys_chem_property_phys_chem_id_fkey FOREIGN KEY (property_phys_chem_id) REFERENCES soil_data.property_phys_chem(property_phys_chem_id) ON UPDATE CASCADE;


--
-- TOC entry 4916 (class 2606 OID 54931069)
-- Name: observation_phys_chem observation_phys_chem_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.observation_phys_chem
    ADD CONSTRAINT observation_phys_chem_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4919 (class 2606 OID 54931120)
-- Name: procedure_phys_chem procedure_phys_chem_broader_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.procedure_phys_chem
    ADD CONSTRAINT procedure_phys_chem_broader_id_fkey FOREIGN KEY (broader_id) REFERENCES soil_data.procedure_phys_chem(procedure_phys_chem_id) ON UPDATE CASCADE;


--
-- TOC entry 4944 (class 2606 OID 54931435)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (project_id) REFERENCES soil_data.project(project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4945 (class 2606 OID 54931440)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES soil_data.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 54931445)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES soil_data.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4923 (class 2606 OID 54931319)
-- Name: result_desc_element result_desc_element_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_element
    ADD CONSTRAINT result_desc_element_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_element(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4925 (class 2606 OID 54931304)
-- Name: result_desc_plot result_desc_plot_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_plot
    ADD CONSTRAINT result_desc_plot_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_plot(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4927 (class 2606 OID 54931314)
-- Name: result_desc_profile result_desc_profile_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_profile
    ADD CONSTRAINT result_desc_profile_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_profile(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4929 (class 2606 OID 54931309)
-- Name: result_desc_surface result_desc_surface_property_desc_id_category_desc_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_desc_surface
    ADD CONSTRAINT result_desc_surface_property_desc_id_category_desc_id_fkey FOREIGN KEY (property_desc_id, category_desc_id) REFERENCES soil_data.observation_desc_plot(property_desc_id, category_desc_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4931 (class 2606 OID 54930817)
-- Name: result_phys_chem result_phys_chem_specimen_observation_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.result_phys_chem
    ADD CONSTRAINT result_phys_chem_specimen_observation_phys_chem_id_fkey FOREIGN KEY (observation_phys_chem_id) REFERENCES soil_data.observation_phys_chem(observation_phys_chem_id);


--
-- TOC entry 4934 (class 2606 OID 54931140)
-- Name: specimen specimen_element_id_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.specimen
    ADD CONSTRAINT specimen_element_id_fkey FOREIGN KEY (element_id) REFERENCES soil_data.element(element_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4941 (class 2606 OID 54931376)
-- Name: translate translate_language_code_fkey; Type: FK CONSTRAINT; Schema: soil_data; Owner: sis
--

ALTER TABLE ONLY soil_data.translate
    ADD CONSTRAINT translate_language_code_fkey FOREIGN KEY (language_code) REFERENCES soil_data.languages(language_code);


--
-- TOC entry 4954 (class 2606 OID 54931592)
-- Name: class class_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.class
    ADD CONSTRAINT class_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4953 (class 2606 OID 54931597)
-- Name: layer layer_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.layer
    ADD CONSTRAINT layer_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4948 (class 2606 OID 54931602)
-- Name: mapset mapset_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4949 (class 2606 OID 54931607)
-- Name: mapset mapset_property_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_property_id_fkey FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE;


--
-- TOC entry 4950 (class 2606 OID 54931612)
-- Name: mapset mapset_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.mapset
    ADD CONSTRAINT mapset_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4955 (class 2606 OID 54931572)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_country_id_project_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_country_id_project_id_fkey FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4956 (class 2606 OID 54931582)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_individual_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4957 (class 2606 OID 54931577)
-- Name: proj_x_org_x_ind proj_x_org_x_ind_organisation_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.proj_x_org_x_ind
    ADD CONSTRAINT proj_x_org_x_ind_organisation_id_fkey FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4947 (class 2606 OID 54931617)
-- Name: project project_country_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.project
    ADD CONSTRAINT project_country_id_fkey FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE;


--
-- TOC entry 4951 (class 2606 OID 54931622)
-- Name: property property_property_phys_chem_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_property_phys_chem_id_fkey FOREIGN KEY (property_phys_chem_id) REFERENCES soil_data.property_phys_chem(property_phys_chem_id) ON UPDATE CASCADE;


--
-- TOC entry 4952 (class 2606 OID 54931627)
-- Name: property property_unit_of_measure_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.property
    ADD CONSTRAINT property_unit_of_measure_id_fkey FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE;


--
-- TOC entry 4958 (class 2606 OID 54931587)
-- Name: url url_mapset_id_fkey; Type: FK CONSTRAINT; Schema: spatial_metadata; Owner: sis
--

ALTER TABLE ONLY spatial_metadata.url
    ADD CONSTRAINT url_mapset_id_fkey FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA kobo; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA kobo TO sis_r;
GRANT ALL ON SCHEMA kobo TO kobo;


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sis
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA soil_data; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA soil_data TO sis_r;


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA spatial_metadata; Type: ACL; Schema: -; Owner: sis
--

GRANT USAGE ON SCHEMA spatial_metadata TO sis_r;


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 1604
-- Name: FUNCTION check_result_value(); Type: ACL; Schema: soil_data; Owner: sis
--

GRANT ALL ON FUNCTION soil_data.check_result_value() TO sis_r;


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 1605
-- Name: FUNCTION class(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.class() TO sis_r;


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 1606
-- Name: FUNCTION map(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.map() TO sis_r;


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 1607
-- Name: FUNCTION sld(); Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT ALL ON FUNCTION spatial_metadata.sld() TO sis_r;


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE layer; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.layer TO sis_r;


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE setting; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.setting TO sis_r;


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE uploaded_dataset; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset TO sis_r;


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE uploaded_dataset_column; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.uploaded_dataset_column TO sis_r;


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE "user"; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api."user" TO sis_r;


--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE user_layer; Type: ACL; Schema: api; Owner: sis
--

GRANT SELECT ON TABLE api.user_layer TO sis_r;


--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE category_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.category_desc TO sis_r;


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.element TO sis_r;


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE element_element_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.element_element_id_seq TO sis_r;


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.individual TO sis_r;


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE languages; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.languages TO sis_r;


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_element TO sis_r;


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE observation_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_plot TO sis_r;


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE observation_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_desc_profile TO sis_r;


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE observation_phys_chem; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.observation_phys_chem TO sis_r;


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 260
-- Name: SEQUENCE observation_phys_chem_element_observation_phys_chem_element_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.observation_phys_chem_element_observation_phys_chem_element_seq TO sis_r;


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE organisation; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.organisation TO sis_r;


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot TO sis_r;


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE plot_individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.plot_individual TO sis_r;


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 234
-- Name: SEQUENCE plot_plot_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.plot_plot_id_seq TO sis_r;


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE procedure_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_desc TO sis_r;


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE procedure_phys_chem; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.procedure_phys_chem TO sis_r;


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profile TO sis_r;


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 238
-- Name: SEQUENCE profile_profile_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.profile_profile_id_seq TO sis_r;


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE project; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project TO sis_r;


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE project_site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.project_site TO sis_r;


--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE result_phys_chem; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_phys_chem TO sis_r;


--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE site; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.site TO sis_r;


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE specimen; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen TO sis_r;


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE profiles; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.profiles TO sis_r;


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE property_desc; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_desc TO sis_r;


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE property_phys_chem; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.property_phys_chem TO sis_r;


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE result_desc_element; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_element TO sis_r;


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE result_desc_plot; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_plot TO sis_r;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE result_desc_profile; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_profile TO sis_r;


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE result_desc_surface; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_desc_surface TO sis_r;


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 261
-- Name: SEQUENCE result_phys_chem_specimen_result_phys_chem_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_phys_chem_specimen_result_phys_chem_specimen_id_seq TO sis_r;


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE result_spectrum; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.result_spectrum TO sis_r;


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 262
-- Name: SEQUENCE result_spectrum_result_spectrum_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.result_spectrum_result_spectrum_id_seq TO sis_r;


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 247
-- Name: SEQUENCE site_site_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.site_site_id_seq TO sis_r;


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE specimen_prep_process; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_prep_process TO sis_r;


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 250
-- Name: SEQUENCE specimen_prep_process_specimen_prep_process_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_prep_process_specimen_prep_process_id_seq TO sis_r;


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 251
-- Name: SEQUENCE specimen_specimen_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_specimen_id_seq TO sis_r;


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE specimen_storage; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_storage TO sis_r;


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 253
-- Name: SEQUENCE specimen_storage_specimen_storage_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_storage_specimen_storage_id_seq TO sis_r;


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE specimen_transport; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.specimen_transport TO sis_r;


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE specimen_transport_specimen_transport_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.specimen_transport_specimen_transport_id_seq TO sis_r;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE surface; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.surface TO sis_r;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE surface_individual; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.surface_individual TO sis_r;


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 258
-- Name: SEQUENCE surface_surface_id_seq; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON SEQUENCE soil_data.surface_surface_id_seq TO sis_r;


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE translate; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.translate TO sis_r;


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE unit_of_measure; Type: ACL; Schema: soil_data; Owner: sis
--

GRANT SELECT ON TABLE soil_data.unit_of_measure TO sis_r;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE class; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE country; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE individual; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE layer; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE mapset; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE organisation; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE proj_x_org_x_ind; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE project; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE property; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE url; Type: ACL; Schema: spatial_metadata; Owner: sis
--

GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--
-- TOC entry 3498 (class 826 OID 54931636)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: api; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA api GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3497 (class 826 OID 54931171)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data GRANT SELECT ON TABLES TO sis_r;


--
-- TOC entry 3499 (class 826 OID 54931638)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: soil_data_upload; Owner: sis
--

ALTER DEFAULT PRIVILEGES FOR ROLE sis IN SCHEMA soil_data_upload GRANT SELECT ON TABLES TO sis_r;


-- Completed on 2025-08-22 17:28:38 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict 0lB8PtiLtajfVtCnUYFuqXQ9ss9cX58JojPYYVXx95KsgwdSoFvVJg55ctzeaa7

