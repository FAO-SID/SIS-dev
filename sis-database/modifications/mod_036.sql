-- OBJECT: many
-- ISSUE: add missing comments to SIS database objects


-- soil_data.category_desc
COMMENT ON TABLE soil_data.category_desc IS 'Controlled vocabulary categories for descriptive properties. Contains thesaurus entries from GloSIS or other vocabularies.';
COMMENT ON COLUMN soil_data.category_desc.category_desc_id IS 'Primary key identifier for the category';
COMMENT ON COLUMN soil_data.category_desc.uri IS 'URI to the corresponding entry in a controlled vocabulary (e.g., GloSIS thesaurus)';

-- soil_data.individual
COMMENT ON TABLE soil_data.individual IS 'Individuals associated with soil data collection, analysis, or project management';
COMMENT ON COLUMN soil_data.individual.individual_id IS 'Unique identifier for the individual (typically name)';
COMMENT ON COLUMN soil_data.individual.email IS 'Email address of the individual';

-- soil_data.languages
COMMENT ON TABLE soil_data.languages IS 'Reference table of supported languages for translations';
COMMENT ON COLUMN soil_data.languages.language_code IS 'ISO 639-1 two-letter language code';
COMMENT ON COLUMN soil_data.languages.language_name IS 'Full name of the language in English';

-- soil_data.organisation
COMMENT ON TABLE soil_data.organisation IS 'Organizations involved in soil data projects and surveys';
COMMENT ON COLUMN soil_data.organisation.organisation_id IS 'Unique identifier for the organization (typically name)';
COMMENT ON COLUMN soil_data.organisation.url IS 'Website URL of the organization';
COMMENT ON COLUMN soil_data.organisation.email IS 'Contact email for the organization';
COMMENT ON COLUMN soil_data.organisation.country IS 'Country where the organization is located';
COMMENT ON COLUMN soil_data.organisation.city IS 'City where the organization is located';
COMMENT ON COLUMN soil_data.organisation.postal_code IS 'Postal code of the organization address';
COMMENT ON COLUMN soil_data.organisation.delivery_point IS 'Street address of the organization';
COMMENT ON COLUMN soil_data.organisation.phone IS 'Phone number of the organization';
COMMENT ON COLUMN soil_data.organisation.facsimile IS 'Fax number of the organization';

-- soil_data.proj_x_org_x_ind
COMMENT ON TABLE soil_data.proj_x_org_x_ind IS 'Junction table linking projects, organizations, and individuals with their roles';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind.project_id IS 'Reference to the project';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind.organisation_id IS 'Reference to the organization';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind.individual_id IS 'Reference to the individual';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind."position" IS 'Position or job title of the individual within the organization';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind.tag IS 'Contact type: contact or pointOfContact';
COMMENT ON COLUMN soil_data.proj_x_org_x_ind.role IS 'ISO 19115 CI_RoleCode: author, custodian, distributor, etc.';

-- soil_data.project_site
COMMENT ON TABLE soil_data.project_site IS 'Junction table linking projects to sites (many-to-many relationship)';
COMMENT ON COLUMN soil_data.project_site.project_id IS 'Reference to the project';
COMMENT ON COLUMN soil_data.project_site.site_id IS 'Reference to the site';

-- soil_data.procedure_spectral
COMMENT ON TABLE soil_data.procedure_spectral IS 'Metadata key-value pairs describing spectral measurement procedures';
COMMENT ON COLUMN soil_data.procedure_spectral.spectral_data_id IS 'Reference to the spectral data record';
COMMENT ON COLUMN soil_data.procedure_spectral.key IS 'Metadata key (e.g., instrument, wavelength_range, resolution)';
COMMENT ON COLUMN soil_data.procedure_spectral.value IS 'Metadata value';

-- soil_data.result_spectral
COMMENT ON TABLE soil_data.result_spectral IS 'Individual spectral measurement values at specific wavelengths';
COMMENT ON COLUMN soil_data.result_spectral.result_spectral_id IS 'Synthetic primary key';
COMMENT ON COLUMN soil_data.result_spectral.observation_num_id IS 'Optional reference to a numerical observation for derived properties';
COMMENT ON COLUMN soil_data.result_spectral.spectral_data_id IS 'Reference to the spectral data record';
COMMENT ON COLUMN soil_data.result_spectral.value IS 'Spectral measurement value (reflectance, absorbance, etc.)';

-- soil_data.result_spectrum
COMMENT ON TABLE soil_data.result_spectrum IS 'Complete spectral signatures stored as JSON for soil specimens';
COMMENT ON COLUMN soil_data.result_spectrum.result_spectrum_id IS 'Synthetic primary key';
COMMENT ON COLUMN soil_data.result_spectrum.specimen_id IS 'Reference to the specimen';
COMMENT ON COLUMN soil_data.result_spectrum.individual_id IS 'Individual who performed the spectral measurement';
COMMENT ON COLUMN soil_data.result_spectrum.spectrum IS 'JSON object containing the full spectral data (wavelengths and values)';

-- soil_data.spectral_data
COMMENT ON TABLE soil_data.spectral_data IS 'Spectral data records linked to specimens, containing full spectra as JSON';
COMMENT ON COLUMN soil_data.spectral_data.spectral_data_id IS 'Synthetic primary key';
COMMENT ON COLUMN soil_data.spectral_data.specimen_id IS 'Reference to the specimen';
COMMENT ON COLUMN soil_data.spectral_data.spectrum IS 'JSON object containing spectral measurement data';

-- soil_data.translate
COMMENT ON TABLE soil_data.translate IS 'Multilingual translations for database content';
COMMENT ON COLUMN soil_data.translate.table_name IS 'Name of the source table containing the translatable content';
COMMENT ON COLUMN soil_data.translate.column_name IS 'Name of the column containing the translatable content';
COMMENT ON COLUMN soil_data.translate.language_code IS 'Target language code (ISO 639-1)';
COMMENT ON COLUMN soil_data.translate.string IS 'Original string to be translated';
COMMENT ON COLUMN soil_data.translate.translation IS 'Translated string in the target language';

-- soil_data.property_desc
COMMENT ON TABLE soil_data.property_desc IS 'Descriptive soil properties used for categorical observations';
COMMENT ON COLUMN soil_data.property_desc.property_desc_id IS 'Primary key identifier for the property';
COMMENT ON COLUMN soil_data.property_desc.property_pretty_name IS 'Human-readable display name for the property';
COMMENT ON COLUMN soil_data.property_desc.uri IS 'URI to the corresponding code in a controlled vocabulary';

-- soil_data.observation_desc_element.category_order
COMMENT ON COLUMN soil_data.observation_desc_element.category_order IS 'Display order of categories for this property';

-- soil_data.observation_desc_plot.category_order
COMMENT ON COLUMN soil_data.observation_desc_plot.category_order IS 'Display order of categories for this property';

-- soil_data.observation_desc_profile.category_order
COMMENT ON COLUMN soil_data.observation_desc_profile.category_order IS 'Display order of categories for this property';

-- soil_data.profile columns without comments
COMMENT ON COLUMN soil_data.profile.altitude IS 'Altitude/elevation of the profile location in meters above sea level';
COMMENT ON COLUMN soil_data.profile.time_stamp IS 'Date when the profile was described or sampled';
COMMENT ON COLUMN soil_data.profile.positional_accuracy IS 'Positional accuracy of the coordinates in meters';
COMMENT ON COLUMN soil_data.profile.geom IS 'Point geometry representing the profile location (EPSG:4326)';
COMMENT ON COLUMN soil_data.profile.type IS 'Type of profile: TrialPit or Borehole';

-- soil_data.procedure_num columns without comments
COMMENT ON COLUMN soil_data.procedure_num.definition IS 'Text definition of the procedure';
COMMENT ON COLUMN soil_data.procedure_num.reference IS 'Reference citation for the procedure';
COMMENT ON COLUMN soil_data.procedure_num.citation IS 'Full bibliographic citation for the procedure';

-- INDEXES soil_data.result_spectrum_specimen_id_idx
COMMENT ON INDEX soil_data.result_spectrum_specimen_id_idx IS 'Index on specimen_id for efficient lookup of spectral data by specimen';

