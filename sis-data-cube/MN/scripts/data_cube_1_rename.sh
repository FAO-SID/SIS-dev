#!/bin/bash

###############################################
#                    Rename                   #
###############################################

echo

COUNTRY=MN
PROJ=GSAS
YEAR=2021
UD="0"
LD=30
INPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/input/$PROJ"                   # << EDIT THIS LINE!
OUTPUT_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/tmp"                          # << EDIT THIS LINE!

mkdir -p "$OUTPUT_DIR"


cp "$INPUT_DIR/EC0_30_uncertain - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-$UD-$LD-SDEV.tif
cp "$INPUT_DIR/EC_0_30 - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-ECX-$YEAR-$UD-$LD-MEAN.tif
cp "$INPUT_DIR/ESP0_30_uncertain - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-$UD-$LD-SDEV.tif
cp "$INPUT_DIR/ESP_0_30 - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-NAEXC-$YEAR-$UD-$LD-MEAN.tif
cp "$INPUT_DIR/pH0_30_uncertain - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-$UD-$LD-SDEV.tif
cp "$INPUT_DIR/PH_0_30 - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-PHAQ-$YEAR-$UD-$LD-MEAN.tif
cp "$INPUT_DIR/Saltaffected0_30 - Enkhtuya Bazarradnaa.tif" $OUTPUT_DIR/$COUNTRY-$PROJ-SALT-$YEAR-$UD-$LD-MEAN.tif
