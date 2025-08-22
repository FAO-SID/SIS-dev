## This script must be placed within the glosis-datacube folder.

# -------------------------------
# 0. Load libraries and clean workspace
# -------------------------------
library(terra)       # Spatial raster processing
library(tidyverse)   # Data manipulation
library(sf)          # GDAL integration

rm(list = ls())  # Clear environment

# -------------------------------
# 1. Define constants and working directory
# -------------------------------
# ISO code for the country, used in building standardized file names
Country_ISO_code <- "BTN"

# Set the working directory to the folder where this script resides
# (Requires RStudio; uses the script’s own file path)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Set input dir
input_dir <- "BT/input"
tmp_dir <- "BT/tmp"
output_dir <- "BT/output"

# -------------------------------
# 2. DATA CUBE RENAME: Prepare input file listing
# -------------------------------
# List all .tif and .tiff files under “BT/input/”, without the full path
files <- list.files(
  path       = input_dir,
  pattern    = "\\.(tif|tiff)$",
  recursive  = TRUE,
  full.names = FALSE
)

# Split each file path on “/” to separate folder and file name,
# convert to a tibble, and write out to CSV for inspection
str_split(string = files, pattern = "/", simplify = TRUE) %>%
  as_tibble() %>%
  write.csv("list_raster_files.csv", row.names = FALSE)

files <- list.files(
  path       = input_dir,
  pattern    = "\\.(tif|tiff)$",
  recursive  = TRUE,
  full.names = TRUE
)

# -------------------------------
# 3. Read lookup tables and join
# -------------------------------
# Read the data cube table specific to each country
raster_dc <- read_csv("raster_datacube - BTN.csv")

# Read the global-standard naming table for all data cubes
glosis_datacube <- read_csv("raster_datacube - glosis_datacube_names.csv")

# Merge the two tables by their common columns
dat <- left_join(raster_dc, glosis_datacube)

# -------------------------------
# 4. Generate standardized filenames
# -------------------------------
# Create a new column “standard_name” by concatenating:
# country code, initiative, soil property code, year, top and bottom depths, and “.tif”
dat <- dat %>%
  mutate(
    standard_name = paste0(
      Country_ISO_code, "-", 
      initiative, "-", 
      soil_property_code, "-", 
      year, "-", 
      top, "-", 
      bottom, 
      ".tif"
    )
  )

# -------------------------------
# 5. Read rasters and save with standardized names
# -------------------------------

# Loop through each entry in 'dat': read input raster, write with new name
for (i in seq_len(nrow(dat))) {
  # Read the raster file
  r <- rast(files[i])
  
  # Build full output path
  file_out <- file.path(tmp_dir, dat$standard_name[i])
  
  # Write the raster to disk (overwrite if exists)
  writeRaster(r, filename = file_out, overwrite = TRUE)
}


# -------------------------------
# 6. Check raster stats & NoData
# -------------------------------
tif_files <- list.files(tmp_dir, pattern = "\\.(tif|tiff)$", full.names = TRUE)

extract_nodata_value <- function(info_lines) {
  nodata_line <- grep("NoData Value=", info_lines, value = TRUE)
  
  if (length(nodata_line) == 0) {
    return(NA_real_)
  }
  # Extract numeric value, handle scientific notation, e.g., -3.4e+38
  value <- sub(".*NoData Value=([-0-9.eE+]+).*", "\\1", nodata_line[1])
}

# Initialize empty list to store stats
stats_list <- list()

# Loop over files
for (file in tif_files) {
  r <- rast(file)
  
  # Compute statistics
  stats <- global(r, fun = c("min", "max", "mean", "sd"), na.rm = TRUE)
  info_lines <- terra::describe(file)
  nodata_str <- extract_nodata_value(info_lines)
  
  # Store as a row in a list
  stats_list[[file]] <- data.frame(
    File = file,
    Minimum = stats[, "min"],
    Maximum = stats[,"max"],
    Mean = stats[,"mean"],
    StdDev = stats[, "sd"],
    NoData = nodata_str,
    stringsAsFactors = FALSE
  )
  
  # Print the row
  cat(sprintf("%-8.2f %-8.2f %-12.2f %-12.2f %-8s %s\n",
              stats[, "min"], stats[, "max"], stats[, "mean"],stats[, "sd"],
              nodata_str, file))
}

# Combine rows into a data.frame
stats_df <- do.call(rbind, stats_list)
stats_df$NoData <- as.numeric(stats_df$NoData)
stats_df$UpdatedNA <- NA

# View result in R
print(stats_df)

# -------------------------------
# 7. Reclassify NoData values
# -------------------------------
stats_df <- stats_df %>%
  mutate(
    UpdatedNA = case_when(
      (Minimum %in% c(-99, -999, -9999)) & is.na(NoData) ~ -9999,
      Minimum == -3.4e+38 & NoData == -3.4e+38 ~ -9999,
      Minimum < -9999 ~ -3.4e+38,
      Minimum > -9999 & NoData == -3.4e+38 ~ -9999,
      Minimum < -9999 & NoData == -3.4e+38 ~ -3.4e+38,
      Minimum > -9999 & is.na(NoData) ~ -9999,
      TRUE ~ UpdatedNA  # Keep existing value if no condition is met
    )
  )


# Utility: assign NoData value to entire raster
assign_nodata <- function(filename, nodata) {
  r <- rast(filename)
  NAflag(r) <- nodata
  
  tmpfile <- tempfile(fileext = ".tif")
  writeRaster(r, tmpfile, overwrite = TRUE, NAflag = nodata)
  file.rename(tmpfile, filename)
}

# Utility: replace specific pixel value with NoData
replace_value_with_nodata <- function(filename, target_value, nodata) {
  r <- rast(filename)
  r[r == target_value] <- nodata
  NAflag(r) <- nodata
  
  tmpfile <- tempfile(fileext = ".tif")
  writeRaster(r, tmpfile, overwrite = TRUE, NAflag = nodata)
  file.rename(tmpfile, filename)
}
# Ensure UpdatedNA is numeric (in case it was formatted as character)
stats_df$UpdatedNA <- as.numeric(stats_df$UpdatedNA)


# Assign NoData value directly
cat("Assigning NoData ...\n")

# Create the nodata_ops list grouped by UpdatedNA
nodata_ops <- stats_df %>%
  filter(!is.na(UpdatedNA)) %>%  # Exclude rows without a new NoData value
  group_by(UpdatedNA) %>%
  summarise(files = list(File), .groups = "drop") %>%
  mutate(group = purrr::map2(files, UpdatedNA, ~ list(files = .x, value = .y))) %>%
  pull(group)

for (group in nodata_ops) {
  for (file in group$files) {
    assign_nodata(file, group$value)
  }
}


# -------------------------------
# 8. Reproject rasters to EPSG:4326
# -------------------------------
epsg <- "EPSG:4326"

for (file in tif_files) {
  r <- rast(file)
  r_proj <- project(r, epsg, method = "bilinear")
  tmpfile <- tempfile(fileext = ".tif")
  writeRaster(r_proj, tmpfile, overwrite = TRUE)
  file.rename(tmpfile, file)
  print(file)
}

# -------------------------------
# 9. Convert aligned rasters to COG
# -------------------------------
get_extent_info <- function(file) {
  r <- rast(file)                   # convert to SpatRaster
  band_info <- describe(r)[[1]]    # metadata for Band 1
  
  e <- ext(r)
  res_vals <- res(r)
  
  # Extract NoData value safely
  nodata <- NA_real_
  if ("Nodata" %in% names(band_info)) {
    nodata <- as.numeric(band_info["Nodata"])
  }
  
  tibble(
    File = basename(file),
    XMIN = e[1],
    YMIN = e[3],
    XMAX = e[2],
    YMAX = e[4],
    PIXEL_SIZE = mean(res_vals),
    NODATA = nodata
  )
}

extent_table <- dplyr::bind_rows(lapply(tif_files, get_extent_info))

# Print before stats
print(extent_table)

# Compute global extent
global_extent <- extent_table %>%
  summarise(
    XMIN = max(XMIN),
    YMIN = max(YMIN),
    XMAX = min(XMAX),
    YMAX = min(YMAX)
  )

xmin <- global_extent$XMIN
ymin <- global_extent$YMIN
xmax <- global_extent$XMAX
ymax <- global_extent$YMAX

message(sprintf("Computing extent to %f %f %f %f ...", xmin, ymin, xmax, ymax))

# Loop to align and convert to COG
# Define target extent (xmin, ymin, xmax, ymax must be predefined)
target_extent <- ext(xmin, xmax, ymin, ymax)
target_crs <- "EPSG:4326"

# Loop through files
for (file in tif_files) {
  base <- basename(file)
  output_tmp_file <- file.path(tmp_dir, paste0("tmp_", base))
  output_file <- file.path(output_dir, base)
  
  if (str_detect(base, "GSAS|GSOC")) {
    res_target <- extent_table$PIXEL_SIZE[first(grep("GSAS|GSOC", extent_table$File))]
  } else {
    res_target <- extent_table$PIXEL_SIZE[first(grep("GSNM", extent_table$File))]
    
  }
  
  # Load raster
  r <- rast(file)
  
  # Create template raster with target extent, resolution, and CRS
  template <- rast(ext = target_extent, resolution = res_target, crs = target_crs)
  
  # Reproject and align to template
  aligned <- project(r, template, method = "near")
  
  # Save aligned raster
  writeRaster(aligned, output_tmp_file, overwrite = TRUE)
  
  # Add overviews
  #system(sprintf("gdaladdo -q -r nearest '%s'", output_tmp_file))
  
  # Convert to COG
  # system(sprintf(
  #   "gdal_translate -q -of COG -co COMPRESS=DEFLATE -co PREDICTOR=2 '%s' '%s'",
  #   output_tmp_file, output_file
  # ))
  
  gdal_utils(
    util = "translate",
    source = output_tmp_file,
    destination = output_file,
    options = c(
      "-of", "COG",
      "-co", "COMPRESS=DEFLATE",
      "-co", "PREDICTOR=2",
      "-q"
    )
  )
  
  # Clean up
  file.remove(output_tmp_file)
}

output_files <- list.files(output_dir, pattern = "\\.(tif|tiff)$", full.names = TRUE)
extent_table_after <- bind_rows(lapply(output_files, get_extent_info))
print(extent_table_after)

# -------------------------------
# 10. Create VRTs
# -------------------------------
create_vrt <- function(pattern, output_name) {
  matching <- list.files(output_dir, pattern = pattern, full.names = TRUE)
  
  if (length(matching) == 0) {
    warning(sprintf("No files matched pattern: %s", pattern))
    return(invisible(NULL))
  }
  
  gdal_utils(
    util = "buildvrt",
    source = matching,
    destination = file.path(output_dir, paste0(output_name, ".vrt")),
    options = c("-separate", "-q")
  )
}

create_vrt("GSAS.*\\.tif$", "PH-GSAS")
create_vrt("GSOC.*\\.tif$", "PH-GSOC")
create_vrt("GSNM.*\\.tif$", "PH-GSNM")
