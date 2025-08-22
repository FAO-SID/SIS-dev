-- OBJECT: core.observation_desc_surface, observation_desc_plot
-- ISSUE: redundancy between these two tables and the other two dependents property and thesaurus


INSERT INTO core.property_desc_plot (property_desc_plot_id, "label", uri)
SELECT property_desc_surface_id, "label", uri
FROM core.property_desc_surface
WHERE "label" NOT IN (SELECT "label" FROM core.property_desc_plot);

INSERT INTO core.thesaurus_desc_plot (thesaurus_desc_plot_id, "label", uri)
SELECT thesaurus_desc_surface_id + 389, "label", uri
FROM core.thesaurus_desc_surface
WHERE thesaurus_desc_surface_id < 77;

INSERT INTO core.observation_desc_plot (property_desc_plot_id, thesaurus_desc_plot_id, procedure_desc_id)
SELECT property_desc_surface_id, thesaurus_desc_surface_id + 389, procedure_desc_id
FROM core.observation_desc_surface
WHERE thesaurus_desc_surface_id < 77;

ALTER TABLE IF EXISTS core.result_desc_surface DROP CONSTRAINT result_desc_surface_property_desc_surface_id_thesaurus_des_fkey;
ALTER TABLE IF EXISTS core.result_desc_surface RENAME COLUMN property_desc_surface_id TO property_desc_plot_id;
ALTER TABLE IF EXISTS core.result_desc_surface RENAME COLUMN thesaurus_desc_surface_id TO thesaurus_desc_plot_id;
ALTER TABLE IF EXISTS core.result_desc_surface ADD FOREIGN KEY (property_desc_plot_id,thesaurus_desc_plot_id) REFERENCES core.observation_desc_plot(property_desc_plot_id,thesaurus_desc_plot_id);

DROP TABLE IF EXISTS core.observation_desc_surface;
DROP TABLE IF EXISTS core.property_desc_surface;
DROP TABLE IF EXISTS core.thesaurus_desc_surface;
