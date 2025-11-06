/**
 * API Client for Soil Information System
 * Handles all API communication with authentication
 */

// Read API configuration from environment or fallback to defaults
const API_BASE_URL = process.env.API_URL || 'http://localhost:8000';
const API_KEY = process.env.API_KEY || '';

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
}

// Export singleton instance
export default new SISApiClient();