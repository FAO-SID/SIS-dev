#!/bin/bash

###############################################
#                NoData & EPSG                #
###############################################

# Variables
INPUT_DIR="/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/tmp"                          # << EDIT THIS LINE!
Set-Location $INPUT_DIR

# Dealing with other Nodata values
Write-Host
Write-Host "Assigning NoData ..."

# the raster has no NoData values but we still want to set a value for it
NODATA=-1
gdal_edit.py -a_nodata $NODATA BT-GSAS-SALT-2021-0-30.tif
gdal_edit.py -a_nodata $NODATA BT-GSAS-SALT-2021-30-100.tif
NODATA=-999
gdal_edit.py -a_nodata $NODATA BT-GSAS-ECXTE-2021-0-30.tif
gdal_edit.py -a_nodata $NODATA BT-GSAS-ECXTE-2021-30-100.tif
gdal_edit.py -a_nodata $NODATA BT-GSAS-NAEXCPT-2021-0-30.tif
gdal_edit.py -a_nodata $NODATA BT-GSAS-NAEXCPT-2021-30-100.tif

# Rewrite pixels with x to -1
NODATA=-1
gdal_calc.py --quiet -A BT-GSAS-ECXSE-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=0.002696042414754629) + ($NODATA)*(A==0.002696042414754629)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXSE-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-ECXSE-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=0.002528232056647539) + ($NODATA)*(A==0.002528232056647539)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXSE-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-NAEXC-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=3.6186575889587402) + ($NODATA)*(A==3.6186575889587402)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-NAEXC-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-NAEXC-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=3.3432693481445312) + ($NODATA)*(A==3.3432693481445312)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-NAEXC-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-PHX-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=5.198665618896484) + ($NODATA)*(A==5.198665618896484)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHX-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-PHX-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=5.611226558685303) + ($NODATA)*(A==5.611226558685303)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHX-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-PHXT-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=2.5153369903564453) + ($NODATA)*(A==2.5153369903564453)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHXT-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-PHXT-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=0.7993636131286621) + ($NODATA)*(A==0.7993636131286621)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHXT-2021-30-100.tif

# Rewrite pixels with -9999 to -1
NODATA=-1
gdal_calc.py --quiet -A BT-GSNM-BASAT-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BASAT-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-BASATSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BASATSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-BKD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BKD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-BKDSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BKDSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-BSEXC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BSEXC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-BSEXCSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-BSEXCSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CAEXC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CAEXC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CAEXCSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CAEXCSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CEC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CEC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CECSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CECSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CFRAGF-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CFRAGF-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CFRAGFSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CFRAGFSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CLAY-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CLAY-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CLAYSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CLAYSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CORG-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CORG-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CORGNTOTR-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CORGNTOTR-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CORGNTOTRSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CORGNTOTRSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-CORGSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-CORGSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-KEXC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-KEXC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-KEXCSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-KEXCSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-KXX-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-KXX-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-KXXSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-KXXSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-MGEXC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-MGEXC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-MGEXCSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-MGEXCSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-NAEXC-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-NAEXC-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-NAEXCSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-NAEXCSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-NTOT-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-NTOT-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-NTOTSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-NTOTSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-PHAQ-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-PHAQ-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-PHAQSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-PHAQSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-PXX-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-PXX-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-PXXSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-PXXSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-SAND-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-SAND-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-SANDSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-SANDSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-SILT-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-SILT-2024-0-30.tif
gdal_calc.py --quiet -A BT-GSNM-SILTSD-2024-0-30.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSNM-SILTSD-2024-0-30.tif
gdal_calc.py --quiet -A BT-OTHER-CLAWRB-2024-0-100.tif  --outfile=temp.tif --calc="A*(A!=-9999.000) + ($NODATA)*(A==-9999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-OTHER-CLAWRB-2024-0-100.tif

# Rewrite pixels with -999 to -1
NODATA=-1
gdal_calc.py --quiet -A BT-GSOC-CORGSOCBAU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGSOCBAU-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGSOCSSM1-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGSOCSSM1-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGSOCSSM2-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGSOCSSM2-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGSOCSSM3-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGSOCSSM3-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGSSMU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGSSMU-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGBAUU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999.000) + ($NODATA)*(A==-999.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGBAUU-2022-0-30.tif	

# Rewrite pixels with 999 to -1
NODATA=-1
gdal_calc.py --quiet -A BT-GSOC-CORGASRBAUU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=999) + ($NODATA)*(A==999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRBAUU-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM1U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=999) + ($NODATA)*(A==999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM1U-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM2U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=999) + ($NODATA)*(A==999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM2U-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM3U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=999) + ($NODATA)*(A==999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM3U-2022-0-30.tif					

# Rewrite pixels with -3.40E+38 to -1
NODATA=-1
gdal_calc.py --quiet -A BT-GSAS-ECXSD-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXSD-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-ECXSD-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXSD-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-ECXU-2021-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXU-2021-0-30.tif
gdal_calc.py --quiet -A BT-GSAS-ECXU-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-ECXU-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-NAEXCSD-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-NAEXCSD-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-NAEXCU-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-NAEXCU-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-PHXSD-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHXSD-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-PHXU-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-PHXU-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSAS-SALTU-2021-30-100.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSAS-SALTU-2021-30-100.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRDSSM1-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRDSSM1-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM1-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM1-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM1U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM1U-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM2U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM2U-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM3U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM3U-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGT0-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGT0-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRDSSM2-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRDSSM2-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRDSSM3-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRDSSM3-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM2-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM2-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGRSRSSM3-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-339999995214436424907732413799364296704.000) + ($NODATA)*(A==-339999995214436424907732413799364296704.000)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGRSRSSM3-2022-0-30.tif

# Rewrite pixels with -3.40E+38 to -999
NODATA=-999
gdal_calc.py --quiet -A BT-GSOC-CORGADBAU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGADBAU-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGADSSM1-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGADSSM1-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGADSSM2-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGADSSM2-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGADSSM3-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGADSSM3-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRBAU-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRBAU-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM1-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM1-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM2-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM2-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGASRSSM3-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGASRSSM3-2022-0-30.tif
gdal_calc.py --quiet -A BT-GSOC-CORGT0U-2022-0-30.tif  --outfile=temp.tif --calc="A*(A!=-999) + ($NODATA)*(A==-999)" --NoDataValue=$NODATA && Move-Item temp.tif BT-GSOC-CORGT0U-2022-0-30.tif

