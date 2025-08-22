#!/usr/bin/env pwsh

###############################################
#       Cloud Optimized GeoTIFF - COG         #
###############################################

# Input and output directories
$INPUT_DIR = "C:\home\carva014\Work\Code\FAO\GloSIS\glosis-datacube\BT\tmp"                   # << EDIT THIS LINE!
$OUTPUT_DIR = "C:\home\carva014\Work\Code\FAO\GloSIS\glosis-datacube\BT\output"               # << EDIT THIS LINE!
Set-Location $INPUT_DIR

# Create output directory if it doesn't exist
if (!(Test-Path $OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path $OUTPUT_DIR -Force
}

# Initialize variables for overall extent
$XMIN = [double]::PositiveInfinity
$YMIN = [double]::PositiveInfinity
$XMAX = [double]::NegativeInfinity
$YMAX = [double]::NegativeInfinity

# Loop through all GeoTIFFs to compute overall extent
Write-Host "########################"
Write-Host "#        Before        #"
Write-Host "########################"
Write-Host ("{0,-15} {1,-15} {2,-15} {3,-15} {4,-20} {5,-15} {6}" -f "XMIN", "YMIN", "XMAX", "YMAX", "PIXEL_SIZE", "NODATA", "File")

Get-ChildItem -Filter "*.tif" | ForEach-Object {
    $FILE = $_.Name
    $BASENAME = $_.BaseName
    
    # Get gdalinfo output
    $gdalInfoOutput = & gdalinfo $FILE
    
    # Extract extent values using regex
    $upperLeftLine = $gdalInfoOutput | Select-String "Upper Left"
    $lowerRightLine = $gdalInfoOutput | Select-String "Lower Right"
    $pixelSizeLine = $gdalInfoOutput | Select-String "Pixel Size"
    $noDataLine = $gdalInfoOutput | Select-String "NoData Value="
    
    if ($upperLeftLine -and $lowerRightLine -and $pixelSizeLine) {
        # Extract coordinates from Upper Left and Lower Right
        $upperLeftCoords = [regex]::Match($upperLeftLine, '\(\s*([+-]?\d+\.?\d*),\s*([+-]?\d+\.?\d*)\)')
        $lowerRightCoords = [regex]::Match($lowerRightLine, '\(\s*([+-]?\d+\.?\d*),\s*([+-]?\d+\.?\d*)\)')
        $pixelSizeMatch = [regex]::Match($pixelSizeLine, '\(\s*([+-]?\d+\.?\d*),')
        
        if ($upperLeftCoords.Success -and $lowerRightCoords.Success) {
            $CURRENT_XMIN = [double]$upperLeftCoords.Groups[1].Value
            $CURRENT_YMAX = [double]$upperLeftCoords.Groups[2].Value
            $CURRENT_XMAX = [double]$lowerRightCoords.Groups[1].Value
            $CURRENT_YMIN = [double]$lowerRightCoords.Groups[2].Value
            $CURRENT_PIXEL_SIZE = if ($pixelSizeMatch.Success) { $pixelSizeMatch.Groups[1].Value } else { "N/A" }
            
            $CURRENT_NODATA = if ($noDataLine) { 
                ($noDataLine -split "NoData Value=")[1].Trim()
            } else { 
                "N/A" 
            }
            
            Write-Host ("{0,-15} {1,-15} {2,-15} {3,-15} {4,-20} {5,-15} {6}" -f $CURRENT_XMIN, $CURRENT_YMIN, $CURRENT_XMAX, $CURRENT_YMAX, $CURRENT_PIXEL_SIZE, $CURRENT_NODATA, $BASENAME)
            
            # Update overall extent
            $XMIN = [Math]::Max($CURRENT_XMIN, $XMIN)
            $YMIN = [Math]::Max($CURRENT_YMIN, $YMIN)
            $XMAX = [Math]::Min($CURRENT_XMAX, $XMAX)
            $YMAX = [Math]::Min($CURRENT_YMAX, $YMAX)
        }
    }
}

Write-Host ""
Write-Host "Computing extent to $XMIN $YMIN $XMAX $YMAX ..."
Write-Host ""

# Loop through all GeoTIFFs to align them and convert them into COG's
Get-ChildItem -Filter "*.tif" | ForEach-Object {
    $FILE = $_.Name
    $BASENAME = $_.BaseName
    $OUTPUT_TMP_FILE = Join-Path $OUTPUT_DIR "tmp_$($_.Name)"
    $OUTPUT_FILE = Join-Path $OUTPUT_DIR $_.Name
    
    # Set resolution based on filename
    if ($BASENAME -match "GSNM|OTHER") {
        $XRES = 0.00225  # 250 meters in degrees
        $YRES = 0.00225  # 250 meters in degrees
    } else {
        $XRES = 0.009    # 1000 meters in degrees
        $YRES = 0.009    # 1000 meters in degrees
    }
    
    Write-Host "Processing: $FILE"
    
    # Align GeoTIFFs
    & gdalwarp -q -r near -tr $XRES $YRES -te $XMIN $YMIN $XMAX $YMAX $FILE $OUTPUT_TMP_FILE
    
    if ($LASTEXITCODE -eq 0) {
        # Overviews
        & gdaladdo -q -r nearest $OUTPUT_TMP_FILE
        
        # Tiling and indexing
        & gdal_translate -q -of COG -co COMPRESS=DEFLATE -co PREDICTOR=2 $OUTPUT_TMP_FILE $OUTPUT_FILE
        
        # Remove tmp files
        Remove-Item $OUTPUT_TMP_FILE -ErrorAction SilentlyContinue
    } else {
        Write-Error "Failed to process $FILE"
        if (Test-Path $OUTPUT_TMP_FILE) {
            Remove-Item $OUTPUT_TMP_FILE -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "########################"
Write-Host "#        After         #"
Write-Host "########################"
Write-Host ("{0,-15} {1,-15} {2,-15} {3,-15} {4,-20} {5,-15} {6}" -f "XMIN", "YMIN", "XMAX", "YMAX", "PIXEL_SIZE", "NODATA", "File")

# Loop through final COGs
Get-ChildItem -Path $OUTPUT_DIR -Filter "*.tif" | ForEach-Object {
    $FILE = $_.FullName
    $BASENAME = $_.BaseName
    
    # Get gdalinfo output
    $gdalInfoOutput = & gdalinfo $FILE
    
    # Extract extent values using regex
    $upperLeftLine = $gdalInfoOutput | Select-String "Upper Left"
    $lowerRightLine = $gdalInfoOutput | Select-String "Lower Right"
    $pixelSizeLine = $gdalInfoOutput | Select-String "Pixel Size"
    $noDataLine = $gdalInfoOutput | Select-String "NoData Value="
    
    if ($upperLeftLine -and $lowerRightLine -and $pixelSizeLine) {
        # Extract coordinates from Upper Left and Lower Right
        $upperLeftCoords = [regex]::Match($upperLeftLine, '\(\s*([+-]?\d+\.?\d*),\s*([+-]?\d+\.?\d*)\)')
        $lowerRightCoords = [regex]::Match($lowerRightLine, '\(\s*([+-]?\d+\.?\d*),\s*([+-]?\d+\.?\d*)\)')
        $pixelSizeMatch = [regex]::Match($pixelSizeLine, '\(\s*([+-]?\d+\.?\d*),')
        
        if ($upperLeftCoords.Success -and $lowerRightCoords.Success) {
            $CURRENT_XMIN = [double]$upperLeftCoords.Groups[1].Value
            $CURRENT_YMAX = [double]$upperLeftCoords.Groups[2].Value
            $CURRENT_XMAX = [double]$lowerRightCoords.Groups[1].Value
            $CURRENT_YMIN = [double]$lowerRightCoords.Groups[2].Value
            $CURRENT_PIXEL_SIZE = if ($pixelSizeMatch.Success) { $pixelSizeMatch.Groups[1].Value } else { "N/A" }
            
            $CURRENT_NODATA = if ($noDataLine) { 
                ($noDataLine -split "NoData Value=")[1].Trim()
            } else { 
                "N/A" 
            }
            
            Write-Host ("{0,-15} {1,-15} {2,-15} {3,-15} {4,-20} {5,-15} {6}" -f $CURRENT_XMIN, $CURRENT_YMIN, $CURRENT_XMAX, $CURRENT_YMAX, $CURRENT_PIXEL_SIZE, $CURRENT_NODATA, $BASENAME)
        }
    }
}

# Create VRTs
Set-Location $OUTPUT_DIR

# Create GSAS VRT
$gsasFiles = Get-ChildItem -Filter "*GSAS*.tif" | Select-Object -ExpandProperty Name
if ($gsasFiles.Count -gt 0) {
    $gsasFiles | Out-File -FilePath "filelist.txt" -Encoding ASCII
    & gdalbuildvrt -q -separate -input_file_list filelist.txt PH-GSAS.vrt
    Remove-Item "filelist.txt" -ErrorAction SilentlyContinue
}

# Create GSOC VRT
$gsocFiles = Get-ChildItem -Filter "*GSOC*.tif" | Select-Object -ExpandProperty Name
if ($gsocFiles.Count -gt 0) {
    $gsocFiles | Out-File -FilePath "filelist.txt" -Encoding ASCII
    & gdalbuildvrt -q -separate -input_file_list filelist.txt PH-GSOC.vrt
    Remove-Item "filelist.txt" -ErrorAction SilentlyContinue
}

# Create GSNM VRT
$gsnmFiles = Get-ChildItem -Filter "*GSNM*.tif" | Select-Object -ExpandProperty Name
if ($gsnmFiles.Count -gt 0) {
    $gsnmFiles | Out-File -FilePath "filelist.txt" -Encoding ASCII
    & gdalbuildvrt -q -separate -input_file_list filelist.txt PH-GSNM.vrt
    Remove-Item "filelist.txt" -ErrorAction SilentlyContinue
}