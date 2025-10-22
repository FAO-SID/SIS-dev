

# copy schema to container
pg_dump -h localhost -p 5432 -U glosis -d sis -n spatial_metadata -O -x --role glosis -F plain -v -f /home/carva014/Downloads/spatial_metadata_schema.sql
pg_restore -h localhost -p 5442 -U glosis -d glosis -F custom -v /home/carva014/Downloads/spatial_metadata_schema.backup
