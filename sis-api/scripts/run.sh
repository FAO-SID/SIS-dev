
# create function to insert dummy data for test
psql -h localhost -p 5442 -U sis -d sis -f /home/carva014/Work/Code/FAO/GloSIS-dev/sis-api/scripts/db_insert_dummy_data.sql

# run function
psql -h localhost -p 5442 -U sis -d sis -c "SELECT api.insert_dummy_data(
                                                    p_num_plots := 200,
                                                    p_observation_ids := ARRAY[514,635,587,683,69,30, 497,742,970,54],
                                                    p_xmin := 88,
                                                    p_xmax := 92,
                                                    p_ymin := 26,
                                                    p_ymax := 28
                                                )"

# reset api schema
psql -h localhost -p 5442 -U sis -d sis -c "DROP SCHEMA api CASCADE"
psql -h localhost -p 5442 -U sis -d sis -f /home/carva014/Work/Code/FAO/GloSIS-dev/sis-api/schema.sql




# copy schema to container
pg_dump -h localhost -p 5432 -U glosis -d sis -n spatial_metadata -O -x --role glosis -F plain -v -f /home/carva014/Downloads/spatial_metadata_schema.sql
pg_restore -h localhost -p 5442 -U glosis -d glosis -F custom -v /home/carva014/Downloads/spatial_metadata_schema.backup
