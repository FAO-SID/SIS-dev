/**
 * Admin Panel Module
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
    label: 'Satellite',
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
      console.log('[Admin Panel] Triggering map data refresh');
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
            <h2>Admin Panel</h2>
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
              <div class="admin-section">
                <h3 class="admin-section-title">Settings</h3>

                <div class="settings-map-layout">
                  <div class="settings-table-side">
                    <div id="settings-table-container">
                      <table class="admin-table" id="settings-table" style="width:auto;">
                        <thead>
                          <tr>
                            <th>Key</th>
                            <th style="width:350px;">Value</th>
                          </tr>
                        </thead>
                        <tbody id="settings-tbody">
                          <tr><td colspan="2" class="loading">Loading settings...</td></tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <div class="settings-map-side">
                    <div id="view-editor-map" style="width:100%;aspect-ratio:21/9;border:1px solid #ccc;border-radius:4px;min-height:180px;"></div>
                  </div>
                </div>
                <!-- hidden form elements kept for compatibility -->
                <form id="setting-form" style="display:none;">
                  <input type="text" id="setting-key">
                  <input type="text" id="setting-value">
                  <select id="setting-value-select"></select>
                  <span id="setting-btn-text"></span>
                  <button id="cancel-setting" type="button"></button>
                </form>
              </div>

              <hr class="admin-divider">

              <div class="admin-section">
                <h3 class="admin-section-title">Users</h3>
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
                <div style="margin-top:var(--sp-3);">
                  <form id="user-form" style="display:flex;align-items:flex-end;gap:var(--sp-3);flex-wrap:wrap;">
                    <div class="form-group" style="margin:0;">
                      <label for="user-email" style="font-size:var(--fs-xs);margin-bottom:2px;">Email</label>
                      <input type="email" id="user-email" required style="padding:4px 8px;font-size:var(--fs-sm);">
                    </div>
                    <div class="form-group" style="margin:0;">
                      <label for="user-password" style="font-size:var(--fs-xs);margin-bottom:2px;">Password</label>
                      <input type="password" id="user-password" required style="padding:4px 8px;font-size:var(--fs-sm);">
                    </div>
                    <label class="checkbox-label" style="font-size:var(--fs-sm);margin-bottom:4px;">
                      <input type="checkbox" id="user-is-admin"> Admin
                    </label>
                    <button type="submit" class="btn btn-primary btn-sm">Add User</button>
                    <button type="button" class="btn btn-secondary btn-sm" id="cancel-user" style="display:none;">Cancel</button>
                  </form>
                </div>
              </div>
            </div>
            
            <!-- Layers Tab -->
            <div id="layers-tab" class="tab-pane">
              <div class="sync-bar" style="margin: 10px 0; display: flex; align-items: center; gap: 10px;">
                <button type="button" class="btn btn-primary" id="sync-layers-btn">Sync from Metadata</button>
                <button type="button" class="btn btn-primary" id="check-wms-btn">Check WMS</button>
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
                    </tr>
                  </thead>
                  <tbody id="layers-tbody">
                    <tr><td colspan="6" class="loading">Loading layers...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- My Account Tab -->
            <div id="account-tab" class="tab-pane">
              <div class="admin-form" style="max-width:500px;">
                <h3>Change Email or Password</h3>
                <p style="color:#555;font-size:0.85em;margin-bottom:var(--sp-4);">
                  Leave a field blank to keep it unchanged. Current password is always required.
                </p>
                <form id="account-form" style="display:grid;grid-template-columns:auto 220px;gap:var(--sp-2) var(--sp-3);align-items:center;">
                  <label for="account-current-password" style="font-size:var(--fs-sm);white-space:nowrap;">Current Password *</label>
                  <input type="password" id="account-current-password" required style="padding:4px 8px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;">
                  <label for="account-new-email" style="font-size:var(--fs-sm);white-space:nowrap;">New Email</label>
                  <input type="email" id="account-new-email" placeholder="Keep current" style="padding:4px 8px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;">
                  <label for="account-new-password" style="font-size:var(--fs-sm);white-space:nowrap;">New Password</label>
                  <input type="password" id="account-new-password" placeholder="Keep current" style="padding:4px 8px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;">
                  <div></div>
                  <div style="display:flex;align-items:center;gap:var(--sp-3);">
                    <button type="submit" class="btn btn-primary btn-sm">Update</button>
                    <span id="account-status" style="font-size:0.85em;"></span>
                  </div>
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

    // Save view is now triggered automatically on map moveend
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
    const baseEntry = BASE_MAP_OPTIONS['osm'];

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

    // Auto-save lat/lon/zoom on map move
    let saveTimeout = null;
    this.viewEditorMap.on('moveend', () => {
      if (saveTimeout) clearTimeout(saveTimeout);
      saveTimeout = setTimeout(() => this.handleSaveView(), 400);
    });
  }

  async handleSaveView() {
    if (!this.viewEditorMap) return;
    const view = this.viewEditorMap.getView();
    const [lon, lat] = toLonLat(view.getCenter());
    const zoom = view.getZoom();

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
      await this.loadSettings();
      this.renderSettings();
    } catch (e) {
      console.error('Error saving view:', e.message);
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
    const mapKeys = ['LATITUDE', 'LONGITUDE', 'ZOOM'];
    const keyOrder = ['APP_TITLE', 'ORG_LOGO_URL', 'BASE_MAP_DEFAULT', 'LATITUDE', 'LONGITUDE', 'ZOOM'];

    if (this.settings.length === 0) {
      tbody.innerHTML = '<tr><td colspan="2" class="empty-state">No settings found</td></tr>';
      return;
    }

    // Sort: known keys first in keyOrder, then remaining alphabetically
    const sorted = [...this.settings].sort((a, b) => {
      const ia = keyOrder.indexOf(a.key);
      const ib = keyOrder.indexOf(b.key);
      if (ia !== -1 && ib !== -1) return ia - ib;
      if (ia !== -1) return -1;
      if (ib !== -1) return 1;
      return a.key.localeCompare(b.key);
    });

    tbody.innerHTML = sorted.map(setting => {
      const key = this.escapeHtml(setting.key);
      const isMapKey = mapKeys.includes(setting.key);
      const isBaseMap = setting.key === 'BASE_MAP_DEFAULT';
      let valueCell;
      if (isBaseMap) {
        const opts = Object.entries(BASE_MAP_OPTIONS).map(([k, v]) =>
          `<option value="${k}"${setting.value === k ? ' selected' : ''}>${v.label}</option>`
        ).join('');
        valueCell = `<select class="inline-edit" data-key="${key}" style="padding:2px 6px;font-size:var(--fs-sm);">${opts}</select>`;
      } else {
        valueCell = `<input class="inline-edit" data-key="${key}" value="${this.escapeHtml(setting.value)}" style="padding:2px 6px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;"${isMapKey ? ' readonly title="Controlled by the map"' : ''}>`;
      }
      return `
        <tr>
          <td><strong>${key}</strong></td>
          <td>${valueCell}</td>
        </tr>`;
    }).join('');

    // Attach inline save on blur / change
    tbody.querySelectorAll('.inline-edit').forEach(el => {
      const event = el.tagName === 'SELECT' ? 'change' : 'blur';
      el.addEventListener(event, async () => {
        const key = el.dataset.key;
        const value = el.value.trim();
        if (!value) return;
        const setting = this.settings.find(s => s.key === key);
        if (setting && setting.value === value) return;
        try {
          await api.updateSetting(key, value);
          await this.loadSettings();
          if (['BASE_MAP_DEFAULT', 'LATITUDE', 'LONGITUDE', 'ZOOM'].includes(key)) {
            this.initViewEditor();
          }
        } catch (err) {
          alert('Error saving: ' + err.message);
        }
      });
      // Save on Enter for text inputs
      if (el.tagName === 'INPUT') {
        el.addEventListener('keydown', (e) => {
          if (e.key === 'Enter') { e.preventDefault(); el.blur(); }
        });
      }
    });
  }

  editSetting(key) {
    // Focus the inline input for this key
    const input = document.querySelector(`.inline-edit[data-key="${key}"]`);
    if (input) input.focus();
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
    document.getElementById('setting-btn-text').textContent = 'Add';
    document.getElementById('cancel-setting').style.display = 'none';
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

    const adminCount = this.users.filter(u => u.is_admin).length;

    tbody.innerHTML = this.users.map(u => {
      const isOnlyAdmin = u.is_admin && adminCount <= 1;
      const deleteBtn = isOnlyAdmin
        ? ''
        : `<button class="btn btn-danger btn-sm" onclick="adminDashboard.deleteUser('${this.escapeHtml(u.user_id)}')">Delete</button>`;
      let activeLabel;
      if (isOnlyAdmin) {
        activeLabel = '<span class="badge badge-success" title="Only admin — cannot deactivate">Yes</span>';
      } else if (u.is_active) {
        activeLabel = '<span class="badge badge-success toggle-active" style="cursor:pointer;" title="Click to deactivate">Yes</span>';
      } else {
        activeLabel = '<span class="badge badge-danger toggle-active" style="cursor:pointer;" title="Click to activate">No</span>';
      }
      return `
        <tr>
          <td><strong>${this.escapeHtml(u.user_id)}</strong></td>
          <td>${u.is_admin ? '<span class="badge badge-success">Admin</span>' : '-'}</td>
          <td data-user-id="${this.escapeHtml(u.user_id)}" data-active="${u.is_active}">${activeLabel}</td>
          <td>${fmt(u.created_at)}</td>
          <td>${fmt(u.last_login)}</td>
          <td class="actions">${deleteBtn}</td>
        </tr>`;
    }).join('');

    // Attach click handlers for active toggle
    tbody.querySelectorAll('.toggle-active').forEach(el => {
      el.addEventListener('click', async () => {
        const td = el.closest('td');
        const userId = td.dataset.userId;
        const currentlyActive = td.dataset.active === 'true';
        try {
          await api.toggleUserActive(userId, !currentlyActive);
          await this.loadUsers();
          this.renderUsers();
        } catch (err) {
          alert('Error toggling active status: ' + err.message);
        }
      });
    });
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
      tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No layers found</td></tr>';
      return;
    }

    tbody.innerHTML = this.layers.map(layer => {
      const id = this.escapeHtml(layer.layer_id);
      const defaultCell = layer.is_default
        ? `<button class="btn btn-secondary" onclick="adminDashboard.clearDefaultLayer()">Clear Default</button>`
        : (layer.publish
            ? `<button class="btn btn-primary" onclick="adminDashboard.setDefaultLayer('${id}')">Set Default</button>`
            : '-');
      return `
      <tr${layer.is_default ? ' style="background:#fff8d6;"' : ''}>
        <td><strong>${id}</strong></td>
        <td>${this.escapeHtml(layer.project_name || '-')}</td>
        <td>${this.escapeHtml(layer.property_name || '-')}</td>
        <td>
          <button class="btn ${layer.publish ? 'btn-secondary' : 'btn-success'}"
                  onclick="adminDashboard.toggleLayerPublish('${id}', ${!layer.publish})">
            ${layer.publish ? 'Unpublish' : 'Publish'}
          </button>
        </td>
        <td>${defaultCell}</td>
        <td id="wms-status-${id}">-</td>
      </tr>
    `;
    }).join('');
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