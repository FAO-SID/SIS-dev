/**
 * QUICK PATCH GUIDE FOR main.js
 * 
 * This file shows the EXACT changes you need to make to main.js
 * Line numbers are approximate based on your uploaded file
 */

// =============================================================================
// CHANGE #1: Add import at the top (after line 8, after other imports)
// =============================================================================

// Add this line after: import api, { MAPSERVER_URL } from './api-client.js';
import adminDashboard from './admin-dashboard.js';


// =============================================================================
// CHANGE #2: Update login button initialization (around line 1268)
// =============================================================================

// FIND THIS (around line 1268):
document.getElementById('login-btn').addEventListener('click', showLoginModal);

// REPLACE WITH:
const loginBtn = document.getElementById('login-btn');
if (api.restoreSession()) {
  loginBtn.textContent = 'Admin Panel';
  loginBtn.onclick = showAdminPanel;
} else {
  loginBtn.onclick = showLoginModal;
}


// =============================================================================
// CHANGE #3: Replace showAdminPanel function (around line 1318-1328)
// =============================================================================

// FIND THIS ENTIRE FUNCTION:
function showAdminPanel() {
  // This would open a full admin interface
  // For now, just show an alert that you're logged in
  alert('Admin panel functionality coming soon! You can now manage layers and settings via API calls.');
  document.getElementById('login-btn').textContent = 'Logout';
  document.getElementById('login-btn').onclick = () => {
    api.logout();
    document.getElementById('login-btn').textContent = 'Admin Login';
    alert('Logged out successfully');
  };
}

// REPLACE WITH THIS ENTIRE FUNCTION:
function showAdminPanel() {
  // Show the admin dashboard
  adminDashboard.show();
  
  // Update login button
  const loginBtn = document.getElementById('login-btn');
  loginBtn.textContent = 'Admin Panel';
  loginBtn.onclick = () => {
    if (api.isAuthenticated()) {
      const dashboardActive = document.getElementById('admin-dashboard')?.classList.contains('active');
      
      if (dashboardActive) {
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
    } else {
      showLoginModal();
    }
  };
}


// =============================================================================
// THAT'S IT! Those are the only 3 changes needed in main.js
// =============================================================================

/**
 * SUMMARY OF CHANGES:
 * 
 * 1. Import the adminDashboard module
 * 2. Update login button to restore session on page load
 * 3. Replace showAdminPanel() to use the dashboard instead of alert
 * 
 * After making these changes:
 * 1. Copy admin-dashboard.js to src/js/
 * 2. Copy admin-dashboard.css to src/css/
 * 3. Update index.html (or add <link rel="stylesheet" href="./css/admin-dashboard.css">)
 * 4. Update main.css (or ensure header-actions class exists)
 * 5. Rebuild: docker compose build sis-web-mapping
 * 6. Restart: docker compose up -d sis-web-mapping
 */
