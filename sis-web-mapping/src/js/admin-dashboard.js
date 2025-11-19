/**
 * Admin Dashboard Module
 * Manages Settings and Layers through a tabbed interface
 */

import api from './api-client.js';

class AdminDashboard {
  constructor() {
    this.currentTab = 'settings';
    this.settings = [];
    this.layers = [];
    this.editingItem = null;
  }

  /**
   * Initialize and show the admin dashboard
   */
  async show() {
    // Create dashboard HTML if it doesn't exist
    if (!document.getElementById('admin-dashboard')) {
      this.createDashboardHTML();
    }

    const dashboard = document.getElementById('admin-dashboard');
    dashboard.classList.add('active');

    // Load initial data
    await this.loadSettings();
    await this.loadLayers();
    this.renderSettings();
    this.renderLayers();
  }

  /**
   * Hide the admin dashboard
   */
  hide() {
    const dashboard = document.getElementById('admin-dashboard');
    if (dashboard) {
      dashboard.classList.remove('active');
    }
    
    // Update the map login button back to "Admin Panel"
    const loginBtn = document.getElementById('login-btn');
    if (loginBtn && api.isAuthenticated()) {
      loginBtn.textContent = 'Admin Panel';
      loginBtn.onclick = () => {
        if (window.showAdminPanel) {
          window.showAdminPanel();
        }
      };
    }
    
    // Trigger map refresh to reload settings and layers
    if (window.refreshMapData && typeof window.refreshMapData === 'function') {
      console.log('[Admin Dashboard] Triggering map data refresh');
      window.refreshMapData();
    }
  }

  /**
   * Logout and close dashboard
   */
  logout() {
    // Perform logout
    api.logout();
    
    // Hide dashboard
    this.hide();
    
    // Reset login button to initial state
    const loginBtn = document.getElementById('login-btn');
    if (loginBtn) {
      loginBtn.textContent = 'Login';
      loginBtn.onclick = () => {
        if (window.showLoginModal) {
          window.showLoginModal();
        } else if (api.isAuthenticated()) {
          window.showAdminPanel();
        } else {
          // Fallback: create simple login prompt
          const email = prompt('Email:');
          const password = prompt('Password:');
          if (email && password) {
            api.login(email, password)
              .then(() => {
                if (window.showAdminPanel) {
                  window.showAdminPanel();
                }
              })
              .catch(err => alert('Login failed: ' + err.message));
          }
        }
      };
    }
    
    // Show confirmation
    alert('Logged out successfully');
  }

  /**
   * Create the dashboard HTML structure
   */
  createDashboardHTML() {
    const dashboardHTML = `
      <div id="admin-dashboard" class="admin-dashboard">
        <div class="dashboard-content">
          <div class="dashboard-header">
            <h2>Admin Dashboard</h2>
            <div class="dashboard-header-actions">
              <button class="close-dashboard" id="close-dashboard">Back to Map</button>
              <button class="logout-btn" id="logout-dashboard">Logout</button>
            </div>
          </div>
          
          <ul class="dashboard-tabs">
            <li><button class="tab-btn active" data-tab="settings">Settings</button></li>
            <li><button class="tab-btn" data-tab="layers">Layers</button></li>
          </ul>
          
          <div class="dashboard-body">
            <!-- Settings Tab -->
            <div id="settings-tab" class="tab-pane active">
              <div class="admin-form">
                <h3>Add/Edit Setting</h3>
                <form id="setting-form">
                  <div class="form-row">
                    <div class="form-group">
                      <label for="setting-key">Key *</label>
                      <input type="text" id="setting-key" required>
                    </div>
                    <div class="form-group">
                      <label for="setting-value">Value *</label>
                      <input type="text" id="setting-value" required>
                    </div>
                  </div>
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                      <span id="setting-btn-text">Add Setting</span>
                    </button>
                    <button type="button" class="btn btn-secondary" id="cancel-setting">Cancel</button>
                  </div>
                </form>
              </div>
              
              <div id="settings-table-container">
                <table class="admin-table" id="settings-table">
                  <thead>
                    <tr>
                      <th>Key</th>
                      <th>Value</th>
                      <th style="width: 150px;">Actions</th>
                    </tr>
                  </thead>
                  <tbody id="settings-tbody">
                    <tr><td colspan="3" class="loading">Loading settings...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
            
            <!-- Layers Tab -->
            <div id="layers-tab" class="tab-pane">
              <div class="admin-form">
                <h3>Add/Edit Layer</h3>
                <form id="layer-form">
                  <div class="form-row">
                    <div class="form-group">
                      <label for="layer-project-id">Project ID</label>
                      <input type="text" id="layer-project-id">
                    </div>
                    <div class="form-group">
                      <label for="layer-project-name">Project Name</label>
                      <input type="text" id="layer-project-name">
                    </div>
                  </div>
                  
                  <div class="form-row">
                    <div class="form-group">
                      <label for="layer-id">Layer ID *</label>
                      <input type="text" id="layer-id" required>
                    </div>
                    <div class="form-group">
                      <label for="layer-property">Property Name</label>
                      <input type="text" id="layer-property">
                    </div>
                  </div>
                  
                  <div class="form-row">
                    <div class="form-group">
                      <label for="layer-dimension">Dimension</label>
                      <input type="text" id="layer-dimension">
                    </div>
                    <div class="form-group">
                      <label for="layer-version">Version</label>
                      <input type="text" id="layer-version">
                    </div>
                    <div class="form-group">
                      <label for="layer-unit">Unit of Measure</label>
                      <input type="text" id="layer-unit">
                    </div>
                  </div>
                  
                  <div class="form-row">
                    <div class="form-group">
                      <label for="layer-metadata-url">Metadata URL</label>
                      <input type="text" id="layer-metadata-url" placeholder="/collections/metadata:main/items/...">
                    </div>
                    <div class="form-group">
                      <label for="layer-download-url">Download URL</label>
                      <input type="text" id="layer-download-url" placeholder="/api/download/...">
                    </div>
                  </div>
                  
                  <div class="form-row">
                    <div class="form-group">
                      <label for="layer-getmap-url">GetMap URL</label>
                      <input type="text" id="layer-getmap-url" placeholder="/mapserver?...">
                    </div>
                    <div class="form-group">
                      <label for="layer-legend-url">Legend URL</label>
                      <input type="text" id="layer-legend-url" placeholder="/mapserver?...">
                    </div>
                    <div class="form-group">
                      <label for="layer-featureinfo-url">FeatureInfo URL</label>
                      <input type="text" id="layer-featureinfo-url" placeholder="/mapserver?...">
                    </div>
                  </div>
                  
                  <div class="form-row">
                    <div class="form-group">
                      <label class="checkbox-label">
                        <input type="checkbox" id="layer-publish" checked>
                        Published
                      </label>
                    </div>
                  </div>
                  
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                      <span id="layer-btn-text">Add Layer</span>
                    </button>
                    <button type="button" class="btn btn-secondary" id="cancel-layer">Cancel</button>
                  </div>
                </form>
              </div>
              
              <div id="layers-table-container">
                <table class="admin-table" id="layers-table">
                  <thead>
                    <tr>
                      <th>Layer ID</th>
                      <th>Project</th>
                      <th>Property</th>
                      <th>Published</th>
                      <th style="width: 200px;">Actions</th>
                    </tr>
                  </thead>
                  <tbody id="layers-tbody">
                    <tr><td colspan="5" class="loading">Loading layers...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', dashboardHTML);
    this.attachEventListeners();
  }

  /**
   * Attach all event listeners
   */
  attachEventListeners() {
    // Close dashboard
    document.getElementById('close-dashboard').addEventListener('click', () => {
      this.hide();
    });

    // Logout button - instant logout (no confirmation)
    const logoutBtn = document.getElementById('logout-dashboard');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', () => {
        this.logout();
      });
    }

    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const tab = e.target.dataset.tab;
        this.switchTab(tab);
      });
    });

    // Settings form
    document.getElementById('setting-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleSettingSubmit();
    });

    document.getElementById('cancel-setting').addEventListener('click', () => {
      this.cancelSettingEdit();
    });

    // Layers form
    document.getElementById('layer-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleLayerSubmit();
    });

    document.getElementById('cancel-layer').addEventListener('click', () => {
      this.cancelLayerEdit();
    });
  }

  /**
   * Switch between tabs
   */
  switchTab(tab) {
    this.currentTab = tab;

    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
      if (btn.dataset.tab === tab) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    // Update tab panes
    document.querySelectorAll('.tab-pane').forEach(pane => {
      pane.classList.remove('active');
    });
    document.getElementById(`${tab}-tab`).classList.add('active');
  }

  // ==================== Settings Management ====================

  async loadSettings() {
    try {
      this.settings = await api.getAllSettings();
    } catch (error) {
      console.error('Error loading settings:', error);
      alert('Failed to load settings: ' + error.message);
    }
  }

  renderSettings() {
    const tbody = document.getElementById('settings-tbody');
    
    if (this.settings.length === 0) {
      tbody.innerHTML = '<tr><td colspan="3" class="empty-state">No settings found</td></tr>';
      return;
    }

    tbody.innerHTML = this.settings.map(setting => `
      <tr>
        <td><strong>${this.escapeHtml(setting.key)}</strong></td>
        <td>${this.escapeHtml(setting.value)}</td>
        <td class="actions">
          <button class="btn btn-primary" onclick="adminDashboard.editSetting('${this.escapeHtml(setting.key)}')">Edit</button>
          <button class="btn btn-danger" onclick="adminDashboard.deleteSetting('${this.escapeHtml(setting.key)}')">Delete</button>
        </td>
      </tr>
    `).join('');
  }

  editSetting(key) {
    const setting = this.settings.find(s => s.key === key);
    if (!setting) return;

    this.editingItem = { type: 'setting', key };
    document.getElementById('setting-key').value = setting.key;
    document.getElementById('setting-key').disabled = true;
    document.getElementById('setting-value').value = setting.value;
    document.getElementById('setting-btn-text').textContent = 'Update Setting';
    
    // Scroll to form
    document.getElementById('setting-form').scrollIntoView({ behavior: 'smooth' });
  }

  cancelSettingEdit() {
    this.editingItem = null;
    document.getElementById('setting-form').reset();
    document.getElementById('setting-key').disabled = false;
    document.getElementById('setting-btn-text').textContent = 'Add Setting';
  }

  async handleSettingSubmit() {
    const key = document.getElementById('setting-key').value.trim();
    const value = document.getElementById('setting-value').value.trim();

    if (!key || !value) {
      alert('Please fill in all required fields');
      return;
    }

    try {
      if (this.editingItem && this.editingItem.type === 'setting') {
        // Update existing
        await api.updateSetting(key, value);
        alert('Setting updated successfully');
      } else {
        // Create new
        await api.createSetting(key, value);
        alert('Setting created successfully');
      }

      this.cancelSettingEdit();
      await this.loadSettings();
      this.renderSettings();
    } catch (error) {
      alert('Error saving setting: ' + error.message);
    }
  }

  async deleteSetting(key) {
    if (!confirm(`Are you sure you want to delete the setting "${key}"?`)) {
      return;
    }

    try {
      await api.deleteSetting(key);
      alert('Setting deleted successfully');
      await this.loadSettings();
      this.renderSettings();
    } catch (error) {
      alert('Error deleting setting: ' + error.message);
    }
  }

  // ==================== Layers Management ====================

  async loadLayers() {
    try {
      this.layers = await api.getAllLayers();
    } catch (error) {
      console.error('Error loading layers:', error);
      alert('Failed to load layers: ' + error.message);
    }
  }

  renderLayers() {
    const tbody = document.getElementById('layers-tbody');
    
    if (this.layers.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No layers found</td></tr>';
      return;
    }

    tbody.innerHTML = this.layers.map(layer => `
      <tr>
        <td><strong>${this.escapeHtml(layer.layer_id)}</strong></td>
        <td>${this.escapeHtml(layer.project_name || '-')}</td>
        <td>${this.escapeHtml(layer.property_name || '-')}</td>
        <td>
          <span class="badge ${layer.publish ? 'badge-success' : 'badge-danger'}">
            ${layer.publish ? 'Published' : 'Unpublished'}
          </span>
        </td>
        <td class="actions">
          <button class="btn btn-primary" onclick="adminDashboard.editLayer('${this.escapeHtml(layer.layer_id)}')">Edit</button>
          <button class="btn ${layer.publish ? 'btn-secondary' : 'btn-success'}" 
                  onclick="adminDashboard.toggleLayerPublish('${this.escapeHtml(layer.layer_id)}', ${!layer.publish})">
            ${layer.publish ? 'Unpublish' : 'Publish'}
          </button>
          <button class="btn btn-danger" onclick="adminDashboard.deleteLayer('${this.escapeHtml(layer.layer_id)}')">Delete</button>
        </td>
      </tr>
    `).join('');
  }

  editLayer(layerId) {
    const layer = this.layers.find(l => l.layer_id === layerId);
    if (!layer) return;

    this.editingItem = { type: 'layer', layerId: layerId };
    
    document.getElementById('layer-project-id').value = layer.project_id || '';
    document.getElementById('layer-project-name').value = layer.project_name || '';
    document.getElementById('layer-id').value = layer.layer_id;
    document.getElementById('layer-id').disabled = true;
    document.getElementById('layer-property').value = layer.property_name || '';
    document.getElementById('layer-dimension').value = layer.dimension || '';
    document.getElementById('layer-version').value = layer.version || '';
    document.getElementById('layer-unit').value = layer.unit_of_measure_id || '';
    document.getElementById('layer-metadata-url').value = layer.metadata_url || '';
    document.getElementById('layer-download-url').value = layer.download_url || '';
    document.getElementById('layer-getmap-url').value = layer.get_map_url || '';
    document.getElementById('layer-legend-url').value = layer.get_legend_url || '';
    document.getElementById('layer-featureinfo-url').value = layer.get_feature_info_url || '';
    document.getElementById('layer-publish').checked = layer.publish;
    
    document.getElementById('layer-btn-text').textContent = 'Update Layer';
    
    // Scroll to form
    document.getElementById('layer-form').scrollIntoView({ behavior: 'smooth' });
  }

  cancelLayerEdit() {
    this.editingItem = null;
    document.getElementById('layer-form').reset();
    document.getElementById('layer-id').disabled = false;
    document.getElementById('layer-btn-text').textContent = 'Add Layer';
    document.getElementById('layer-publish').checked = true;
  }

  async handleLayerSubmit() {
    const layerData = {
      project_id: document.getElementById('layer-project-id').value.trim() || null,
      project_name: document.getElementById('layer-project-name').value.trim() || null,
      layer_id: document.getElementById('layer-id').value.trim(),
      property_name: document.getElementById('layer-property').value.trim() || null,
      dimension: document.getElementById('layer-dimension').value.trim() || null,
      version: document.getElementById('layer-version').value.trim() || null,
      unit_of_measure_id: document.getElementById('layer-unit').value.trim() || null,
      metadata_url: document.getElementById('layer-metadata-url').value.trim() || null,
      download_url: document.getElementById('layer-download-url').value.trim() || null,
      get_map_url: document.getElementById('layer-getmap-url').value.trim() || null,
      get_legend_url: document.getElementById('layer-legend-url').value.trim() || null,
      get_feature_info_url: document.getElementById('layer-featureinfo-url').value.trim() || null,
      publish: document.getElementById('layer-publish').checked
    };

    if (!layerData.layer_id) {
      alert('Layer ID is required');
      return;
    }

    try {
      if (this.editingItem && this.editingItem.type === 'layer') {
        // Update existing - use the stored layerId
        await api.updateLayer(this.editingItem.layerId, layerData);
        alert('Layer updated successfully');
      } else {
        // Create new
        await api.createLayer(layerData);
        alert('Layer created successfully');
      }

      this.cancelLayerEdit();
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error saving layer: ' + error.message);
    }
  }

  async toggleLayerPublish(layerId, publish) {
    try {
      await api.toggleLayerPublish(layerId, publish);
      alert(`Layer ${publish ? 'published' : 'unpublished'} successfully`);
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error toggling layer publish status: ' + error.message);
    }
  }

  async deleteLayer(layerId) {
    const layer = this.layers.find(l => l.layer_id === layerId);
    if (!layer) return;

    if (!confirm(`Are you sure you want to delete the layer "${layer.layer_id}"?`)) {
      return;
    }

    try {
      await api.deleteLayer(layerId);
      alert('Layer deleted successfully');
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error deleting layer: ' + error.message);
    }
  }

  // ==================== Utility ====================

  escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}

// Create singleton instance and expose it globally for onclick handlers
const adminDashboard = new AdminDashboard();
window.adminDashboard = adminDashboard;

export default adminDashboard;