import Papa from 'papaparse';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';

// Function to fetch and parse layer info from CSV
export async function fetchLayerInfo() {
    try {
        const response = await fetch('/public/layer_info.csv');
        const csvText = await response.text();
        
        return new Promise((resolve, reject) => {
            Papa.parse(csvText, {
                header: true,
                skipEmptyLines: true,
                complete: (results) => {
                    // Group layers by project_name
                    const groupedLayers = results.data.reduce((acc, layer) => {
                        const group = layer.project_name;
                        if (!acc[group]) {
                            acc[group] = [];
                        }
                        
                        acc[group].push({
                            id: layer.layer_id,
                            name: layer.property_name,
                            metadata_url: layer.metadata_url,
                            download_url: layer.download_url,
                            get_map_url: layer.get_map_url,
                            get_legend_url: layer.get_legend_url,
                            get_feature_info_url: layer.get_feature_info_url,
                            unit: layer.unit_id,
                            depth: layer.dimension_des
                        });
                        
                        return acc;
                    }, {});

                    resolve(groupedLayers);
                },
                error: (error) => {
                    console.error('Error parsing CSV:', error);
                    reject(error);
                }
            });
        });
    } catch (error) {
        console.error('Error loading layer info:', error);
        return {};
    }
}

// Function to create WMS layer
function createWMSLayer(layerId, getMapUrl, featureInfoUrl, unit) {
    // Parse the URL and parameters from getMapUrl
    const url = new URL(getMapUrl);
    const mapFile = url.searchParams.get('map');
    
    const layer = new ImageLayer({
        source: new ImageWMS({
            url: 'http://localhost:8082/',
            params: {
                'map': mapFile,
                'LAYERS': layerId,
                'FORMAT': 'image/png',
                'TRANSPARENT': true
            },
            ratio: 1,
            serverType: 'mapserver'
        })
    });
    
    // Set the layer name and feature info URL
    layer.set('name', layerId);
    layer.set('featureInfoUrl', featureInfoUrl);
    layer.set('unit', unit);
    
    return layer;
}

// Function to create layer configuration
export function createLayerConfig(layerInfo) {
    const config = {};
    
    // Add layer groups in specified order
    const groupOrder = [
        'Soil Profiles',
        'Soil Nutrients',
        'Salt-Affected Soils',
        'Organic Carbon Sequestration Potential'
    ];
    
    groupOrder.forEach(groupName => {
        if (layerInfo[groupName]) {
            config[groupName] = layerInfo[groupName].map(layer => ({
                id: layer.id,
                name: `${layer.name}${layer.depth ? ` (${layer.depth})` : ''}${layer.unit ? ` [${layer.unit}]` : ''}`,
                metadata_url: layer.metadata_url,
                download_url: layer.download_url,
                layer: createWMSLayer(layer.id, layer.get_map_url, layer.get_feature_info_url, layer.unit)
            }));
        }
    });
    
    return config;
} 