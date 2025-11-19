# Admin Dashboard for Soil Information System

This admin dashboard provides a complete interface for managing Settings and Layers in your Soil Information System.

## Features

✅ **User Authentication**
- Login with email and password
- JWT token-based authentication
- Session persistence (survives page refreshes)
- Secure logout

✅ **Settings Management**
- View all system settings
- Create new settings
- Edit existing settings
- Delete settings
- Simple key-value interface

✅ **Layers Management**
- View all layers in the system
- Create new layers with full metadata
- Edit existing layers
- Toggle publish/unpublish status
- Delete layers
- Support for all layer properties:
  - Project information
  - Property details
  - URLs for metadata, download, WMS, legend, feature info

✅ **Modern UI**
- Clean, tabbed interface
- Responsive design
- Inline editing
- Confirmation dialogs for destructive actions
- Real-time updates

## Installation

### 1. Copy the new files to your project

Copy these files from the outputs folder to your sis-web-mapping project:

```bash
# CSS files
cp admin-dashboard.css ./sis-web-mapping/src/css/

# JavaScript files
cp admin-dashboard.js ./sis-web-mapping/src/js/

# Updated files (replace existing)
cp index.html ./sis-web-mapping/src/index.html
cp main.css ./sis-web-mapping/src/css/main.css
```

### 2. Update main.js

Open `./sis-web-mapping/src/js/main.js` and make these changes:

#### A. Add import at the top (after existing imports)

```javascript
import adminDashboard from './admin-dashboard.js';
```

#### B. Replace the `showAdminPanel()` function (around line 1318)

Find this function:
```javascript
function showAdminPanel() {
  alert('Admin panel functionality coming soon! You can now manage layers and settings via API calls.');
  document.getElementById('login-btn').textContent = 'Logout';
  document.getElementById('login-btn').onclick = () => {
    api.logout();
    document.getElementById('login-btn').textContent = 'Admin Login';
    alert('Logged out successfully');
  };
}
```

Replace it with:
```javascript
function showAdminPanel() {
  // Show the admin dashboard
  adminDashboard.show();
  
  // Update login button
  const loginBtn = document.getElementById('login-btn');
  loginBtn.textContent = 'Admin Panel';
  loginBtn.onclick = () => {
    if (api.isAuthenticated()) {
      if (document.getElementById('admin-dashboard')?.classList.contains('active')) {
        // Dashboard is visible, offer to logout
        if (confirm('Do you want to logout?')) {
          api.logout();
          loginBtn.textContent = 'Admin Login';
          loginBtn.onclick = showLoginModal;
          adminDashboard.hide();
          alert('Logged out successfully');
        } else {
          // User cancelled, close dashboard
          adminDashboard.hide();
        }
      } else {
        // Dashboard is hidden, show it again
        adminDashboard.show();
      }
    }
  };
}
```

#### C. Update login button initialization (around line 1268)

Find this line:
```javascript
document.getElementById('login-btn').addEventListener('click', showLoginModal);
```

Replace it with:
```javascript
const loginBtn = document.getElementById('login-btn');
if (api.restoreSession()) {
  loginBtn.textContent = 'Admin Panel';
  loginBtn.onclick = showAdminPanel;
} else {
  loginBtn.onclick = showLoginModal;
}
```

### 3. Rebuild the container

```bash
cd /path/to/your/project
docker compose build sis-web-mapping
docker compose up -d sis-web-mapping
```

## Usage

### Logging In

1. Open your application at `http://localhost/`
2. Click the **"Admin Login"** button in the top-right corner
3. Enter your admin credentials:
   - Email: (your admin email)
   - Password: (your admin password)
4. Click **"Login"**

### Managing Settings

1. After logging in, the dashboard opens automatically to the **Settings** tab
2. **Add a new setting:**
   - Enter the Key and Value
   - Click **"Add Setting"**
3. **Edit a setting:**
   - Click **"Edit"** button next to the setting
   - Modify the value (key cannot be changed)
   - Click **"Update Setting"**
4. **Delete a setting:**
   - Click **"Delete"** button next to the setting
   - Confirm the deletion

### Managing Layers

1. Click the **"Layers"** tab at the top of the dashboard
2. **Add a new layer:**
   - Fill in the form fields (at minimum, Layer ID is required)
   - Check/uncheck "Published" as needed
   - Click **"Add Layer"**
3. **Edit a layer:**
   - Click **"Edit"** button next to the layer
   - Modify the fields as needed
   - Click **"Update Layer"**
4. **Toggle publish status:**
   - Click **"Publish"** or **"Unpublish"** button
   - Layer visibility updates immediately
5. **Delete a layer:**
   - Click **"Delete"** button next to the layer
   - Confirm the deletion

### Session Persistence

Your login session is saved in the browser. This means:
- You remain logged in even after refreshing the page
- Close the dashboard and reopen it anytime by clicking **"Admin Panel"**
- To logout, click **"Admin Panel"** and confirm logout when prompted

## Layer Fields Reference

| Field | Description | Required |
|-------|-------------|----------|
| **Project ID** | Unique identifier for the project | No |
| **Project Name** | Display name of the project | No |
| **Layer ID** | Unique identifier for the layer | **Yes** |
| **Property Name** | Name of the soil property | No |
| **Dimension** | Dimension or depth range (e.g., "0-30-MEAN") | No |
| **Version** | Version identifier | No |
| **Unit of Measure** | Unit of measurement for values | No |
| **Metadata URL** | Link to metadata record | No |
| **Download URL** | Link to download the dataset | No |
| **GetMap URL** | WMS GetMap endpoint URL | No |
| **Legend URL** | WMS GetLegendGraphic URL | No |
| **FeatureInfo URL** | WMS GetFeatureInfo URL | No |
| **Published** | Whether layer is visible to users | No (default: true) |

## API Endpoints Used

The dashboard uses these API endpoints (already implemented in your FastAPI backend):

### Authentication
- `POST /api/auth/login` - Login with credentials

### Settings
- `GET /api/setting/all` - Get all settings (requires JWT)
- `POST /api/setting` - Create new setting (requires JWT)
- `PUT /api/setting/{key}` - Update setting (requires JWT)
- `DELETE /api/setting/{key}` - Delete setting (requires JWT)

### Layers
- `GET /api/layer/all` - Get all layers (requires JWT)
- `POST /api/layer` - Create new layer (requires JWT)
- `PUT /api/layer/{gid}` - Update layer (requires JWT)
- `PATCH /api/layer/{gid}/publish` - Toggle publish status (requires JWT)
- `DELETE /api/layer/{gid}` - Delete layer (requires JWT)

## Security Notes

- Admin operations require JWT authentication
- Tokens are stored in localStorage
- Tokens expire based on ACCESS_TOKEN_EXPIRE_MINUTES setting
- All destructive operations require confirmation
- Input is sanitized to prevent XSS attacks

## Troubleshooting

### "Not authenticated" error
- Your session may have expired
- Click logout and login again

### Changes not appearing in map
- Refresh the browser after modifying layers
- Check that layers are marked as "Published"

### Can't login
- Verify your admin credentials in the database
- Check FastAPI logs: `docker logs sis-api`
- Ensure CORS is properly configured

### Dashboard not appearing
- Check browser console for JavaScript errors
- Verify admin-dashboard.js is properly imported in main.js
- Verify admin-dashboard.css is loaded in index.html

## File Structure

```
sis-web-mapping/src/
├── index.html                  # Updated with CSS link and login button
├── css/
│   ├── main.css               # Updated with header-actions styling
│   └── admin-dashboard.css    # NEW - Dashboard styles
└── js/
    ├── main.js                # Updated with dashboard integration
    ├── api-client.js          # Existing - no changes needed
    └── admin-dashboard.js     # NEW - Dashboard functionality
```

## Browser Compatibility

- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- Mobile browsers: ✅ Responsive design

## Support

For issues or questions:
1. Check browser console for errors
2. Check Docker logs: `docker logs sis-api` and `docker logs sis-web-mapping`
3. Verify database connection and JWT token configuration

---

**Your admin dashboard is now ready to use! 🎉**
