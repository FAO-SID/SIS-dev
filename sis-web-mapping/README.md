# SIS Web Mapping - API Integration Instructions

## Overview

This document explains how to integrate your sis-web-mapping application with the REST API.

## What Changed

### Removed
- ❌ CSV-based layer loading (`layer_info.csv`)
- ❌ Old `layers.js` file
- ❌ Direct file references

### Added
- ✅ API client (`src/js/api-client.js`)
- ✅ Dynamic layer loading from `/api/layer` endpoint
- ✅ Profile layer with clustering from `/api/profile` endpoint
- ✅ Observation popup from `/api/observation` endpoint
- ✅ Settings management from `/api/setting` endpoint
- ✅ Admin login functionality

## Files to Update

### 1. Replace `src/js/main.js`
Replace the entire content with the new `main.js` provided.

### 2. Create `src/js/api-client.js`
Create this new file with the API client code provided.

### 3. Update `Dockerfile`
Replace with the new Dockerfile that accepts build arguments.

### 4. Update `nginx.conf`
Replace with the updated nginx configuration.

### 5. Update `docker-compose.yml`
Update the `sis-web-mapping` service section.

### 6. Delete old files
```bash
cd sis-web-mapping
rm src/js/layers.js  # No longer needed
# Keep layer_info.csv for reference but it won't be used
```

## Step-by-Step Integration

### Step 1: Backup Current Files
```bash
cd ~/Work/Code/FAO/SIS-dev/sis-web-mapping
cp src/js/main.js src/js/main.js.backup
cp Dockerfile Dockerfile.backup
cp nginx.conf nginx.conf.backup
```

### Step 2: Copy New Files

1. **Create API Client**:
```bash
# Copy the api-client.js content into:
nano src/js/api-client.js
```

2. **Replace Main.js**:
```bash
# Replace src/js/main.js with the new version
nano src/js/main.js
```

3. **Update Dockerfile**:
```bash
# Replace Dockerfile with the new version
nano Dockerfile
```

4. **Update nginx.conf**:
```bash
# Replace nginx.conf with the new version
nano nginx.conf
```

### Step 3: Populate Settings in Database

Run these commands to set up your application settings:

```bash
# Login first
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user_id":"admin@example.com","password":"admin123"}' | jq -r '.access_token')

# Create settings
curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"ORG_LOGO_URL","value":"../public/img/logo.png"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"APP_TITLE","value":"Bhutan Soil Information System"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"LATITUDE","value":"27.5"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"LONGITUDE","value":"89.7"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"ZOOM","value":"9"}'

curl -X POST http://localhost:8000/api/setting \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key":"BASE_MAP_DEFAULT","value":"esri-imagery"}'
```

### Step 4: Import Layers from CSV to Database

Create a script to import your existing layers:

```bash
# Create import script
cat > import_layers.py << 'EOF'
import csv
import requests
import sys

API_BASE = 'http://localhost:8000'
TOKEN = sys.argv[1] if len(sys.argv) > 1 else None

if not TOKEN:
    print("Please provide JWT token as argument")
    sys.exit(1)

headers = {
    'Authorization': f'Bearer {TOKEN}',
    'Content-Type': 'application/json'
}

with open('layer_info.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        layer_data = {
            'layer_id': row['layer_id'],
            'project_id': row['project_id'],
            'project_name': row['project_name'],
            'property_name': row['property_name'],
            'dimension': row['dimension_des'],
            'unit_of_measure_id': row['unit_id'],
            'metadata_url': row['metadata_url'],
            'download_url': row['download_url'],
            'get_map_url': row['get_map_url'],
            'get_legend_url': row['get_legend_url'],
            'get_feature_info_url': row['get_feature_info_url'],
            'publish': True
        }
        
        response = requests.post(
            f'{API_BASE}/api/layer',
            headers=headers,
            json=layer_data
        )
        
        if response.status_code == 201:
            print(f"✓ Imported: {layer_data['layer_id']}")
        else:
            print(f"✗ Failed: {layer_data['layer_id']} - {response.text}")

print("\nImport complete!")
EOF

# Run the import
python import_layers.py $TOKEN
```

### Step 5: Rebuild and Restart

```bash
# Make sure API key is in .env
echo "WEB_MAPPING_API_KEY=your-api-key-here" >> ../.env

# Rebuild and restart
cd ..
docker-compose build sis-web-mapping
docker-compose up -d sis-web-mapping

# Check logs
docker logs sis-web-mapping -f
```

### Step 6: Test the Application

1. Open `http://localhost:1234`
2. Verify layers load from API
3. Click on profile points to see observations
4. Test layer switching
5. Test admin login (top-right button)

## How It Works Now

### Data Flow

```
Application Startup
  ↓
Load Settings (/api/setting) → Apply logo, title, map center
  ↓
Load Layers (/api/layer) → Create layer switcher UI
  ↓
Load Profiles (/api/profile) → Add clustered point layer
  ↓
User clicks profile → Load Observations (/api/observation?profile_code=XXX)
```

### Configuration

All application configuration is now stored in the `api.setting` table:

| Key | Purpose | Example |
|-----|---------|---------|
| ORG_LOGO_URL | Header logo | `../public/img/logo.png` |
| APP_TITLE | Application title | `Bhutan Soil Information System` |
| LATITUDE | Map center latitude | `27.5` |
| LONGITUDE | Map center longitude | `89.7` |
| ZOOM | Initial zoom level | `9` |
| BASE_MAP_DEFAULT | Default basemap | `esri-imagery` |

### Layer Management

Layers are managed through the API:

- **View published layers**: Automatic on app load
- **Add/Edit layers**: Admin login required
- **Publish/Unpublish**: Changes layer visibility in app
- **Delete layers**: Removes from app immediately

### Profile Data

- **Point clustering**: Automatic based on zoom level
- **Click to view**: Shows profile details and observations
- **Always visible**: Can overlay with other layers

## Admin Features (Coming Soon)

The current implementation includes basic admin login. Full admin panel will include:

- ✅ Login/Logout
- 🚧 Layer management UI (add, edit, delete, publish)
- 🚧 Settings management UI
- 🚧 User management
- 🚧 API client management

## Troubleshooting

### Layers not loading
```bash
# Check API is accessible
curl -H "X-API-Key: YOUR_KEY" http://localhost:8000/api/layer

# Check browser console for errors
# Open DevTools → Console
```

### Settings not applied
```bash
# Verify settings exist
curl -H "X-API-Key: YOUR_KEY" http://localhost:8000/api/setting

# Check they're in correct format (key-value pairs)
```

### Profile clustering not working
```bash
# Verify profile data
curl -H "X-API-Key: YOUR_KEY" http://localhost:8000/api/profile

# Check geometry format (should be GeoJSON)
```

### Admin login fails
```bash
# Verify user exists
docker exec -it sis-database psql -U sis -d sis -c "SELECT * FROM api.user;"

# Check JWT token in browser console
# localStorage.getItem('jwt_token')
```

## Next Steps

1. **Test thoroughly** - Click around, test all features
2. **Import your data** - Use the import script for layers
3. **Customize styles** - Modify CSS as needed
4. **Add admin panel** - Extend the admin functionality
5. **Deploy** - Update docker-compose and deploy

## Support

If you encounter issues:
1. Check browser console for JavaScript errors
2. Check docker logs: `docker logs sis-web-mapping`
3. Verify API endpoints return data
4. Check network tab in DevTools

## Success Checklist

- [ ] API client created
- [ ] Main.js replaced
- [ ] Dockerfile updated
- [ ] nginx.conf updated
- [ ] Settings populated in database
- [ ] Layers imported to database
- [ ] Application rebuilds without errors
- [ ] Map loads correctly
- [ ] Layers switch properly
- [ ] Profiles show and cluster
- [ ] Observations popup works
- [ ] Admin login functional

Once all items are checked, your integration is complete! 🎉