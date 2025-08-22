-- OBJECT: core.specimen
-- ISSUE: ADD the same depth CONSTRAINT as in core.element and split two checks in one


ALTER TABLE IF EXISTS core.specimen ADD CHECK (lower_depth > upper_depth);
ALTER TABLE IF EXISTS core.specimen ADD CHECK (upper_depth >= 0);
ALTER TABLE IF EXISTS core.specimen ADD CHECK (upper_depth <= 1000);

ALTER TABLE IF EXISTS core.element DROP CONSTRAINT element_check;
ALTER TABLE IF EXISTS core.element DROP CONSTRAINT element_upper_depth_check;

ALTER TABLE IF EXISTS core.element ADD CHECK (lower_depth > upper_depth);
ALTER TABLE IF EXISTS core.element ADD CHECK (upper_depth >= 0);
ALTER TABLE IF EXISTS core.element ADD CHECK (upper_depth <= 1000);
