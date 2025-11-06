import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import { Tile as TileLayer, Image as ImageLayer, Vector as VectorLayer } from 'ol/layer';
import { OSM, XYZ, ImageWMS, Vector as VectorSource, Cluster } from 'ol/source';
import { fromLonLat } from 'ol/proj';
import { ScaleLine, defaults as defaultControls } from 'ol/control';
import Overlay from 'ol/Overlay';
import { Circle as CircleStyle, Fill, Stroke, Style, Text } from 'ol/style';
import { GeoJSON } from 'ol/format';
import api from './api-client.js';

// Global variables
let map;
let appConfig = {};
let currentLayers = {};
let profileLayer;
let activeLayer = null;

// ==================== Initialization ====================

async function initializeApp() {
  try {
    showLoading(true);

    // Load settings from API
    const settings = await api.getSettings();
    appConfig = settingsArrayToObject(settings);

    // Apply settings to UI
    applySettings();

    // Initialize map
    initializeMap();

    // Load layers from API
    await loadLayers();

    // Load profiles
    await loadProfiles();

    // Setup UI controls
    setupControls();

    // Check if user is logged in
    if (api.restoreSession()) {
      showAdminPanel();
    }

    showLoading(false);
  } catch (error) {
    console.error('Failed to initialize app:', error);
    showError('Failed to load application. Please check your connection and refresh.');
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
    controls: defaultControls({ attribution: false }).extend([
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
      ${layer.metadata_url ? `<a href="${layer.metadata_url}" target="_blank" title="Metadata"><img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23666'%3E%3Cpath d='M13 9h-2V7h2m0 10h-2v-6h2m-1-9A10 10 0 0 0 2 12a10 10 0 0 0 10 10 10 10 0 0 0 10-10A10 10 0 0 0 12 2z'/%3E%3C/svg%3E" alt="Info"></a>` : ''}
      ${layer.download_url ? `<a href="${layer.download_url}" title="Download"><img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23666'%3E%3Cpath d='M5 20h14v-2H5m14-9h-4V3H9v6H5l7 7 7-7z'/%3E%3C/svg%3E" alt="Download"></a>` : ''}
    </div>
  `;

  const radio = itemDiv.querySelector('input[type="radio"]');
  radio.addEventListener('change', (e) => {
    if (e.target.checked) {
      switchLayer(layer);
    }
  });

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
  // Parse WMS URL to extract base URL and layer name
  const mapServerUrl = 'http://localhost:8082/';
  
  const layer = new ImageLayer({
    source: new ImageWMS({
      url: mapServerUrl,
      params: {
        'LAYERS': layerConfig.layer_id,
        'FORMAT': 'image/png',
        'TRANSPARENT': true
      },
      ratio: 1,
      serverType: 'mapserver'
    })
  });

  layer.set('layerId', layerConfig.layer_id);
  layer.set('featureInfoUrl', layerConfig.get_feature_info_url);
  
  return layer;
}

// ==================== Profile Layer ====================

async function loadProfiles() {
  try {
    const profiles = await api.getProfiles();
    
    // Create features from profiles
    const features = profiles.map(profile => {
      const geometry = JSON.parse(profile.geometry);
      const feature = new GeoJSON().readFeature({
        type: 'Feature',
        geometry: geometry,
        properties: {
          profile_code: profile.profile_code,
          project_name: profile.project_name,
          altitude: profile.altitude,
          date: profile.date
        }
      }, {
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
      });
      return feature;
    });

    // Create vector source with clustering
    const vectorSource = new VectorSource({ features });
    
    const clusterSource = new Cluster({
      distance: 40,
      source: vectorSource
    });

    // Create profile layer
    profileLayer = new VectorLayer({
      source: clusterSource,
      style: getProfileStyle,
      zIndex: 1000
    });

    profileLayer.set('name', 'Soil Profiles');
    map.addLayer(profileLayer);

    // Add checkbox for profile layer
    addProfileLayerControl();

  } catch (error) {
    console.error('Failed to load profiles:', error);
    showError('Failed to load soil profiles');
  }
}

function getProfileStyle(feature) {
  const size = feature.get('features').length;
  
  if (size > 1) {
    // Clustered style
    return new Style({
      image: new CircleStyle({
        radius: 15 + Math.min(size / 2, 10),
        fill: new Fill({ color: 'rgba(255, 153, 0, 0.8)' }),
        stroke: new Stroke({ color: 'rgba(255, 153, 0, 1)', width: 2 })
      }),
      text: new Text({
        text: size.toString(),
        fill: new Fill({ color: '#fff' }),
        font: 'bold 12px sans-serif'
      })
    });
  } else {
    // Single point style
    return new Style({
      image: new CircleStyle({
        radius: 8,
        fill: new Fill({ color: 'rgba(0, 123, 255, 0.8)' }),
        stroke: new Stroke({ color: '#fff', width: 2 })
      })
    });
  }
}

function addProfileLayerControl() {
  const profileGroup = document.createElement('div');
  profileGroup.className = 'layer-group';
  profileGroup.innerHTML = `
    <div class="layer-group-header">Soil Profiles</div>
    <div class="layer-group-content">
      <div class="layer-item">
        <input type="checkbox" id="layer-profiles" checked>
        <label for="layer-profiles">Profile Locations</label>
      </div>
    </div>
  `;

  // Insert at the beginning of layer groups
  const layerGroupsContainer = document.getElementById('layer-groups');
  layerGroupsContainer.insertBefore(profileGroup, layerGroupsContainer.firstChild);

  // Add event listener
  document.getElementById('layer-profiles').addEventListener('change', (e) => {
    profileLayer.setVisible(e.target.checked);
  });

  // Make collapsible
  profileGroup.querySelector('.layer-group-header').addEventListener('click', () => {
    profileGroup.classList.toggle('collapsed');
  });
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
    
    if (features && features.length > 0) {
      const feature = features[0];
      const clusterFeatures = feature.get('features');
      
      if (clusterFeatures && clusterFeatures.length === 1) {
        // Single profile - show observations
        await showProfileObservations(clusterFeatures[0], popup, evt.coordinate);
      } else if (clusterFeatures && clusterFeatures.length > 1) {
        // Cluster - zoom in
        const extent = clusterFeatures[0].getGeometry().getExtent();
        map.getView().fit(extent, { duration: 500, maxZoom: map.getView().getZoom() + 2 });
      }
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

  try {
    const observations = await api.getObservations(profileCode);
    
    let html = `
      <div class="feature-info-layer">
        <h3>Profile: ${profileCode}</h3>
        <div class="feature-info-item">
          <div class="feature-info-property"><strong>Project:</strong> ${projectName || 'N/A'}</div>
          <div class="feature-info-property"><strong>Altitude:</strong> ${altitude || 'N/A'} m</div>
          <div class="feature-info-property"><strong>Date:</strong> ${date ? new Date(date).toLocaleDateString() : 'N/A'}</div>
          <div class="feature-info-property"><strong>Observations:</strong> ${observations.length}</div>
        </div>
      </div>
    `;

    if (observations.length > 0) {
      html += '<div class="feature-info-layer"><h3>Sample Data (first 5):</h3>';
      observations.slice(0, 5).forEach(obs => {
        html += `
          <div class="feature-info-item">
            <div class="feature-info-property"><strong>Property:</strong> ${obs.property_phys_chem_id}</div>
            <div class="feature-info-property"><strong>Depth:</strong> ${obs.upper_depth}-${obs.lower_depth} cm</div>
            <div class="feature-info-property"><strong>Value:</strong> ${obs.value} ${obs.unit_of_measure_id || ''}</div>
          </div>
        `;
      });
      html += '</div>';
    }

    document.getElementById('popup-content').innerHTML = html;
    popup.setPosition(coordinate);
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
  loginBtn.textContent = 'Admin Login';
  loginBtn.style.cssText = 'position: absolute; top: 20px; right: 20px; padding: 8px 16px; background: rgba(255,255,255,0.9); border: none; border-radius: 4px; cursor: pointer; z-index: 1001;';
  
  loginBtn.addEventListener('click', () => {
    if (api.isAuthenticated()) {
      showAdminPanel();
    } else {
      showLoginModal();
    }
  });

  document.body.appendChild(loginBtn);
}

// ==================== Admin Functions ====================

function showLoginModal() {
  const modal = document.createElement('div');
  modal.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 10000; display: flex; align-items: center; justify-content: center;';
  
  modal.innerHTML = `
    <div style="background: white; padding: 30px; border-radius: 8px; min-width: 300px;">
      <h2 style="margin-top: 0;">Admin Login</h2>
      <input type="email" id="login-email" placeholder="Email" style="width: 100%; padding: 8px; margin-bottom: 10px; box-sizing: border-box;">
      <input type="password" id="login-password" placeholder="Password" style="width: 100%; padding: 8px; margin-bottom: 15px; box-sizing: border-box;">
      <button id="login-submit" style="width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Login</button>
      <button id="login-cancel" style="width: 100%; padding: 10px; margin-top: 10px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer;">Cancel</button>
      <div id="login-error" style="color: red; margin-top: 10px; display: none;"></div>
    </div>
  `;

  document.body.appendChild(modal);

  document.getElementById('login-submit').addEventListener('click', async () => {
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    try {
      await api.login(email, password);
      document.body.removeChild(modal);
      showAdminPanel();
      document.getElementById('login-btn').textContent = 'Admin Panel';
    } catch (error) {
      document.getElementById('login-error').textContent = error.message;
      document.getElementById('login-error').style.display = 'block';
    }
  });

  document.getElementById('login-cancel').addEventListener('click', () => {
    document.body.removeChild(modal);
  });
}

function showAdminPanel() {
  // This would open a full admin interface
  // For now, just show an alert that you're logged in
  alert('Admin panel functionality coming soon! You can now manage layers and settings via API calls.');
  document.getElementById('login-btn').textContent = 'Logout';
  document.getElementById('login-btn').onclick = () => {
    api.logout();
    document.getElementById('login-btn').textContent = 'Admin Login';
    alert('Logged out successfully');
  };
}

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