#!/bin/bash

###############################################
#                   NoData                    #
###############################################

echo

# Variables
COUNTRY=LA
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


# Resample the mask to match the target raster's grid. Computing extent to 100.0835516 13.9126580 107.7080026 22.5050437 ...
gdalwarp -overwrite -srcnodata nan -dstnodata -9999 -tr 0.0083333 0.0083333 -te 100.0835516 13.9134114 107.7085211 22.5050437 -r near LA-GSNM-BKD-2026-0-30-MEAN.tif mask.tif

# Transfer the -9999 pixels from Geotiff A to Geotiff B (mask country shape)
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-ECX-2020-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-ECX-2020-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-ECX-2020-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-ECX-2020-0-30-SDEV.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-PHX-2020-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-PHX-2020-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-PHX-2020-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-PHX-2020-0-30-SDEV.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-SALT-2020-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-SALT-2020-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-SALT-2020-0-30-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-SALT-2020-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-ECX-2020-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-ECX-2020-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-ECX-2020-30-100-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-ECX-2020-30-100-SDEV.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-NAEXC-2020-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-NAEXC-2020-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-NAEXC-2020-0-30-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-NAEXC-2020-0-30-SDEV.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-PHX-2020-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-PHX-2020-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-PHX-2020-30-100-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-PHX-2020-30-100-SDEV.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-SALT-2020-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-SALT-2020-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-SALT-2020-30-100-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-SALT-2020-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-NAEXC-2020-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-NAEXC-2020-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B LA-GSAS-NAEXC-2020-30-100-SDEV.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif LA-GSAS-NAEXC-2020-30-100-SDEV.tif
rm mask.tif

rm -f *.tif.aux.xml
