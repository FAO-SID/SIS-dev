#!/bin/bash

###############################################
#                   NoData                    #
###############################################

echo

# Variables
COUNTRY=KH
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
ogr2ogr -f "ESRI Shapefile" $INPUT_DIR/mask.shp /home/carva014/Downloads/FAO/AFACI/UNBorders2020/BNDA_CTY.shp -where "ISO3CD = 'KHM'" -t_srs EPSG:32648
gdal_rasterize -burn 1 -init 0 -ot Byte -te 208300.003 1096004.007 788295.831 1625763.976 -tr 913.379256692913373 913.379256896551851 -ts 635 580 -a_srs EPSG:32648 $INPUT_DIR/mask.shp $INPUT_DIR/mask.tif

# Transfer the -9999 pixels from Geotiff A to Geotiff B (mask country shape)
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-ECX-2021-0-30-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-ECX-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-ECX-2021-0-30-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-ECX-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-ECX-2021-30-100-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-ECX-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-ECX-2021-30-100-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-ECX-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-NAEXC-2021-0-30-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-NAEXC-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-NAEXC-2021-0-30-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-NAEXC-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-NAEXC-2021-30-100-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-NAEXC-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-NAEXC-2021-30-100-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-NAEXC-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-PHAQ-2021-0-30-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-PHAQ-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-PHAQ-2021-0-30-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-PHAQ-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-PHAQ-2021-30-100-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-PHAQ-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-PHAQ-2021-30-100-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-PHAQ-2021-30-100-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-SALT-2021-0-30-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-SALT-2021-0-30-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-SALT-2021-0-30-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-SALT-2021-0-30-UNCT.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-SALT-2021-30-100-MEAN.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-SALT-2021-30-100-MEAN.tif
gdal_calc.py --quiet -A mask.tif -B KH-GSAS-SALT-2021-30-100-UNCT.tif --outfile=$INPUT_DIR/temp.tif --calc="where(A==1, B, -9999)" --NoDataValue=-9999 --overwrite && mv $INPUT_DIR/temp.tif KH-GSAS-SALT-2021-30-100-UNCT.tif

rm $INPUT_DIR/mask.*
rm -f *.tif.aux.xml
