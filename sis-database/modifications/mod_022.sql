-- OBJECT: triggers
-- ISSUE: relation "core.observation_numerical_specimen" does not exist


DROP TRIGGER IF EXISTS trg_check_result_value_specimen ON core.result_phys_chem;
DROP FUNCTION IF EXISTS core.check_result_value();
DROP FUNCTION IF EXISTS core.check_result_value_specimen();

CREATE OR REPLACE FUNCTION core.check_result_value()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
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
$BODY$;
ALTER FUNCTION core.check_result_value() OWNER TO sis;
COMMENT ON FUNCTION core.check_result_value() IS 'Checks if the value assigned to a result record is within the numerical bounds declared in the related observations (fields value_min and value_max).';

CREATE TRIGGER trg_check_result_value
    BEFORE INSERT OR UPDATE 
    ON core.result_phys_chem
    FOR EACH ROW
    EXECUTE FUNCTION core.check_result_value();
COMMENT ON TRIGGER trg_check_result_value ON core.result_phys_chem IS 'Verifies if the value assigned to the result is valid. See the function core.ceck_result_value function for implementation.';
