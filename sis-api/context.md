I need help building a REST API for my existing web mapping application. Here's what I have and what I need:

## Technical Context Template

### Current Application Overview
- **Type**: Web mapping application using OpenLayers
- **Current functionality**: Interactive map with soil data layers
- **Technology stack**: PostgreSQL, MapServer, Node.js, Docker
- **Hosting/Deployment**: running on localhost as docker containers

### Required API Specifications

**1. Authentication System**
```
- RESTful API with JWT token-based authentication
- Endpoints needed: `/auth/login`, `/auth/logout`, `/auth/refresh`
- User roles: admin and basic auth
```

**2. Database Architecture**
```
PostgreSQL Database Requirements:
In file sis-database_latest_only_schema.sql
- api schema for user, app settings, file upload details, and manage layers shown on the web-mappinp app
- kobo shcema will not be used here, it is for another application
- public schema, I don't use it
- soil_data schema to store soil data, we will need some end-points on some of the tables, specified later
- soil_data_upload schema to store the uploaded files converted into tables
- spatial metadata schema to store rasters metadata. No end-poins need here, for now.
```


**3. Core API Endpoints Needed**
```
GET, POST PUT in all resources on database schema api
GET, POST in tables soil_data.individual, soil_data.organisation, soil_data.proj_x_org_x_ind, soil_data.project
GET on view soil_data.profiles
```

**4. File Upload Requirements**
```
- Support for Excel (.xlsx, .xls) and CSV files
- Automatic table creation in PostgreSQL in schema upload
- Data validation and type inference
- Geospatial data handling
- File size limits and error handling
```

### Technical Preferences
- **Backend Framework**: Python/FastAPI
- **Database**: PostgreSQL
- **Database ORM**: SQLAlchemy
- **File Processing**: Libraries for Excel/CSV parsing
- **Security**: Password hashing, input validation, rate limiting, best practices

### Integration Requirements
- API should serve GeoJSON/vector tiles for map layers
- CORS configuration for your frontend domain
- Database connection pooling
- Environment-based configuration

### Additional Context to Include
1. **Current map data source**: MapServer
2. **User base size**: 50
3. **Data sensitivity**: No sensible data, still should be a secure application
4. **Deployment environment**: Docker container
5. **Existing database**: PostgreSQL, one database for all application separated by schemas

### REQUIRED API FEATURES:
1. JWT-based authentication system
2. PostgreSQL backend with connection pooling
3. User settings management (customizable via settings_key table)
4. Layer management with project-based organization
5. Excel/CSV upload functionality that creates tables in PostgreSQL
6. Security best practices
7. Sample implementation code
8. Complete API architecture design
