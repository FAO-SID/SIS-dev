-- OBJECT: site and plot
-- ISSUE: geography to geometry


ALTER TABLE IF EXISTS core.site ALTER COLUMN position TYPE geometry(point, 4326) USING position::geometry(Point,4326);
ALTER TABLE IF EXISTS core.site ALTER COLUMN extent TYPE geometry(polygon, 4326) USING extent::geometry(polygon,4326);
ALTER TABLE IF EXISTS core.plot ALTER COLUMN position TYPE geometry(point, 4326) USING position::geometry(Point,4326);
