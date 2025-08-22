#!/bin/bash

###############################################
#                      EPSG                   #
###############################################

# Variables
INPUT_DIR="/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/PH/tmp"                          # << EDIT THIS LINE!
EPSG="EPSG:32651"
cd $INPUT_DIR

# Reproject
echo "Reprojecting to $EPSG ..."
echo
for FILE in *.tif; do
    gdalwarp -q -t_srs "$EPSG" -overwrite -of GTiff "$FILE" temp.tif && mv temp.tif "$FILE"
done
