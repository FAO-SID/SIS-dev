-- OBJECT: specimen
-- ISSUE: Remove depths


ALTER TABLE core.specimen DROP COLUMN upper_depth;
ALTER TABLE core.specimen DROP COLUMN lower_depth;
