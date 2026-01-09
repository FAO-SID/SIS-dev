-- OBJECT: soil_data.surface
-- ISSUE: drop table surface

ALTER TABLE IF EXISTS soil_data.site RENAME COLUMN extent TO geom;
ALTER TABLE IF EXISTS soil_data.site DROP COLUMN typical_profile;
ALTER TABLE IF EXISTS soil_data.site DROP COLUMN position;

ALTER TABLE IF EXISTS soil_data.plot DROP COLUMN altitude;
ALTER TABLE IF EXISTS soil_data.plot DROP COLUMN time_stamp;
ALTER TABLE IF EXISTS soil_data.plot DROP COLUMN positional_accuracy;
ALTER TABLE IF EXISTS soil_data.plot DROP COLUMN type;
ALTER TABLE IF EXISTS soil_data.plot RENAME COLUMN position TO geom;
ALTER TABLE IF EXISTS soil_data.plot ALTER COLUMN geom TYPE geometry(Polygon,4326);

ALTER TABLE IF EXISTS soil_data.profile DROP COLUMN surface_id;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN altitude smallint;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN time_stamp date;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN positional_accuracy smallint;
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN geom geometry(Point,4326);
ALTER TABLE IF EXISTS soil_data.profile ADD COLUMN type text;
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_altitude_check CHECK (altitude::numeric > '-100'::integer::numeric);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_altitude_check1 CHECK (altitude::numeric < 8000::numeric);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_time_stamp_check CHECK (time_stamp > '1900-01-01'::date);
ALTER TABLE IF EXISTS soil_data.profile ADD CONSTRAINT profile_type_check CHECK (type = ANY (ARRAY['TrialPit'::text, 'Borehole'::text]));

DROP TABLE IF EXISTS soil_data.result_desc_surface;
DROP TABLE IF EXISTS soil_data.surface_individual;
DROP TABLE IF EXISTS soil_data.plot_individual;
DROP TABLE IF EXISTS soil_data.surface;
