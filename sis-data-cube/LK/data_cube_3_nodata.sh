#!/bin/bash

###############################################
#                   NoData                    #
###############################################

echo

# Variables
COUNTRY=LK
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!

cd $INPUT_DIR


# Dealing with other Nodata values
echo
echo "Assigning NoData ..."
echo


printf "%-8s %-8s %-8s %s\n" "Minimum" "oNoData" "nNoData" "File"
for FILE in *.tif; do
    CURRENT_NODATA=$(gdalinfo "$FILE" | grep "NoData Value=" | awk -F'NoData Value=' '{print $2}' | tr -d '[:space:]')
    MIN=$(gdalinfo -stats "$FILE" | grep "Minimum=" | awk -F'Minimum=' '{print $2}' | awk -F',' '{print $1}' | tr -d '[:space:]')
    NODATA=-9999
    if awk "BEGIN {exit !($MIN == -999.000)}"; then
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue="$NODATA"
        mv "${FILE}.tmp.tif" "$FILE"
    fi
    if awk "BEGIN {exit !($MIN > $NODATA)}"; then
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        if [[ "$CURRENT_NODATA" == "nan" ]]; then
            # NaN NoData means fill pixels are float32 -3.4e+38 values, not actual NaNs
            gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="where(A < -1e38, $NODATA, A)" --NoDataValue="$NODATA" --hideNoData
        else
            gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=$CURRENT_NODATA) + ($NODATA)*(A==$CURRENT_NODATA)" --NoDataValue="$NODATA"
        fi
        mv "${FILE}.tmp.tif" "$FILE"
    fi
    if awk "BEGIN {exit !($MIN < $NODATA)}"; then
        NODATA=-3.39999995214436425e+38
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_edit.py -a_nodata "$NODATA" "$FILE"
    fi
done


# Resample the mask to match the target raster's grid.
# ogr2ogr -f "ESRI Shapefile" $INPUT_DIR/mask.shp /home/carva014/Downloads/FAO/AFACI/UNBorders2020/BNDA_CTY.shp -where "ISO3CD = 'LKA'" -t_srs EPSG:32644
# gdal_rasterize -burn 1 -init 0 -ot Byte -te 336315.713 654058.983 597688.501 1087532.866 -tr 920.326718309859416 -920.326715498938256 -ts 284 471 -a_srs EPSG:32644 $INPUT_DIR/mask.shp $INPUT_DIR/mask.tif


# Mask country shape preserving NoData value
# for FILE in *GSAS*.tif; do
#     NODATA=$(gdalinfo "$FILE" | grep "NoData Value=" | awk -F'NoData Value=' '{print $2}' | tr -d '[:space:]')
#     gdal_calc.py --quiet -A mask.tif -B "$FILE" --outfile=$INPUT_DIR/temp.tif \
#         --calc="where(A==1, B, $NODATA)" --NoDataValue=$NODATA --overwrite && mv $INPUT_DIR/temp.tif "$FILE"
# done


# rm $INPUT_DIR/mask.*
rm -f *.tif.aux.xml
