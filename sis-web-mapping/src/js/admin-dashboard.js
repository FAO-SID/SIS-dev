/**
 * Admin Dashboard Module
 * Manages Settings and Layers through a tabbed interface
 */

import api from './api-client.js';
import Map from 'ol/Map';
import View from 'ol/View';
import { Tile as TileLayer } from 'ol/layer';
import { OSM, XYZ } from 'ol/source';
import { fromLonLat, toLonLat } from 'ol/proj';

const BASE_MAP_OPTIONS = {
  'esri-imagery': {
    label: 'ESRI Imagery',
    factory: () => new TileLayer({
      source: new XYZ({
        url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attributions: 'Tiles © Esri',
        crossOrigin: 'anonymous'
      })
    })
  },
  'osm': {
    label: 'OpenStreetMap',
    factory: () => new TileLayer({ source: new OSM() })
  },
  'terrain': {
    label: 'Open TopoMap',
    factory: () => new TileLayer({
      source: new XYZ({
        url: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
        attributions: '© OpenTopoMap (CC-BY-SA)',
        crossOrigin: 'anonymous'
      })
    })
  }
};

class AdminDashboard {
  constructor() {
    this.currentTab = 'administration';
    this.settings = [];
    this.layers = [];
    this.users = [];
    this.isAdmin = false;
    this.editingItem = null;
  }

  /**
   * Initialize and show the admin dashboard
   */
  async show() {
    // Check admin status before building UI
    try {
      const auth = await api.verifyAuth();
      this.isAdmin = !!auth.is_admin;
      this.currentUserId = auth.user_id || null;
    } catch (e) {
      this.isAdmin = false;
      this.currentUserId = null;
    }

    // Create dashboard HTML if it doesn't exist
    if (!document.getElementById('admin-dashboard')) {
      this.createDashboardHTML();
    }

    const dashboard = document.getElementById('admin-dashboard');
    dashboard.classList.add('active');

    // Gate the Administration tab by admin status
    const adminTabBtn = document.querySelector('.tab-btn[data-tab="administration"]');
    const adminPane = document.getElementById('administration-tab');
    if (this.isAdmin) {
      if (adminTabBtn) adminTabBtn.style.display = '';
      if (adminPane) adminPane.style.display = '';
      this.switchTab('administration');
      await this.loadSettings();
      await this.loadUsers();
      this.renderSettings();
      this.renderUsers();
      this.initViewEditor();
    } else {
      if (adminTabBtn) adminTabBtn.style.display = 'none';
      if (adminPane) adminPane.style.display = 'none';
      this.switchTab('layers');
    }

    await this.loadLayers();
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
            <li><button class="tab-btn active" data-tab="administration">Administration</button></li>
            <li><button class="tab-btn" data-tab="layers">Layers</button></li>
            <li><button class="tab-btn" data-tab="account">My Account</button></li>
          </ul>

          <div class="dashboard-body">
            <!-- Administration Tab -->
            <div id="administration-tab" class="tab-pane active">
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
                      <input type="text" id="setting-value">
                      <select id="setting-value-select" style="display:none;">
                        <option value="esri-imagery">ESRI Imagery</option>
                        <option value="osm">OpenStreetMap</option>
                        <option value="terrain">Open TopoMap</option>
                      </select>
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
              
              <div class="admin-form" style="margin-bottom:20px;">
                <h3>Default Map View</h3>
                <p style="color:#555;font-size:0.9em;">
                  Navigate and zoom to set the default LATITUDE, LONGITUDE and ZOOM.
                </p>
                <div id="view-editor-map" style="width:100%;height:320px;border:1px solid #ccc;border-radius:4px;"></div>
                <div class="form-actions" style="margin-top:10px;align-items:center;display:flex;gap:10px;">
                  <button type="button" class="btn btn-primary" id="save-view-btn">Save as Default View</button>
                  <span id="view-editor-status" style="font-size:0.9em;color:#555;"></span>
                </div>
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

              <div class="admin-form" style="margin-top: 30px;">
                <h3>Add User</h3>
                <form id="user-form">
                  <div class="form-row">
                    <div class="form-group">
                      <label for="user-email">Email *</label>
                      <input type="email" id="user-email" required>
                    </div>
                    <div class="form-group">
                      <label for="user-password">Password *</label>
                      <input type="password" id="user-password" required>
                    </div>
                    <div class="form-group">
                      <label class="checkbox-label">
                        <input type="checkbox" id="user-is-admin">
                        Admin
                      </label>
                    </div>
                  </div>
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add User</button>
                    <button type="button" class="btn btn-secondary" id="cancel-user">Cancel</button>
                  </div>
                </form>
              </div>

              <div id="users-table-container">
                <table class="admin-table" id="users-table">
                  <thead>
                    <tr>
                      <th>Email</th>
                      <th>Admin</th>
                      <th>Active</th>
                      <th>Created</th>
                      <th>Last Login</th>
                      <th style="width: 120px;">Actions</th>
                    </tr>
                  </thead>
                  <tbody id="users-tbody">
                    <tr><td colspan="6" class="loading">Loading users...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
            
            <!-- Layers Tab -->
            <div id="layers-tab" class="tab-pane">
              <div class="sync-bar" style="margin: 10px 0; display: flex; align-items: center; gap: 10px;">
                <button type="button" class="btn btn-primary" id="sync-layers-btn">Sync from Metadata</button>
                <button type="button" class="btn btn-secondary" id="check-wms-btn">Check WMS</button>
                <span id="sync-status" style="font-size: 0.9em; color: #555;"></span>
              </div>

              <div id="layers-table-container">
                <table class="admin-table" id="layers-table">
                  <thead>
                    <tr>
                      <th>Layer ID</th>
                      <th>Project</th>
                      <th>Property</th>
                      <th>Published</th>
                      <th>Default</th>
                      <th>WMS</th>
                      <th style="width: 260px;">Actions</th>
                    </tr>
                  </thead>
                  <tbody id="layers-tbody">
                    <tr><td colspan="7" class="loading">Loading layers...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- My Account Tab -->
            <div id="account-tab" class="tab-pane">
              <div class="admin-form">
                <h3>Change Email or Password</h3>
                <p style="color:#555;font-size:0.9em;">
                  Leave a field blank to keep it unchanged. Your current password is always required.
                </p>
                <form id="account-form">
                  <div class="form-row">
                    <div class="form-group">
                      <label for="account-current-password">Current Password *</label>
                      <input type="password" id="account-current-password" required>
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label for="account-new-email">New Email</label>
                      <input type="email" id="account-new-email" placeholder="Leave blank to keep current">
                    </div>
                    <div class="form-group">
                      <label for="account-new-password">New Password</label>
                      <input type="password" id="account-new-password" placeholder="Leave blank to keep current">
                    </div>
                  </div>
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update Account</button>
                  </div>
                  <p id="account-status" style="margin-top:10px;font-size:0.9em;"></p>
                </form>
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

    document.getElementById('user-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleUserSubmit();
    });

    document.getElementById('cancel-user').addEventListener('click', () => {
      document.getElementById('user-form').reset();
    });

    document.getElementById('sync-layers-btn').addEventListener('click', () => {
      this.handleSyncLayers();
    });

    document.getElementById('check-wms-btn').addEventListener('click', () => {
      this.checkAllWms();
    });

    document.getElementById('account-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleAccountSubmit();
    });

    const saveViewBtn = document.getElementById('save-view-btn');
    if (saveViewBtn) {
      saveViewBtn.addEventListener('click', () => this.handleSaveView());
    }
  }

  initViewEditor() {
    const container = document.getElementById('view-editor-map');
    if (!container) return;

    const getSetting = (k, fallback) => {
      const s = this.settings.find(s => s.key === k);
      const v = s ? parseFloat(s.value) : NaN;
      return Number.isFinite(v) ? v : fallback;
    };
    const lat = getSetting('LATITUDE', 0);
    const lon = getSetting('LONGITUDE', 0);
    const zoom = getSetting('ZOOM', 2);
    const baseName = (this.settings.find(s => s.key === 'BASE_MAP_DEFAULT') || {}).value;
    const baseEntry = BASE_MAP_OPTIONS[baseName] || BASE_MAP_OPTIONS['osm'];

    if (this.viewEditorMap) {
      this.viewEditorMap.setTarget(null);
      this.viewEditorMap = null;
    }

    this.viewEditorMap = new Map({
      target: container,
      layers: [baseEntry.factory()],
      view: new View({
        center: fromLonLat([lon, lat]),
        zoom
      })
    });

    setTimeout(() => this.viewEditorMap && this.viewEditorMap.updateSize(), 100);
  }

  async handleSaveView() {
    if (!this.viewEditorMap) return;
    const view = this.viewEditorMap.getView();
    const [lon, lat] = toLonLat(view.getCenter());
    const zoom = view.getZoom();
    const statusEl = document.getElementById('view-editor-status');
    statusEl.textContent = 'Saving…';
    statusEl.style.color = '#555';

    const upsert = async (key, value) => {
      const exists = this.settings.find(s => s.key === key);
      if (exists) {
        await api.updateSetting(key, String(value));
      } else {
        await api.createSetting(key, String(value));
      }
    };

    try {
      await upsert('LATITUDE', lat.toFixed(6));
      await upsert('LONGITUDE', lon.toFixed(6));
      await upsert('ZOOM', Math.round(zoom));
      statusEl.textContent = `Saved: lat ${lat.toFixed(4)}, lon ${lon.toFixed(4)}, zoom ${Math.round(zoom)}`;
      statusEl.style.color = '#2a7';
      await this.loadSettings();
      this.renderSettings();
    } catch (e) {
      statusEl.textContent = 'Error: ' + e.message;
      statusEl.style.color = '#c33';
    }
  }

  async handleAccountSubmit() {
    const currentPassword = document.getElementById('account-current-password').value;
    const newEmail = document.getElementById('account-new-email').value.trim();
    const newPassword = document.getElementById('account-new-password').value;
    const statusEl = document.getElementById('account-status');

    if (!currentPassword) {
      statusEl.textContent = 'Current password is required.';
      statusEl.style.color = '#c33';
      return;
    }
    if (!newEmail && !newPassword) {
      statusEl.textContent = 'Enter a new email or a new password.';
      statusEl.style.color = '#c33';
      return;
    }

    statusEl.textContent = 'Updating…';
    statusEl.style.color = '#555';

    try {
      await api.updateOwnAccount(currentPassword, newEmail || null, newPassword || null);
      statusEl.textContent = 'Account updated successfully.';
      statusEl.style.color = '#2a7';
      document.getElementById('account-form').reset();
      if (newEmail) this.currentUserId = newEmail;
    } catch (error) {
      statusEl.textContent = 'Error: ' + error.message;
      statusEl.style.color = '#c33';
    }
  }

  async checkAllWms() {
    const btn = document.getElementById('check-wms-btn');
    btn.disabled = true;
    const originalText = btn.textContent;
    btn.textContent = 'Checking...';

    this.layers.forEach(layer => {
      const cell = document.getElementById(`wms-status-${layer.layer_id}`);
      if (cell) cell.innerHTML = '<span style="color:#888;">…</span>';
    });

    await Promise.all(this.layers.map(async (layer) => {
      const cell = document.getElementById(`wms-status-${layer.layer_id}`);
      if (!cell) return;
      if (!layer.get_legend_url) {
        cell.innerHTML = '<span style="color:#888;" title="No URL">—</span>';
        return;
      }
      try {
        const res = await fetch(layer.get_legend_url, { method: 'GET', cache: 'no-store' });
        const ct = res.headers.get('content-type') || '';
        if (res.ok && ct.startsWith('image/')) {
          cell.innerHTML = '<span style="color:#2a7;font-weight:bold;" title="OK">✓</span>';
        } else {
          cell.innerHTML = `<span style="color:#c33;font-weight:bold;" title="HTTP ${res.status} · ${ct}">✗</span>`;
        }
      } catch (e) {
        cell.innerHTML = `<span style="color:#c33;font-weight:bold;" title="${this.escapeHtml(e.message)}">✗</span>`;
      }
    }));

    btn.disabled = false;
    btn.textContent = originalText;
  }

  async handleSyncLayers() {
    const btn = document.getElementById('sync-layers-btn');
    const statusEl = document.getElementById('sync-status');

    if (!confirm('Sync layers from sis-metadata?\n\nThis will add new layers, update existing ones, and DELETE layers no longer in the metadata server.')) {
      return;
    }

    btn.disabled = true;
    const originalText = btn.textContent;
    btn.textContent = 'Syncing...';
    statusEl.textContent = '';

    try {
      const result = await api.syncLayers();
      statusEl.textContent = `Added: ${result.added} · Updated: ${result.updated} · Deleted: ${result.deleted} (of ${result.total_metadata_records} metadata records)`;
      statusEl.style.color = '#2a7';
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      statusEl.textContent = 'Sync failed: ' + error.message;
      statusEl.style.color = '#c33';
    } finally {
      btn.disabled = false;
      btn.textContent = originalText;
    }
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

    const textInput = document.getElementById('setting-value');
    const selectInput = document.getElementById('setting-value-select');
    if (key === 'BASE_MAP_DEFAULT') {
      textInput.style.display = 'none';
      textInput.removeAttribute('required');
      selectInput.style.display = '';
      selectInput.value = BASE_MAP_OPTIONS[setting.value] ? setting.value : 'osm';
    } else {
      selectInput.style.display = 'none';
      textInput.style.display = '';
      textInput.setAttribute('required', 'required');
      textInput.value = setting.value;
    }
    document.getElementById('setting-btn-text').textContent = 'Update Setting';
    
    // Scroll to form
    document.getElementById('setting-form').scrollIntoView({ behavior: 'smooth' });
  }

  cancelSettingEdit() {
    this.editingItem = null;
    document.getElementById('setting-form').reset();
    document.getElementById('setting-key').disabled = false;
    const textInput = document.getElementById('setting-value');
    const selectInput = document.getElementById('setting-value-select');
    textInput.style.display = '';
    textInput.setAttribute('required', 'required');
    selectInput.style.display = 'none';
    document.getElementById('setting-btn-text').textContent = 'Add Setting';
  }

  async handleSettingSubmit() {
    const key = document.getElementById('setting-key').value.trim();
    const selectInput = document.getElementById('setting-value-select');
    const value = (key === 'BASE_MAP_DEFAULT' && selectInput.style.display !== 'none')
      ? selectInput.value
      : document.getElementById('setting-value').value.trim();

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
      if (['BASE_MAP_DEFAULT', 'LATITUDE', 'LONGITUDE', 'ZOOM'].includes(key)) {
        this.initViewEditor();
      }
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

  // ==================== User Management ====================

  async loadUsers() {
    try {
      this.users = await api.getUsers();
    } catch (error) {
      console.error('Error loading users:', error);
    }
  }

  renderUsers() {
    const tbody = document.getElementById('users-tbody');
    if (!tbody) return;

    if (this.users.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No users found</td></tr>';
      return;
    }

    const fmt = (d) => d ? new Date(d).toLocaleString() : '-';

    tbody.innerHTML = this.users.map(u => `
      <tr>
        <td><strong>${this.escapeHtml(u.user_id)}</strong></td>
        <td>${u.is_admin ? '<span class="badge badge-success">Admin</span>' : '-'}</td>
        <td>${u.is_active ? 'Yes' : 'No'}</td>
        <td>${fmt(u.created_at)}</td>
        <td>${fmt(u.last_login)}</td>
        <td class="actions">
          <button class="btn btn-danger" onclick="adminDashboard.deleteUser('${this.escapeHtml(u.user_id)}')">Delete</button>
        </td>
      </tr>
    `).join('');
  }

  async handleUserSubmit() {
    const email = document.getElementById('user-email').value.trim();
    const password = document.getElementById('user-password').value;
    const isAdmin = document.getElementById('user-is-admin').checked;

    if (!email || !password) {
      alert('Email and password are required');
      return;
    }

    try {
      await api.createUser(email, password, isAdmin);
      document.getElementById('user-form').reset();
      await this.loadUsers();
      this.renderUsers();
    } catch (error) {
      alert('Error creating user: ' + error.message);
    }
  }

  async deleteUser(userId) {
    if (!confirm(`Delete user "${userId}"?`)) return;
    try {
      await api.deleteUser(userId);
      await this.loadUsers();
      this.renderUsers();
    } catch (error) {
      alert('Error deleting user: ' + error.message);
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
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state">No layers found</td></tr>';
      return;
    }

    tbody.innerHTML = this.layers.map(layer => `
      <tr${layer.is_default ? ' style="background:#fff8d6;"' : ''}>
        <td><strong>${this.escapeHtml(layer.layer_id)}</strong></td>
        <td>${this.escapeHtml(layer.project_name || '-')}</td>
        <td>${this.escapeHtml(layer.property_name || '-')}</td>
        <td>
          <span class="badge ${layer.publish ? 'badge-success' : 'badge-danger'}">
            ${layer.publish ? 'Published' : 'Unpublished'}
          </span>
        </td>
        <td>${layer.is_default ? '<span class="badge badge-success">Default</span>' : '-'}</td>
        <td id="wms-status-${this.escapeHtml(layer.layer_id)}">-</td>
        <td class="actions">
          <button class="btn ${layer.publish ? 'btn-secondary' : 'btn-success'}"
                  onclick="adminDashboard.toggleLayerPublish('${this.escapeHtml(layer.layer_id)}', ${!layer.publish})">
            ${layer.publish ? 'Unpublish' : 'Publish'}
          </button>
          ${layer.is_default
            ? `<button class="btn btn-secondary" onclick="adminDashboard.clearDefaultLayer()">Clear Default</button>`
            : (layer.publish
                ? `<button class="btn btn-primary" onclick="adminDashboard.setDefaultLayer('${this.escapeHtml(layer.layer_id)}')">Set Default</button>`
                : '')}
        </td>
      </tr>
    `).join('');
  }

  async setDefaultLayer(layerId) {
    try {
      await api.setDefaultLayer(layerId);
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error setting default layer: ' + error.message);
    }
  }

  async clearDefaultLayer() {
    try {
      await api.clearDefaultLayer();
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error clearing default layer: ' + error.message);
    }
  }

  async toggleLayerPublish(layerId, publish) {
    try {
      await api.toggleLayerPublish(layerId, publish);
      await this.loadLayers();
      this.renderLayers();
    } catch (error) {
      alert('Error toggling layer publish status: ' + error.message);
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