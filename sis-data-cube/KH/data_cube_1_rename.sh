#!/bin/bash

###############################################
#                    Rename                   #
###############################################

echo

COUNTRY=KH
PROJ=GSAS
YEAR=2021
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                   # << EDIT THIS LINE!
OUTPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!

mkdir -p "$OUTPUT_DIR"

# Non existing NoData parameter, add now or fail after.
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil EC Map 0-30 cm(855_SalinityMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil EC Map 30-100 cm (855_SalinityMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil ESP Map 0-30 cm (855_ESPMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil ESP Map 30-100 cm (855_ESPMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil pH Map 0-30 cm (855_pHMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil pH Map 30-100 cm (855_pHMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil Salt-affected Map 0-30 cm (855_SaltMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/National Soil Salt-affected Map 30-100 cm (855_SaltMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty EC Map 0-30 cm (855_UncertaintySalinityMap030.tif).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty EC Map 30-100 cm (855_UncertaintySalinityMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty ESP Map 0-30 cm (855_UncertaintyESPMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty ESP Map 30-100 cm (855_UncertaintyESPMap30100.tiff) .tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty PH Map 0-30 cm (855_UncertaintypHMap030.tiff) .tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty PH Map 30-100 cm (855_UncertaintyPHMap30100.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty Salt-affected Map 0-30 cm (855_UncertaintySaltMap030.tiff).tif"
gdal_edit.py -a_nodata nan "$INPUT_DIR/Uncertainty Salt-affected Map 30-100 cm (855_UncertaintySaltMap30100.tiff).tif"

cp "$INPUT_DIR/National Soil EC Map 0-30 cm(855_SalinityMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-MEAN.tif
cp "$INPUT_DIR/National Soil EC Map 30-100 cm (855_SalinityMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-100-MEAN.tif
cp "$INPUT_DIR/National Soil ESP Map 0-30 cm (855_ESPMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-0-30-MEAN.tif
cp "$INPUT_DIR/National Soil ESP Map 30-100 cm (855_ESPMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-30-100-MEAN.tif
cp "$INPUT_DIR/National Soil pH Map 0-30 cm (855_pHMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-MEAN.tif
cp "$INPUT_DIR/National Soil pH Map 30-100 cm (855_pHMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-100-MEAN.tif
cp "$INPUT_DIR/National Soil Salt-affected Map 0-30 cm (855_SaltMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-0-30-MEAN.tif
cp "$INPUT_DIR/National Soil Salt-affected Map 30-100 cm (855_SaltMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-30-100-MEAN.tif
cp "$INPUT_DIR/Uncertainty EC Map 0-30 cm (855_UncertaintySalinityMap030.tif).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-UNCT.tif
cp "$INPUT_DIR/Uncertainty EC Map 30-100 cm (855_UncertaintySalinityMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-100-UNCT.tif
cp "$INPUT_DIR/Uncertainty ESP Map 0-30 cm (855_UncertaintyESPMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-0-30-UNCT.tif
cp "$INPUT_DIR/Uncertainty ESP Map 30-100 cm (855_UncertaintyESPMap30100.tiff) .tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-30-100-UNCT.tif
cp "$INPUT_DIR/Uncertainty PH Map 0-30 cm (855_UncertaintypHMap030.tiff) .tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-UNCT.tif
cp "$INPUT_DIR/Uncertainty PH Map 30-100 cm (855_UncertaintyPHMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-100-UNCT.tif
cp "$INPUT_DIR/Uncertainty Salt-affected Map 0-30 cm (855_UncertaintySaltMap030.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-0-30-UNCT.tif
cp "$INPUT_DIR/Uncertainty Salt-affected Map 30-100 cm (855_UncertaintySaltMap30100.tiff).tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-30-100-UNCT.tif


PROJ=GSOCSEQ
YEAR=2021
UD="0"
LD=30
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                 # << EDIT THIS LINE!

cp $INPUT_DIR/KHD_GSOCseq_AbsDiff_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADBAU-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_AbsDiff_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM1-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_AbsDiff_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM2-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_AbsDiff_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM3-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRBAU-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_BAU_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRBAU-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM1-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM1_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM1-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM2-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM2_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM2-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM3-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_ASR_SSM3_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM3-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_BAU_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCBAU-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_finalSOC_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCBAU-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_finalSOC_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM1-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_finalSOC_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM2-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_finalSOC_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM3-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RelDiff_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM1-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RelDiff_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM2-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RelDiff_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM3-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM1-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM1_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM1-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM2-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM2_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM2-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM3-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_RSR_SSM3_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM3-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM1-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM2-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM3-$YEAR-$UD-$LD-UNCT.tif
cp $INPUT_DIR/KHD_GSOCseq_T0_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGT0-$YEAR-$UD-$LD-MEAN.tif
cp $INPUT_DIR/KHD_GSOCseq_T0_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGT0-$YEAR-$UD-$LD-UNCT.tif
