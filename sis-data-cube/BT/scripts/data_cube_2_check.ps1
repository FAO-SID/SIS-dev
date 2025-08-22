#!/usr/bin/env pwsh

###############################################
#                NoData & EPSG                #
###############################################

# Variables
$INPUT_DIR = "C:\home\carva014\Work\Code\FAO\GloSIS\glosis-datacube\BT\tmp"                   # << EDIT THIS LINE!
Set-Location $INPUT_DIR

# Check NoData values before processing
Write-Host ("{0,-8} {1,-8} {2,-12} {3,-12} {4,-8} {5}" -f "Minimum", "Maximum", "Mean", "StdDev", "NoData", "File")

Get-ChildItem -Filter "*.tif" | ForEach-Object {
    $FILE = $_.Name
    $BASENAME = $_.BaseName
    
    # Extract NoData and stat values using gdalinfo
    $gdalInfoOutput = & gdalinfo $FILE
    $gdalStatsOutput = & gdalinfo -stats $FILE
    
    # Extract NoData value
    $CURRENT_NODATA = ""
    $noDataLine = $gdalInfoOutput | Select-String "NoData Value="
    if ($noDataLine) {
        $CURRENT_NODATA = ($noDataLine -split "NoData Value=")[1]
    }
    
    # Extract statistics
    $MIN = ""
    $MAX = ""
    $MEA = ""
    $STD = ""
    
    $statsLine = $gdalStatsOutput | Select-String "Minimum="
    if ($statsLine) {
        $parts = $statsLine -split ","
        if ($parts.Count -ge 4) {
            $MIN = ($parts[0] -split "Minimum=")[1]
            $MAX = ($parts[1] -split "Maximum=")[1]
            $MEA = ($parts[2] -split "Mean=")[1]
            $STD = ($parts[3] -split "StdDev=")[1]
        }
    }
    
    Write-Host ("{0,-8} {1,-8} {2,-12} {3,-12} {4,-8} {5}" -f $MIN, $MAX, $MEA, $STD, $CURRENT_NODATA, $BASENAME)
}

# Remove auxiliary XML files
Remove-Item "*.tif.aux.xml" -ErrorAction SilentlyContinue