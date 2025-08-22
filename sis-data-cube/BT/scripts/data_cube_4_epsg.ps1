#!/usr/bin/env pwsh

###############################################
#                      EPSG                   #
###############################################

# Variables
$INPUT_DIR = "C:\home\carva014\Work\Code\FAO\GloSIS\glosis-datacube\BT\tmp"                   # << EDIT THIS LINE!
$EPSG = "EPSG:4326"
Set-Location $INPUT_DIR

# Reproject
Write-Host "Reprojecting to $EPSG ..."
Write-Host ""

Get-ChildItem -Filter "*.tif" | ForEach-Object {
    $FILE = $_.Name
    Write-Host "Processing: $FILE"
    
    # Use gdalwarp to reproject the file
    & gdalwarp -q -t_srs $EPSG -overwrite -of GTiff $FILE temp.tif
    
    # Check if gdalwarp succeeded
    if ($LASTEXITCODE -eq 0) {
        # Move temp file to replace original
        Move-Item "temp.tif" $FILE -Force
    } else {
        Write-Error "Failed to reproject $FILE"
        # Clean up temp file if it exists
        if (Test-Path "temp.tif") {
            Remove-Item "temp.tif"
        }
    }
}