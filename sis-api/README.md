# SIS API - Soil Information System REST API

A comprehensive REST API built with FastAPI for managing soil data, file uploads, and web mapping layers.

## Features

- 🔐 **JWT-based Authentication** - Secure token-based authentication with refresh tokens
- 📁 **File Upload Processing** - Excel/CSV file upload with automatic PostgreSQL table creation
- 🗺️ **Geospatial Data Support** - PostGIS integration for spatial data handling
- 📊 **Comprehensive Data Management** - Full CRUD operations for soil data entities
- 🛡️ **Security Best Practices** - Rate limiting, CORS, input validation, password hashing
- 📚 **Auto-generated Documentation** - Interactive API docs with Swagger UI
- 🐳 **Docker Support** - Containerized deployment with Docker Compose

## Technical Stack

- **Backend**: FastAPI (Python 3.11+)
- **Database**: PostgreSQL with PostGIS extension
- **ORM**: SQLAlchemy 2.0
- **Authentication**: JWT tokens with bcrypt password hashing
- **File Processing**: Pandas, OpenPyXL for Excel/CSV handling
- **Validation**: Pydantic schemas
- **Rate Limiting**: SlowAPI with Redis backend
- **Documentation**: Automatic OpenAPI/Swagger generation

## Database Schemas

The API manages data across multiple PostgreSQL schemas:

- `api` - User management, settings, layers, file uploads
- `soil_data` - Core soil data entities (ISO-28258 compliant)
- `soil_data_upload` - Dynamically created tables from file uploads
- `spatial_metadata` - Spatial metadata for rasters (read-only for API)

## Quick Start

### Using Docker (Recommended)

1. **Clone and setup**:
```bash
git clone <repository>
cd sis-api
cp .env.example .env
# Edit .env with your settings
```

2. **Start services**:
```bash
docker-compose up -d
```

3. **Access the API**:
- API Documentation: http://localhost:8000/api/v1/docs
- Database Admin: http://localhost:8080 (Adminer)
- API Endpoint: http://localhost:8000

### Manual Installation

1. **Install dependencies**:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. **Setup PostgreSQL database**:
```bash
# Create database and run schema
psql -U postgres -c "CREATE DATABASE sis_database;"
psql -U postgres -d sis_database -f sis-database_latest_only_schema.sql
```

3. **Configure environment**:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. **Run the application**:
```bash
uvicorn app.main:app --reload
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user info
- `POST /api/v1/auth/change-password` - Change password

### API Resources (api schema)
- `GET/POST/PUT/DELETE /api/v1/api/settings` - Application settings
- `GET/POST/PUT/DELETE /api/v1/api/layers` - Map layers management
- `GET/POST/DELETE /api/v1/api/user-layers` - User layer associations
- `POST /api/v1/api/upload` - File upload (Excel/CSV)
- `GET/PUT/DELETE /api/v1/api/uploaded-datasets` - Manage uploaded datasets

### Soil Data (soil_data schema)
- `GET/POST /api/v1/soil-data/individuals` - Individual entities
- `GET/POST /api/v1/soil-data/organisations` - Organisation entities
- `GET/POST /api/v1/soil-data/projects` - Project entities
- `GET/POST/DELETE /api/v1/soil-data/proj-org-ind` - Project associations
- `GET /api/v1/soil-data/profiles` - Soil profiles view (read-only)
- `GET /api/v1/soil-data/profiles/geojson` - Profiles as GeoJSON

## File Upload Features

The API supports uploading Excel (.xlsx, .xls) and CSV files:

1. **Automatic Processing**:
   - Data type inference (text, numeric, date, boolean)
   - Column name cleaning for database compatibility
   - Coordinate detection for geospatial data

2. **Database Integration**:
   - Creates tables in `soil_data_upload` schema
   - Maintains metadata in `uploaded_dataset` table
   - Column mapping support for data integration

3. **Data Access**:
   - Paginated data retrieval
   - REST endpoints for uploaded table management
   - Integration with existing soil data workflow

## Authentication & Security

### JWT Token Authentication
```python
# Login to get tokens
POST /api/v1/auth/login
{
  "individual_id": "user123",
  "password": "password"
}

# Use access token in headers
Authorization: Bearer <access_token>
```

### Security Features
- Password hashing with bcrypt
- Rate limiting (configurable per endpoint)
- CORS protection
- Input validation with Pydantic
- SQL injection prevention with SQLAlchemy
- File upload size and type restrictions

## Configuration

Key environment variables:

```env
# Database
DATABASE_URL=postgresql://user:pass@host:port/database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sis_database
DB_USER=sis
DB_PASSWORD=password

# JWT Authentication
SECRET_KEY=your-super-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# File Upload
MAX_FILE_SIZE_MB=50
UPLOAD_DIR=./uploads
ALLOWED_EXTENSIONS=[".xlsx", ".xls", ".csv"]

# API Settings
API_V1_STR=/api/v1
BACKEND_CORS_ORIGINS=["http://localhost:3000"]

# Rate Limiting
REDIS_URL=redis://localhost:6379/0
```

## API Usage Examples

### User Registration and Authentication
```bash
# Register new user
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "individual_id": "john_doe",
    "email": "john@example.com",
    "password": "secure_password"
  }'

# Login
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "individual_id": "john_doe",
    "password": "secure_password"
  }'
```

### File Upload
```bash
# Upload Excel/CSV file
curl -X POST "http://localhost:8000/api/v1/api/upload" \
  -H "Authorization: Bearer <access_token>" \
  -F "file=@data.xlsx" \
  -F "project_id=project123"
```

### Get Soil Profiles as GeoJSON
```bash
curl -X GET "http://localhost:8000/api/v1/soil-data/profiles/geojson?limit=10" \
  -H "Authorization: Bearer <access_token>"
```

## Development

### Running Tests
```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

### Database Migrations
The application uses the existing database schema. For schema changes:

1. Update the SQL schema file
2. Apply changes to your database
3. Update SQLAlchemy models accordingly

### Adding New Endpoints
1. Create new route in appropriate router file
2. Add Pydantic schemas for request/response models
3. Update the main API router to include new routes
4. Add authentication/authorization as needed

## Deployment

### Production Considerations
- Use strong `SECRET_KEY` (generate with `openssl rand -hex 32`)
- Configure proper CORS origins
- Set up SSL/TLS termination
- Configure PostgreSQL connection pooling
- Set up monitoring and logging
- Use environment-specific configuration files
- Consider using a reverse proxy (nginx)

### Docker Production Deployment
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  api:
    image: sis-api:latest
    environment:
      - ENVIRONMENT=production
      - SECRET_KEY=${SECRET_KEY}
      - DATABASE_URL=${DATABASE_URL}
    ports:
      - "8000:8000"
    restart: always
```

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/api/v1/docs
- **ReDoc**: http://localhost:8000/api/v1/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues:
1. Check the API documentation at `/api/v1/docs`
2. Review this README
3. Open an issue in the repository

## Roadmap

- [ ] GraphQL endpoint support
- [ ] Advanced spatial query capabilities  
- [ ] Data export functionality (Excel, CSV, GeoJSON)
- [ ] Background task processing for large file uploads
- [ ] Advanced user role management
- [ ] API versioning strategy
- [ ] Comprehensive test suite
- [ ] Performance monitoring and metrics 