-- OBJECT: core.plot_individual, project_related, result_desc_element, result_desc_plot, result_desc_profile, result_desc_specimen, result_desc_surface, surface_individual)
-- ISSUE: use PRIMARY KEY instead of UNIQUE

ALTER TABLE IF EXISTS core.result_desc_specimen DROP CONSTRAINT IF EXISTS result_desc_specimen_property_desc_specimen_id_thesaurus_des_fk;
ALTER TABLE IF EXISTS core.observation_desc_specimen DROP CONSTRAINT IF EXISTS observation_desc_specimen_property_desc_specimen_id_thesaur_key;
ALTER TABLE IF EXISTS core.observation_desc_specimen ADD PRIMARY KEY (property_desc_specimen_id, thesaurus_desc_specimen_id);
ALTER TABLE IF EXISTS core.result_desc_specimen ADD FOREIGN KEY (property_desc_specimen_id, thesaurus_desc_specimen_id)
    REFERENCES core.observation_desc_specimen (property_desc_specimen_id, thesaurus_desc_specimen_id);

ALTER TABLE IF EXISTS core.plot_individual DROP CONSTRAINT IF EXISTS plot_individual_plot_id_individual_id_key;
ALTER TABLE IF EXISTS core.plot_individual ADD PRIMARY KEY (plot_id, individual_id);

ALTER TABLE IF EXISTS core.project_related DROP CONSTRAINT IF EXISTS project_related_project_source_id_project_target_id_key;
ALTER TABLE IF EXISTS core.project_related ADD PRIMARY KEY (project_source_id, project_target_id);

ALTER TABLE IF EXISTS core.result_desc_element DROP CONSTRAINT IF EXISTS unq_result_desc_element;
ALTER TABLE IF EXISTS core.result_desc_element ADD PRIMARY KEY (element_id, property_desc_element_id);

ALTER TABLE IF EXISTS core.result_desc_plot DROP CONSTRAINT IF EXISTS unq_result_desc_plot;
ALTER TABLE IF EXISTS core.result_desc_plot ADD PRIMARY KEY (plot_id, property_desc_plot_id);

ALTER TABLE IF EXISTS core.result_desc_profile DROP CONSTRAINT IF EXISTS unq_result_desc_profile;
ALTER TABLE IF EXISTS core.result_desc_profile ADD PRIMARY KEY (profile_id, property_desc_profile_id);

ALTER TABLE IF EXISTS core.result_desc_specimen DROP CONSTRAINT IF EXISTS result_desc_specimen_specimen_id_property_desc_specimen_id_key;
ALTER TABLE IF EXISTS core.result_desc_specimen ADD PRIMARY KEY (specimen_id, property_desc_specimen_id);

ALTER TABLE IF EXISTS core.result_desc_surface DROP CONSTRAINT IF EXISTS unq_result_desc_surface;
ALTER TABLE IF EXISTS core.result_desc_surface ADD PRIMARY KEY (surface_id, property_desc_surface_id);

ALTER TABLE IF EXISTS core.surface_individual DROP CONSTRAINT IF EXISTS surface_individual_surface_id_individual_id_key;
ALTER TABLE IF EXISTS core.surface_individual ADD PRIMARY KEY (surface_id, individual_id);
