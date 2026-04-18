/**
 * API Client for Soil Information System
 * Handles all API communication with authentication
 */

// Read API configuration from environment or fallback to defaults
// Parcel will replace process.env at build time
const API_BASE_URL = process.env.API_URL;
const API_KEY = process.env.API_KEY;
const MAPSERVER_URL = process.env.MAPSERVER_URL;


class SISApiClient {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.apiKey = API_KEY;
    this.jwtToken = null;
  }

  /**
   * Make authenticated request with API key
   */
  async request(endpoint, options = {}) {
    const headers = {
      'X-API-Key': this.apiKey,
      'Content-Type': 'application/json',
      ...options.headers
    };

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: response.statusText }));
      throw new Error(error.detail || `API Error: ${response.status}`);
    }

    return response.json();
  }

  /**
   * Make authenticated request with JWT token (for admin operations)
   */
  async authenticatedRequest(endpoint, options = {}) {
    if (!this.jwtToken) {
      throw new Error('Not authenticated. Please login first.');
    }

    const headers = {
      'Authorization': `Bearer ${this.jwtToken}`,
      'Content-Type': 'application/json',
      ...options.headers
    };

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers
    });

    if (!response.ok) {
      if (response.status === 401) {
        this.jwtToken = null;
        localStorage.removeItem('jwt_token');
        window.dispatchEvent(new Event('auth:expired'));
        throw new Error('Session expired. Please login again.');
      }
      const error = await response.json().catch(() => ({ detail: response.statusText }));
      throw new Error(error.detail || `API Error: ${response.status}`);
    }

    return response.json();
  }

  // ==================== Authentication ====================

  async login(email, password) {
    const response = await fetch(`${this.baseURL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: email, password })
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Login failed' }));
      throw new Error(error.detail);
    }

    const data = await response.json();
    this.jwtToken = data.access_token;
    localStorage.setItem('jwt_token', this.jwtToken);
    return data;
  }

  logout() {
    this.jwtToken = null;
    localStorage.removeItem('jwt_token');
  }

  isAuthenticated() {
    return !!this.jwtToken;
  }

  restoreSession() {
    const token = localStorage.getItem('jwt_token');
    if (token) {
      this.jwtToken = token;
      return true;
    }
    return false;
  }

  // ==================== Data Endpoints (API Key) ====================

  async getSettings() {
    return this.request('/api/setting');
  }

  async getLayers() {
    return this.request('/api/layer');
  }

  async getProfiles() {
    return this.request('/api/profile');
  }

  async getObservations(profileCode = null) {
    const endpoint = profileCode 
      ? `/api/observation?profile_code=${encodeURIComponent(profileCode)}`
      : '/api/observation';
    return this.request(endpoint);
  }

  async getManifest() {
    return this.request('/api/manifest');
  }

  // ==================== Admin Endpoints (JWT Token) ====================

  // Settings Management
  async getAllSettings() {
    return this.authenticatedRequest('/api/setting/all');
  }

  async createSetting(key, value) {
    return this.authenticatedRequest('/api/setting', {
      method: 'POST',
      body: JSON.stringify({ key, value })
    });
  }

  async updateSetting(key, value) {
    return this.authenticatedRequest(`/api/setting/${key}`, {
      method: 'PUT',
      body: JSON.stringify({ value })
    });
  }

  async deleteSetting(key) {
    return this.authenticatedRequest(`/api/setting/${key}`, {
      method: 'DELETE'
    });
  }

  // Layer Management
  async getAllLayers() {
    return this.authenticatedRequest('/api/layer/all');
  }

  async createLayer(layerData) {
    return this.authenticatedRequest('/api/layer', {
      method: 'POST',
      body: JSON.stringify(layerData)
    });
  }

  async updateLayer(layerId, layerData) {
    return this.authenticatedRequest(`/api/layer/${layerId}`, {
      method: 'PUT',
      body: JSON.stringify(layerData)
    });
  }

  async toggleLayerPublish(layerId, publish) {
    return this.authenticatedRequest(`/api/layer/${layerId}/publish`, {
      method: 'PATCH',
      body: JSON.stringify({ publish })
    });
  }

  async deleteLayer(layerId) {
    return this.authenticatedRequest(`/api/layer/${layerId}`, {
      method: 'DELETE'
    });
  }

  async syncLayers() {
    return this.authenticatedRequest('/api/sync/layers', {
      method: 'POST'
    });
  }

  async setDefaultLayer(layerId) {
    return this.authenticatedRequest(`/api/layer/${layerId}/default`, {
      method: 'PATCH'
    });
  }

  async clearDefaultLayer() {
    return this.authenticatedRequest('/api/default-layer/clear', {
      method: 'POST'
    });
  }

  // Soil profile layers (per-project)
  async getSoilProfileLayers() {
    return this.authenticatedRequest('/api/layer/soil_profiles');
  }

  async setSoilProfilePublish(projectId, isPublished) {
    return this.authenticatedRequest(`/api/layer/soil_profiles/${encodeURIComponent(projectId)}/publish`, {
      method: 'PATCH',
      body: JSON.stringify({ is_published: isPublished })
    });
  }

  async setSoilProfileLimit(projectId, profileLimit) {
    return this.authenticatedRequest(`/api/layer/soil_profiles/${encodeURIComponent(projectId)}/limit`, {
      method: 'PATCH',
      body: JSON.stringify({ profile_limit: profileLimit })
    });
  }

  async setSoilProfileBlur(projectId, spatialBlurM) {
    return this.authenticatedRequest(`/api/layer/soil_profiles/${encodeURIComponent(projectId)}/blur`, {
      method: 'PATCH',
      body: JSON.stringify({ spatial_blur_m: spatialBlurM })
    });
  }

  // Dashboard
  async getDashboardStats() {
    return this.authenticatedRequest('/api/stats/dashboard');
  }

  // ==================== User Management (Admin JWT) ====================

  async verifyAuth() {
    return this.authenticatedRequest('/api/auth/verify');
  }

  async getUsers() {
    return this.authenticatedRequest('/api/users');
  }

  async createUser(userId, password, isAdmin = false) {
    return this.authenticatedRequest('/api/users', {
      method: 'POST',
      body: JSON.stringify({ user_id: userId, password, is_admin: isAdmin })
    });
  }

  async toggleUserActive(userId, isActive) {
    return this.authenticatedRequest(`/api/users/${encodeURIComponent(userId)}/active?is_active=${isActive}`, {
      method: 'PATCH'
    });
  }

  async deleteUser(userId) {
    return this.authenticatedRequest(`/api/users/${encodeURIComponent(userId)}`, {
      method: 'DELETE'
    });
  }

  // ==================== Codelist Endpoints (JWT Token) ====================

  async getOrganisations() {
    return this.authenticatedRequest('/api/codelist/organisations');
  }

  async getIndividuals() {
    return this.authenticatedRequest('/api/codelist/individuals');
  }

  async getProjects() {
    return this.authenticatedRequest('/api/codelist/projects');
  }

  async getProperties() {
    return this.authenticatedRequest('/api/codelist/properties');
  }

  async getProcedures() {
    return this.authenticatedRequest('/api/codelist/procedures');
  }

  async getUnits() {
    return this.authenticatedRequest('/api/codelist/units');
  }

  async getProceduresForProperty(propertyNumId) {
    return this.authenticatedRequest(`/api/codelist/procedures_for_property/${encodeURIComponent(propertyNumId)}`);
  }

  async getUnitsForProperty(propertyNumId) {
    return this.authenticatedRequest(`/api/codelist/units_for_property/${encodeURIComponent(propertyNumId)}`);
  }

  async createProject(data) {
    return this.authenticatedRequest('/api/codelist/projects', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  async updateProject(projectId, data) {
    return this.authenticatedRequest(`/api/codelist/projects/${encodeURIComponent(projectId)}`, {
      method: 'PATCH',
      body: JSON.stringify(data)
    });
  }

  async createOrganisation(data) {
    return this.authenticatedRequest('/api/codelist/organisations', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  async createIndividual(data) {
    return this.authenticatedRequest('/api/codelist/individuals', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  // ==================== ETL Endpoints (JWT Token) ====================

  async saveEtlMetadata(metadata) {
    return this.authenticatedRequest('/api/etl/metadata', {
      method: 'PUT',
      body: JSON.stringify(metadata)
    });
  }

  async getProjectAuthors(projectId) {
    return this.authenticatedRequest(`/api/etl/project/${encodeURIComponent(projectId)}/authors`);
  }

  async uploadCsv(file, projectId) {
    if (!this.jwtToken) {
      throw new Error('Not authenticated. Please login first.');
    }
    const formData = new FormData();
    formData.append('file', file);
    if (projectId) formData.append('project_id', projectId);
    const response = await fetch(`${this.baseURL}/api/etl/upload`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${this.jwtToken}` },
      body: formData
    });
    if (!response.ok) {
      if (response.status === 401) {
        this.jwtToken = null;
        localStorage.removeItem('jwt_token');
        window.dispatchEvent(new Event('auth:expired'));
        throw new Error('Session expired. Please login again.');
      }
      const error = await response.json().catch(() => ({ detail: response.statusText }));
      throw new Error(error.detail || `API Error: ${response.status}`);
    }
    return response.json();
  }

  async getDatasets() {
    return this.authenticatedRequest('/api/etl/datasets');
  }

  async getDatasetPreview(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/preview`);
  }

  async getDatasetColumns(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/columns`);
  }

  async saveDatasetColumns(tableName, columns, epsg) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/columns`, {
      method: 'PUT',
      body: JSON.stringify({ columns, epsg })
    });
  }

  async ingestDataset(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/ingest`, {
      method: 'POST'
    });
  }

  async pruneDataset(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/prune`, {
      method: 'POST'
    });
  }

  async deleteDataset(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}`, {
      method: 'DELETE'
    });
  }

  async validateDataset(tableName) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/validate`, {
      method: 'POST'
    });
  }

  async editDatasetCells(tableName, edits) {
    return this.authenticatedRequest(`/api/etl/datasets/${encodeURIComponent(tableName)}/cells`, {
      method: 'PATCH',
      body: JSON.stringify({ edits })
    });
  }

  async updateOwnAccount(currentPassword, newUserId, newPassword) {
    const body = { current_password: currentPassword };
    if (newUserId) body.new_user_id = newUserId;
    if (newPassword) body.new_password = newPassword;
    const res = await this.authenticatedRequest('/api/users/me', {
      method: 'PATCH',
      body: JSON.stringify(body)
    });
    if (res.access_token) {
      this.jwtToken = res.access_token;
      localStorage.setItem('jwt_token', res.access_token);
    }
    return res;
  }
}

// Export singleton instance
export { MAPSERVER_URL };
export default new SISApiClient();