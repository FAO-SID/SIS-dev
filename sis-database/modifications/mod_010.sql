-- OBJECT: core.element
-- ISSUE: CHECK CONSTRAINT 'type' column instead of a new data type


ALTER TABLE IF EXISTS core.element ALTER COLUMN "type" TYPE text;
DROP TYPE IF EXISTS core.element_type;
ALTER TABLE IF EXISTS core.element ADD CHECK (type IN ('Horizon','Layer'));
