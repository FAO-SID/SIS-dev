#!/bin/bash

###############################################
#                   NoData                    #
###############################################

echo

# Variables
COUNTRY=MN
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!

cd $INPUT_DIR


# Dealing with other Nodata values
echo
echo "Assigning NoData ..."
echo

# conver 1 (NoData) to -9999 (NoData)
gdal_calc.py --quiet -A MN-GSAS-SALT-2021-0-30-MEAN.tif --outfile=temp.tif --calc="A*(A!=1) + (-9999)*(A==1)" --NoDataValue="-9999" && mv temp.tif MN-GSAS-SALT-2021-0-30-MEAN.tif


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

rm -f *.tif.aux.xml

# Transfer the -9999 pixels from Geotiff A to Geotiff B (mask country shape)
gdal_calc.py --quiet -A MN-GSAS-ECX-2021-0-30-MEAN.tif -B MN-GSAS-ECX-2021-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif MN-GSAS-ECX-2021-0-30-SDEV.tif
gdal_calc.py --quiet -A MN-GSAS-ECX-2021-0-30-MEAN.tif -B MN-GSAS-NAEXC-2021-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif MN-GSAS-NAEXC-2021-0-30-SDEV.tif
gdal_calc.py --quiet -A MN-GSAS-ECX-2021-0-30-MEAN.tif -B MN-GSAS-PHAQ-2021-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif MN-GSAS-PHAQ-2021-0-30-SDEV.tif
gdal_calc.py --quiet -A MN-GSAS-ECX-2021-0-30-MEAN.tif -B MN-GSAS-SALT-2021-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif MN-GSAS-SALT-2021-0-30-MEAN.tif
