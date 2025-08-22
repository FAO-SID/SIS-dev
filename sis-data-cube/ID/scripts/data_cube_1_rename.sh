#!/bin/bash

###############################################
#                    Rename                   #
###############################################



# Merge, using the max value when there is a overlap and sets the nodata value to -9999
COUNTRY=ID
INPUT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev/sis-data-cube/$COUNTRY/Input/GSNM"
OUTPUT_DIR="/home/carva014/Work/Code/FAO/GloSIS-dev/sis-data-cube/$COUNTRY/tmp"
PROJ=GSNM
YEAR=2023
UD="0"
LD=30
gdalwarp -r max $INPUT_DIR/JAVA/ak_0_30_mean.tif $INPUT_DIR/KALIMANTAN/ak_0_30_QRF.tif $INPUT_DIR/SUMATRA/ak_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-KXX-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/ak_0_30_sd.tif $INPUT_DIR/KALIMANTAN/ak_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/ak_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-KXXSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/ap_0_30_mean.tif $INPUT_DIR/KALIMANTAN/ap_0_30_QRF.tif $INPUT_DIR/SUMATRA/ap_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-PXX-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/ap_0_30_sd.tif $INPUT_DIR/KALIMANTAN/ap_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/ap_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-PXXSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/cec_0_30_mean.tif $INPUT_DIR/KALIMANTAN/cec_0_30_QRF.tif $INPUT_DIR/SUMATRA/cec_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/cec_0_30_sd.tif $INPUT_DIR/KALIMANTAN/cec_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/cec_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CECSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/clay_0_30_mean.tif $INPUT_DIR/KALIMANTAN/clay_0_30_QRF.tif $INPUT_DIR/SUMATRA/clay_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/clay_0_30_sd.tif $INPUT_DIR/KALIMANTAN/clay_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/clay_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CLAYSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/ph_0_30_mean.tif $INPUT_DIR/KALIMANTAN/ph_0_30_QRF.tif $INPUT_DIR/SUMATRA/ph_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-PHX-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/ph_0_30_sd.tif $INPUT_DIR/KALIMANTAN/ph_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/ph_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-PHXSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/sand_0_30_mean.tif $INPUT_DIR/KALIMANTAN/sand_0_30_QRF.tif $INPUT_DIR/SUMATRA/sand_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/sand_0_30_sd.tif $INPUT_DIR/KALIMANTAN/sand_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/sand_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-SANDSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/silt_0_30_mean.tif $INPUT_DIR/KALIMANTAN/silt_0_30_QRF.tif $INPUT_DIR/SUMATRA/silt_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/silt_0_30_sd.tif $INPUT_DIR/KALIMANTAN/silt_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/silt_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-SILTSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/soc_0_30_mean.tif $INPUT_DIR/KALIMANTAN/soc_0_30_QRF.tif $INPUT_DIR/SUMATRA/soc_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/soc_0_30_sd.tif $INPUT_DIR/KALIMANTAN/soc_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/soc_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSD-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/total_N_0_30_mean.tif $INPUT_DIR/KALIMANTAN/total_N_0_30_QRF.tif $INPUT_DIR/SUMATRA/total_N_0_30_mean.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-NTOT-$YEAR-$UD-$LD.tif
gdalwarp -r max $INPUT_DIR/JAVA/total_N_0_30_sd.tif $INPUT_DIR/KALIMANTAN/total_N_0_30_QRF_SD.tif $INPUT_DIR/SUMATRA/total_N_0_30_sd.tif -dstnodata -9999 $OUTPUT_DIR/$COUNTRY-$PROJ-NTOTSD-$YEAR-$UD-$LD.tif
