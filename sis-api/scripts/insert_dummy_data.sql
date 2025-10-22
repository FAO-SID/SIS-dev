-- OBJECT: core.insert_dummy_data()
-- ISSUE: add dummy data to he database


-- PL/pgSQL function that inserts dummy data.
-- Key features:

-- Single project and site named "dummy data"
-- x plots (parameter p_num_plots, default 100) with unique codes (PLOT_000001 to PLOT_000100) with geometry within (p_xmin, p_xmax, p_ymin, p_ymax)
-- 3 elements (layers) per plot with depth ranges:
--     Element 1: 0-30 cm
--     Element 2: 30-60 cm
--     Element 3: 60-100 cm
-- 1 specimen (sample) per element (layer)
-- Physical/chemical results for all, or for the array of observation_phys_chem_id specified in the parameter (p_observation_ids), and with random values that respect the value_min and value_max bounds of the property

CREATE OR REPLACE FUNCTION core.insert_dummy_data(
    p_num_plots integer DEFAULT 100,
    p_observation_ids integer[] DEFAULT NULL,
    p_xmin float DEFAULT -1.0,
    p_xmax float DEFAULT 1.0,
    p_ymin float DEFAULT -1.0,
    p_ymax float DEFAULT 1.0
) 
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_project_id integer;
    v_site_id integer;
    v_plot_id integer;
    v_profile_id integer;
    v_element_id integer;
    v_specimen_id integer;
    v_plot_num integer;
    v_observation_rec RECORD;
    v_random_value real;
    v_random_x float;
    v_random_y float;
    v_observation_filter integer[];
BEGIN
    -- Use all observations if none specified
    IF p_observation_ids IS NULL THEN
        SELECT array_agg(observation_phys_chem_id) 
        INTO v_observation_filter
        FROM core.observation_phys_chem;
    ELSE
        v_observation_filter := p_observation_ids;
    END IF;
    
    RAISE NOTICE 'Starting dummy data insertion with parameters:';
    RAISE NOTICE '  - Number of plots: %', p_num_plots;
    RAISE NOTICE '  - Observations: %', array_length(v_observation_filter, 1);
    RAISE NOTICE '  - X range: [%, %]', p_xmin, p_xmax;
    RAISE NOTICE '  - Y range: [%, %]', p_ymin, p_ymax;
    -- Insert project
    INSERT INTO core.project (name)
    VALUES ('dummy data')
    RETURNING project_id INTO v_project_id;
    
    RAISE NOTICE 'Created project with ID: %', v_project_id;
    
    -- Insert site
    INSERT INTO core.site (site_code, "position")
    VALUES ('dummy data', ST_SetSRID(ST_MakePoint(0, 0), 4326))
    RETURNING site_id INTO v_site_id;
    
    RAISE NOTICE 'Created site with ID: %', v_site_id;
    
    -- Link project and site
    INSERT INTO core.project_site (project_id, site_id)
    VALUES (v_project_id, v_site_id);
    
    -- Insert plots
    FOR v_plot_num IN 1..p_num_plots LOOP
        -- Generate random coordinates within specified bounds
        v_random_x := p_xmin + (random() * (p_xmax - p_xmin));
        v_random_y := p_ymin + (random() * (p_ymax - p_ymin));
        
        INSERT INTO core.plot (site_id, plot_code, altitude, time_stamp, "position", type)
        VALUES (
            v_site_id,
            'PLOT_' || LPAD(v_plot_num::text, 6, '0'),
            100 + (random() * 500)::integer,  -- Random altitude between 100 and 600
            CURRENT_DATE - (random() * 365)::integer,
            ST_SetSRID(ST_MakePoint(v_random_x, v_random_y), 4326),
            'TrialPit'
        )
        RETURNING plot_id INTO v_plot_id;
        
        -- Insert profile for this plot
        INSERT INTO core.profile (plot_id, profile_code)
        VALUES (v_plot_id, 'PROFILE_' || LPAD(v_plot_num::text, 3, '0'))
        RETURNING profile_id INTO v_profile_id;
        
        -- Insert 3 elements (layers) per plot
        -- Element 1: 0-30 cm
        INSERT INTO core.element (profile_id, order_element, upper_depth, lower_depth, type)
        VALUES (v_profile_id, 1, 0, 30, 'Layer')
        RETURNING element_id INTO v_element_id;
        
        -- Insert specimen for element 1
        INSERT INTO core.specimen (element_id, code)
        VALUES (v_element_id, 'SPEC_P' || LPAD(v_plot_num::text, 3, '0') || '_E1')
        RETURNING specimen_id INTO v_specimen_id;
        
        -- Insert result_phys_chem for specified observations for this specimen
        FOR v_observation_rec IN 
            SELECT observation_phys_chem_id, value_min, value_max 
            FROM core.observation_phys_chem
            WHERE observation_phys_chem_id = ANY(v_observation_filter)
        LOOP
            -- Generate random value within bounds
            v_random_value := v_observation_rec.value_min + 
                (random() * (v_observation_rec.value_max - v_observation_rec.value_min));
            
            INSERT INTO core.result_phys_chem (observation_phys_chem_id, specimen_id, value)
            VALUES (v_observation_rec.observation_phys_chem_id, v_specimen_id, v_random_value);
        END LOOP;
        
        -- Element 2: 30-60 cm
        INSERT INTO core.element (profile_id, order_element, upper_depth, lower_depth, type)
        VALUES (v_profile_id, 2, 30, 60, 'Layer')
        RETURNING element_id INTO v_element_id;
        
        -- Insert specimen for element 2
        INSERT INTO core.specimen (element_id, code)
        VALUES (v_element_id, 'SPEC_P' || LPAD(v_plot_num::text, 3, '0') || '_E2')
        RETURNING specimen_id INTO v_specimen_id;
        
        -- Insert result_phys_chem for specified observations for this specimen
        FOR v_observation_rec IN 
            SELECT observation_phys_chem_id, value_min, value_max 
            FROM core.observation_phys_chem
            WHERE observation_phys_chem_id = ANY(v_observation_filter)
        LOOP
            v_random_value := v_observation_rec.value_min + 
                (random() * (v_observation_rec.value_max - v_observation_rec.value_min));
            
            INSERT INTO core.result_phys_chem (observation_phys_chem_id, specimen_id, value)
            VALUES (v_observation_rec.observation_phys_chem_id, v_specimen_id, v_random_value);
        END LOOP;
        
        -- Element 3: 60-100 cm
        INSERT INTO core.element (profile_id, order_element, upper_depth, lower_depth, type)
        VALUES (v_profile_id, 3, 60, 100, 'Layer')
        RETURNING element_id INTO v_element_id;
        
        -- Insert specimen for element 3
        INSERT INTO core.specimen (element_id, code)
        VALUES (v_element_id, 'SPEC_P' || LPAD(v_plot_num::text, 3, '0') || '_E3')
        RETURNING specimen_id INTO v_specimen_id;
        
        -- Insert result_phys_chem for specified observations for this specimen
        FOR v_observation_rec IN 
            SELECT observation_phys_chem_id, value_min, value_max 
            FROM core.observation_phys_chem
            WHERE observation_phys_chem_id = ANY(v_observation_filter)
        LOOP
            v_random_value := v_observation_rec.value_min + 
                (random() * (v_observation_rec.value_max - v_observation_rec.value_min));
            
            INSERT INTO core.result_phys_chem (observation_phys_chem_id, specimen_id, value)
            VALUES (v_observation_rec.observation_phys_chem_id, v_specimen_id, v_random_value);
        END LOOP;
        
        IF v_plot_num % GREATEST(1, p_num_plots / 10) = 0 THEN
            RAISE NOTICE 'Created % plots...', v_plot_num;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Dummy data insertion completed successfully!';
    RAISE NOTICE 'Total records created:';
    RAISE NOTICE '  - 1 project';
    RAISE NOTICE '  - 1 site';
    RAISE NOTICE '  - % plots', p_num_plots;
    RAISE NOTICE '  - % profiles', p_num_plots;
    RAISE NOTICE '  - % elements (3 per plot)', p_num_plots * 3;
    RAISE NOTICE '  - % specimens (1 per element)', p_num_plots * 3;
    RAISE NOTICE '  - % physical/chemical results (% observations × % specimens)', 
        array_length(v_observation_filter, 1) * p_num_plots * 3,
        array_length(v_observation_filter, 1),
        p_num_plots * 3;
END;
$$;

-- Usage examples:

-- 1. Default usage (100 plots, all observations, default coordinate range):
-- SELECT core.insert_dummy_data();

-- 2. Custom number of plots:
-- SELECT core.insert_dummy_data(50);

-- 3. Specific observations only (e.g., pH and Clay):
-- SELECT core.insert_dummy_data(100, ARRAY[514, 635]);

-- 4. Custom geographic bounds (e.g., Portugal area):
-- SELECT core.insert_dummy_data(100, NULL, -9.5, -6.2, 36.9, 42.2);


-- To clean up dummy data, you can use:
-- DELETE FROM core.result_phys_chem;
-- DELETE FROM core.specimen;
-- DELETE FROM core.element;
-- DELETE FROM core.profile;
-- DELETE FROM core.plot;
-- DELETE FROM core.project_site;
-- DELETE FROM core.site;
-- DELETE FROM core.project;


-- Example for 500 plots in Portugal and soil properties:
-- 514	pH - Hydrogen potential	pHH2O	pH	1.5	13
-- 635	Clay texture fraction	SaSiCl_2-50-2000u-adj100	%	0	100
-- 587	Sand texture fraction	SaSiCl_2-50-2000u-adj100	%	0	100
-- 683	Silt texture fraction	SaSiCl_2-50-2000u-adj100	%	0	100
-- 69	electricalConductivityProperty	EC_ratio1-2	dS/m	0	60
-- 30	bulkDensityWholeSoilProperty	BlkDensW_we-unkn	kg/dm³	0.01	3.6
-- 497	Nitrogen (N) - total	TotalN_kjeldahl	g/kg	0	1000
-- 742	Potassium (K) - total	Total_h2so4	cmol/kg	0	1000
-- 970	Sodium (Na) - total	Total_h2so4	cmol/kg	0	1000
-- 54	Carbon (C) - organic	OrgC_wc-cro3-nrcs6a1c	g/kg	0	1000

SELECT core.insert_dummy_data(
    p_num_plots := 500,
    p_observation_ids := ARRAY[514,635,587,683,69,30, 497,742,970,54],
    p_xmin := -8.7,
    p_xmax := -6.6,
    p_ymin := 37,
    p_ymax := 41.9
);

-- Look to the results for specific plot
SELECT st.site_code, p.plot_code, pf.profile_code, e.upper_depth, e.lower_depth, opc.property_phys_chem_id, opc.unit_of_measure_id , opc.procedure_phys_chem_id , rpc.value 
FROM core.result_phys_chem rpc 
LEFT JOIN core.observation_phys_chem opc ON opc.observation_phys_chem_id = rpc.observation_phys_chem_id 
LEFT JOIN core.specimen s ON s.specimen_id = rpc.specimen_id 
LEFT JOIN core.element e ON e.element_id = s.element_id 
LEFT JOIN core.profile pf ON pf.profile_id = e.profile_id 
LEFT JOIN core.plot p ON p.plot_id = pf.plot_id
LEFT JOIN core.site st ON st.site_id = p.site_id 
WHERE p.plot_code ='PLOT_000001'
ORDER BY p.plot_code, pf.profile_code, opc.property_phys_chem_id, e.upper_depth, e.lower_depth;
