# GloSIS - Global Soil Information System

GloSIS software stack structure:

## Project Structure

```
GloSIS/
├── .env                            # Environment variables
├── .gitignore                      # gitignore
├── deploy.sh                       # Instructions
├── docker-compose.yml              # Main composition file
├── LICENSE                         # License manifest
├── README.md                       # Project documentation
│
├── glosis-datacube/                # Raster Data Cube (GDAL)
│   └── PH/                         # Philippines case
│       ├── data_cube_1_rename.sh   # Rename files acording naming convention <country>-<project>-<property>-<year>-<top>-<bottom>
│       ├── data_cube_2_check.sh    # Print out raster stats and NoData
│       ├── data_cube_3_nodata.sh   # Fix NoData
│       ├── data_cube_4_epsg.sh     # Set the same EPSG for all rasters
│       └── data_cube_5_cog.sh      # Set the same BBox for all rasters and converts them into Cloud Optmized GeoTIFFs
│
├── glosis-db/                      # Database (DONE)
│   ├── Changes/                    # All changes made since fork
│   └── pgdata/                     # Persistent data (added to .gitignore)
│
├── glosis-md/                      # GeoNetwork metadata catalog (DONE)
│   ├── records/                    # Metadata records in XML
|   └── pycsw.yml                    # Configuration file
|
├── glosis-shiny/                   # Shiny app to help with ingest soil profile data into PostgreSQL (DONE)
│   ├── init-scripts/               # Init scripts
│   └── test_data/                  # Test data
│
├── glosis-wm/                      # Web mapping (DONE)
|   ├── dist                        # Node distro
|   ├── node_modules                # Mode modules
|   ├── .parcel-cache               # Cache
|   ├── deploy.sh                   # Instructions
|   ├── Dockerfile                  # Web mapping container definition
|   ├── index.html                  # HTML index file
|   ├── logo.png                    # Logo image
|   ├── main.js                     # OpenLayers js code
|   ├── package.json                # Dependencies
|   └── .gitignore                  # gitignore
│
└── glosis-ws/                      # MapServer (DONE)
    └── data/                       # GeoTIFFs and mapfiles
```

## Docker Compose File

docker-compose.yml ties everything together:

## Environment File (`.env`)

Create a `.env` file in your project root:


## Implementation Steps

1. **Database - PostgreSQL**:
   - PostgreSQL Database. Originally based on the [ISRIC implementation](https://github.com/ISRICWorldSoil/iso-28258) of the [domain model ISO 28258](https://www.iso.org/standard/44595.html).

2. **Metadata catalogue - pyCSW**:
   - Customize configuration in `md/config/` as needed
   - GeoNetwork will automatically connect to your PostGIS database

3. **Web-services - MapServer**:
   - Place your mapfiles in `ws/data/mapfiles/`
   - Add spatial data to `ws/data/data/`

4. **Web-mapping - Openlayers**:
   - Build your OpenLayers application in `wm/src/`
   - Configure it to connect to your API and MapServer services

5. **Soil data upload tool - Shiny server**:


## Deployment Instructions

Follow the steps detail in file [deploy.sh](https://github.com/FAO-SID/GloSIS/blob/main/deploy.sh) (linux) or [deploy.ps1](https://github.com/FAO-SID/GloSIS/blob/main/deploy.ps1) (windows)

