#!/bin/bash

###############################################
#                      EPSG                   #
###############################################

echo

# Variables
COUNTRY=MN
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!
EPSG="EPSG:4326"
cd $INPUT_DIR

# Reproject
echo "Reprojecting to $EPSG ..."
echo
for FILE in *.tif; do
    gdalwarp -q -t_srs "$EPSG" -overwrite -of GTiff "$FILE" temp.tif && mv temp.tif "$FILE"
done
