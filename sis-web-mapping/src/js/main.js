import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import { Tile as TileLayer, Image as ImageLayer, Vector as VectorLayer } from 'ol/layer';
import { OSM, XYZ, ImageWMS, Vector as VectorSource, Cluster } from 'ol/source';
import { fromLonLat } from 'ol/proj';
import { fromLonLat, toLonLat } from 'ol/proj';
import { ScaleLine, defaults as defaultControls } from 'ol/control';
import Overlay from 'ol/Overlay';
import { Circle as CircleStyle, Fill, Stroke, Style, Text } from 'ol/style';
import { GeoJSON } from 'ol/format';
import api, { MAPSERVER_URL } from './api-client.js';
import adminDashboard from './admin-dashboard.js';

// Global variables
let map;
let appConfig = {};
let currentLayers = {};
let profileLayers = {};
let profileColors = {};
let activeLayer = null;

// ==================== Initialization ====================

async function initializeApp() {
  try {
    console.log('Starting application initialization...');
    showLoading(true);

    // Load settings from API
    console.log('Fetching settings...');
    const settings = await api.getSettings();
    console.log('Settings loaded:', settings);
    appConfig = settingsArrayToObject(settings);

    // Apply settings to UI
    applySettings();

    // Initialize map
    console.log('Initializing map...');
    initializeMap();

    // Load layers from API
    console.log('Loading layers...');
    await loadLayers();

    // Load profiles
    console.log('Loading profiles...');
    await loadProfiles();

    // Setup UI controls
    setupControls();

    // Check if user is logged in
    // if (api.restoreSession()) {
    //   showAdminPanel();
    // }
    api.restoreSession();

    console.log('Application initialized successfully!');
    showLoading(false);
  } catch (error) {
    console.error('Failed to initialize app:', error);
    console.error('Error details:', error.message, error.stack);
    showError(`Failed to load application: ${error.message}`);
    showLoading(false);
  }
}

function settingsArrayToObject(settingsArray) {
  const config = {};
  settingsArray.forEach(s => config[s.key] = s.value);
  return config;
}

function applySettings() {
  // Update logo
  if (appConfig.ORG_LOGO_URL) {
    document.querySelector('.header .logo').src = appConfig.ORG_LOGO_URL;
  }

  // Update title
  if (appConfig.APP_TITLE) {
    document.querySelector('.header h1').textContent = appConfig.APP_TITLE;
    document.title = appConfig.APP_TITLE;
  }
}

// ==================== Map Initialization ====================

function initializeMap() {
  const latitude = parseFloat(appConfig.LATITUDE || 27.5);
  const longitude = parseFloat(appConfig.LONGITUDE || 89.7);
  const zoom = parseInt(appConfig.ZOOM || 9);

  // Base layers
  const baseLayers = {
    'esri-imagery': new TileLayer({
      source: new XYZ({
        url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attributions: 'Tiles © Esri'
      }),
      visible: appConfig.BASE_MAP_DEFAULT === 'esri-imagery'
    }),
    'osm': new TileLayer({
      source: new OSM(),
      visible: appConfig.BASE_MAP_DEFAULT === 'osm'
    }),
    'terrain': new TileLayer({
      source: new XYZ({
        url: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
        attributions: '© OpenTopoMap'
      }),
      visible: appConfig.BASE_MAP_DEFAULT === 'terrain'
    })
  };

  map = new Map({
    target: 'map',
    layers: Object.values(baseLayers),
    view: new View({
      center: fromLonLat([longitude, latitude]),
      zoom: zoom
    }),
    controls: defaultControls({ 
      attribution: false,
      zoom: false  // Add this to remove default zoom controls
    }).extend([
      new ScaleLine({ target: 'scale-line' })
    ])
  });

  // Store base layers for later use
  map.set('baseLayers', baseLayers);

  // Setup popup
  setupPopup();
}

// ==================== Layer Loading ====================

async function loadLayers() {
  try {
    const layers = await api.getLayers();
    
    // Group layers by project_name
    const groupedLayers = layers.reduce((acc, layer) => {
      const group = layer.project_name || 'Ungrouped';
      if (!acc[group]) {
        acc[group] = [];
      }
      acc[group].push(layer);
      return acc;
    }, {});

    // Create layer groups in UI
    const layerGroupsContainer = document.getElementById('layer-groups');
    layerGroupsContainer.innerHTML = '';

    // Add base maps group first
    addBaseMapsGroup(layerGroupsContainer);

    // Add data layer groups
    for (const [groupName, groupLayers] of Object.entries(groupedLayers)) {
      addLayerGroup(layerGroupsContainer, groupName, groupLayers);
    }

    // Load default layer if specified in settings
    if (appConfig.LAYER_DEFAULT) {
      const defaultLayer = layers.find(l => l.layer_id === appConfig.LAYER_DEFAULT);
      if (defaultLayer) {
        // Check the radio button
        const radio = document.getElementById(`layer-${defaultLayer.layer_id}`);
        if (radio) {
          radio.checked = true;
          // Load the layer
          switchLayer(defaultLayer);
        }
      }
    }

  } catch (error) {
    console.error('Failed to load layers:', error);
    showError('Failed to load layers from API');
  }
}

function addBaseMapsGroup(container) {
  const groupDiv = document.createElement('div');
  groupDiv.className = 'layer-group';
  groupDiv.innerHTML = `
    <div class="layer-group-header">Base Maps</div>
    <div class="layer-group-content">
      <div class="layer-item">
        <input type="radio" name="basemap" id="basemap-esri" value="esri-imagery" 
               ${appConfig.BASE_MAP_DEFAULT === 'esri-imagery' ? 'checked' : ''}>
        <label for="basemap-esri">ESRI Imagery</label>
      </div>
      <div class="layer-item">
        <input type="radio" name="basemap" id="basemap-osm" value="osm"
               ${appConfig.BASE_MAP_DEFAULT === 'osm' ? 'checked' : ''}>
        <label for="basemap-osm">OpenStreetMap</label>
      </div>
      <div class="layer-item">
        <input type="radio" name="basemap" id="basemap-terrain" value="terrain"
               ${appConfig.BASE_MAP_DEFAULT === 'terrain' ? 'checked' : ''}>
        <label for="basemap-terrain">Terrain</label>
      </div>
    </div>
  `;

  container.appendChild(groupDiv);

  // Add event listeners for basemap switching
  groupDiv.querySelectorAll('input[name="basemap"]').forEach(radio => {
    radio.addEventListener('change', (e) => {
      switchBasemap(e.target.value);
    });
  });

  // Make group collapsible
  groupDiv.classList.add('collapsed');
  groupDiv.querySelector('.layer-group-header').addEventListener('click', () => {
    groupDiv.classList.toggle('collapsed');
  });
}

function addLayerGroup(container, groupName, layers) {
  const groupDiv = document.createElement('div');
  groupDiv.className = 'layer-group';
  
  const headerDiv = document.createElement('div');
  headerDiv.className = 'layer-group-header';
  headerDiv.textContent = groupName;
  groupDiv.appendChild(headerDiv);

  const contentDiv = document.createElement('div');
  contentDiv.className = 'layer-group-content';

  layers.forEach(layer => {
    const layerItem = createLayerItem(layer);
    contentDiv.appendChild(layerItem);
  });

  groupDiv.appendChild(contentDiv);
  container.appendChild(groupDiv);

  // Make group collapsible
  groupDiv.classList.add('collapsed');
  headerDiv.addEventListener('click', () => {
    groupDiv.classList.toggle('collapsed');
  });
}

function createLayerItem(layer) {
  const itemDiv = document.createElement('div');
  itemDiv.className = 'layer-item';
  
  const layerName = layer.dimension 
    ? `${layer.property_name} (${layer.dimension})`
    : layer.property_name;

  itemDiv.innerHTML = `
    <input type="radio" name="data-layer" id="layer-${layer.layer_id}" value="${layer.layer_id}">
    <label for="layer-${layer.layer_id}" title="${layerName}">${layerName}</label>
    <div class="layer-icons">
      ${layer.metadata_url ? `<a href="#" class="metadata-link" data-url="${layer.metadata_url}" title="Metadata"><img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23666'%3E%3Cpath d='M13 9h-2V7h2m0 10h-2v-6h2m-1-9A10 10 0 0 0 2 12a10 10 0 0 0 10 10 10 10 0 0 0 10-10A10 10 0 0 0 12 2z'/%3E%3C/svg%3E" alt="Info"></a>` : ''}
      ${layer.download_url ? `<a href="${layer.download_url}" title="Download"><img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23666'%3E%3Cpath d='M5 20h14v-2H5m14-9h-4V3H9v6H5l7 7 7-7z'/%3E%3C/svg%3E" alt="Download"></a>` : ''}
    </div>
  `;

  const radio = itemDiv.querySelector('input[type="radio"]');
  radio.addEventListener('change', (e) => {
    if (e.target.checked) {
      switchLayer(layer);
    }
  });

  // Add metadata link handler
  const metadataLink = itemDiv.querySelector('.metadata-link');
  if (metadataLink) {
    metadataLink.addEventListener('click', async (e) => {
      e.preventDefault();
      const metadataUrl = e.currentTarget.dataset.url;
      await showMetadataPopup(metadataUrl);
    });
  }

  return itemDiv;
}

function switchBasemap(basemapId) {
  const baseLayers = map.get('baseLayers');
  Object.entries(baseLayers).forEach(([id, layer]) => {
    layer.setVisible(id === basemapId);
  });
}

function switchLayer(layerConfig) {
  // Remove currently active layer
  if (activeLayer) {
    map.removeLayer(activeLayer);
    document.getElementById('legend').style.display = 'none';
  }

  // Create and add new layer
  const layer = createWMSLayer(layerConfig);
  map.addLayer(layer);
  activeLayer = layer;

  // Show legend if available
  if (layerConfig.get_legend_url) {
    showLegend(layerConfig.get_legend_url);
  }

  // Store current layer config
  currentLayers[layerConfig.layer_id] = layerConfig;
}

function createWMSLayer(layerConfig) {
  // Parse the get_map_url to extract the map parameter
  let mapParam = null;
  
  if (layerConfig.get_map_url) {
    try {
      const url = new URL(layerConfig.get_map_url);
      mapParam = url.searchParams.get('map');
    } catch (e) {
      console.warn('Could not parse get_map_url:', layerConfig.get_map_url);
    }
  }

  // MapServer base URL
  const mapServerUrl = MAPSERVER_URL;
  
  const params = {
    'LAYERS': layerConfig.layer_id,
    'FORMAT': 'image/png',
    'TRANSPARENT': true
  };

  // Add map parameter if found
  if (mapParam) {
    params['map'] = mapParam;
  }

  const layer = new ImageLayer({
    source: new ImageWMS({
      url: mapServerUrl,
      params: params,
      ratio: 1,
      serverType: 'mapserver'
    })
  });

  layer.set('layerId', layerConfig.layer_id);
  layer.set('featureInfoUrl', layerConfig.get_feature_info_url);
  
  return layer;
}


// ==================== Metadata ====================

function formatMetadata(metadata) {
  let html = '';
  
  // Title
  if (metadata.properties?.title) {
    html += `<h3 style="margin-top: 0; color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px;">${metadata.properties.title}</h3>`;
  }
  
  // Description
  if (metadata.properties?.description) {
    html += `<div style="margin: 15px 0; padding: 10px; background: #f8f9fa; border-left: 3px solid #3498db; border-radius: 3px;">
      <strong>Description:</strong><br/>
      <p style="margin: 8px 0 0 0; line-height: 1.6;">${metadata.properties.description}</p>
    </div>`;
  }
  
  // Basic Information
  html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Basic Information</h4>';
  html += '<table style="width: 100%; border-collapse: collapse;">';
  
  const basicInfo = [
    { label: 'Type', value: metadata.properties?.type },
    { label: 'Language', value: metadata.properties?.language },
    { label: 'Created', value: metadata.properties?.created },
    { label: 'Updated', value: metadata.properties?.updated },
    { label: 'ID', value: metadata.id }
  ];
  
  basicInfo.forEach(item => {
    if (item.value) {
      html += `<tr style="border-bottom: 1px solid #eee;">
        <td style="padding: 8px; font-weight: bold; width: 30%; color: #555;">${item.label}:</td>
        <td style="padding: 8px;">${item.value}</td>
      </tr>`;
    }
  });
  html += '</table></div>';
  
  // Keywords
  if (metadata.properties?.keywords && metadata.properties.keywords.length > 0) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Keywords</h4>';
    html += '<div style="display: flex; flex-wrap: wrap; gap: 8px;">';
    metadata.properties.keywords.forEach(keyword => {
      html += `<span style="background: #e8f4f8; color: #2980b9; padding: 5px 12px; border-radius: 15px; font-size: 13px;">${keyword}</span>`;
    });
    html += '</div></div>';
  }
  
  // Themes
  if (metadata.properties?.themes && metadata.properties.themes.length > 0) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Themes</h4>';
    metadata.properties.themes.forEach(theme => {
      if (theme.concepts && theme.concepts.length > 0) {
        html += `<div style="margin-bottom: 10px; padding: 8px; background: #f8f9fa; border-radius: 3px;">`;
        if (theme.scheme) {
          html += `<div style="font-size: 12px; color: #666; margin-bottom: 5px;">${theme.scheme}</div>`;
        }
        theme.concepts.forEach(concept => {
          html += `<span style="background: #fff; border: 1px solid #ddd; padding: 4px 10px; border-radius: 3px; margin-right: 8px; display: inline-block; margin-bottom: 5px;">${concept.id}</span>`;
        });
        html += '</div>';
      }
    });
    html += '</div>';
  }
  
  // Contacts
  if (metadata.properties?.contacts && metadata.properties.contacts.length > 0) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Contacts</h4>';
    metadata.properties.contacts.forEach((contact, index) => {
      html += `<div style="margin-bottom: 15px; padding: 12px; background: #f8f9fa; border-radius: 5px; border-left: 3px solid #27ae60;">`;
      if (contact.name) html += `<div style="font-weight: bold; color: #2c3e50; margin-bottom: 5px;">${contact.name}</div>`;
      if (contact.organization) html += `<div style="margin-bottom: 3px;"><strong>Organization:</strong> ${contact.organization}</div>`;
      if (contact.position) html += `<div style="margin-bottom: 3px;"><strong>Position:</strong> ${contact.position}</div>`;
      if (contact.roles && contact.roles.length > 0) html += `<div style="margin-bottom: 3px;"><strong>Role:</strong> ${contact.roles.join(', ')}</div>`;
      if (contact.emails && contact.emails.length > 0 && contact.emails[0].value) {
        html += `<div style="margin-bottom: 3px;"><strong>Email:</strong> <a href="mailto:${contact.emails[0].value}" style="color: #3498db;">${contact.emails[0].value}</a></div>`;
      }
      if (contact.addresses && contact.addresses.length > 0) {
        const addr = contact.addresses[0];
        let addressParts = [];
        if (addr.deliveryPoint && addr.deliveryPoint.length > 0) addressParts.push(addr.deliveryPoint.join(', '));
        if (addr.city) addressParts.push(addr.city);
        if (addr.postalCode) addressParts.push(addr.postalCode);
        if (addr.country) addressParts.push(addr.country);
        if (addressParts.length > 0) {
          html += `<div style="margin-top: 5px; font-size: 13px; color: #555;">${addressParts.join(', ')}</div>`;
        }
      }
      html += '</div>';
    });
    html += '</div>';
  }
  
  // Geometry/Extent
  if (metadata.geometry) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Spatial Extent</h4>';
    if (metadata.geometry.type === 'Polygon' && metadata.geometry.coordinates) {
      const coords = metadata.geometry.coordinates[0];
      const [minLon, minLat] = coords[0];
      const [maxLon, maxLat] = coords[2];
      html += `<div style="padding: 10px; background: #f8f9fa; border-radius: 3px; font-family: monospace; font-size: 13px;">
        West: ${minLon}° | East: ${maxLon}°<br/>
        South: ${minLat}° | North: ${maxLat}°
      </div>`;
    }
    html += '</div>';
  }
  
  // Time Period
  if (metadata.time?.interval) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Temporal Extent</h4>';
    html += `<div style="padding: 10px; background: #f8f9fa; border-radius: 3px;">
      From: <strong>${metadata.time.interval[0]}</strong> to <strong>${metadata.time.interval[1]}</strong>
    </div></div>`;
  }
  
  // Formats
  if (metadata.properties?.formats && metadata.properties.formats.length > 0) {
    html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Available Formats</h4>';
    html += '<div style="display: flex; flex-wrap: wrap; gap: 8px;">';
    metadata.properties.formats.forEach(format => {
      html += `<span style="background: #e8f4f8; padding: 5px 12px; border-radius: 3px; font-size: 13px; border: 1px solid #3498db;">${format.name}</span>`;
    });
    html += '</div></div>';
  }
  
  // Links
  if (metadata.links && metadata.links.length > 0) {
    // Filter out 'preview' - only keep 'information' and 'download'
    const dataLinks = metadata.links.filter(link => 
      link.rel === 'information' || link.rel === 'download'
    );
    
    if (dataLinks.length > 0) {
      html += '<div style="margin: 20px 0;"><h4 style="color: #2c3e50; margin-bottom: 10px;">Data Access Links</h4>';
      html += '<div style="display: flex; flex-direction: column; gap: 8px;">';
      
      dataLinks.forEach(link => {
        // Removed preview emoji - only download and information
        const linkType = link.rel === 'download' ? '📥' : '🔗';
        const linkName = link.name || link.title || link.rel;
        html += `<a href="${link.href}" target="_blank" style="padding: 10px; background: #fff; border: 1px solid #ddd; border-radius: 5px; text-decoration: none; color: #2c3e50; display: flex; align-items: center; gap: 10px; transition: all 0.2s;" 
          onmouseover="this.style.background='#f0f0f0'; this.style.borderColor='#3498db';"
          onmouseout="this.style.background='#fff'; this.style.borderColor='#ddd';">
          <span style="font-size: 20px;">${linkType}</span>
          <div style="flex: 1;">
            <div style="font-weight: bold;">${linkName}</div>
            ${link.protocol ? `<div style="font-size: 12px; color: #666;">${link.protocol}</div>` : ''}
          </div>
        </a>`;
      });
      
      html += '</div></div>';
  }
}

  
  return html;
}


function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}


async function showMetadataPopup(metadataUrl) {
  // Create modal overlay
  const modal = document.createElement('div');
  modal.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 10000; display: flex; align-items: center; justify-content: center; padding: 20px;';
  
  modal.innerHTML = `
    <div style="background: white; padding: 20px; border-radius: 8px; max-width: 800px; max-height: 90vh; overflow-y: auto; position: relative; width: 100%;">
      <button id="metadata-close" style="position: absolute; top: 10px; right: 10px; background: none; border: none; font-size: 24px; cursor: pointer; color: #666;">&times;</button>
      <h2 style="margin-top: 0;">Metadata</h2>
      <div id="metadata-content" style="margin-top: 20px;">Loading...</div>
    </div>
  `;
  
  document.body.appendChild(modal);
  
  // Close button handler
  document.getElementById('metadata-close').addEventListener('click', () => {
    document.body.removeChild(modal);
  });
  
  // Close on background click
  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      document.body.removeChild(modal);
    }
  });
  
  // Fetch metadata
  try {
    // Handle both relative and absolute URLs
    let jsonUrl;
    if (metadataUrl.startsWith('http://') || metadataUrl.startsWith('https://')) {
      // Absolute URL - parse and remove port to go through nginx
      const url = new URL(metadataUrl);
      jsonUrl = `http://${url.hostname}${url.pathname}?f=json`;
    } else {
      // Relative URL - just append ?f=json
      jsonUrl = `${metadataUrl}?f=json`;
    }
    
    console.log('Original URL:', metadataUrl);
    console.log('Fetching metadata from:', jsonUrl);
    
    const response = await fetch(jsonUrl);
    const contentType = response.headers.get('content-type');
    
    console.log('Response content-type:', contentType);
    console.log('Response status:', response.status);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    // Always try to parse as JSON first, regardless of content-type
    const text = await response.text();
    
    try {
      // Try to parse as JSON
      const metadata = JSON.parse(text);
      console.log('Metadata received:', metadata);
      
      // Format and display
      const content = formatMetadata(metadata);
      document.getElementById('metadata-content').innerHTML = content;
      
    } catch (jsonError) {
      // Not valid JSON - display as text
      console.log('Response is not valid JSON, displaying as text');
      console.log('Response text:', text.substring(0, 200));
      
      document.getElementById('metadata-content').innerHTML = `
        <div style="background: #f8f8f8; padding: 15px; border-radius: 4px; overflow-x: auto;">
          <pre style="white-space: pre-wrap; word-wrap: break-word; font-size: 12px;">${escapeHtml(text)}</pre>
        </div>
      `;
    }
    
  } catch (error) {
    console.error('Failed to load metadata:', error);
    document.getElementById('metadata-content').innerHTML = `
      <p style="color: red;">Failed to load metadata: ${error.message}</p>
      <p>URL attempted: ${metadataUrl}?f=json</p>
      <p><a href="${metadataUrl}" target="_blank">Open metadata in new tab</a></p>
    `;
  }
}


// ==================== Profile Layer ====================

function generateProjectColors(projectNames) {
  const colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', 
    '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2',
    '#F8B739', '#52B788', '#E63946', '#457B9D'
  ];
  
  const projectColors = {};
  projectNames.forEach((name, index) => {
    projectColors[name] = colors[index % colors.length];
  });
  
  return projectColors;
}


async function loadProfiles() {
  try {
    const profiles = await api.getProfiles();
    
    if (!profiles || profiles.length === 0) {
      console.log('No profiles found in database');
      return;
    }

    console.log('Loading profiles:', profiles.length);
    console.log('First profile sample:', profiles[0]);
    
    // Get unique project names
    const projectNames = [...new Set(profiles.map(p => p.project_name || 'Unknown Project'))];
    console.log('Projects found:', projectNames);
    
    // Generate colors for each project
    profileColors = generateProjectColors(projectNames);
    
    // Create GeoJSON format parser
    const geoJsonFormat = new GeoJSON();
    
    // Create ALL features in one array (not separated by project)
    const allFeatures = profiles.map(profile => {
      try {
        if (!profile.geometry) {
          console.warn('Profile missing geometry:', profile.profile_code);
          return null;
        }

        const feature = geoJsonFormat.readFeature(profile.geometry, {
          dataProjection: 'EPSG:4326',
          featureProjection: 'EPSG:3857'
        });
        
        // Set properties including project name for styling
        feature.setProperties({
          profile_code: profile.profile_code,
          project_name: profile.project_name || 'Unknown Project',
          altitude: profile.altitude,
          date: profile.date
        });
        
        return feature;
      } catch (e) {
        console.error('Failed to create feature for profile:', profile.profile_code, e);
        return null;
      }
    }).filter(f => f !== null);

    if (allFeatures.length === 0) {
      console.warn('No valid profile features could be created');
      return;
    }

    console.log(`Created ${allFeatures.length} total features`);

    // Create ONE vector source with ALL profiles
    const vectorSource = new VectorSource({ features: allFeatures });
    
    // Create ONE cluster source for all profiles
    const clusterSource = new Cluster({
      distance: 100,
      source: vectorSource
    });

    // Create ONE profile layer with unified clustering
    const profileLayer = new VectorLayer({
      source: clusterSource,
      style: getUnifiedClusterStyle,
      zIndex: 1000,
      visible: true
    });

    profileLayer.set('name', 'Soil Profiles');
    
    // IMPORTANT: Store ALL original features for filtering
    profileLayer.set('allFeatures', allFeatures);
    
    // Store the single layer
    profileLayers['all'] = profileLayer;
    
    // Store individual project visibility states
    projectNames.forEach(name => {
      profileLayers[name] = { visible: true };
    });
    
    // Add to map
    map.addLayer(profileLayer);

    // Add checkbox controls
    addProfileLayerControl();

  } catch (error) {
    console.error('Failed to load profiles:', error);
    console.error('Error details:', error.message, error.stack);
  }
}



function getUnifiedClusterStyle(feature) {
  const features = feature.get('features');
  const size = features.length;
  
  if (size > 1) {
    // Clustered style - count projects in cluster
    const projectCounts = {};
    features.forEach(f => {
      const projectName = f.get('project_name');
      projectCounts[projectName] = (projectCounts[projectName] || 0) + 1;
    });
    
    // Get dominant project color (project with most profiles in cluster)
    let dominantProject = Object.keys(projectCounts)[0];
    let maxCount = 0;
    Object.entries(projectCounts).forEach(([project, count]) => {
      if (count > maxCount) {
        maxCount = count;
        dominantProject = project;
      }
    });
    
    const color = profileColors[dominantProject] || '#007BFF';
    
    // Convert hex to rgba
    const hexToRgba = (hex, alpha) => {
      const r = parseInt(hex.slice(1, 3), 16);
      const g = parseInt(hex.slice(3, 5), 16);
      const b = parseInt(hex.slice(5, 7), 16);
      return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    };
    
    return new Style({
      image: new CircleStyle({
        radius: 15 + Math.min(size / 2, 10),
        fill: new Fill({ color: hexToRgba(color, 0.8) }),
        stroke: new Stroke({ color: color, width: 2 })
      }),
      text: new Text({
        text: size.toString(),
        fill: new Fill({ color: '#fff' }),
        font: 'bold 12px sans-serif'
      })
    });
  } else {
    // Single point style - use project color
    const projectName = features[0].get('project_name');
    const color = profileColors[projectName] || '#007BFF';
    
    const hexToRgba = (hex, alpha) => {
      const r = parseInt(hex.slice(1, 3), 16);
      const g = parseInt(hex.slice(3, 5), 16);
      const b = parseInt(hex.slice(5, 7), 16);
      return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    };
    
    return new Style({
      image: new CircleStyle({
        radius: 8,
        fill: new Fill({ color: hexToRgba(color, 0.8) }),
        stroke: new Stroke({ color: '#fff', width: 2 })
      })
    });
  }
}


function addProfileLayerControl() {
  const profileGroup = document.createElement('div');
  profileGroup.className = 'layer-group';
  
  // Create header
  const header = document.createElement('div');
  header.className = 'layer-group-header';
  header.textContent = 'Soil Profiles';
  profileGroup.appendChild(header);
  
  // Create content container
  const content = document.createElement('div');
  content.className = 'layer-group-content';
  
  // Get the unified layer
  const unifiedLayer = profileLayers['all'];
  const vectorSource = unifiedLayer.getSource().getSource(); // Get the non-clustered source
  const allFeatures = unifiedLayer.get('allFeatures'); // Get ALL original features
  
  // Function to update visible features based on checkbox states
  const updateVisibleFeatures = () => {
    const visibleFeatures = allFeatures.filter(feature => {
      const featureProject = feature.get('project_name');
      return profileLayers[featureProject] && profileLayers[featureProject].visible;
    });
    
    // Clear and re-add filtered features
    vectorSource.clear();
    vectorSource.addFeatures(visibleFeatures);
  };
  
  // Add a checkbox and color picker for each project
  Object.entries(profileColors).forEach(([projectName, color]) => {
    const layerItem = document.createElement('div');
    layerItem.className = 'layer-item';
    layerItem.style.display = 'flex';
    layerItem.style.alignItems = 'center';
    layerItem.style.gap = '8px';
    
    const checkboxId = `layer-profile-${projectName.replace(/\s+/g, '-').toLowerCase()}`;
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = checkboxId;
    checkbox.checked = true;
    
    const label = document.createElement('label');
    label.htmlFor = checkboxId;
    label.textContent = projectName;
    label.style.flex = '1';
    
    // Create circular color picker wrapper
    const colorWrapper = document.createElement('div');
    colorWrapper.style.position = 'relative';
    colorWrapper.style.width = '24px';
    colorWrapper.style.height = '24px';
    colorWrapper.style.borderRadius = '50%';
    colorWrapper.style.overflow = 'hidden';
    colorWrapper.style.border = '2px solid #fff';
    colorWrapper.style.boxShadow = '0 2px 4px rgba(0,0,0,0.2)';
    colorWrapper.style.cursor = 'pointer';
    colorWrapper.title = 'Change color';
    
    const colorPicker = document.createElement('input');
    colorPicker.type = 'color';
    colorPicker.value = color;
    colorPicker.style.position = 'absolute';
    colorPicker.style.top = '0';
    colorPicker.style.left = '0';
    colorPicker.style.width = '100%';
    colorPicker.style.height = '100%';
    colorPicker.style.border = 'none';
    colorPicker.style.cursor = 'pointer';
    colorPicker.style.opacity = '0';
    
    const colorCircle = document.createElement('div');
    colorCircle.style.width = '100%';
    colorCircle.style.height = '100%';
    colorCircle.style.backgroundColor = color;
    colorCircle.style.borderRadius = '50%';
    colorCircle.style.pointerEvents = 'none';
    
    colorWrapper.appendChild(colorCircle);
    colorWrapper.appendChild(colorPicker);
    
    layerItem.appendChild(checkbox);
    layerItem.appendChild(label);
    layerItem.appendChild(colorWrapper);
    content.appendChild(layerItem);
    
    // Toggle visibility by filtering features
    checkbox.addEventListener('change', (e) => {
      profileLayers[projectName].visible = e.target.checked;
      updateVisibleFeatures(); // Use the function that always works from allFeatures
    });
    
    // Update color
    colorPicker.addEventListener('input', (e) => {
      colorCircle.style.backgroundColor = e.target.value;
    });
    
    colorPicker.addEventListener('change', (e) => {
      profileColors[projectName] = e.target.value;
      colorCircle.style.backgroundColor = e.target.value;
      unifiedLayer.changed();
    });
  });
  
  profileGroup.appendChild(content);

  // Insert at the beginning of layer groups
  const layerGroupsContainer = document.getElementById('layer-groups');
  layerGroupsContainer.insertBefore(profileGroup, layerGroupsContainer.firstChild);

  // Make collapsible
  profileGroup.classList.add('collapsed');
  header.addEventListener('click', () => {
    profileGroup.classList.toggle('collapsed');
  });
}


// ==================== GetFeatureInfo ====================

async function showRasterInfo(evt, popup) {
  const viewResolution = map.getView().getResolution();
  const source = activeLayer.getSource();
  const url = source.getFeatureInfoUrl(
    evt.coordinate,
    viewResolution,
    'EPSG:3857',
    { 'INFO_FORMAT': 'text/html' }
  );

  if (url) {
    try {
      const response = await fetch(url);
      const htmlText = await response.text();
      
      if (htmlText && htmlText.trim() && !htmlText.includes('no features')) {
        // Transform coordinates to WGS84
        const lonLat = toLonLat(evt.coordinate);
        const longitude = lonLat[0].toFixed(6);
        const latitude = lonLat[1].toFixed(6);
        
        // Extract value from HTML (adjust regex based on your MapServer output)
        const valueMatch = htmlText.match(/Value:\s*([0-9.-]+)/);
        const value = valueMatch ? valueMatch[1] : 'N/A';
        
        // Get current layer info
        const layerId = activeLayer.get('layerId');
        const layerConfig = currentLayers[layerId];
        const layerName = layerConfig ? layerConfig.property_name : 'Unknown';
        const unit = layerConfig ? layerConfig.unit_of_measure_id || '' : '';
        
        // Format like profile popup
        const html = `
          <div class="feature-info-layer">
            <h3>${layerName}</h3>
            <div class="feature-info-item">
              <div class="feature-info-property"><strong>Value:</strong> ${value} ${unit}</div>
              <div class="feature-info-property"><strong>Latitude:</strong> ${latitude}°</div>
              <div class="feature-info-property"><strong>Longitude:</strong> ${longitude}°</div>
            </div>
          </div>
        `;
        
        document.getElementById('popup-content').innerHTML = html;
        popup.setPosition(evt.coordinate);
      } else {
        popup.setPosition(undefined);
      }
    } catch (error) {
      console.error('Failed to get feature info:', error);
      popup.setPosition(undefined);
    }
  }
}


// ==================== Popup ====================

function setupPopup() {
  const popup = new Overlay({
    element: document.getElementById('popup'),
    autoPan: true,
    autoPanAnimation: { duration: 250 }
  });
  map.addOverlay(popup);

  // Close popup
  document.getElementById('popup-closer').addEventListener('click', () => {
    popup.setPosition(undefined);
  });

  // Handle map clicks
  map.on('singleclick', async (evt) => {
    const features = map.getFeaturesAtPixel(evt.pixel);
    
    // Check for profile points first (priority)
    if (features && features.length > 0) {
      const feature = features[0];
      const clusterFeatures = feature.get('features');
      
      if (clusterFeatures && clusterFeatures.length === 1) {
        // Single profile - show observations
        await showProfileObservations(clusterFeatures[0], popup, evt.coordinate);
        return; // Stop here, don't check raster
      } else if (clusterFeatures && clusterFeatures.length > 1) {
        // Cluster - zoom in
        const extent = clusterFeatures[0].getGeometry().getExtent();
        map.getView().fit(extent, { duration: 500, maxZoom: map.getView().getZoom() + 2 });
        return; // Stop here
      }
    }
    
    // No profile clicked, check for active raster layer
    if (activeLayer) {
      await showRasterInfo(evt, popup);
    } else {
      popup.setPosition(undefined);
    }
  });
}

async function showProfileObservations(feature, popup, coordinate) {
  const profileCode = feature.get('profile_code');
  const projectName = feature.get('project_name');
  const altitude = feature.get('altitude');
  const date = feature.get('date');
  
  // Get coordinates from feature geometry
  const geometry = feature.getGeometry();
  const coords = geometry.getCoordinates();
  // Transform from map projection (EPSG:3857) to WGS84 (EPSG:4326)
  const lonLat = toLonLat(coords);
  const longitude = lonLat[0].toFixed(6);
  const latitude = lonLat[1].toFixed(6);

  try {
    const observations = await api.getObservations(profileCode);
    
    let html = `
      <div class="popup-tabs">
        <button class="tab-button active" data-tab="profile">Profile</button>
        <button class="tab-button" data-tab="observations">Observations (${observations.length})</button>
      </div>
      
      <div class="tab-content active" id="tab-profile">
        <h3>Profile: ${profileCode}</h3>
        <div class="feature-info-item">
          <div class="feature-info-property"><strong>Project:</strong> ${projectName || 'N/A'}</div>
          <div class="feature-info-property"><strong>Latitude:</strong> ${latitude}°</div>
          <div class="feature-info-property"><strong>Longitude:</strong> ${longitude}°</div>
          <div class="feature-info-property"><strong>Altitude:</strong> ${altitude || 'N/A'} m</div>
          <div class="feature-info-property"><strong>Date:</strong> ${date || 'N/A'}</div>
          <div class="feature-info-property"><strong>Total Observations:</strong> ${observations.length}</div>
        </div>
      </div>
      
      <div class="tab-content" id="tab-observations">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
          <h3 style="margin: 0;">Observations</h3>
          <button id="download-csv-btn" style="padding: 5px 10px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 4px; display: flex; align-items: center; gap: 5px; margin-right: 20px;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
              <path d="M5 20h14v-2H5m14-9h-4V3H9v6H5l7 7 7-7z"/>
            </svg>
            Download CSV
          </button>
        </div>
    `;
    
    if (observations.length > 0) {
      html += `
        <div>
          <table class="observations-table">
            <thead style="position: sticky; top: 0; background: white;">
              <tr>
                <th>Top</th>
                <th>Bottom</th>
                <th>Property</th>
                <th>Procedure</th>
                <th>Value</th>
                <th>Unit</th>
              </tr>
            </thead>
            <tbody>
      `;
      
      observations.forEach(obs => {
        html += `
          <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 5px;">${obs.upper_depth}</td>
            <td style="padding: 5px;">${obs.lower_depth}</td>
            <td style="padding: 5px;">${obs.property_phys_chem_id}</td>
            <td style="padding: 5px;">${obs.procedure_phys_chem_id || 'N/A'}</td>
            <td style="padding: 5px; text-align: right;">${obs.value}</td>
            <td style="padding: 5px;">${obs.unit_of_measure_id || ''}</td>
          </tr>
        `;
      });
      
      html += `
            </tbody>
          </table>
        </div>
      `;
    } else {
      html += '<p>No observations available</p>';
    }
    
    html += '</div>';

    document.getElementById('popup-content').innerHTML = html;
    popup.setPosition(coordinate);
    
    // Add tab switching functionality
    document.querySelectorAll('.tab-button').forEach(button => {
      button.addEventListener('click', (e) => {
        const tabName = e.target.dataset.tab;
        
        // Update button states
        document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
        e.target.classList.add('active');
        
        // Update content visibility
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        document.getElementById(`tab-${tabName}`).classList.add('active');
      });
    });
    
    // Add tab switching functionality
    document.querySelectorAll('.tab-button').forEach(button => {
      button.addEventListener('click', (e) => {
        const tabName = e.target.dataset.tab;
        
        // Update button states
        document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
        e.target.classList.add('active');
        
        // Update content visibility
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        document.getElementById(`tab-${tabName}`).classList.add('active');
      });
    });
    
    // Add CSV download functionality
    const downloadBtn = document.getElementById('download-csv-btn');
    if (downloadBtn) {
      downloadBtn.addEventListener('click', () => {
        downloadObservationsCSV(profileCode, projectName, altitude, date, latitude, longitude, observations);
      });
    }

  } catch (error) {
    console.error('Failed to load observations:', error);
    document.getElementById('popup-content').innerHTML = `
      <div class="feature-info-layer">
        <h3>Profile: ${profileCode}</h3>
        <p>Failed to load observations</p>
      </div>
    `;
    popup.setPosition(coordinate);
  }
}

function showLegend(legendUrl) {
  const legendContainer = document.getElementById('legend');
  const legendContent = legendContainer.querySelector('.legend-content');
  legendContent.innerHTML = `<img src="${legendUrl}" alt="Legend">`;
  legendContainer.style.display = 'block';
}


function downloadObservationsCSV(profileCode, projectName, altitude, date, latitude, longitude, observations) {
  // Create CSV header
  let csv = 'Profile Code,Project,Latitude,Longitude,Altitude (m),Date,Top (cm),Bottom (cm),Property,Procedure,Value,Unit\n';
  
  // Add data rows
  observations.forEach(obs => {
    const row = [
      profileCode,
      projectName || '',
      latitude,
      longitude,
      altitude || '',
      date || '',
      obs.upper_depth,
      obs.lower_depth,
      obs.property_phys_chem_id,
      obs.procedure_phys_chem_id || '',
      obs.value,
      obs.unit_of_measure_id || ''
    ];
    
    // Escape values that contain commas or quotes
    const escapedRow = row.map(value => {
      const stringValue = String(value);
      if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
        return `"${stringValue.replace(/"/g, '""')}"`;
      }
      return stringValue;
    });
    
    csv += escapedRow.join(',') + '\n';
  });
  
  // Create blob and download
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', `${profileCode}_observations.csv`);
  link.style.visibility = 'hidden';
  
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}


// ==================== UI Controls ====================

function setupControls() {
  // Layer switcher collapse
  const collapseBtn = document.getElementById('collapse-btn');
  const layerSwitcher = document.getElementById('layer-switcher');
  
  collapseBtn.addEventListener('click', () => {
    layerSwitcher.classList.toggle('collapsed');
  });

  // Opacity control
  const opacitySlider = document.getElementById('opacity');
  opacitySlider.addEventListener('input', (e) => {
    if (activeLayer) {
      activeLayer.setOpacity(parseFloat(e.target.value));
    }
  });

  // Zoom controls
  document.getElementById('zoom-in').addEventListener('click', () => {
    const view = map.getView();
    view.setZoom(view.getZoom() + 1);
  });

  document.getElementById('zoom-out').addEventListener('click', () => {
    const view = map.getView();
    view.setZoom(view.getZoom() - 1);
  });

  // Add login button
  addLoginButton();
}

function addLoginButton() {
  const loginBtn = document.createElement('button');
  loginBtn.id = 'login-btn';
  loginBtn.style.cssText = 'position: absolute; top: 20px; right: 20px; padding: 8px 16px; background: rgba(255,255,255,0.9); border: none; border-radius: 4px; cursor: pointer; z-index: 1001; font-weight: 500;';
  
  // Check if user is already logged in (restore session)
  if (api.restoreSession()) {
    loginBtn.textContent = 'Admin Panel';
    loginBtn.onclick = showAdminPanel;  // CHANGED: Use .onclick instead of addEventListener
  } else {
    loginBtn.textContent = 'Login';
    loginBtn.onclick = showLoginModal;  // CHANGED: Use .onclick instead of addEventListener
  }

  document.body.appendChild(loginBtn);
}

// ==================== Admin Functions ====================

function showLoginModal() {
  // If already authenticated, show admin panel instead
  if (api.isAuthenticated()) {
    showAdminPanel();
    return;
  }

  // Create modal HTML
  const modal = document.createElement('div');
  modal.className = 'login-modal active';
  modal.innerHTML = `
    <div class="login-content">
      <h2>Admin Login</h2>
      <div id="login-error" class="login-error"></div>
      <form class="login-form" id="login-form">
        <div class="form-group">
          <label for="login-email">Email</label>
          <input type="email" id="login-email" required>
        </div>
        <div class="form-group">
          <label for="login-password">Password</label>
          <input type="password" id="login-password" required>
        </div>
        <div class="login-actions">
          <button type="submit" class="btn btn-primary">Login</button>
          <button type="button" id="login-cancel" class="btn btn-secondary">Cancel</button>
        </div>
      </form>
    </div>
  `;

  document.body.appendChild(modal);

  // Handle form submission
  document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    try {
      await api.login(email, password);
      document.body.removeChild(modal);
      showAdminPanel();
    } catch (error) {
      document.getElementById('login-error').textContent = error.message;
      document.getElementById('login-error').classList.add('active');
    }
  });

  document.getElementById('login-cancel').addEventListener('click', () => {
    document.body.removeChild(modal);
  });
}

// Make it globally accessible:
window.showLoginModal = showLoginModal;

function showAdminPanel() {
  // Show the admin dashboard
  adminDashboard.show();
  
  // Update login button to "Back to Map"
  const loginBtn = document.getElementById('login-btn');
  if (!loginBtn) return;
  
  loginBtn.textContent = 'Back to Map';
  
  // Set click handler for closing dashboard
  loginBtn.onclick = () => {
    // Close dashboard and return to map
    adminDashboard.hide();
    
    // Reset button to reopen dashboard
    loginBtn.textContent = 'Admin Panel';
    loginBtn.onclick = showAdminPanel; // This line is critical!
  };
}

window.showAdminPanel = showAdminPanel;

// ==================== Utility Functions ====================

function showLoading(show) {
  let loader = document.getElementById('loading-overlay');
  if (show) {
    if (!loader) {
      loader = document.createElement('div');
      loader.id = 'loading-overlay';
      loader.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.9); z-index: 10000; display: flex; align-items: center; justify-content: center; font-size: 24px;';
      loader.textContent = 'Loading...';
      document.body.appendChild(loader);
    }
  } else {
    if (loader) {
      document.body.removeChild(loader);
    }
  }
}

function showError(message) {
  alert(message);
}

// ==================== Start App ====================

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeApp);
} else {
  initializeApp();
}

// ==================== Map Data Refresh ====================

function refreshMapData() {
  console.log('Refreshing map after admin changes...');
  window.location.reload();
}

window.refreshMapData = refreshMapData;

