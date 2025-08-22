-- OBJECT: multiple
-- ISSUE: data type 'varchar' is widly used without limit, then use 'text' data type insead. https://stackoverflow.com/questions/4848964/difference-between-text-and-varchar-character-varying


DO $$
DECLARE
    f record;
BEGIN
    FOR f IN
        SELECT table_catalog d, table_schema s, table_name t, column_name c, data_type dt
        FROM information_schema.columns 
        WHERE table_catalog = 'iso28258'
          AND table_schema IN ('metadata', 'core') 
          AND data_type = 'character varying'
        ORDER BY 1,2,3,4,5
    LOOP
    EXECUTE format('ALTER TABLE IF EXISTS %I.%I ALTER COLUMN %I TYPE text USING %I::text', f.s, f.t, f.c, f.c);
    END LOOP;
END $$;
