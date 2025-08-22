# SIS Web Mapping Application

A web-mapping application for visualizing of soil data.

## Features

- Interactive map interface using OpenLayers
- Layer switcher with collapsible groups:
  - Soil Profiles (point data)
  - Soil Nutrients
  - Salt-Affected Soils
  - Organic Carbon Sequestration Potential
  - Base Maps (ESRI Imagery, OpenStreetMap, Open Terrain)
- Layer opacity control
- Zoom controls and scale bar
- Mobile-friendly interface
- Metadata and download links for each layer

## Prerequisites

- Node.js 18 or higher
- npm 8 or higher
- Docker (optional, for containerized deployment)

## Development Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd sis-web-mapping
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Open your browser and navigate to `http://localhost:1234`

## Building for Production

1. Build the application:
   ```bash
   npm run build
   ```

2. The built files will be in the `dist` directory

## Docker Deployment

1. Build the Docker image:
   ```bash
   docker build -t sis-web-mapping .
   ```

2. Run the container:
   ```bash
   docker run -p 1234:1234 sis-web-mapping
   ```

3. Access the application at `http://localhost:1234`

## Project Structure

```
sis-web-mapping/
├── src/
│   ├── index.html
│   ├── js/
│   │   ├── main.js
│   │   └── layers.js
│   └── styles/
│       └── main.css
├── public/
│   └── assets/
│       ├── metadata-icon.svg
│       └── download-icon.svg
├── package.json
├── Dockerfile
└── README.md
```

## Layer Configuration

The application reads layer information from a CSV file with the following columns:
- project_name: Layer group name
- layer_id: Unique identifier for the layer
- property_id: Soil property code
- property_name: Display name of the soil property
- unit_id: Unit of measurement
- dimension_des: Soil depth information
- metadata_url: Link to layer metadata
- download_url: Link to download the layer data
- get_map_url: WMS GetMap request URL
- get_legend_url: WMS GetLegendGraphic request URL
- get_feature_info_url: WMS GetFeatureInfo request URL

## Development Guidelines

1. Use `npm start` for development with hot reloading
2. Run `npm run clean` to clear the build cache if needed
3. Test the application on different devices and screen sizes
4. Ensure all layer services are accessible before deployment

## License

ISC License 