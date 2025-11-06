# REST API Documentation - Soil Information System

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Usage Examples](#usage-examples)
5. [Database Schema](#database-schema)

---

## Overview

The Soil Information System REST API provides two types of authentication:
- **JWT Tokens**: For human administrators managing the system
- **API Keys**: For applications and servers accessing data

**Base URL**: `http://your-server:8000`

**API Documentation**: `http://your-server:8000/docs` (Interactive Swagger UI)

---

## Authentication

### JWT Token Authentication (Admin Users)

**Used for**: User management, API client management, layer/settings CRUD operations

**How to get a token**:
```bash
POST /api/auth/login
Content-Type: application/json

{
  "user_id": "admin@example.com",
  "password": "your-password"
}
```

**Response**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Token expires**: 60 minutes (configurable)

**How to use**:
```bash
Authorization: Bearer YOUR_JWT_TOKEN
```

### API Key Authentication (Applications/Servers)

**Used for**: Reading data (manifest, profiles, observations, layers, settings)

**How to get an API key**: Admin must create it via `/api/clients` endpoint

**How to use**:
```bash
X-API-Key: YOUR_API_KEY
```

---

## API Endpoints

### 🔓 Public Endpoints (No Authentication Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API root information |
| GET | `/health` | Health check endpoint |
| GET | `/docs` | Interactive API documentation (Swagger UI) |
| GET | `/openapi.json` | OpenAPI specification |

---

### 🔐 Authentication Endpoints

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| POST | `/api/auth/login` | Login with email/password, returns JWT token | Public (requires valid credentials) |
| GET | `/api/auth/verify` | Verify if JWT token is valid | JWT Token |

**Example - Login**:
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "admin@example.com",
    "password": "admin123"
  }'
```

---

### 👤 User Management (Admin Only)

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| POST | `/api/users` | Create a new user | JWT Token (Admin) |
| GET | `/api/users` | List all users | JWT Token (Admin) |
| DELETE | `/api/users/{user_id}` | Delete a user | JWT Token (Admin) |

**Example - Create User**:
```bash
curl -X POST http://localhost:8000/api/users?user_id=user@example.com&password=pass123&is_admin=false \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example - List Users**:
```bash
curl http://localhost:8000/api/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 🔑 API Client Management (Admin Only)

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| POST | `/api/clients` | Create new API client, returns API key (⚠️ shown only once!) | JWT Token (Admin) |
| GET | `/api/clients` | List all API clients | JWT Token (Admin) |
| PATCH | `/api/clients/{id}/status` | Activate/deactivate API client | JWT Token (Admin) |
| DELETE | `/api/clients/{id}` | Delete API client | JWT Token (Admin) |

**Example - Create API Client**:
```bash
curl -X POST http://localhost:8000/api/clients \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "api_client_id": "external-server",
    "description": "External data analysis server"
  }'
```

**Response**:
```json
{
  "message": "API client created successfully",
  "api_client_id": "external-server",
  "api_key": "AbCdEf123456789...",
  "warning": "Save this API key now. You won't be able to see it again!"
}
```

**Example - Deactivate API Client**:
```bash
curl -X PATCH http://localhost:8000/api/clients/external-server/status?is_active=false \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 🗺️ Layer Management (Authenticated Users)

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| POST | `/api/layer` | Create a new layer | JWT Token |
| PUT | `/api/layer/{layer_id}` | Update a layer (all fields) | JWT Token |
| PATCH | `/api/layer/{layer_id}/publish` | Publish or unpublish a layer | JWT Token |
| DELETE | `/api/layer/{layer_id}` | Delete a layer | JWT Token |
| GET | `/api/layer/all` | Get all layers (including unpublished) | JWT Token |
| GET | `/api/layer` | Get published layers only | API Key |

**Example - Create Layer**:
```bash
curl -X POST http://localhost:8000/api/layer \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "layer_id": "soil-ph-layer",
    "project_id": "proj-001",
    "project_name": "Soil pH Mapping",
    "publish": true,
    "property_name": "pH",
    "get_map_url": "http://mapserver/wms?layer=ph"
  }'
```

**Example - Update Layer**:
```bash
curl -X PUT http://localhost:8000/api/layer/soil-ph-layer \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "layer_id": "soil-ph-layer",
    "publish": true,
    "property_name": "pH (updated)"
  }'
```

**Example - Toggle Publish Status**:
```bash
curl -X PATCH http://localhost:8000/api/layer/soil-ph-layer/publish \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"publish": false}'
```

**Example - Get Published Layers (with API Key)**:
```bash
curl http://localhost:8000/api/layer \
  -H "X-API-Key: YOUR_API_KEY"
```

---

### 🔧 Settings Management

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| POST | `/api/setting` | Create a new setting | JWT Token |
| PUT | `/api/setting/{key}` | Update a setting value | JWT Token |
| DELETE | `/api/setting/{key}` | Delete a setting | JWT Token |
| GET | `/api/setting/all` | Get all settings (admin view) | JWT Token |
| GET | `/api/setting` | Get all settings (for applications) | API Key |

**Settings are used for**: Application configuration (logo URL, map center, default zoom, default layers, etc.)

**Example - Create Setting**:
```bash
curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "LATITUDE",
    "value": "27.5"
  }'
```

**Example - Update Setting**:
```bash
curl -X PUT http://localhost:8000/api/setting/LATITUDE \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value": "28.0"}'
```

**Example - Get Settings (with API Key)**:
```bash
curl http://localhost:8000/api/setting \
  -H "X-API-Key: YOUR_API_KEY"
```

**Response**:
```json
[
  {"key": "BASE_MAP_DEFAULT", "value": "esri-imagery"},
  {"key": "LATITUDE", "value": "27.5"},
  {"key": "LAYER_DEFAULT", "value": "BT-GSNM-BKD-2024-0-30"},
  {"key": "LONGITUDE", "value": "89.7"},
  {"key": "ORG_LOGO_URL", "value": "https://..."},
  {"key": "ZOOM", "value": "9"}
]
```

---

### 📊 Data Access Endpoints (API Key Required)

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| GET | `/api/manifest` | Get soil properties manifest | API Key |
| GET | `/api/profile` | Get all soil profiles | API Key |
| GET | `/api/observation` | Get all observational data | API Key |
| GET | `/api/observation?profile_code=XXX` | Get observations for specific profile | API Key |
| GET | `/api/layer` | Get published layers | API Key |
| GET | `/api/setting` | Get application settings | API Key |

**Example - Get Manifest**:
```bash
curl http://localhost:8000/api/manifest \
  -H "X-API-Key: YOUR_API_KEY"
```

**Example - Get Profiles**:
```bash
curl http://localhost:8000/api/profile \
  -H "X-API-Key: YOUR_API_KEY"
```

**Example - Get Observations (filtered)**:
```bash
curl http://localhost:8000/api/observation?profile_code=PROF001 \
  -H "X-API-Key: YOUR_API_KEY"
```

---

## Usage Examples

### Complete Workflow: Setting Up a New Application

#### 1. Create Admin User (One-time setup)
```bash
# Run inside sis-api container
docker exec -i sis-api python << 'EOF'
from main import hash_password, get_db

password_hash = hash_password("admin123")
with get_db() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO api.user (user_id, password_hash, is_admin, is_active) VALUES (%s, %s, %s, %s)",
            ('admin@example.com', password_hash, True, True)
        )
print("Admin user created!")
EOF
```

#### 2. Login as Admin
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "admin@example.com",
    "password": "admin123"
  }'

# Save the access_token from response
TOKEN="eyJhbGc..."
```

#### 3. Create API Client for Your Application
```bash
curl -X POST http://localhost:8000/api/clients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "api_client_id": "my-app",
    "description": "My mapping application"
  }'

# Save the api_key from response
API_KEY="AbCdEf123..."
```

#### 4. Configure Application Settings
```bash
curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "ORG_LOGO_URL", "value": "https://example.com/logo.png"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "LATITUDE", "value": "27.5"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "LONGITUDE", "value": "89.7"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "ZOOM", "value": "9"}'
```

#### 5. Create and Publish Layers
```bash
curl -X POST http://localhost:8000/api/layer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "layer_id": "soil-organic-carbon",
    "project_name": "SOC Mapping 2024",
    "publish": true,
    "property_name": "Organic Carbon",
    "get_map_url": "http://mapserver/wms?layer=soc"
  }'
```

#### 6. Access Data in Your Application
```javascript
// JavaScript example for web application
const API_KEY = 'AbCdEf123...';
const API_BASE = 'http://your-server:8000';

// Fetch settings on app load
async function loadConfig() {
  const response = await fetch(`${API_BASE}/api/setting`, {
    headers: { 'X-API-Key': API_KEY }
  });
  const settings = await response.json();
  
  // Convert to object
  const config = {};
  settings.forEach(s => config[s.key] = s.value);
  return config;
}

// Fetch layers
async function loadLayers() {
  const response = await fetch(`${API_BASE}/api/layer`, {
    headers: { 'X-API-Key': API_KEY }
  });
  return await response.json();
}

// Fetch profiles
async function loadProfiles() {
  const response = await fetch(`${API_BASE}/api/profile`, {
    headers: { 'X-API-Key': API_KEY }
  });
  return await response.json();
}

// Use the data
const config = await loadConfig();
const layers = await loadLayers();
const profiles = await loadProfiles();

// Initialize map with config
map.setView([config.LATITUDE, config.LONGITUDE], config.ZOOM);
```

---

## Database Schema

### Core Tables

#### `api.user`
Stores admin/user accounts for system management.

| Column | Type | Description |
|--------|------|-------------|
| user_id | text | Primary key, email address |
| password_hash | text | Bcrypt hashed password |
| is_active | boolean | Account active status |
| is_admin | boolean | Admin privileges flag |
| created_at | timestamp | Account creation date |
| updated_at | timestamp | Last update timestamp |
| last_login | timestamp | Last login timestamp |

#### `api.api_client`
Stores API keys for applications and servers.

| Column | Type | Description |
|--------|------|-------------|
| api_client_id | text | Primary key, client identifier |
| api_key | text | Unique API key (shown only once at creation) |
| is_active | boolean | API key active status |
| created_at | date | Creation date |
| expires_at | date | Optional expiration date |
| last_login | timestamp | Last usage timestamp |
| description | text | Client description |

#### `api.layer`
Stores map layer configurations.

| Column | Type | Description |
|--------|------|-------------|
| layer_id | text | Primary key |
| project_id | text | Project identifier |
| project_name | text | Project name |
| publish | boolean | Published status |
| property_name | text | Soil property name |
| dimension | text | Dimension info |
| version | text | Version string |
| unit_of_measure_id | text | Unit reference |
| metadata_url | text | Metadata service URL |
| download_url | text | Download URL |
| get_map_url | text | WMS GetMap URL |
| get_legend_url | text | Legend URL |
| get_feature_info_url | text | Feature info URL |

#### `api.setting`
Stores application configuration settings.

| Column | Type | Description |
|--------|------|-------------|
| key | text | Primary key, setting name |
| value | text | Setting value |

**Common settings**:
- `ORG_LOGO_URL`: Organization logo URL
- `LATITUDE`: Default map center latitude
- `LONGITUDE`: Default map center longitude
- `ZOOM`: Default zoom level
- `LAYER_DEFAULT`: Default layer ID
- `BASE_MAP_DEFAULT`: Default basemap

#### `api.audit`
Audit log of all API actions.

| Column | Type | Description |
|--------|------|-------------|
| audit_id | integer | Primary key (auto-increment) |
| user_id | text | User who performed action (nullable) |
| api_client_id | text | API client that performed action (nullable) |
| action | text | Action description |
| details | jsonb | Additional details |
| ip_address | inet | Client IP address |
| created_at | timestamp | Action timestamp |

### Views

#### `api.vw_api_manifest`
View exposing soil properties and geographic extent.

#### `api.vw_api_profile`
View exposing soil profile information.

#### `api.vw_api_observation`
View exposing observational data.

---

## Error Responses

### Common HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created successfully |
| 400 | Bad request (validation error) |
| 401 | Unauthorized (missing or invalid authentication) |
| 403 | Forbidden (insufficient privileges) |
| 404 | Not found |
| 500 | Internal server error |

### Error Response Format

```json
{
  "detail": "Error message describing what went wrong"
}
```

### Common Errors

**Missing API Key**:
```json
{
  "detail": "API key required. Include X-API-Key header in your request."
}
```

**Invalid API Key**:
```json
{
  "detail": "Invalid API key"
}
```

**Expired Token**:
```json
{
  "detail": "Could not validate credentials"
}
```

**Insufficient Privileges**:
```json
{
  "detail": "Admin privileges required"
}
```

---

## Security Best Practices

### For Administrators

1. **Change default passwords immediately** after initial setup
2. **Use strong passwords** (minimum 12 characters, mixed case, numbers, symbols)
3. **Store API keys securely** - treat them like passwords
4. **Rotate API keys periodically** for external clients
5. **Monitor audit logs** regularly for suspicious activity
6. **Use HTTPS** in production (configure SSL in nginx)
7. **Deactivate unused API clients** instead of deleting (preserves audit trail)
8. **Don't commit** `.env` files or API keys to version control

### For Developers

1. **Never hardcode API keys** in source code
2. **Use environment variables** for configuration
3. **Implement proper error handling** for authentication failures
4. **Set appropriate request timeouts**
5. **Use HTTPS** for all API requests in production
6. **Validate API responses** before using data
7. **Handle token expiration** gracefully (implement refresh logic)

---

## Rate Limiting

Rate limiting is configured in nginx:

- **API endpoints**: 10 requests/second (burst: 20)
- **Login endpoint**: 5 requests/minute (burst: 5)

Exceeding rate limits returns HTTP 429 (Too Many Requests).

---

## Support & Contact

For issues or questions:
- Check interactive documentation: `/docs`
- Review audit logs: `api.audit` table
- Check container logs: `docker logs sis-api`

---

**Document Version**: 1.0  
**Last Updated**: November 2024  
**API Version**: 1.0.0