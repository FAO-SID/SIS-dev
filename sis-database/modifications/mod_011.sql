-- OBJECT: core.plot
-- ISSUE: ADD CHECK CONSTRAINT 'type' for 'TrialPit' or 'Borehole'


ALTER TABLE IF EXISTS core.plot ADD COLUMN "type" text;
ALTER TABLE IF EXISTS core.plot ADD CHECK ("type" IN ('TrialPit','Borehole'));

DO $$
BEGIN

  IF EXISTS (SELECT relname FROM pg_class WHERE relname='plot') THEN
    COMMENT ON COLUMN core.plot.type IS 'Type of plot, TrialPit or Borehole.';
  END IF;

END $$;
