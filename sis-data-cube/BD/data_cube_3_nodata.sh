#!/bin/bash

###############################################
#                   NoData                    #
###############################################

echo

# Variables
COUNTRY=BD
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
    if (( $(echo "$MIN == -999.000" | bc -l) )); then
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue="$NODATA"
        mv "${FILE}.tmp.tif" "$FILE"
    fi

    if (( $(echo "$MIN > $NODATA" | bc -l) )); then
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=$CURRENT_NODATA) + ($NODATA)*(A==$CURRENT_NODATA)" --NoDataValue="$NODATA"
        mv "${FILE}.tmp.tif" "$FILE"
    fi

    if (( $(echo "$MIN < $NODATA" | bc -l) )); then
        NODATA=-3.39999995214436425e+38
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=$CURRENT_NODATA) + ($NODATA)*(A==$CURRENT_NODATA)" --NoDataValue="$NODATA"
        mv "${FILE}.tmp.tif" "$FILE"
    fi

done


printf "%-8s %-8s %-8s %s\n" "Minimum" "oNoData" "nNoData" "File"
for FILE in *.tif; do

    CURRENT_NODATA=$(gdalinfo "$FILE" | grep "NoData Value=" | awk -F'NoData Value=' '{print $2}' | tr -d '[:space:]')

    if [[ "$FILE" == *"GSOCSEQ"* ]]; then
        NODATA=-3.39999995214436425e+38
        printf "%-8s %-8s %-8s %s\n" "$MIN" "$CURRENT_NODATA" "$NODATA" "$FILE"
        gdal_calc.py --quiet -A "$FILE" --outfile="${FILE}.tmp.tif" --calc="A*(A!=$CURRENT_NODATA) + ($NODATA)*(A==$CURRENT_NODATA)" --NoDataValue="$NODATA"
        mv "${FILE}.tmp.tif" "$FILE"
    fi

done


rm -f *.tif.aux.xml