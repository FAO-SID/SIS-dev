-- OBJECT: metadata.organisation
-- ISSUE: self reference, TABLE metadata.organisation has CONSTRAINT fk_parent FOREIGN KEY (organisation_id) REFERENCES metadata.organisation(organisation_id) <<-- self reference


ALTER TABLE IF EXISTS metadata.organisation DROP CONSTRAINT fk_parent;
ALTER TABLE IF EXISTS metadata.organisation ADD FOREIGN KEY (parent_id) REFERENCES metadata.organisation(organisation_id);
