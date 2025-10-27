-- OBJECT: schemas
-- ISSUE: rename schemas

ALTER SCHEMA core RENAME TO soil_data;
ALTER SCHEMA metadata RENAME TO soil_metadata;


DROP TRIGGER IF EXISTS trg_check_result_value ON soil_data.result_phys_chem;
DROP FUNCTION IF EXISTS soil_data.check_result_value();

CREATE OR REPLACE FUNCTION soil_data.check_result_value()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
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
$BODY$;

ALTER FUNCTION soil_data.check_result_value() OWNER TO sis;
GRANT EXECUTE ON FUNCTION soil_data.check_result_value() TO sis;
GRANT EXECUTE ON FUNCTION soil_data.check_result_value() TO sis_r;
COMMENT ON FUNCTION soil_data.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';

CREATE OR REPLACE TRIGGER trg_check_result_value
    BEFORE INSERT OR UPDATE 
    ON soil_data.result_phys_chem
    FOR EACH ROW
    EXECUTE FUNCTION soil_data.check_result_value();
