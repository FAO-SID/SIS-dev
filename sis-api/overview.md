Overview of all endpoints, their HTTP methods, and who can access them:

## 🔓 **Public Endpoints** (No Authentication)

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| GET | `/` | API root information | Anyone |
| GET | `/health` | Health check | Anyone |
| GET | `/docs` | Interactive API documentation | Anyone |

## 🔐 **Admin Authentication Endpoints**

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| POST | `/api/auth/login` | Login with email/password, returns JWT token | Anyone (but needs valid credentials) |
| GET | `/api/auth/verify` | Verify if JWT token is valid | Users with valid JWT token |

## 👤 **User Management** (Admin Only - Requires JWT)

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| POST | `/api/users` | Create a new user | Admins only |
| GET | `/api/users` | List all users | Admins only |
| DELETE | `/api/users/{user_id}` | Delete a user | Admins only |

## 🔑 **API Client Management** (Admin Only - Requires JWT)

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| POST | `/api/clients` | Create new API client, returns API key | Admins only |
| GET | `/api/clients` | List all API clients | Admins only |
| PATCH | `/api/clients/{api_client_id}/status` | Activate/deactivate API client | Admins only |
| DELETE | `/api/clients/{api_client_id}` | Delete API client | Admins only |

## 🗺️ **Layer Management** (Authenticated Users - Requires JWT)

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| POST | `/api/layer` | Create a new layer | Authenticated users (JWT) |
| PUT | `/api/layer/{layer_id}` | Update a layer (all fields) | Authenticated users (JWT) |
| PATCH | `/api/layer/{layer_id}/publish` | Publish/unpublish a layer | Authenticated users (JWT) |
| DELETE | `/api/layer/{layer_id}` | Delete a layer | Authenticated users (JWT) |
| GET | `/api/layer/all` | Get all layers (including unpublished) | Authenticated users (JWT) |

## 📊 **Data Access** (Applications - Requires API Key)

| Method | Endpoint | Description | Who Can Access |
|--------|----------|-------------|----------------|
| GET | `/api/manifest` | Get soil properties manifest | Applications with API key |
| GET | `/api/profile` | Get soil profiles | Applications with API key |
| GET | `/api/observation` | Get observational data | Applications with API key |
| GET | `/api/observation?profile_code=XXX` | Filter observations by profile | Applications with API key |
| GET | `/api/layer` | Get published layers only | Applications with API key |

## 📝 **Summary by Authentication Type**

### **JWT Token** (for human admins)
```bash
# Get token
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user_id": "admin@example.com", "password": "admin123"}'

# Use token
curl http://localhost:8000/api/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Can do:**
- ✅ Manage users
- ✅ Manage API clients
- ✅ Create/update/delete layers
- ✅ See all layers (published & unpublished)

### **API Key** (for applications/servers)
```bash
curl http://localhost:8000/api/manifest \
  -H "X-API-Key: YOUR_API_KEY"
```

**Can do:**
- ✅ Read manifest data
- ✅ Read profiles
- ✅ Read observations
- ✅ Read published layers only
- ❌ Cannot manage users, clients, or layers

## 🔒 **Security Notes**

- **JWT tokens** expire after 60 minutes (configurable)
- **API keys** are long-lived (until manually revoked/deleted)
- All actions are logged in the `api.audit` table
- Failed authentication attempts are also logged

Is there anything specific you'd like me to clarify about any endpoint?