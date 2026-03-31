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


# Resample the mask to match the target raster's grid.
gdalwarp -overwrite -s_srs EPSG:4326 -t_srs EPSG:32646 -srcnodata nan -dstnodata -9999 -tr 896.365400369003623 896.365401084011069 -te -18057.323 2293800.977 467772.724 2955318.643 -r near BD-GSNM-BULDFINE-2024-0-30-MEAN.tif mask.tif

# Transfer the -9999 pixels from Geotiff A to Geotiff B (mask country shape)
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-ELECCOND-2021-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-ELECCOND-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-ELECCOND-2021-0-30-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-ELECCOND-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-ELECCOND-2021-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-ELECCOND-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-ELECCOND-2021-30-100-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-ELECCOND-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SODEXP-2021-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SODEXP-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SODEXP-2021-0-30-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SODEXP-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SODEXP-2021-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SODEXP-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SODEXP-2021-30-100-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SODEXP-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-PHX-2021-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-PHX-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-PHX-2021-0-30-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-PHX-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-PHX-2021-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-PHX-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-PHX-2021-30-100-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-PHX-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SALT-2021-0-30-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SALT-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SALT-2021-0-30-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SALT-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SALT-2021-30-100-MEAN.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SALT-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B BD-GSAS-SALT-2021-30-100-UNCT.tif --outfile=temp.tif --calc="where(A==-9999, -9999, B)" --NoDataValue=-9999 --overwrite && mv temp.tif BD-GSAS-SALT-2021-30-100-UNCT.tif
rm mask.tif
rm -f *.tif.aux.xml
