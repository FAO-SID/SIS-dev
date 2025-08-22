#!/bin/bash

###############################################
#                NoData & EPSG                #
###############################################

# Variables
INPUT_DIR="/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/PH/tmp"                          # << EDIT THIS LINE!
NODATA=-1
cd $INPUT_DIR

# Dealing with other Nodata values
echo
echo "Assigning NoData to $NODATA ..."

# NoData NULL
gdal_calc.py --quiet -A PH-GSAS-ECX-2020-0-30.tif --outfile=temp.tif --calc="A*(A!=0.23120065033435822) + ($NODATA)*(A==0.23120065033435822)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-ECX-2020-0-30.tif
gdal_calc.py --quiet -A PH-GSAS-ECX-2020-30-100.tif --outfile=temp.tif --calc="A*(A!=0.1270795613527298) + ($NODATA)*(A==0.1270795613527298)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-ECX-2020-30-100.tif
gdal_calc.py --quiet -A PH-GSAS-NAEXC-2020-0-30.tif --outfile=temp.tif --calc="A*(A!=3.2343051433563232) + ($NODATA)*(A==3.2343051433563232)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-NAEXC-2020-0-30.tif
gdal_calc.py --quiet -A PH-GSAS-NAEXC-2020-30-100.tif --outfile=temp.tif --calc="A*(A!=6.29727840423584) + ($NODATA)*(A==6.29727840423584)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-NAEXC-2020-30-100.tif
gdal_calc.py --quiet -A PH-GSAS-PHX-2020-0-30.tif --outfile=temp.tif --calc="A*(A!=6.248271942138672) + ($NODATA)*(A==6.248271942138672)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-PHX-2020-0-30.tif
gdal_calc.py --quiet -A PH-GSAS-PHX-2020-30-100.tif --outfile=temp.tif --calc="A*(A!=6.0150837898254395) + ($NODATA)*(A==6.0150837898254395)" --NoDataValue=$NODATA && mv temp.tif PH-GSAS-PHX-2020-30-100.tif

# Transfer the -1 pixels from Geotiff A to Geotiff B
gdal_calc.py --quiet -A PH-GSAS-PHX-2020-0-30.tif -B PH-GSAS-SALT-2020-0-30.tif --outfile=temp.tif --calc="where(A==-1, -1, B)" --NoDataValue=-1 --overwrite && mv temp.tif PH-GSAS-SALT-2020-0-30.tif
gdal_calc.py --quiet -A PH-GSAS-PHX-2020-0-30.tif -B PH-GSAS-SALT-2020-30-100.tif --outfile=temp.tif --calc="where(A==-1, -1, B)" --NoDataValue=-1 --overwrite && mv temp.tif PH-GSAS-SALT-2020-30-100.tif

# Rewrite pixels with -99999 to -1
gdal_calc.py --quiet -A PH-GSOC-CORGADBAU-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGADBAU-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGADSSM1-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGADSSM1-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGADSSM2-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGADSSM2-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGADSSM3-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGADSSM3-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGASRBAU-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGASRBAU-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGASRSSM1-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGASRSSM1-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGASRSSM2-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGASRSSM2-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGASRSSM3-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGASRSSM3-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGSSMU-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGSSMU-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGSOCBAU-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGSOCBAU-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGSOCSSM1-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGSOCSSM1-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGSOCSSM2-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGSOCSSM2-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGSOCSSM3-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-99999) + ($NODATA)*(A==-99999)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGSOCSSM3-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSNM-BKD-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-BKD-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-BKD-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-BKD-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-CEC-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CEC-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-CEC-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CEC-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-CLAY-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CLAY-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-CLAY-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CLAY-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-KXX-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-KXX-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-KXX-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-KXX-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-CORG-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CORG-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-CORG-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-CORG-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-PXX-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-PXX-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-PXX-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-PXX-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-PHX-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-PHX-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-PHX-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-PHX-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-SAND-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-SAND-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-SAND-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-SAND-2023-30-60.tif 
gdal_calc.py --quiet -A PH-GSNM-SILT-2023-0-30.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-SILT-2023-0-30.tif 
gdal_calc.py --quiet -A PH-GSNM-SILT-2023-30-60.tif --outfile=temp.tif --calc="A*(A!=-9999) + ($NODATA)*(A==-9999)" --NoDataValue=$NODATA && mv temp.tif PH-GSNM-SILT-2023-30-60.tif 

# NoData -3.4e+38
gdal_calc.py --quiet -A PH-GSOC-CORGRDSSM1-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRDSSM1-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRDSSM2-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRDSSM2-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRDSSM3-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRDSSM3-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM1-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM1-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM1U-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM1U-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM2-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM2-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM2U-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM2U-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM3-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM3-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGRSRSSM3U-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGRSRSSM3U-2021-0-30.tif
gdal_calc.py --quiet -A PH-GSOC-CORGT0-2021-0-30.tif --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && mv temp.tif PH-GSOC-CORGT0-2021-0-30.tif
