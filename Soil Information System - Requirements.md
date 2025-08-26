# Soil Information System - Requirements and Infrastructure Guide

Repository: https://github.com/FAO-SID/GloSIS
Deploy file step-by-step: https://github.com/FAO-SID/GloSIS/blob/main/deploy.sh

## Container Application Deployment Overview
This guide outlines the hardware, software, and infrastructure requirements for deploying a multi-container application consisting of:
- PostgreSQL (Database)
- Web-Mapping  
- MapServer (Geographic mapping service)
- Metadata Server
- Shiny Server

## Hardware Requirements

### Minimum System Requirements
- **Processor**: 4-core CPU (Intel i5 or AMD Ryzen 5 equivalent)
- **Memory (RAM)**: 8 GB minimum
- **Storage**: 100 GB available disk space
- **Network**: Stable internet connection (10 Mbps minimum)

### Recommended System Requirements
- **Processor**: 8-core CPU (Intel i7 or AMD Ryzen 7 equivalent)
- **Memory (RAM)**: 16 GB or more
- **Storage**: 250 GB SSD storage
- **Network**: High-speed internet (50+ Mbps)

### Production Environment Requirements
- **Processor**: 12+ core CPU (Intel Xeon or AMD EPYC)
- **Memory (RAM)**: 32 GB or more
- **Storage**: 500 GB+ NVMe SSD
- **Network**: Enterprise-grade connection (100+ Mbps)
- **Redundancy**: RAID configuration for data protection

## Memory Allocation per Container

| Container | Minimum RAM | Recommended RAM | Peak Usage |
|-----------|-------------|-----------------|------------|
| PostgreSQL Database | 1 GB | 4 GB | 8 GB |
| Web-Mapping | 512 MB | 1 GB | 2 GB |
| MapServer | 512 MB | 2 GB | 4 GB |
| Metadata Server | 512 MB | 1 GB | 2 GB |
| Shiny Server | 1 GB | 2 GB | 4 GB |
| **System Overhead** | 1 GB | 2 GB | 4 GB |
| **Total Required** | **4.5 GB** | **12 GB** | **24 GB** |

## Storage Requirements

### Disk Space Allocation
- **Application Files**: 5 GB
- **Database Storage**: 10 GB
- **Map Data Files**: 1-50 GB (depends on your raster data)
- **Log Files**: 5-10 GB
- **System Cache**: 10-20 GB
- **Backup Space**: 50-100 GB
- **Free Space Buffer**: 20% of total

### Storage Performance
- **Minimum**: 7200 RPM HDD
- **Recommended**: SATA SSD
- **Optimal**: NVMe SSD
- **IOPS Requirements**: 1000+ for database operations

## Operating System Compatibility

### Supported Operating Systems
- **Linux** (Recommended)
  - Ubuntu 20.04 LTS or newer
  - CentOS 8 or newer
  - Red Hat Enterprise Linux 8+
  - Debian 10 or newer
  - Amazon Linux 2

### Linux Distribution Recommendations
| Use Case | Recommended OS | Reason |
|----------|---------------|---------|
| Production | Ubuntu Server 22.04 LTS | Stability, long-term support |
| Enterprise | Red Hat Enterprise Linux | Commercial support |
| Cloud Deployment | Amazon Linux 2 | AWS optimization |
| Development | Ubuntu Desktop 22.04 | Easy setup and maintenance |


### Bandwidth Requirements
- **Light Usage**: 10 Mbps upload/download
- **Moderate Usage**: 50 Mbps upload/download  
- **Heavy Usage**: 100+ Mbps upload/download
- **Geographic Data**: Additional 20-50 Mbps for map tile serving

## Cloud Platform Requirements

### Amazon Web Services (AWS)
- **Instance Type**: t3.large (minimum), m5.xlarge (recommended)
- **Storage**: EBS GP3 volumes
- **Network**: VPC with proper security groups
- **Database**: Consider RDS for PostgreSQL in production

### Google Cloud Platform
- **Machine Type**: e2-standard-2 (minimum), n2-standard-4 (recommended)
- **Storage**: Persistent SSD
- **Network**: VPC with firewall rules
- **Database**: Cloud SQL for PostgreSQL available

## Software Dependencies

### Required Software Stack
- **Container Runtime**: Docker (version 20.10+)
- **Orchestration**: Docker Compose (version 2.0+)
- **Operating System Updates**: Keep current with security patches
- **SSL Certificates**: For production HTTPS access
- **Backup Software**: For automated data protection

## Performance Considerations

### CPU Usage Patterns
- **PostgreSQL**: CPU-intensive during complex queries
- **MapServer**: High CPU when rendering map tiles
- **Shiny Server**: Generally low, spikes during user activity
- **Web Application**: Generally low, spikes during user activity

### Memory Usage Patterns
- **Database**: Gradual increase with data growth
- **MapServer**: Memory spikes during tile generation
- **Shiny Apps**: Can consume significant memory during processing
- **Caching**: Benefits from additional available RAM

### I/O Patterns
- **Database**: High read/write operations
- **Map Data**: Large sequential reads
- **Log Files**: Continuous writes
- **Temporary Files**: Frequent creation/deletion

