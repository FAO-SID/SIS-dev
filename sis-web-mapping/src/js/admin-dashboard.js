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
import Chart from 'chart.js/auto';

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
    // ETL state
    this.etlCodelists = {};
    this.etlUploadResult = null;
    this.etlDatasets = [];
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
      this.initGlosis();
    } else {
      if (adminTabBtn) adminTabBtn.style.display = 'none';
      if (adminPane) adminPane.style.display = 'none';
      this.switchTab('layers');
    }

    await this.loadLayers();
    this.renderLayers();
    await this.loadSoilProfileLayers();
    this.renderSoilProfileLayers();
  }

  /**
   * Hide the admin dashboard
   */
  hide() {
    this.flushPendingSoilProfileEdits();
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
            <li><button class="tab-btn" data-tab="account">My Account</button></li>
            <li><button class="tab-btn active" data-tab="administration">Administration</button></li>
            <li><button class="tab-btn" data-tab="layers">Layers</button></li>
            <li><button class="tab-btn" data-tab="etl">ETL</button></li>
            <li><button class="tab-btn" data-tab="dashboard">Dashboard</button></li>
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
                      <th>Username</th>
                      <th>Admin</th>
                      <th>Active</th>
                      <th>Created</th>
                      <th>Last login</th>
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
                      <label for="user-email" style="font-size:var(--fs-xs);margin-bottom:2px;">Username</label>
                      <input type="text" id="user-email" required style="padding:4px 8px;font-size:var(--fs-sm);">
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

              <hr class="admin-divider">

              <div class="admin-section" id="glosis-section">
                <h3 class="admin-section-title">GloSIS Federation</h3>
                <p style="color:#555;font-size:var(--fs-sm);margin:0 0 var(--sp-3);">
                  When enabled, this SIS connects to the GloSIS Federation.<br>
                  The profiles shown in the federation will be the same ones currently visible on this SIS
                  (customizable under Layers → Soil profiles).<br>
                  Rasters will be advertised separately via the public metadata catalogue.
                </p>
                <div style="display:flex;align-items:center;gap:var(--sp-3);margin-bottom:var(--sp-3);">
                  <span><strong>Status:</strong> <span id="glosis-status">…</span></span>
                  <button type="button" class="btn btn-success btn-sm" id="glosis-enable-btn">Enable</button>
                  <button type="button" class="btn btn-sm" id="glosis-disable-btn" style="background:#ffc107;color:#212529;">Disable</button>
                  <button type="button" class="btn btn-sm" id="glosis-disable-delete-btn" style="background:#dc3545;color:#fff;">Disable &amp; Delete token</button>
                </div>

                <div style="margin-bottom:var(--sp-3);">
                  <strong>Endpoints to share with the GloSIS Discovery Hub:</strong>
                  <ul id="glosis-endpoints" style="margin:4px 0 0 18px;font-size:var(--fs-sm);"></ul>
                </div>

              </div>
            </div>

            <!-- Dashboard Tab -->
            <div id="dashboard-tab" class="tab-pane">
              <div id="dashboard-empty" style="padding:var(--sp-5,24px);color:#777;">Loading dashboard…</div>
              <div id="dashboard-content" style="display:none;">
                <div class="stat-card-grid" id="stat-card-grid"></div>
                <div class="chart-grid">
                  <div class="chart-card">
                    <h4 class="chart-title">Profiles per project</h4>
                    <div class="chart-wrap"><canvas id="chart-profiles-per-project"></canvas></div>
                  </div>
                  <div class="chart-card">
                    <h4 class="chart-title">Top measured properties</h4>
                    <div class="chart-wrap"><canvas id="chart-top-properties"></canvas></div>
                  </div>
                  <div class="chart-card chart-card-wide">
                    <h4 class="chart-title">Profiles sampled per year</h4>
                    <div class="chart-wrap"><canvas id="chart-profiles-per-year"></canvas></div>
                  </div>
                  <div class="chart-card">
                    <h4 class="chart-title">Observation depth distribution</h4>
                    <div class="chart-wrap"><canvas id="chart-depth-distribution"></canvas></div>
                  </div>
                  <div class="chart-card">
                    <h4 class="chart-title">Value range per property (min / Q1–Q3 / max)</h4>
                    <div class="chart-wrap"><canvas id="chart-value-summary"></canvas></div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Layers Tab -->
            <div id="layers-tab" class="tab-pane">

              <!-- Soil profiles section -->
              <section class="layers-section">
                <h3 class="layers-section-title">Soil profiles</h3>
                <div id="soil-profile-layers-container">
                  <table class="admin-table" id="soil-profile-layers-table">
                    <thead>
                      <tr>
                        <th>Project</th>
                        <th>Profiles</th>
                        <th>Observations</th>
                        <th>Public limit</th>
                        <th title="Random coordinate offset in meters. Blank = precise coords.">Spatial blur (meters)</th>
                        <th>Published</th>
                      </tr>
                    </thead>
                    <tbody id="soil-profile-layers-tbody">
                      <tr><td colspan="6" class="loading">Loading soil profile layers...</td></tr>
                    </tbody>
                  </table>
                </div>
              </section>

              <!-- Maps section -->
              <section class="layers-section" style="margin-top: var(--sp-6, 24px);">
                <h3 class="layers-section-title">Rasters</h3>
                <div class="sync-bar" style="margin: 10px 0; display: flex; align-items: center; gap: 10px;">
                  <button type="button" class="btn btn-primary" id="sync-layers-btn">Sync from Metadata</button>
                  <button type="button" class="btn btn-primary" id="check-wms-btn">Check WMS</button>
                  <span id="sync-status" style="font-size: 0.9em; color: #555;"></span>
                </div>

                <div id="layers-table-container">
                  <table class="admin-table" id="layers-table">
                    <thead>
                      <tr>
                        <th>Raster ID</th>
                        <th style="width:120px;">Group</th>
                        <th>Raster name</th>
                        <th>Published</th>
                        <th>Default</th>
                        <th>WMS</th>
                        <th>Download</th>
                      </tr>
                    </thead>
                    <tbody id="layers-tbody">
                      <tr><td colspan="7" class="loading">Loading layers...</td></tr>
                    </tbody>
                  </table>
                </div>
              </section>
            </div>

            <!-- ETL Tab -->
            <div id="etl-tab" class="tab-pane">
              <div class="etl-steps">

                <!-- List view (always visible unless detail panel open) -->
                <div id="etl-list-view">
                  <div style="display:flex;align-items:center;gap:var(--sp-3);margin-bottom:var(--sp-4);">
                    <input type="file" id="etl-file-input" accept=".csv">
                    <button type="button" class="btn btn-primary btn-sm" id="etl-upload-btn">Upload CSV</button>
                    <span id="etl-upload-status" style="font-size:var(--fs-sm);"></span>
                  </div>
                  <div id="etl-datasets-list"></div>
                </div>

                <!-- Detail panel (hidden until Open is clicked) -->
                <div id="etl-detail-panel" style="display:none;">

                  <div style="margin-bottom:var(--sp-4);">
                    <button type="button" class="btn btn-secondary btn-sm" id="etl-back-btn">&larr; Back to list</button>
                    <span id="etl-detail-title" style="font-weight:600;margin-left:var(--sp-3);"></span>
                  </div>

                  <!-- Preview -->
                  <details id="etl-preview-section" class="etl-section" open>
                    <summary class="etl-section-title" style="cursor:pointer;">Preview <span id="etl-preview-info" style="font-weight:normal;font-size:var(--fs-sm);color:#555;"></span></summary>
                    <div class="etl-preview-scroll" style="margin-top:var(--sp-3);">
                      <table class="admin-table" id="etl-preview-table">
                        <thead id="etl-preview-thead"></thead>
                        <tbody id="etl-preview-tbody"></tbody>
                      </table>
                    </div>
                    <div id="etl-preview-pager" style="display:flex;align-items:center;gap:var(--sp-3);font-size:var(--fs-sm);margin-bottom:var(--sp-3);">
                      <button type="button" class="btn btn-sm" id="etl-preview-prev">Previous</button>
                      <span id="etl-preview-page-info"></span>
                      <button type="button" class="btn btn-sm" id="etl-preview-next">Next</button>
                    </div>
                  </details>

                  <!-- Metadata -->
                  <div id="etl-section-metadata" class="etl-section">
                    <h3 class="etl-section-title">Metadata</h3>
                    <form id="etl-metadata-form">
                      <div class="etl-metadata-grid" style="margin-bottom:var(--sp-4);">
                        <label for="etl-project">Project</label>
                        <div>
                          <select id="etl-project" required><option value="">Loading...</option></select>
                          <div id="etl-new-project" class="etl-new-entry" style="display:none;">
                            <input type="text" id="etl-new-project-id" placeholder="Project ID" style="margin-top:4px;">
                            <input type="text" id="etl-new-project-name" placeholder="Project Name" style="margin-top:4px;">
                            <button type="button" class="btn btn-primary btn-sm" style="margin-top:4px;" onclick="adminDashboard.addNewProject()">Add</button>
                            <button type="button" class="btn btn-secondary btn-sm" style="margin-top:4px;" onclick="adminDashboard.cancelNew('project')">Cancel</button>
                          </div>
                        </div>
                      </div>

                      <div class="etl-metadata-grid" style="margin-bottom:var(--sp-4);">
                        <label for="etl-abstract">Abstract</label>
                        <div><textarea id="etl-abstract" rows="3" style="width:100%;font-family:inherit;font-size:var(--fs-sm);padding:4px 8px;border:1px solid var(--color-border-strong);border-radius:var(--radius-sm);" placeholder="Project description..."></textarea></div>
                        <label for="etl-license">License</label>
                        <div>
                          <select id="etl-license" style="width:100%;">
                            <option value="">-- Select --</option>
                            <option value="CC BY">CC BY</option>
                            <option value="CC BY-SA">CC BY-SA</option>
                            <option value="CC BY-NC">CC BY-NC</option>
                            <option value="CC BY-NC-SA">CC BY-NC-SA</option>
                            <option value="CC BY-ND">CC BY-ND</option>
                            <option value="CC BY-NC-ND">CC BY-NC-ND</option>
                            <option value="CC0">CC0</option>
                            <option value="Public Domain Mark">Public Domain Mark</option>
                          </select>
                        </div>
                        <label for="etl-epsg">EPSG code of the coordinates</label>
                        <div><input type="text" id="etl-epsg" value="4326" style="width:80px;padding:2px 6px;font-size:var(--fs-sm);"></div>
                      </div>

                      <div class="etl-author-row etl-author-header">
                        <div class="etl-author-field"><label>Organisation</label></div>
                        <div class="etl-author-field"><label>Author</label></div>
                        <div class="etl-author-field etl-author-field-sm"><label>Position</label></div>
                        <div class="etl-author-field etl-author-field-sm"><label>Tag</label></div>
                        <div class="etl-author-field etl-author-field-sm"><label>Role</label></div>
                      </div>
                      <div id="etl-author-rows"></div>

                      <div id="etl-new-org-block" class="etl-new-entry" style="display:none;margin-top:var(--sp-2);margin-bottom:var(--sp-2);">
                        <strong style="font-size:var(--fs-xs);">New Organisation</strong>
                        <div style="display:flex;gap:var(--sp-2);margin-top:4px;flex-wrap:wrap;">
                          <input type="text" id="etl-new-org-id" placeholder="Organisation ID" style="flex:1;min-width:100px;">
                          <input type="text" id="etl-new-org-country" placeholder="Country" style="flex:1;min-width:80px;">
                          <input type="text" id="etl-new-org-city" placeholder="City" style="flex:1;min-width:80px;">
                          <button type="button" class="btn btn-primary btn-sm" onclick="adminDashboard.addNewOrganisation()">Add</button>
                          <button type="button" class="btn btn-secondary btn-sm" onclick="adminDashboard.cancelNew('organisation')">Cancel</button>
                        </div>
                      </div>
                      <div id="etl-new-ind-block" class="etl-new-entry" style="display:none;margin-bottom:var(--sp-2);">
                        <strong style="font-size:var(--fs-xs);">New Author</strong>
                        <div style="display:flex;gap:var(--sp-2);margin-top:4px;flex-wrap:wrap;">
                          <input type="text" id="etl-new-ind-id" placeholder="Name / ID" style="flex:1;min-width:100px;">
                          <input type="email" id="etl-new-ind-email" placeholder="Email" style="flex:1;min-width:100px;">
                          <button type="button" class="btn btn-primary btn-sm" onclick="adminDashboard.addNewIndividual()">Add</button>
                          <button type="button" class="btn btn-secondary btn-sm" onclick="adminDashboard.cancelNew('individual')">Cancel</button>
                        </div>
                      </div>

                      <div style="margin-top:var(--sp-3);">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="adminDashboard.addAuthorRow()">+ Add Author</button>
                      </div>
                    </form>
                  </div>

                  <!-- Standardization -->
                  <div id="etl-mapping-section" class="etl-section">
                    <h3 class="etl-section-title">Standardization</h3>
                    <table class="admin-table" id="etl-mapping-table">
                      <thead>
                        <tr>
                          <th>CSV column</th>
                          <th>Destination</th>
                          <th>Property</th>
                          <th>Procedure</th>
                          <th>Unit</th>
                          <th>Validation</th>
                        </tr>
                      </thead>
                      <tbody id="etl-mapping-tbody"></tbody>
                    </table>
                  </div>

                  <!-- Save / Validate -->
                  <div style="margin-top:var(--sp-5);display:flex;align-items:center;gap:var(--sp-3);">
                    <button type="button" class="btn btn-primary" id="etl-save-btn">Save</button>
                    <button type="button" class="btn" id="etl-validate-btn" style="background:#17a2b8;color:#fff;">Validate</button>
                    <span id="etl-save-status" style="font-size:var(--fs-sm);"></span>
                  </div>

                </div>

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
                  <label for="account-new-email" style="font-size:var(--fs-sm);white-space:nowrap;">New username</label>
                  <input type="text" id="account-new-email" placeholder="Keep current" style="padding:4px 8px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;">
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

    // ETL metadata form — prevent default submit, save handled by unified button
    document.getElementById('etl-metadata-form').addEventListener('submit', (e) => {
      e.preventDefault();
    });

    // ETL upload
    document.getElementById('etl-upload-btn').addEventListener('click', () => {
      this.handleEtlUpload();
    });

    // ETL back to list
    document.getElementById('etl-back-btn').addEventListener('click', () => {
      this.closeDetailPanel();
    });

    // ETL unified save (attribution + standardization)
    document.getElementById('etl-save-btn').addEventListener('click', () => {
      this.handleEtlSave();
    });

    // ETL validate
    document.getElementById('etl-validate-btn').addEventListener('click', () => {
      this.handleEtlValidate();
    });

    // Preview pagination
    document.getElementById('etl-preview-prev').addEventListener('click', () => {
      if (this.etlPreviewPage > 0) { this.etlPreviewPage--; this.renderEtlPreviewPage(); }
    });
    document.getElementById('etl-preview-next').addEventListener('click', () => {
      const total = (this.etlPreviewRows || []).length;
      const max = Math.max(0, Math.ceil(total / (this.etlPreviewPageSize || 100)) - 1);
      if (this.etlPreviewPage < max) { this.etlPreviewPage++; this.renderEtlPreviewPage(); }
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
    if (this.currentTab === 'layers' && tab !== 'layers') {
      this.flushPendingSoilProfileEdits();
    }
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

    // Load ETL codelists when tab is first opened
    if (tab === 'etl' && !this.etlCodelistsLoaded) {
      this.loadEtlCodelists();
    }

    if (tab === 'dashboard') {
      this.loadDashboard();
    }
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
    // Infrastructure settings — kept in DB but hidden from the UI to avoid accidental edits
    const hiddenKeys = new Set(['DOWNLOAD_BASE_URL', 'GLOSIS_FEDERATION_ENABLED']);

    const visible = this.settings.filter(s => !hiddenKeys.has(s.key));

    if (visible.length === 0) {
      tbody.innerHTML = '<tr><td colspan="2" class="empty-state">No settings found</td></tr>';
      return;
    }

    // Sort: known keys first in keyOrder, then remaining alphabetically
    const sorted = [...visible].sort((a, b) => {
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
        : `<button class="btn btn-danger btn-sm" onclick="adminDashboard.deleteUser('${this.escapeJsAttr(u.user_id)}')">Delete</button>`;
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
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state">No layers found</td></tr>';
      return;
    }

    const baseSetting = (this.settings || []).find(s => s.key === 'DOWNLOAD_BASE_URL');
    const downloadBase = baseSetting ? baseSetting.value : '/downloads/';

    const editStyle = 'padding:2px 6px;font-size:var(--fs-sm);width:100%;box-sizing:border-box;background:transparent;border:1px solid transparent;';
    tbody.innerHTML = this.layers.map(layer => {
      const id = this.escapeHtml(layer.layer_id);
      const idJs = this.escapeJsAttr(layer.layer_id);
      const defaultCell = layer.is_default
        ? `<button class="btn btn-secondary" onclick="adminDashboard.clearDefaultLayer()">Clear Default</button>`
        : (layer.publish
            ? `<button class="btn btn-primary" onclick="adminDashboard.setDefaultLayer('${idJs}')">Set Default</button>`
            : '-');
      const downloadUrl = layer.download_url
        || (downloadBase.replace(/\/$/, '') + '/' + layer.layer_id + '.tif');
      const downloadCell = `<a class="btn btn-sm btn-secondary" href="${this.escapeHtml(downloadUrl)}" download title="Download GeoTIFF">GeoTIFF</a>`;
      return `
      <tr${layer.is_default ? ' style="background:#fff8d6;"' : ''}>
        <td><strong>${id}</strong></td>
        <td style="width:120px;"><input class="layer-edit" data-layer-id="${id}" data-field="project_name" value="${this.escapeHtml(layer.project_name || '')}" placeholder="-" style="${editStyle}" title="Click to edit"></td>
        <td><input class="layer-edit" data-layer-id="${id}" data-field="property_name" value="${this.escapeHtml(layer.property_name || '')}" placeholder="-" style="${editStyle}" title="Click to edit"></td>
        <td>
          <button class="btn ${layer.publish ? 'btn-secondary' : 'btn-success'}"
                  onclick="adminDashboard.toggleLayerPublish('${idJs}', ${!layer.publish})">
            ${layer.publish ? 'Unpublish' : 'Publish'}
          </button>
        </td>
        <td>${defaultCell}</td>
        <td id="wms-status-${id}">-</td>
        <td>${downloadCell}</td>
      </tr>
    `;
    }).join('');

    tbody.querySelectorAll('.layer-edit').forEach(el => {
      el.addEventListener('focus', () => { el.style.border = '1px solid #ccc'; el.style.background = '#fff'; });
      el.addEventListener('keydown', e => { if (e.key === 'Enter') el.blur(); });
      el.addEventListener('blur', async () => {
        el.style.border = '1px solid transparent';
        el.style.background = 'transparent';
        const layerId = el.dataset.layerId;
        const field = el.dataset.field;
        const newValue = el.value.trim() || null;
        const layer = this.layers.find(l => l.layer_id === layerId);
        if (!layer) return;
        if ((layer[field] || null) === newValue) return;
        const updated = { ...layer, [field]: newValue };
        try {
          await api.updateLayer(layerId, updated);
          layer[field] = newValue;
        } catch (e) {
          alert('Failed to save: ' + e.message);
          el.value = layer[field] || '';
        }
      });
    });
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

  // ==================== Soil Profile Layers ====================

  async loadSoilProfileLayers() {
    try {
      this.soilProfileLayers = await api.getSoilProfileLayers();
    } catch (error) {
      console.error('Error loading soil profile layers:', error);
      this.soilProfileLayers = [];
    }
  }

  renderSoilProfileLayers() {
    const tbody = document.getElementById('soil-profile-layers-tbody');
    if (!tbody) return;

    const rows = this.soilProfileLayers || [];
    if (rows.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No projects found</td></tr>';
      return;
    }

    tbody.innerHTML = rows.map(r => {
      const pid = this.escapeHtml(r.project_id);
      const name = this.escapeHtml(r.project_name || r.project_id);
      const limitVal = r.profile_limit == null ? '' : String(r.profile_limit);
      const blurVal = r.spatial_blur_m == null ? '' : String(r.spatial_blur_m);
      const totalProfiles = Number(r.total_profile_count || 0);
      const pubProfiles = Number(r.published_profile_count || 0);
      const totalObs = Number(r.total_observation_count || 0);
      const pubObs = Number(r.published_observation_count || 0);
      return `
      <tr>
        <td><strong>${name}</strong></td>
        <td title="Published / Total">
          <span class="sp-count-pub">${pubProfiles.toLocaleString()}</span>
          <span class="sp-count-sep">/</span>
          <span class="sp-count-total">${totalProfiles.toLocaleString()}</span>
        </td>
        <td title="Published / Total">
          <span class="sp-count-pub">${pubObs.toLocaleString()}</span>
          <span class="sp-count-sep">/</span>
          <span class="sp-count-total">${totalObs.toLocaleString()}</span>
        </td>
        <td>
          <input type="number" min="1" step="1" class="sp-limit-input"
                 data-project-id="${pid}" value="${this.escapeHtml(limitVal)}"
                 placeholder="no limit" inputmode="numeric">
          <span class="sp-limit-status" data-project-id="${pid}"></span>
        </td>
        <td>
          <input type="number" min="0" step="1" class="sp-blur-input"
                 data-project-id="${pid}" value="${this.escapeHtml(blurVal)}"
                 placeholder="precise" inputmode="numeric">
          <span class="sp-blur-status" data-project-id="${pid}"></span>
        </td>
        <td>
          <button class="btn ${r.is_published ? 'btn-secondary' : 'btn-success'} sp-publish-btn"
                  data-project-id="${pid}" data-publish="${r.is_published ? '0' : '1'}">
            ${r.is_published ? 'Unpublish' : 'Publish'}
          </button>
        </td>
      </tr>`;
    }).join('');

    tbody.querySelectorAll('.sp-publish-btn').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const projectId = e.currentTarget.dataset.projectId;
        const publish = e.currentTarget.dataset.publish === '1';
        await this.flushPendingSoilProfileEdits();
        this.toggleSoilProfilePublish(projectId, publish);
      });
    });

    this.pendingSoilProfileLimits = this.pendingSoilProfileLimits || {};
    this.pendingSoilProfileBlurs = this.pendingSoilProfileBlurs || {};
    tbody.querySelectorAll('.sp-limit-input').forEach(input => {
      input.addEventListener('input', (e) => {
        const projectId = e.currentTarget.dataset.projectId;
        const raw = (e.currentTarget.value || '').trim();
        const current = this.soilProfileLayers.find(r => r.project_id === projectId);
        const original = current && current.profile_limit != null ? String(current.profile_limit) : '';
        if (raw === original) {
          delete this.pendingSoilProfileLimits[projectId];
        } else {
          this.pendingSoilProfileLimits[projectId] = raw;
        }
      });
    });
    tbody.querySelectorAll('.sp-blur-input').forEach(input => {
      input.addEventListener('input', (e) => {
        const projectId = e.currentTarget.dataset.projectId;
        const raw = (e.currentTarget.value || '').trim();
        const current = this.soilProfileLayers.find(r => r.project_id === projectId);
        const original = current && current.spatial_blur_m != null ? String(current.spatial_blur_m) : '';
        if (raw === original) {
          delete this.pendingSoilProfileBlurs[projectId];
        } else {
          this.pendingSoilProfileBlurs[projectId] = raw;
        }
      });
    });
  }

  setSoilProfileBlurStatus(projectId, text, isError = false) {
    const el = document.querySelector(`.sp-blur-status[data-project-id="${CSS.escape(projectId)}"]`);
    if (!el) return;
    el.textContent = text;
    el.style.color = isError ? '#a80000' : '#2e7d32';
    if (text) setTimeout(() => { if (el.textContent === text) el.textContent = ''; }, 3000);
  }

  setSoilProfileLimitStatus(projectId, text, isError = false) {
    const el = document.querySelector(`.sp-limit-status[data-project-id="${CSS.escape(projectId)}"]`);
    if (!el) return;
    el.textContent = text;
    el.style.color = isError ? '#a80000' : '#2e7d32';
    if (text) setTimeout(() => { if (el.textContent === text) el.textContent = ''; }, 3000);
  }

  async toggleSoilProfilePublish(projectId, publish) {
    try {
      await api.setSoilProfilePublish(projectId, publish);
      await this.loadSoilProfileLayers();
      this.renderSoilProfileLayers();
    } catch (error) {
      alert('Error updating publish state: ' + error.message);
    }
  }

  async flushPendingSoilProfileLimits() {
    const pending = this.pendingSoilProfileLimits || {};
    const entries = Object.entries(pending);
    if (entries.length === 0) return false;
    this.pendingSoilProfileLimits = {};
    let anySaved = false;
    let anyError = false;
    for (const [projectId, raw] of entries) {
      const limit = raw === '' ? null : parseInt(raw, 10);
      if (limit !== null && (Number.isNaN(limit) || limit <= 0)) {
        this.setSoilProfileLimitStatus(projectId, 'Invalid — must be a positive integer', true);
        anyError = true;
        continue;
      }
      try {
        await api.setSoilProfileLimit(projectId, limit);
        const row = (this.soilProfileLayers || []).find(r => r.project_id === projectId);
        if (row) row.profile_limit = limit;
        anySaved = true;
      } catch (error) {
        this.setSoilProfileLimitStatus(projectId, error.message || 'Error saving limit', true);
        anyError = true;
      }
    }
    return { anySaved, anyError };
  }

  async flushPendingSoilProfileBlurs() {
    const pending = this.pendingSoilProfileBlurs || {};
    const entries = Object.entries(pending);
    if (entries.length === 0) return { anySaved: false, anyError: false };
    this.pendingSoilProfileBlurs = {};
    let anySaved = false;
    let anyError = false;
    for (const [projectId, raw] of entries) {
      const blur = raw === '' ? null : parseInt(raw, 10);
      if (blur !== null && (Number.isNaN(blur) || blur < 0)) {
        this.setSoilProfileBlurStatus(projectId, 'Invalid — must be ≥ 0 or blank', true);
        anyError = true;
        continue;
      }
      try {
        await api.setSoilProfileBlur(projectId, blur);
        const row = (this.soilProfileLayers || []).find(r => r.project_id === projectId);
        if (row) row.spatial_blur_m = blur;
        anySaved = true;
      } catch (error) {
        this.setSoilProfileBlurStatus(projectId, error.message || 'Error saving blur', true);
        anyError = true;
      }
    }
    return { anySaved, anyError };
  }

  async flushPendingSoilProfileEdits() {
    const [a, b] = await Promise.all([
      this.flushPendingSoilProfileLimits(),
      this.flushPendingSoilProfileBlurs(),
    ]);
    if (a.anySaved || b.anySaved) {
      await this.loadSoilProfileLayers();
      this.renderSoilProfileLayers();
    }
    return a.anySaved || b.anySaved || a.anyError || b.anyError;
  }

  // ==================== Dashboard (stats) ====================

  async loadDashboard() {
    const empty = document.getElementById('dashboard-empty');
    const content = document.getElementById('dashboard-content');
    if (!empty || !content) return;

    if (this.dashboardLoaded) return; // one-shot; user can reload page to refresh
    try {
      empty.textContent = 'Loading dashboard…';
      const stats = await api.getDashboardStats();
      this.renderDashboardCards(stats.totals || {});
      this.renderDashboardCharts(stats);
      empty.style.display = 'none';
      content.style.display = '';
      this.dashboardLoaded = true;
    } catch (e) {
      console.error('Dashboard load failed:', e);
      empty.textContent = 'Failed to load dashboard: ' + (e.message || e);
    }
  }

  renderDashboardCards(t) {
    const grid = document.getElementById('stat-card-grid');
    if (!grid) return;
    const fmt = (n) => Number(n || 0).toLocaleString();
    const cards = [
      { label: 'Profiles', value: fmt(t.profile_count), accent: 'a' },
      { label: 'Observations', value: fmt(t.observation_count), accent: 'b' },
      { label: 'Projects', value: fmt(t.project_count), accent: 'c' },
      { label: 'Properties', value: fmt(t.property_count), accent: 'd' },
      { label: 'Sites', value: fmt(t.site_count), accent: 'e' },
    ];
    grid.innerHTML = cards.map(c => `
      <div class="stat-card stat-card-${c.accent}">
        <div class="stat-card-value">${this.escapeHtml(c.value)}</div>
        <div class="stat-card-label">${this.escapeHtml(c.label)}</div>
      </div>
    `).join('');
  }

  renderDashboardCharts(stats) {
    if (this._dashboardCharts) {
      Object.values(this._dashboardCharts).forEach(c => c && c.destroy && c.destroy());
    }
    this._dashboardCharts = {};

    const palette = [
      '#2e7d32', '#1976d2', '#ef6c00', '#8e24aa',
      '#c62828', '#00838f', '#6d4c41', '#455a64',
      '#558b2f', '#ad1457'
    ];
    const paletteFor = (n) => Array.from({ length: n }, (_, i) => palette[i % palette.length]);

    const baseOpts = {
      responsive: true,
      maintainAspectRatio: false,
      animation: { duration: 700, easing: 'easeOutQuart' },
      plugins: { legend: { display: false } },
    };

    // Profiles per project (horizontal bar)
    const pp = stats.profiles_per_project || [];
    this._dashboardCharts.profilesPerProject = new Chart(
      document.getElementById('chart-profiles-per-project'),
      {
        type: 'bar',
        data: {
          labels: pp.map(r => r.project_name),
          datasets: [{
            data: pp.map(r => r.profile_count),
            backgroundColor: paletteFor(pp.length),
            borderRadius: 4,
          }],
        },
        options: { ...baseOpts, indexAxis: 'y', scales: { x: { beginAtZero: true } } },
      }
    );

    // Top properties (horizontal bar)
    const tp = stats.top_properties || [];
    this._dashboardCharts.topProperties = new Chart(
      document.getElementById('chart-top-properties'),
      {
        type: 'bar',
        data: {
          labels: tp.map(r => r.property),
          datasets: [{
            data: tp.map(r => r.observation_count),
            backgroundColor: paletteFor(tp.length),
            borderRadius: 4,
          }],
        },
        options: { ...baseOpts, indexAxis: 'y', scales: { x: { beginAtZero: true } } },
      }
    );

    // Profiles per year (line, filled)
    const py = stats.profiles_per_year || [];
    this._dashboardCharts.profilesPerYear = new Chart(
      document.getElementById('chart-profiles-per-year'),
      {
        type: 'line',
        data: {
          labels: py.map(r => String(r.year)),
          datasets: [{
            data: py.map(r => r.profile_count),
            borderColor: '#2e7d32',
            backgroundColor: 'rgba(46,125,50,0.15)',
            fill: true,
            tension: 0.35,
            pointRadius: 3,
            pointHoverRadius: 5,
            borderWidth: 2,
          }],
        },
        options: { ...baseOpts, scales: { y: { beginAtZero: true } } },
      }
    );

    // Depth distribution (vertical bar)
    const dd = stats.depth_distribution || [];
    this._dashboardCharts.depthDistribution = new Chart(
      document.getElementById('chart-depth-distribution'),
      {
        type: 'bar',
        data: {
          labels: dd.map(r => r.depth_range + ' cm'),
          datasets: [{
            data: dd.map(r => r.element_count),
            backgroundColor: paletteFor(dd.length),
            borderRadius: 4,
          }],
        },
        options: { ...baseOpts, scales: { y: { beginAtZero: true } } },
      }
    );

    // Value summary — floating bars for Q1-Q3, with whiskers from min/max
    const vs = stats.value_summary || [];
    this._dashboardCharts.valueSummary = new Chart(
      document.getElementById('chart-value-summary'),
      {
        type: 'bar',
        data: {
          labels: vs.map(r => r.property),
          datasets: [
            {
              label: 'min–max',
              data: vs.map(r => [r.vmin, r.vmax]),
              backgroundColor: 'rgba(25,118,210,0.12)',
              borderColor: 'rgba(25,118,210,0.4)',
              borderWidth: 1,
              borderRadius: 2,
            },
            {
              label: 'Q1–Q3',
              data: vs.map(r => [r.q1, r.q3]),
              backgroundColor: paletteFor(vs.length),
              borderRadius: 4,
            },
          ],
        },
        options: {
          ...baseOpts,
          indexAxis: 'y',
          plugins: {
            legend: { display: true, position: 'bottom', labels: { boxWidth: 12 } },
            tooltip: {
              callbacks: {
                label: (ctx) => {
                  const r = vs[ctx.dataIndex] || {};
                  return [
                    `n: ${Number(r.n).toLocaleString()}`,
                    `min: ${r.vmin}`,
                    `Q1: ${r.q1}`,
                    `median: ${r.median}`,
                    `Q3: ${r.q3}`,
                    `max: ${r.vmax}`,
                  ];
                },
              },
            },
          },
          scales: { x: { beginAtZero: false } },
        },
      }
    );
  }

  // ==================== ETL ====================

  // Single combined destination dropdown: friendly label → (table, column)
  // required: true → must be mapped (validated in backend)
  get ETL_DEST_OPTIONS() {
    return [
      { label: 'Profile code',                          table: 'plot',       column: 'plot_code',           required: true  },
      { label: 'Longitude',                             table: 'plot',       column: 'geom (longitude)',    required: true  },
      { label: 'Latitude',                              table: 'plot',       column: 'geom (latitude)',     required: true  },
      { label: 'Profile type (TrialPit or Borehole)',   table: 'plot',       column: 'type',                required: false },
      { label: 'Altitude',                              table: 'plot',       column: 'altitude',            required: false },
      { label: 'Sampling date',                         table: 'plot',       column: 'sampling_date',       required: true  },
      { label: 'Positional accuracy',                   table: 'plot',       column: 'positional_accuracy', required: false },
      { label: 'Upper depth',                           table: 'element',    column: 'upper_depth',         required: true  },
      { label: 'Lower depth',                           table: 'element',    column: 'lower_depth',         required: true  },
      { label: 'Layer type (Horizon or Layer)',         table: 'element',    column: 'type',                required: false },
      { label: 'Horizon',                               table: 'element',    column: 'horizon',             required: false },
      { label: 'Soil property',                         table: 'result_num', column: 'value',               required: true  },
    ];
  }

  etlDestValue(table, column) {
    return table && column ? `${table}|${column}` : '';
  }

  async loadEtlCodelists() {
    try {
      const [projects, organisations, individuals, properties, procedures, units] = await Promise.all([
        api.getProjects(),
        api.getOrganisations(),
        api.getIndividuals(),
        api.getProperties(),
        api.getProcedures(),
        api.getUnits()
      ]);
      this.etlCodelists = { projects, organisations, individuals, properties, procedures, units };
      this.etlCodelistsLoaded = true;
      this.populateEtlDropdowns();
      this.loadEtlDatasets();
    } catch (e) {
      console.error('Error loading ETL codelists:', e);
    }
  }

  populateEtlDropdowns() {
    const cl = this.etlCodelists;

    // Project dropdown (single)
    const projEl = document.getElementById('etl-project');
    if (projEl) {
      projEl.innerHTML = '<option value="">-- Select --</option>' +
        (cl.projects || []).map(i => `<option value="${this.escapeHtml(i.project_id)}">${this.escapeHtml(i.project_id + ' — ' + (i.name || ''))}</option>`).join('') +
        '<option value="__new__">+ Add new...</option>';
      projEl.onchange = () => {
        document.getElementById('etl-new-project').style.display = projEl.value === '__new__' ? '' : 'none';
        this.loadProjectAuthors(projEl.value);
        this.loadProjectDetails(projEl.value);
      };
    }

    // Fill all org selects and individual selects in author rows
    this.refreshAuthorDropdowns();
  }

  refreshAuthorDropdowns() {
    const cl = this.etlCodelists;
    const orgOpts = '<option value="">-- Select --</option>' +
      (cl.organisations || []).map(i => `<option value="${this.escapeHtml(i.organisation_id)}">${this.escapeHtml(i.organisation_id + ' — ' + (i.country || '') + ' ' + (i.city || ''))}</option>`).join('') +
      '<option value="__new__">+ Add new...</option>';
    const indOpts = '<option value="">-- Select --</option>' +
      (cl.individuals || []).map(i => `<option value="${this.escapeHtml(i.individual_id)}">${this.escapeHtml(i.individual_id + ' — ' + (i.email || ''))}</option>`).join('') +
      '<option value="__new__">+ Add new...</option>';

    document.querySelectorAll('.etl-org-sel').forEach(sel => {
      const prev = sel.value;
      sel.innerHTML = orgOpts;
      if (prev && prev !== '__new__') sel.value = prev;
      sel.onchange = () => {
        document.getElementById('etl-new-org-block').style.display = sel.value === '__new__' ? '' : 'none';
      };
    });
    document.querySelectorAll('.etl-ind-sel').forEach(sel => {
      const prev = sel.value;
      sel.innerHTML = indOpts;
      if (prev && prev !== '__new__') sel.value = prev;
      sel.onchange = () => {
        document.getElementById('etl-new-ind-block').style.display = sel.value === '__new__' ? '' : 'none';
      };
    });
  }

  async loadProjectAuthors(projectId) {
    const container = document.getElementById('etl-author-rows');
    // Clear rows if no valid project selected
    if (!projectId || projectId === '__new__') {
      container.innerHTML = '';
      return;
    }
    try {
      const authors = await api.getProjectAuthors(projectId);
      if (!authors.length) {
        container.innerHTML = '';
        return;
      }
      container.innerHTML = '';
      for (const a of authors) {
        this.addAuthorRow();
        const row = container.lastElementChild;
        // Set values after dropdowns are populated by addAuthorRow → refreshAuthorDropdowns
        row.querySelector('.etl-org-sel').value = a.organisation_id || '';
        row.querySelector('.etl-ind-sel').value = a.individual_id || '';
        row.querySelector('.etl-pos-input').value = a.position || '';
        if (a.tag) row.querySelector('.etl-tag-sel').value = a.tag;
        if (a.role) row.querySelector('.etl-role-sel').value = a.role;
      }
    } catch (e) {
      console.error('Failed to load project authors:', e);
    }
  }

  loadProjectDetails(projectId) {
    const abstractEl = document.getElementById('etl-abstract');
    const licenseEl = document.getElementById('etl-license');
    if (!projectId || projectId === '__new__') {
      abstractEl.value = '';
      licenseEl.value = '';
      return;
    }
    const proj = (this.etlCodelists.projects || []).find(p => p.project_id === projectId);
    abstractEl.value = proj?.abstract || '';
    licenseEl.value = proj?.license || '';
  }

  addAuthorRow() {
    const container = document.getElementById('etl-author-rows');
    const row = document.createElement('div');
    row.className = 'etl-author-row';
    row.innerHTML = `
      <div class="etl-author-field">
        <select class="etl-org-sel"><option value="">Loading...</option></select>
      </div>
      <div class="etl-author-field">
        <select class="etl-ind-sel"><option value="">Loading...</option></select>
      </div>
      <div class="etl-author-field etl-author-field-sm">
        <input type="text" class="etl-pos-input" placeholder="e.g. Researcher">
      </div>
      <div class="etl-author-field etl-author-field-sm">
        <select class="etl-tag-sel">
          <option value="contact">contact</option>
          <option value="pointOfContact">pointOfContact</option>
        </select>
      </div>
      <div class="etl-author-field etl-author-field-sm">
        <select class="etl-role-sel">
          <option value="author">author</option>
          <option value="custodian">custodian</option>
          <option value="distributor">distributor</option>
          <option value="originator">originator</option>
          <option value="owner">owner</option>
          <option value="pointOfContact">pointOfContact</option>
          <option value="principalInvestigator">principalInvestigator</option>
          <option value="processor">processor</option>
          <option value="publisher">publisher</option>
          <option value="resourceProvider">resourceProvider</option>
          <option value="user">user</option>
        </select>
      </div>
      <button type="button" class="btn btn-danger btn-sm etl-remove-author" title="Remove" onclick="this.closest('.etl-author-row').remove()">×</button>
    `;
    container.appendChild(row);
    this.refreshAuthorDropdowns();
  }

  cancelNew(type) {
    if (type === 'project') {
      document.getElementById('etl-new-project').style.display = 'none';
      document.getElementById('etl-project').value = '';
    } else if (type === 'organisation') {
      document.getElementById('etl-new-org-block').style.display = 'none';
      document.querySelectorAll('.etl-org-sel').forEach(s => { if (s.value === '__new__') s.value = ''; });
    } else if (type === 'individual') {
      document.getElementById('etl-new-ind-block').style.display = 'none';
      document.querySelectorAll('.etl-ind-sel').forEach(s => { if (s.value === '__new__') s.value = ''; });
    }
  }

  async addNewProject() {
    const pid = document.getElementById('etl-new-project-id').value.trim();
    const name = document.getElementById('etl-new-project-name').value.trim();
    if (!pid || !name) { alert('Project ID and Name are required'); return; }
    try {
      await api.createProject({ project_id: pid, name });
      this.etlCodelists.projects.push({ project_id: pid, name });
      this.populateEtlDropdowns();
      document.getElementById('etl-project').value = pid;
      document.getElementById('etl-new-project').style.display = 'none';
    } catch (e) { alert('Error: ' + e.message); }
  }

  async addNewOrganisation() {
    const oid = document.getElementById('etl-new-org-id').value.trim();
    const country = document.getElementById('etl-new-org-country').value.trim();
    const city = document.getElementById('etl-new-org-city').value.trim();
    if (!oid) { alert('Organisation ID is required'); return; }
    try {
      await api.createOrganisation({ organisation_id: oid, country, city });
      this.etlCodelists.organisations.push({ organisation_id: oid, country, city });
      this.refreshAuthorDropdowns();
      // Select the new org in any dropdown that had __new__
      document.querySelectorAll('.etl-org-sel').forEach(s => { if (s.value === '__new__' || !s.value) s.value = oid; });
      document.getElementById('etl-new-org-block').style.display = 'none';
    } catch (e) { alert('Error: ' + e.message); }
  }

  async addNewIndividual() {
    const iid = document.getElementById('etl-new-ind-id').value.trim();
    const email = document.getElementById('etl-new-ind-email').value.trim();
    if (!iid) { alert('Name / ID is required'); return; }
    try {
      await api.createIndividual({ individual_id: iid, email });
      this.etlCodelists.individuals.push({ individual_id: iid, email });
      this.refreshAuthorDropdowns();
      document.querySelectorAll('.etl-ind-sel').forEach(s => { if (s.value === '__new__' || !s.value) s.value = iid; });
      document.getElementById('etl-new-ind-block').style.display = 'none';
    } catch (e) { alert('Error: ' + e.message); }
  }

  async handleEtlSave() {
    const statusEl = document.getElementById('etl-save-status');
    statusEl.textContent = 'Saving...';
    statusEl.style.color = '#555';

    try {
      // Save attribution (metadata)
      const projectId = document.getElementById('etl-project').value;
      if (!projectId || projectId === '__new__') {
        statusEl.textContent = 'Please select a project.';
        statusEl.style.color = '#c33';
        return;
      }

      const authorRows = document.querySelectorAll('#etl-author-rows .etl-author-row');
      const authors = [];
      for (const row of authorRows) {
        const orgId = row.querySelector('.etl-org-sel')?.value;
        const indId = row.querySelector('.etl-ind-sel')?.value;
        const position = row.querySelector('.etl-pos-input')?.value.trim();
        const tag = row.querySelector('.etl-tag-sel')?.value;
        const role = row.querySelector('.etl-role-sel')?.value;
        if (!orgId || orgId === '__new__' || !indId || indId === '__new__') {
          statusEl.textContent = 'Please select organisation and author for every row.';
          statusEl.style.color = '#c33';
          return;
        }
        authors.push({ organisation_id: orgId, individual_id: indId, position, tag, role });
      }

      await api.saveEtlMetadata({ project_id: projectId, authors });

      // Save project abstract and license
      const abstract = document.getElementById('etl-abstract').value.trim();
      const license = document.getElementById('etl-license').value;
      await api.updateProject(projectId, { abstract: abstract || null, license: license || null });

      // Update local cache
      const proj = (this.etlCodelists.projects || []).find(p => p.project_id === projectId);
      if (proj) { proj.abstract = abstract || null; proj.license = license || null; }

      // Save standardization (column mapping)
      const section = document.getElementById('etl-mapping-section');
      const tableName = section.dataset.tableName;
      if (tableName) {
        const mappingRows = document.querySelectorAll('#etl-mapping-tbody tr');
        const columns = [];
        mappingRows.forEach(tr => {
          const colName = tr.dataset.col;
          const destVal = tr.querySelector('.etl-dest').value;
          const [destTable, destCol] = destVal ? destVal.split('|') : [null, null];
          const entry = {
            column_name: colName,
            destination_table: destTable || null,
            destination_column: destCol || null,
            ignore_column: !destTable,
            property_num_id: null,
            procedure_num_id: null,
            unit_of_measure_id: null,
            conversion_operation: null,
            conversion_value: null
          };
          if (destTable === 'result_num') {
            entry.property_num_id = tr.querySelector('.etl-prop').value || null;
            entry.procedure_num_id = tr.querySelector('.etl-proc').value || null;
            entry.unit_of_measure_id = tr.querySelector('.etl-unit').value || null;
          }
          columns.push(entry);
        });
        const epsg = document.getElementById('etl-epsg').value.trim();
        await api.saveDatasetColumns(tableName, columns, epsg, projectId);
      }

      this.closeDetailPanel();
    } catch (e) {
      statusEl.textContent = 'Error: ' + e.message;
      statusEl.style.color = '#c33';
    }
  }

  async persistCurrentMappings() {
    const section = document.getElementById('etl-mapping-section');
    const tableName = section ? section.dataset.tableName : null;
    if (!tableName) return;
    const mappingRows = document.querySelectorAll('#etl-mapping-tbody tr');
    const columns = [];
    mappingRows.forEach(tr => {
      const colName = tr.dataset.col;
      const destVal = tr.querySelector('.etl-dest').value;
      const [destTable, destCol] = destVal ? destVal.split('|') : [null, null];
      const entry = {
        column_name: colName,
        destination_table: destTable || null,
        destination_column: destCol || null,
        ignore_column: !destTable,
        property_num_id: null,
        procedure_num_id: null,
        unit_of_measure_id: null,
        conversion_operation: null,
        conversion_value: null
      };
      if (destTable === 'result_num') {
        entry.property_num_id = tr.querySelector('.etl-prop').value || null;
        entry.procedure_num_id = tr.querySelector('.etl-proc').value || null;
        entry.unit_of_measure_id = tr.querySelector('.etl-unit').value || null;
      }
      columns.push(entry);
    });
    const epsg = document.getElementById('etl-epsg').value.trim();
    const projectId = document.getElementById('etl-project').value;
    const projectIdToSave = (projectId && projectId !== '__new__') ? projectId : null;
    await api.saveDatasetColumns(tableName, columns, epsg, projectIdToSave);
  }

  async handleEtlValidate() {
    const statusEl = document.getElementById('etl-save-status');
    const section = document.getElementById('etl-mapping-section');
    const tableName = section.dataset.tableName;
    if (!tableName) {
      statusEl.textContent = 'No dataset open.';
      statusEl.style.color = '#c33';
      return;
    }
    statusEl.textContent = 'Validating...';
    statusEl.style.color = '#555';
    try {
      await this.persistCurrentMappings();
      const result = await api.validateDataset(tableName);
      const cols = result.columns || {};

      // Apply per-column results in the mapping table
      document.querySelectorAll('#etl-mapping-tbody tr').forEach(tr => {
        const colName = tr.dataset.col;
        const cell = tr.querySelector('.etl-validation');
        if (!cell) return;
        const r = cols[colName];
        if (!r) {
          cell.textContent = '';
          cell.style.color = '#555';
          return;
        }
        const text = r.status === 'OK' ? 'OK' : r.errors.join('; ');
        cell.textContent = text;
        cell.style.color = r.status === 'OK' ? '#28a745' : '#dc3545';
      });

      // Rebuild error-cell map and re-render preview to highlight
      this.etlErrorCells = {};
      Object.entries(cols).forEach(([colName, r]) => {
        if (r.error_rows && r.error_rows.length) {
          this.etlErrorCells[colName] = new Set(r.error_rows);
        }
      });
      this.renderEtlPreviewPage();

      statusEl.textContent = result.message;
      statusEl.style.color = /OK/.test(result.message) ? '#28a745' : '#dc3545';

      this.showEtlValidationPopup(result);
    } catch (e) {
      statusEl.textContent = 'Validation failed: ' + e.message;
      statusEl.style.color = '#c33';
    }
  }

  // The rule applied for each (destination_table, destination_column) — kept
  // here so we can describe what was checked in the validation report popup.
  // Mirrors RULES in sis-api/main.py:validate_dataset.
  get ETL_RULE_DESCRIPTIONS() {
    return {
      'plot|plot_code':           "free-text identifier; rows sharing the same profile_code are merged into one profile and must agree on Longitude and Latitude",
      'plot|type':                "must be 'TrialPit' or 'Borehole'",
      'plot|altitude':            "must be a whole number in smallint range (-32768 to 32767)",
      'plot|positional_accuracy': "must be a whole number in smallint range (-32768 to 32767)",
      'plot|sampling_date':       "must be a valid date (YYYY-MM-DD)",
      'plot|geom (longitude)':    "must be a number in [-180, 180]",
      'plot|geom (latitude)':     "must be a number in [-90, 90]",
      'element|upper_depth':      "must be a whole number in [0, 1000]; layers within the same profile must be contiguous (each upper = previous lower)",
      'element|lower_depth':      "must be a whole number ≥ 0 (and greater than upper depth); layers within the same profile must be contiguous",
      'element|type':             "must be 'Horizon' or 'Layer'",
      'element|horizon':          "free-text horizon designation (e.g. A, Bw, C); no format check",
      'result_num|value':         "must be a number; converted to canonical unit",
    };
  }

  showEtlValidationPopup(result) {
    const cols = result.columns || {};
    const missing = result.missing_required || [];
    const required = ['Profile code', 'Longitude', 'Latitude', 'Sampling date',
                      'Upper depth', 'Lower depth', 'Soil property'];
    const e = (s) => this.escapeHtml(s);

    // Required-destinations checklist
    const reqRows = required.map(r => {
      const ok = !missing.includes(r);
      const icon = ok ? '✅' : '❌';
      const color = ok ? '#28a745' : '#dc3545';
      return `<li style="color:${color};">${icon} ${e(r)}</li>`;
    }).join('');

    // Per-column rule executions — we need to know what destination each
    // CSV column was mapped to. The mapping table has that info on the row.
    const rows = Array.from(document.querySelectorAll('#etl-mapping-tbody tr'));
    const colDestMap = {};   // csv_col → "plot|geom (longitude)" or null
    rows.forEach(tr => {
      const dest = tr.querySelector('.etl-dest');
      colDestMap[tr.dataset.col] = dest && dest.value ? dest.value : null;
    });

    const ruleDescs = this.ETL_RULE_DESCRIPTIONS;
    // String() wrappers below: escapeHtml() treats 0 as falsy and returns ''.
    const fmtBounds = (b) => {
      if (!b) return '';
      const minStr = (b.vmin !== null && b.vmin !== undefined) ? String(b.vmin) : '−∞';
      const maxStr = (b.vmax !== null && b.vmax !== undefined) ? String(b.vmax) : '+∞';
      const unit = b.canonical_unit || '?';
      const conv = b.conversion
        ? ` (CSV value × ${b.conversion.value} ${b.conversion.operation === '/' ? '⁻¹' : ''}, ${b.source_unit} → ${unit})`
        : (b.source_unit && b.source_unit !== unit
            ? ` (no conversion configured: ${b.source_unit} → ${unit})`
            : '');
      const hasData = b.data_min !== null && b.data_min !== undefined;
      const dataLine = hasData
        ? `<div style="font-size:0.85em;color:#555;margin-top:2px;">Your data: min = <strong>${e(String(b.data_min))}</strong>, max = <strong>${e(String(b.data_max))}</strong> ${e(unit)}</div>`
        : '';
      return `<div style="font-size:0.85em;color:#555;margin-top:2px;">Bounds applied: between <strong>${e(minStr)}</strong> and <strong>${e(maxStr)}</strong> ${e(unit)}${e(conv)}</div>${dataLine}`;
    };
    const colRows = Object.entries(cols).map(([csvCol, r]) => {
      const dest = colDestMap[csvCol];
      const destLabel = dest ? dest : '(skip)';
      let ruleDesc = dest && ruleDescs[dest] ? ruleDescs[dest] : '—';
      // Specialise the result_num rule with the actual canonical unit so it
      // doesn't read as generic "converted to canonical unit" boilerplate.
      if (dest === 'result_num|value' && r.applied_bounds && r.applied_bounds.canonical_unit) {
        ruleDesc = `must be a number; converted to ${r.applied_bounds.canonical_unit}`;
      }
      const ok = r.status === 'OK';
      const icon = ok ? '✅' : '❌';
      const color = ok ? '#28a745' : '#dc3545';
      const errBlock = (r.errors && r.errors.length)
        ? `<div style="margin-top:4px;font-size:0.85em;color:#dc3545;background:#fff5f5;padding:6px 8px;border-radius:3px;white-space:pre-wrap;">${e(r.errors.join('\n'))}</div>`
        : '';
      return `
        <div style="border:1px solid #e1e4e8;border-radius:4px;padding:8px;margin-bottom:8px;">
          <div style="font-weight:bold;color:${color};">${icon} <code>${e(csvCol)}</code> → ${e(destLabel)}</div>
          <div style="font-size:0.85em;color:#555;margin-top:2px;">Rule: ${e(ruleDesc)}</div>
          ${fmtBounds(r.applied_bounds)}
          ${errBlock}
        </div>`;
    }).join('') || '<em style="color:#777;">No mapped columns to check.</em>';

    // Build/replace modal
    document.getElementById('etl-validation-modal')?.remove();
    const modal = document.createElement('div');
    modal.id = 'etl-validation-modal';
    modal.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:10001;display:flex;align-items:flex-start;justify-content:center;padding:40px 20px;overflow:auto;';
    modal.innerHTML = `
      <div style="background:#fff;border-radius:6px;max-width:780px;width:100%;box-shadow:0 4px 20px rgba(0,0,0,0.3);">
        <div style="padding:14px 20px;border-bottom:1px solid #e1e4e8;display:flex;align-items:center;justify-content:space-between;">
          <h3 style="margin:0;color:#2c3e50;">Validation results</h3>
          <button id="etl-validation-close" type="button" style="background:transparent;border:0;font-size:22px;cursor:pointer;color:#555;">&times;</button>
        </div>
        <div style="padding:16px 20px;">
          <div style="margin-bottom:10px;font-size:0.95em;">
            <strong>Summary:</strong>
            <span style="color:${/OK/.test(result.message) ? '#28a745' : '#dc3545'};">${e(result.message || '')}</span>
            <span style="color:#777;font-size:0.9em;margin-left:8px;">${result.total_rows ?? '?'} data rows checked</span>
          </div>

          <h4 style="margin:16px 0 6px;">Required destinations</h4>
          <ul style="margin:0;padding-left:20px;">${reqRows}</ul>

          <h4 style="margin:16px 0 6px;">Country bounds</h4>
          ${this.formatCountryBoundsBlock(result.country_bounds)}

          <h4 style="margin:16px 0 6px;">Per-column checks</h4>
          ${colRows}
        </div>
        <div style="padding:10px 20px;border-top:1px solid #e1e4e8;text-align:right;">
          <button id="etl-validation-export" type="button" class="btn btn-sm" style="background:#17a2b8;color:#fff;margin-right:8px;">Export</button>
          <button id="etl-validation-ok" type="button" class="btn btn-primary btn-sm">Close</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    const close = () => modal.remove();
    modal.querySelector('#etl-validation-close').addEventListener('click', close);
    modal.querySelector('#etl-validation-ok').addEventListener('click', close);
    modal.addEventListener('click', (ev) => { if (ev.target === modal) close(); });
    modal.querySelector('#etl-validation-export').addEventListener('click', () => {
      this.exportEtlValidationReport(result, colDestMap, ruleDescs, missing, required);
    });
  }

  formatCountryBoundsBlock(cb) {
    const e = (s) => this.escapeHtml(String(s));
    if (!cb || !cb.checked) {
      return `<div style="color:#777;font-size:0.9em;">Skipped — needs both Longitude and Latitude mapped, plus a <code>COUNTRY_CODE</code> setting and a non-null <code>spatial_metadata.country.geom_convexhull</code>.</div>`;
    }
    const ok = cb.status === 'OK';
    const icon = ok ? '✅' : '❌';
    const color = ok ? '#28a745' : '#dc3545';
    const previewRows = (cb.outside_rows_preview && cb.outside_rows_preview.length)
      ? `<div style="font-size:0.85em;color:#dc3545;background:#fff5f5;padding:6px 8px;border-radius:3px;margin-top:6px;">Outside rows (first ${cb.outside_rows_preview.length}): ${cb.outside_rows_preview.join(', ')}${cb.outside > cb.outside_rows_preview.length ? ', …' : ''}</div>`
      : '';
    return `
      <div style="border:1px solid #e1e4e8;border-radius:4px;padding:8px;">
        <div style="font-weight:bold;color:${color};">${icon} ${e(cb.percent_inside)}% of points inside ${e(cb.country_code)} convex hull (need ≥${e(cb.threshold)}%)</div>
        <div style="font-size:0.85em;color:#555;margin-top:2px;">Rule: ≥95% of mapped (longitude, latitude) points must fall within <code>spatial_metadata.country.geom_convexhull</code> for the configured COUNTRY_CODE.</div>
        <div style="font-size:0.85em;color:#555;margin-top:2px;">${e(cb.checked_rows)} rows checked · ${e(cb.inside)} inside · ${e(cb.outside)} outside</div>
        ${previewRows}
      </div>`;
  }

  exportEtlValidationReport(result, colDestMap, ruleDescs, missing, required) {
    const cols = result.columns || {};
    const section = document.getElementById('etl-mapping-section');
    const tableName = section ? section.dataset.tableName : 'dataset';
    const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);

    const lines = [];
    lines.push(`# Validation report — ${tableName}`);
    lines.push(`Generated: ${new Date().toISOString()}`);
    lines.push('');
    lines.push(`**Summary:** ${result.message || ''}`);
    lines.push(`Rows checked: ${result.total_rows ?? '?'}`);
    lines.push('');
    lines.push('## Required destinations');
    required.forEach(r => {
      const ok = !missing.includes(r);
      lines.push(`- ${ok ? '[x]' : '[ ]'} ${r}`);
    });
    lines.push('');
    lines.push('## Country bounds');
    const cb = result.country_bounds || {};
    if (!cb.checked) {
      lines.push('- Skipped (needs Longitude, Latitude, COUNTRY_CODE, geom_convexhull).');
    } else {
      lines.push(`- Status: ${cb.status}`);
      lines.push(`- Country: ${cb.country_code}`);
      lines.push(`- Inside: ${cb.percent_inside}% (${cb.inside} of ${cb.checked_rows}); threshold ≥${cb.threshold}%`);
      if (cb.outside_rows_preview && cb.outside_rows_preview.length) {
        lines.push(`- Outside rows (first ${cb.outside_rows_preview.length}): ${cb.outside_rows_preview.join(', ')}`);
      }
    }
    lines.push('');
    lines.push('## Per-column checks');
    Object.entries(cols).forEach(([csvCol, r]) => {
      const dest = colDestMap[csvCol] || '(skip)';
      let rule = (colDestMap[csvCol] && ruleDescs[colDestMap[csvCol]]) || '—';
      if (dest === 'result_num|value' && r.applied_bounds && r.applied_bounds.canonical_unit) {
        rule = `must be a number; converted to ${r.applied_bounds.canonical_unit}`;
      }
      const status = r.status === 'OK' ? 'OK' : 'ERROR';
      lines.push(`### ${csvCol} → ${dest}`);
      lines.push(`- Rule: ${rule}`);
      lines.push(`- Status: ${status}`);
      if (r.applied_bounds) {
        const b = r.applied_bounds;
        const min = (b.vmin !== null && b.vmin !== undefined) ? b.vmin : '-inf';
        const max = (b.vmax !== null && b.vmax !== undefined) ? b.vmax : '+inf';
        lines.push(`- Bounds: between ${min} and ${max} ${b.canonical_unit || '?'}`);
        if (b.data_min !== null && b.data_min !== undefined) {
          lines.push(`- Your data: min = ${b.data_min}, max = ${b.data_max} ${b.canonical_unit || '?'}`);
        }
        if (b.conversion) {
          lines.push(`- Conversion: CSV ${b.conversion.operation} ${b.conversion.value} (${b.source_unit} → ${b.canonical_unit})`);
        } else if (b.source_unit && b.source_unit !== b.canonical_unit) {
          lines.push(`- Conversion: NONE (source ${b.source_unit} ≠ canonical ${b.canonical_unit})`);
        }
      }
      if (r.errors && r.errors.length) {
        lines.push('- Errors:');
        r.errors.forEach(err => lines.push(`  - ${err}`));
      }
      lines.push('');
    });

    const blob = new Blob([lines.join('\n')], { type: 'text/markdown;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `validation_${tableName}_${stamp}.md`;
    a.click();
    URL.revokeObjectURL(url);
  }

  async handleEtlUpload() {
    const fileInput = document.getElementById('etl-file-input');
    const statusEl = document.getElementById('etl-upload-status');
    if (!fileInput.files.length) {
      statusEl.textContent = 'Please select a CSV file.';
      statusEl.style.color = '#c33';
      return;
    }
    const projectId = document.getElementById('etl-project').value;
    const btn = document.getElementById('etl-upload-btn');
    btn.disabled = true;
    statusEl.textContent = 'Uploading...';
    statusEl.style.color = '#555';
    try {
      const result = await api.uploadCsv(fileInput.files[0], projectId !== '__new__' ? projectId : null);
      this.etlUploadResult = result;
      statusEl.textContent = '';
      fileInput.value = '';
      await this.loadEtlDatasets();
      this.openDataset(result.table_name);
    } catch (e) {
      statusEl.textContent = 'Error: ' + e.message;
      statusEl.style.color = '#c33';
    } finally {
      btn.disabled = false;
    }
  }

  async loadEtlDatasets() {
    try {
      const datasets = await api.getDatasets();
      this.etlDatasets = datasets;
      this.renderEtlDatasets();
    } catch (e) {
      console.error('Error loading datasets:', e);
    }
  }

  renderEtlDatasets() {
    const container = document.getElementById('etl-datasets-list');
    if (!container) return;
    if (!this.etlDatasets.length) {
      container.innerHTML = '<p style="font-size:var(--fs-sm);color:#555;">No datasets uploaded yet.</p>';
      return;
    }
    const fmtDate = v => {
      if (!v) return '-';
      const d = new Date(v);
      return isNaN(d) ? this.escapeHtml(String(v)) : d.toISOString().slice(0, 10);
    };
    container.innerHTML = `
      <table class="admin-table">
        <thead><tr><th>Table</th><th>User</th><th>Uploaded</th><th>Ingested</th><th>Status</th><th>Cols</th><th>Rows</th><th>Actions</th><th>Result</th></tr></thead>
        <tbody>${this.etlDatasets.map(d => {
          const tn = this.escapeHtml(d.table_name);
          const tnJs = this.escapeJsAttr(d.table_name);
          const ingested = d.status === 'Ingested' || d.status === 'Partial';
          const noPrune = d.status === 'Uploaded' || d.status === 'Removed' || !d.status;
          return `<tr data-table="${tn}">
            <td>${tn}</td>
            <td>${this.escapeHtml(d.user_id || '-')}</td>
            <td>${fmtDate(d.upload_date)}</td>
            <td>${fmtDate(d.ingestion_date)}</td>
            <td>${this.escapeHtml(d.status || '-')}</td>
            <td>${d.n_col ?? '-'}</td>
            <td>${d.n_rows ?? '-'}</td>
            <td>
              <button class="btn btn-primary btn-sm" onclick="adminDashboard.openDataset('${tnJs}')">Open</button>
              <button class="btn btn-sm" style="background:#28a745;color:#fff;margin-left:4px;${ingested ? 'opacity:0.5;pointer-events:none;' : ''}" onclick="adminDashboard.ingestDataset('${tnJs}')"${ingested ? ' disabled' : ''}>Ingest</button>
              <button class="btn btn-sm" style="background:#dc3545;color:#fff;margin-left:4px;${noPrune ? 'opacity:0.5;pointer-events:none;' : ''}" onclick="adminDashboard.pruneDataset('${tnJs}')"${noPrune ? ' disabled' : ''}>Prune DB</button>
              ${this.isAdmin ? `<button class="btn btn-sm" style="background:#6c757d;color:#fff;margin-left:4px;" onclick="adminDashboard.deleteDataset('${tnJs}')">Delete</button>` : ''}
            </td>
            <td class="etl-result" style="font-size:var(--fs-xs);max-width:300px;white-space:pre-wrap;">${this.escapeHtml(d.note || '')}</td>
          </tr>`;
        }).join('')}
        </tbody>
      </table>`;
  }

  async openDataset(tableName) {
    try {
      const [preview, columns] = await Promise.all([
        api.getDatasetPreview(tableName),
        api.getDatasetColumns(tableName)
      ]);
      this.etlUploadResult = { table_name: tableName, columns: preview.columns };
      this.etlErrorCells = {};
      this.showEtlPreview(preview.columns, preview.rows);
      this.showEtlMapping(tableName, preview.columns, columns);

      // Restore project and authors from the dataset record
      const dataset = (this.etlDatasets || []).find(d => d.table_name === tableName);
      if (dataset && dataset.project_id) {
        const projEl = document.getElementById('etl-project');
        if (projEl) {
          projEl.value = dataset.project_id;
          document.getElementById('etl-new-project').style.display = 'none';
        }
        await this.loadProjectAuthors(dataset.project_id);
        this.loadProjectDetails(dataset.project_id);
      } else {
        document.getElementById('etl-project').value = '';
        document.getElementById('etl-abstract').value = '';
        document.getElementById('etl-license').value = '';
        document.getElementById('etl-author-rows').innerHTML = '';
      }

      // Switch to detail panel
      document.getElementById('etl-list-view').style.display = 'none';
      document.getElementById('etl-detail-panel').style.display = '';
      document.getElementById('etl-detail-title').textContent = tableName;
      document.getElementById('etl-save-status').textContent = '';
    } catch (e) {
      alert('Error opening dataset: ' + e.message);
    }
  }

  closeDetailPanel() {
    document.getElementById('etl-detail-panel').style.display = 'none';
    document.getElementById('etl-list-view').style.display = '';
    this.loadEtlDatasets();
  }

  setRowResult(tableName, html, isError) {
    const row = document.querySelector(`tr[data-table="${tableName}"]`);
    if (!row) return;
    const cell = row.querySelector('.etl-result');
    if (cell) {
      cell.innerHTML = html;
      cell.style.color = isError ? '#dc3545' : '#28a745';
    }
  }

  async ingestDataset(tableName) {
    this.setRowResult(tableName, 'Ingesting...', false);
    try {
      const result = await api.ingestDataset(tableName);
      let msg = result.message || `Ingested ${result.ingested}/${result.total} rows`;
      if (result.errors && result.errors.length) {
        msg += `\nErrors: ${result.errors.length}`;
      }
      this.setRowResult(tableName, this.escapeHtml(msg), false);
      this.loadEtlDatasets();
    } catch (e) {
      this.setRowResult(tableName, this.escapeHtml(e.message), true);
    }
  }

  async pruneDataset(tableName) {
    this.setRowResult(tableName, 'Pruning...', false);
    try {
      const result = await api.pruneDataset(tableName);
      this.setRowResult(tableName, this.escapeHtml(result.message), false);
      this.loadEtlDatasets();
    } catch (e) {
      this.setRowResult(tableName, this.escapeHtml(e.message), true);
    }
  }

  async deleteDataset(tableName) {
    this.setRowResult(tableName, 'Deleting...', false);
    try {
      await api.deleteDataset(tableName);
      await this.loadEtlDatasets();
    } catch (e) {
      this.setRowResult(tableName, this.escapeHtml(e.message), true);
    }
  }

  showEtlPreview(columns, rows) {
    this.etlPreviewColumns = columns;
    this.etlPreviewRows = rows;
    this.etlPreviewPage = 0;
    this.etlPreviewPageSize = 100;
    this.etlErrorCells = this.etlErrorCells || {};
    this.etlSort = [];
    this.renderEtlPreviewPage();
  }

  etlToggleSort(col, additive) {
    if (!this.etlSort) this.etlSort = [];
    const idx = this.etlSort.findIndex(s => s.col === col);
    if (!additive) {
      // Plain click: if only this column is sorted, cycle it; else replace with asc on this column
      if (this.etlSort.length === 1 && idx === 0) {
        const dir = this.etlSort[0].dir;
        if (dir === 'asc') this.etlSort = [{ col, dir: 'desc' }];
        else this.etlSort = [];
      } else {
        this.etlSort = [{ col, dir: 'asc' }];
      }
    } else {
      // Shift+click: add or cycle this column within existing sort
      if (idx === -1) {
        this.etlSort.push({ col, dir: 'asc' });
      } else if (this.etlSort[idx].dir === 'asc') {
        this.etlSort[idx].dir = 'desc';
      } else {
        this.etlSort.splice(idx, 1);
      }
    }
    this.etlPreviewPage = 0;
    this.renderEtlPreviewPage();
  }

  renderEtlPreviewPage() {
    const thead = document.getElementById('etl-preview-thead');
    const tbody = document.getElementById('etl-preview-tbody');
    const info = document.getElementById('etl-preview-info');
    const pageInfo = document.getElementById('etl-preview-page-info');
    const prevBtn = document.getElementById('etl-preview-prev');
    const nextBtn = document.getElementById('etl-preview-next');

    const columns = this.etlPreviewColumns || [];
    const rows = this.etlPreviewRows || [];
    const pageSize = this.etlPreviewPageSize || 100;
    const total = rows.length;

    // Build index array, sort if requested — preserves original indices for error highlighting
    let order = rows.map((_, i) => i);
    const sortList = this.etlSort || [];
    if (sortList.length) {
      const asNum = v => {
        if (v === null || v === undefined || v === '') return null;
        const n = Number(v);
        return Number.isFinite(n) ? n : null;
      };
      const getVal = (idx, col) => {
        const row = rows[idx];
        return Array.isArray(row) ? row[columns.indexOf(col)] : row[col];
      };
      order.sort((a, b) => {
        for (const { col, dir } of sortList) {
          const va = getVal(a, col), vb = getVal(b, col);
          const aEmpty = va === null || va === undefined || va === '';
          const bEmpty = vb === null || vb === undefined || vb === '';
          if (aEmpty && bEmpty) continue;
          if (aEmpty) return 1;
          if (bEmpty) return -1;
          const na = asNum(va), nb = asNum(vb);
          let cmp;
          if (na !== null && nb !== null) cmp = na - nb;
          else cmp = String(va).localeCompare(String(vb));
          if (cmp !== 0) return dir === 'asc' ? cmp : -cmp;
        }
        return 0;
      });
    }

    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    if (this.etlPreviewPage >= totalPages) this.etlPreviewPage = totalPages - 1;
    if (this.etlPreviewPage < 0) this.etlPreviewPage = 0;
    const start = this.etlPreviewPage * pageSize;
    const end = Math.min(start + pageSize, total);

    info.textContent = `(${total} rows loaded)`;
    pageInfo.textContent = `Page ${this.etlPreviewPage + 1}/${totalPages} — rows ${start + 1}-${end}`;
    prevBtn.disabled = this.etlPreviewPage === 0;
    nextBtn.disabled = this.etlPreviewPage >= totalPages - 1;

    const sortIndicator = c => {
      const i = sortList.findIndex(s => s.col === c);
      if (i === -1) return '';
      const arrow = sortList[i].dir === 'asc' ? '▲' : '▼';
      const badge = sortList.length > 1 ? `<sup style="font-size:0.75em;">${i + 1}</sup>` : '';
      return ` ${arrow}${badge}`;
    };
    thead.innerHTML = '<tr><th style="width:40px;">#</th>' + columns.map(c =>
      `<th class="etl-preview-sort" data-col="${this.escapeHtml(c)}" style="cursor:pointer;user-select:none;" title="Click to sort; Shift+click to add secondary sort">${this.escapeHtml(c)}${sortIndicator(c)}</th>`
    ).join('') + '</tr>';

    thead.querySelectorAll('.etl-preview-sort').forEach(th => {
      th.addEventListener('click', (e) => this.etlToggleSort(th.dataset.col, e.shiftKey));
    });

    const errCells = this.etlErrorCells || {};
    const getErrCols = rid => {
      const cols = [];
      columns.forEach(c => {
        const set = errCells[c];
        if (set && set.has(rid)) cols.push(c);
      });
      return new Set(cols);
    };

    const html = [];
    for (let pos = start; pos < end; pos++) {
      const i = order[pos];
      const row = rows[i];
      const rid = row._row_id;
      const errSet = getErrCols(rid);
      html.push(`<tr data-rid="${rid}"><td style="color:#777;">${rid}</td>` + columns.map(c => {
        const v = row[c];
        const val = v == null ? '' : String(v);
        const cls = errSet.has(c) ? 'etl-preview-cell etl-preview-error' : 'etl-preview-cell';
        return `<td class="${cls}" contenteditable="true" data-rid="${rid}" data-col="${this.escapeHtml(c)}" data-orig="${this.escapeHtml(val)}" spellcheck="false">${this.escapeHtml(val)}</td>`;
      }).join('') + '</tr>');
    }
    tbody.innerHTML = html.join('');

    // Wire cell edits
    tbody.querySelectorAll('.etl-preview-cell').forEach(td => {
      td.addEventListener('keydown', e => {
        if (e.key === 'Enter') { e.preventDefault(); td.blur(); }
        if (e.key === 'Escape') { td.textContent = td.dataset.orig; td.blur(); }
      });
      td.addEventListener('blur', () => this.handleEtlCellEdit(td));
    });
  }

  async handleEtlCellEdit(td) {
    const section = document.getElementById('etl-mapping-section');
    const tableName = section.dataset.tableName;
    if (!tableName) return;
    const rid = parseInt(td.dataset.rid, 10);
    const col = td.dataset.col;
    const orig = td.dataset.orig;
    const newVal = td.textContent;
    if (newVal === orig) return;
    td.style.backgroundColor = '#fff3cd';
    try {
      const result = await api.editDatasetCells(tableName, [{ row_id: rid, column: col, value: newVal }]);
      if (result.updated) {
        td.dataset.orig = newVal;
        // Update local row data
        const row = (this.etlPreviewRows || []).find(r => r._row_id === rid);
        if (row) row[col] = newVal;
        td.style.backgroundColor = '#d4edda';
        setTimeout(() => { td.style.backgroundColor = ''; }, 800);
        // Debounce revalidate
        clearTimeout(this._etlRevalidateTimer);
        this._etlRevalidateTimer = setTimeout(() => this.handleEtlValidate(), 1000);
      } else {
        td.textContent = orig;
        td.style.backgroundColor = '';
        if (result.errors && result.errors.length) {
          alert('Edit failed: ' + result.errors.join('; '));
        }
      }
    } catch (e) {
      td.textContent = orig;
      td.style.backgroundColor = '';
      alert('Edit failed: ' + e.message);
    }
  }

  showEtlMapping(tableName, columns, existingMappings) {
    const section = document.getElementById('etl-mapping-section');
    const tbody = document.getElementById('etl-mapping-tbody');
    section.dataset.tableName = tableName;

    const destOptions = this.ETL_DEST_OPTIONS;
    const cl = this.etlCodelists;
    const ss = 'font-size:var(--fs-xs);padding:2px 4px;';

    const existingMap = {};
    if (existingMappings) {
      existingMappings.forEach(m => { existingMap[m.column_name] = m; });
    }

    tbody.innerHTML = columns.map(col => {
      const existing = existingMap[col] || {};
      const selTable = existing.destination_table || '';
      const selCol = existing.destination_column || '';
      const selVal = this.etlDestValue(selTable, selCol);
      const isResult = selTable === 'result_num';

      const destOpts = '<option value="">(skip)</option>' +
        destOptions.map(o => {
          const v = `${o.table}|${o.column}`;
          const labelText = (o.required ? '* ' : '') + o.label;
          const styleAttr = o.required ? ' style="font-weight:bold;"' : '';
          return `<option value="${v}"${selVal === v ? ' selected' : ''}${styleAttr}>${this.escapeHtml(labelText)}</option>`;
        }).join('');

      const propOpts = '<option value="">—</option>' + (cl.properties || []).map(p =>
        `<option value="${p.property_num_id}" data-uri="${this.escapeHtml(p.uri || '')}"${existing.property_num_id == p.property_num_id ? ' selected' : ''}>${this.escapeHtml(p.property_name)}</option>`
      ).join('');

      const hideResult = isResult ? '' : 'display:none;';

      const validation = existing.validation || '';
      const valColor = validation === 'OK' ? '#28a745' : (validation ? '#dc3545' : '#555');

      const linkSS = 'margin-left:4px;font-size:var(--fs-xs);text-decoration:none;';
      return `
        <tr data-col="${this.escapeHtml(col)}">
          <td><strong>${this.escapeHtml(col)}</strong></td>
          <td><select class="etl-dest" style="${ss}">${destOpts}</select></td>
          <td style="white-space:nowrap;">
            <select class="etl-prop" style="${ss}${hideResult}">${propOpts}</select>
            <a class="etl-prop-link" href="" target="_blank" rel="noopener" title="Open property reference" style="${linkSS}display:none;">↗</a>
          </td>
          <td style="white-space:nowrap;">
            <select class="etl-proc" style="${ss}${hideResult}"><option value="">—</option></select>
            <a class="etl-proc-link" href="" target="_blank" rel="noopener" title="Open procedure reference" style="${linkSS}display:none;">↗</a>
          </td>
          <td style="white-space:nowrap;">
            <select class="etl-unit" style="${ss}${hideResult}"><option value="">—</option></select>
            <a class="etl-unit-link" href="" target="_blank" rel="noopener" title="Open unit reference" style="${linkSS}display:none;">↗</a>
          </td>
          <td class="etl-validation" style="font-size:var(--fs-xs);max-width:260px;white-space:pre-wrap;color:${valColor};vertical-align:middle;">${this.escapeHtml(validation)}</td>
        </tr>`;
    }).join('');

    // Rebuild every dest dropdown so options already used by other rows are hidden.
    // result_num|value is the only multi-use destination (one per soil-property column).
    const refreshDestDropdowns = () => {
      const allSelects = tbody.querySelectorAll('.etl-dest');
      const used = new Set();
      allSelects.forEach(s => {
        if (s.value && s.value !== 'result_num|value') used.add(s.value);
      });
      allSelects.forEach(s => {
        const current = s.value;
        const opts = ['<option value="">(skip)</option>'];
        destOptions.forEach(o => {
          const v = `${o.table}|${o.column}`;
          if (used.has(v) && v !== current) return; // hide if taken by another row
          const labelText = (o.required ? '* ' : '') + o.label;
          const styleAttr = o.required ? ' style="font-weight:bold;"' : '';
          const selected = current === v ? ' selected' : '';
          opts.push(`<option value="${v}"${selected}${styleAttr}>${this.escapeHtml(labelText)}</option>`);
        });
        s.innerHTML = opts.join('');
      });
    };
    refreshDestDropdowns();

    // Cascade: destination changes → toggle result_num extras + refilter all dropdowns
    tbody.querySelectorAll('.etl-dest').forEach(sel => {
      sel.addEventListener('change', () => {
        const tr = sel.closest('tr');
        const [table] = (sel.value || '').split('|');
        const isResult = table === 'result_num';

        tr.querySelector('.etl-prop').style.display = isResult ? '' : 'none';
        tr.querySelector('.etl-proc').style.display = isResult ? '' : 'none';
        tr.querySelector('.etl-unit').style.display = isResult ? '' : 'none';
        const propLink = tr.querySelector('.etl-prop-link');
        const procLink = tr.querySelector('.etl-proc-link');
        const unitLink = tr.querySelector('.etl-unit-link');
        if (!isResult) {
          tr.querySelector('.etl-proc').innerHTML = '<option value="">—</option>';
          tr.querySelector('.etl-unit').innerHTML = '<option value="">—</option>';
          if (propLink) propLink.style.display = 'none';
          if (procLink) procLink.style.display = 'none';
          if (unitLink) unitLink.style.display = 'none';
        } else {
          updateRefLink(tr.querySelector('.etl-prop'), '.etl-prop-link');
          updateRefLink(tr.querySelector('.etl-proc'), '.etl-proc-link');
          updateUnitLink(tr);
        }
        refreshDestDropdowns();
      });
    });

    const updateRefLink = (selectEl, linkClass) => {
      const tr = selectEl.closest('tr');
      const link = tr.querySelector(linkClass);
      if (!link) return;
      const opt = selectEl.options[selectEl.selectedIndex];
      const uri = (opt && opt.dataset && opt.dataset.uri) ? opt.dataset.uri : '';
      if (uri) {
        link.href = uri;
        link.style.display = '';
      } else {
        link.removeAttribute('href');
        link.style.display = 'none';
      }
    };

    // Initial state for prop links (procedure links are wired after async load)
    tbody.querySelectorAll('.etl-prop').forEach(sel => updateRefLink(sel, '.etl-prop-link'));

    const updateUnitLink = (tr) => {
      const link = tr.querySelector('.etl-unit-link');
      const unitSel = tr.querySelector('.etl-unit');
      if (!link || !unitSel) return;
      const uri = unitSel.dataset.canonicalUri || '';
      if (uri) {
        link.href = uri;
        link.style.display = '';
      } else {
        link.removeAttribute('href');
        link.style.display = 'none';
      }
    };

    const reloadUnits = async (tr, selectedUnit) => {
      const propId = tr.querySelector('.etl-prop').value;
      const procId = tr.querySelector('.etl-proc').value;
      const unitSel = tr.querySelector('.etl-unit');
      delete unitSel.dataset.canonicalUri;
      if (!propId || !procId) {
        unitSel.innerHTML = '<option value="">—</option>';
        updateUnitLink(tr);
        return;
      }
      unitSel.innerHTML = '<option value="">Loading...</option>';
      try {
        const opts = await api.getSourceUnitsForObservation(propId, procId);
        const canonical = opts.find(u => u.is_canonical);
        if (canonical && canonical.uri) unitSel.dataset.canonicalUri = canonical.uri;
        unitSel.innerHTML = '<option value="">—</option>' + opts.map(u => {
          const v = u.unit_of_measure_id;
          const sel = selectedUnit && selectedUnit === v ? ' selected' : '';
          const label = u.is_canonical
            ? `${v} (canonical)`
            : `${v} → ${u.unit_to} (${u.operation}${u.value})`;
          return `<option value="${v}"${sel}>${this.escapeHtml(label)}</option>`;
        }).join('');
      } catch (e) {
        unitSel.innerHTML = '<option value="">Error</option>';
      }
      updateUnitLink(tr);
    };

    const procOptionsHtml = (procs, selectedId) => '<option value="">—</option>' +
      procs.map(p => {
        const sel = selectedId && p.procedure_num_id === selectedId ? ' selected' : '';
        return `<option value="${p.procedure_num_id}" data-uri="${this.escapeHtml(p.uri || '')}"${sel}>${this.escapeHtml(p.procedure_name)}</option>`;
      }).join('');

    // Cascade: property changes → load procedures, clear units, update prop link
    tbody.querySelectorAll('.etl-prop').forEach(sel => {
      sel.addEventListener('change', async () => {
        updateRefLink(sel, '.etl-prop-link');
        const tr = sel.closest('tr');
        const procSel = tr.querySelector('.etl-proc');
        const unitSel = tr.querySelector('.etl-unit');
        const propId = sel.value;
        unitSel.innerHTML = '<option value="">—</option>';
        procSel.innerHTML = '<option value="">Loading...</option>';
        updateRefLink(procSel, '.etl-proc-link');
        if (!propId) {
          procSel.innerHTML = '<option value="">—</option>';
          return;
        }
        try {
          const procs = await api.getProceduresForProperty(propId);
          procSel.innerHTML = procOptionsHtml(procs, null);
        } catch (e) {
          procSel.innerHTML = '<option value="">Error</option>';
        }
        updateRefLink(procSel, '.etl-proc-link');
      });
    });

    // Cascade: procedure changes → load source-unit options + update proc link
    tbody.querySelectorAll('.etl-proc').forEach(sel => {
      sel.addEventListener('change', () => {
        updateRefLink(sel, '.etl-proc-link');
        reloadUnits(sel.closest('tr'), null);
      });
    });


    // For existing mappings, restore procedures and units
    if (existingMappings) {
      tbody.querySelectorAll('tr[data-col]').forEach(tr => {
        const col = tr.dataset.col;
        const existing = existingMap[col];
        if (existing && existing.property_num_id) {
          const savedProc = existing.procedure_num_id;
          const savedUnit = existing.unit_of_measure_id;
          api.getProceduresForProperty(existing.property_num_id).then(procs => {
            const procSel = tr.querySelector('.etl-proc');
            procSel.innerHTML = procOptionsHtml(procs, savedProc);
            updateRefLink(procSel, '.etl-proc-link');
            if (savedProc) reloadUnits(tr, savedUnit);
          }).catch(() => {});
        }
      });
    }
  }

  // handleSaveMapping merged into handleEtlSave

  // ==================== GloSIS Federation ====================

  initGlosis() {
    const enableBtn = document.getElementById('glosis-enable-btn');
    const disableBtn = document.getElementById('glosis-disable-btn');
    const disableDeleteBtn = document.getElementById('glosis-disable-delete-btn');
    if (!enableBtn || !disableBtn || !disableDeleteBtn) return;

    enableBtn.addEventListener('click', async () => {
      try {
        await api.enableGlosis();
        await this.loadGlosis();
      } catch (e) {
        alert('Failed to enable: ' + e.message);
      }
    });
    disableBtn.addEventListener('click', async () => {
      try { await api.disableGlosis(); await this.loadGlosis(); }
      catch (e) { alert('Failed to disable: ' + e.message); }
    });
    disableDeleteBtn.addEventListener('click', async () => {
      if (!confirm('Disable federation and delete the token? Re-enabling will mint a new key — the current one stops working.')) return;
      try { await api.disableAndDeleteGlosis(); await this.loadGlosis(); }
      catch (e) { alert('Failed: ' + e.message); }
    });

    this.renderGlosisEndpoints();
    this.loadGlosis();
  }

  renderGlosisEndpoints(apiKey) {
    const ul = document.getElementById('glosis-endpoints');
    if (!ul) return;
    const origin = window.location.origin;
    const tokenDisplay = apiKey
      ? `<code>${this.escapeHtml(apiKey)}</code>`
      : '<em>&lt;federation token — Enable to generate&gt;</em>';
    // sis-api-glosis is exposed on host port 8006 in dev. In prod (nginx-only),
    // the operator should front it under e.g. /glosis/ — show both.
    const items = [
      `<li>Manifest: <code>${origin}:8006/manifest</code> (or via nginx, <code>/glosis/manifest</code>)</li>`,
      `<li>Profiles: <code>${origin}:8006/profile</code></li>`,
      `<li>Observations: <code>${origin}:8006/observation</code></li>`,
      `<li>Header to send: <code>X-API-Key:</code> ${tokenDisplay}</li>`,
      `<li>Metadata catalogue (rasters, public): <code>${origin}:8003/collections/metadata:main/items</code></li>`,
    ];
    ul.innerHTML = items.join('');
  }

  async loadGlosis() {
    const statusEl = document.getElementById('glosis-status');
    if (!statusEl) return;
    try {
      const data = await api.getGlosisStatus();
      const enabled = !!data.enabled;
      statusEl.textContent = enabled ? 'Enabled' : 'Disabled';
      statusEl.style.color = enabled ? '#28a745' : '#777';
      document.getElementById('glosis-enable-btn').disabled = enabled;
      document.getElementById('glosis-disable-btn').disabled = !enabled;
      document.getElementById('glosis-disable-delete-btn').disabled = !data.token;
      this.renderGlosisEndpoints(data.token ? data.token.api_key : null);
    } catch (e) {
      statusEl.textContent = 'Error';
      statusEl.style.color = '#c33';
    }
  }

  // ==================== Utility ====================

  escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Escape a value so it can appear inside a single-quoted JS string literal
  // that is itself inside an HTML attribute. Protects against payloads like
  // ');alert(1);// breaking out of the JS string and executing.
  escapeJsAttr(text) {
    if (text === null || text === undefined) return '';
    return String(text)
      .replace(/\\/g, '\\\\')
      .replace(/'/g, "\\'")
      .replace(/"/g, '&quot;')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\r?\n/g, '\\n');
  }
}

// Create singleton instance and expose it globally for onclick handlers
const adminDashboard = new AdminDashboard();
window.adminDashboard = adminDashboard;

export default adminDashboard;