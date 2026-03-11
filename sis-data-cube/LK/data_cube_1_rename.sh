#!/bin/bash

###############################################
#                    Rename                   #
###############################################

echo

COUNTRY=LK
# PROJ=GSAS
# YEAR=2020
# INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                   # << EDIT THIS LINE!
OUTPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!

mkdir -p "$OUTPUT_DIR"

# # Non existing NoData parameter, add now or fail after.
# gdal_edit.py -a_nodata nan "$INPUT_DIR/EC0_30_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/EC30_100_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/ESP0_30_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/ESP30_100_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/pH0-30_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/pH30-100_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Salt0_30cm_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Salt30_100cm_uncertain - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top0-30PH - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top0_30ECse - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top0_30ESP - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top0_30saltaffected - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top30-100PH - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top30_100ECse - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top30_100ESP - Harsha Kumara Kadupitiya.tif"
# gdal_edit.py -a_nodata nan "$INPUT_DIR/Top30_100saltaffected - Harsha Kumara Kadupitiya.tif"

# cp "$INPUT_DIR/EC0_30_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-UNCT.tif
# cp "$INPUT_DIR/EC30_100_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-100-UNCT.tif
# cp "$INPUT_DIR/ESP0_30_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-0-30-UNCT.tif
# cp "$INPUT_DIR/ESP30_100_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-30-100-UNCT.tif
# cp "$INPUT_DIR/pH0-30_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-UNCT.tif
# cp "$INPUT_DIR/pH30-100_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-100-UNCT.tif
# cp "$INPUT_DIR/Salt0_30cm_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-0-30-UNCT.tif
# cp "$INPUT_DIR/Salt30_100cm_uncertain - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-30-100-UNCT.tif
# cp "$INPUT_DIR/Top0-30PH - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-MEAN.tif
# cp "$INPUT_DIR/Top0_30ECse - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-MEAN.tif
# cp "$INPUT_DIR/Top0_30ESP - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-0-30-MEAN.tif
# cp "$INPUT_DIR/Top0_30saltaffected - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-0-30-MEAN.tif
# cp "$INPUT_DIR/Top30-100PH - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-100-MEAN.tif
# cp "$INPUT_DIR/Top30_100ECse - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-100-MEAN.tif
# cp "$INPUT_DIR/Top30_100ESP - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-30-100-MEAN.tif
# cp "$INPUT_DIR/Top30_100saltaffected - Harsha Kumara Kadupitiya.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-30-100-MEAN.tif


# PROJ=GSOCSEQ
# YEAR=2021
# UD="0"
# LD=30
# INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                 # << EDIT THIS LINE!

# cp $INPUT_DIR/SL_GSOCseq_AbsDiff_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADBAU-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_AbsDiff_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM1-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_AbsDiff_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM2-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_AbsDiff_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGADSSM3-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRBAU-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_BAU_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRBAU-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM1-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM1_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM1-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM2-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM2_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM2-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM3-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_ASR_SSM3_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGASRSSM3-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_BAU_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCBAU-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_finalSOC_BAU_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCBAU-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_finalSOC_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM1-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_finalSOC_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM2-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_finalSOC_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM3-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RelDiff_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM1-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RelDiff_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM2-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RelDiff_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRDSSM3-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM1_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM1-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM1_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM1-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM2_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM2-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM2_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM2-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM3_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM3-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_RSR_SSM3_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGRSRSSM3-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM1-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM2-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_SSM_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGSOCSSM3-$YEAR-$UD-$LD-UNCT.tif
# cp $INPUT_DIR/SL_GSOCseq_T0_Map030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGT0-$YEAR-$UD-$LD-MEAN.tif
# cp $INPUT_DIR/SL_GSOCseq_T0_UncertaintyMap030.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGT0-$YEAR-$UD-$LD-UNCT.tif


PROJ=GSNM
YEAR=2025
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                 # << EDIT THIS LINE!

cp $INPUT_DIR/LKA_GSNmap_mean_bd_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_bd_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_bd_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_cec_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_cec_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_cec_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_clay_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_clay_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_clay_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ec_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ec_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_oc_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_oc_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_oc_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ocs_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ocs_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ocs_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ph_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ph_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_ph_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_sand_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_sand_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_sand_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_silt_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-0-30-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_silt_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-30-60-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_mean_silt_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-60-100-MEAN.tif
cp $INPUT_DIR/LKA_GSNmap_sd_bd_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_bd_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_bd_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-BKD-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_cec_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_cec_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_cec_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CEC-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_clay_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_clay_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_clay_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CLAY-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ec_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ec_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_oc_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_oc_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_oc_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORG-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ocs_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ocs_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ocs_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-CORGS-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ph_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ph_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_ph_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_sand_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_sand_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_sand_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SAND-$YEAR-60-100-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_silt_0_30.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-0-30-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_silt_30_60.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-30-60-SDEV.tif
cp $INPUT_DIR/LKA_GSNmap_sd_silt_60_100.tif $OUTPUT_DIR/$COUNTRY-$PROJ-SILT-$YEAR-60-100-SDEV.tif
