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
├── glosis-api/                     # API (TODO)
|   ├── Dockerfile                  # API container definition
|   ├── src/                        # Your API source code
|   └── requirements.txt            # Python/Node dependencies if applicable

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

1. **GloSIS database**:
   - GLOSIS Database. Based on the [ISRIC implementation](https://github.com/ISRICWorldSoil/iso-28258) with accompaning [documentation](https://iso28258.isric.org/) of the [domain model ISO 28258](https://www.iso.org/standard/44595.html).

2. **API Service**:
   - Create a Dockerfile in `api/` based on your tech stack (Python/Node/etc.)
   - Implement endpoints that connect to PostGIS

3. **pyCSW**:
   - Customize configuration in `md/config/` as needed
   - GeoNetwork will automatically connect to your PostGIS database

4. **MapServer**:
   - Place your mapfiles in `ws/data/mapfiles/`
   - Add spatial data to `ws/data/data/`

5. **Web Mapping**:
   - Build your OpenLayers application in `wm/src/`
   - Configure it to connect to your API and MapServer services

## Deployment Instructions

1. Build and start all services:
   ```bash
   docker-compose up -d --build
   ```

2. Access services:
   - API: `http://localhost:5000` (TODO)
   - PostgreSQL port 5442
   - pyWCS: `http://localhost:8001`
   - Shiny app: `http://localhost:3838`
   - Web Mapping: `http://localhost:1234`
   - MapServer: `http://localhost:8082`

## Best Practices

1. **Version Control**: Add `glosis-db/pgdata/` to your `.gitignore`
2. **Documentation**: Clearly document in README.md how to:
   - Set up the environment
   - Add new data
   - Configure services
3. **Security**: Use proper secrets management for production
4. **Monitoring**: Consider adding health checks to services
5. **Updates**: Regularly update your container images

This structure provides a clean separation of concerns, makes each component independently maintainable, and allows for easy scaling or replacement of individual services.
