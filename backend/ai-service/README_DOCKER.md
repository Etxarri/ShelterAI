# 🐳 ShelterAI - Docker Deployment Guide

This guide explains how to containerize and deploy the ShelterAI API using Docker.

---

## 📋 Overview

Docker allows you to package the AI service with all its dependencies into a container that runs consistently across different environments.

**What you'll learn:**
1. Understanding the Docker configuration
2. Building the Docker image
3. Running the container with Docker Compose
4. Testing the containerized API
5. Troubleshooting common issues

---

## 🛠️ Prerequisites

- **Docker Desktop** installed and running ([Download here](https://www.docker.com/products/docker-desktop))
- **Trained model** (`models/shelter_model.pkl`) - See [README_MODEL_TRAINING.md](README_MODEL_TRAINING.md)
- **PostgreSQL database** running on host machine (from api-service)

**Verify Docker is installed:**
```powershell
docker --version
docker compose version
```

Expected output:
```
Docker version 24.0.0, build abc123
Docker Compose version v2.20.0
```

---

## 📦 Understanding the Docker Setup

### File Structure

```
ai-service/
├── Dockerfile                 # Image build instructions
├── docker-compose.yml         # Service orchestration
├── requirements_prod.txt      # Production dependencies
├── inference_api/             # API source code
└── models/                    # Trained model files
```

### Key Files Explained

**1. Dockerfile** - Defines how to build the image:
```dockerfile
FROM python:3.11-slim          # Base image with Python 3.11
RUN apt-get update && ...      # Install system dependencies
COPY requirements_prod.txt     # Copy dependency list
RUN pip install ...            # Install Python packages
COPY inference_api/            # Copy API code
COPY models/                   # Copy trained model
CMD ["uvicorn", ...]           # Start the API server
```

**2. docker-compose.yml** - Defines service configuration:
```yaml
services:
  ai-service:
    build: .                   # Build from Dockerfile
    ports:
      - "8000:8000"            # Expose port 8000
    environment:
      - DATABASE_URL=...       # Database connection
    extra_hosts:
      - "host.docker.internal:host-gateway"  # Access host machine
```

**3. requirements_prod.txt** - Production-only dependencies (no dev tools):
- ✅ fastapi, uvicorn - API framework
- ✅ numpy, pandas - Data processing
- ✅ scikit-learn, hdbscan, umap-learn - ML libraries
- ❌ matplotlib, seaborn - Visualization (not needed in production)
- ❌ jupyter, black, pytest - Development tools (not needed in production)

---

## 🔨 Step 1: Prepare for Build

### Verify Model Exists

```powershell
# Check model file exists
ls .\models\shelter_model.pkl

# Expected output:
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# -a---          1/7/2026   2:30 PM        2621440 shelter_model.pkl
```

If model doesn't exist, train it first:
```powershell
cd model_training
python train_final_model.py
cd ..
```

### Check PostgreSQL is Running

```powershell
# Test database connection
Test-NetConnection -ComputerName localhost -Port 5432

# Expected output:
# ComputerName     : localhost
# RemoteAddress    : ::1
# RemotePort       : 5432
# TcpTestSucceeded : True
```

If database is not running, start your Spring Boot api-service first.

---

## 🏗️ Step 2: Build the Docker Image

```powershell
# Navigate to ai-service folder
cd backend\ai-service

# Build the image (with no cache for clean build)
docker compose build --no-cache
```

### Build Process

The build follows these steps:

**1. Pull base image**
```
[+] Building 120.5s (15/15) FINISHED
 => [internal] load build definition from Dockerfile
 => => pulling python:3.11-slim
```

**2. Install system dependencies**
```
 => RUN apt-get update && apt-get install -y \
    gcc g++ gfortran \           # Compilers for C/C++/Fortran
    libpq-dev \                  # PostgreSQL client library
    build-essential \            # Build tools
    python3-dev \                # Python development headers
    libopenblas-dev \            # Linear algebra library
    liblapack-dev                # Linear algebra routines
```

**3. Install Python packages**
```
 => COPY requirements_prod.txt .
 => RUN pip install --no-cache-dir -r requirements_prod.txt
    Successfully installed fastapi-0.109.0 uvicorn-0.27.0 ...
```

**Key package installations:**
- `hdbscan==0.8.38.post1` - Upgraded version with precompiled wheels (no compilation needed!)
- `umap-learn==0.5.5` - Dimensionality reduction
- `scikit-learn==1.4.0` - ML utilities
- `psycopg2-binary>=2.9.0` - PostgreSQL driver

**4. Copy application files**
```
 => COPY inference_api/ /app/inference_api/
 => COPY models/ /app/models/
```

**5. Final configuration**
```
 => EXPOSE 8000
 => CMD ["uvicorn", "inference_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Expected Build Time
- **First build:** 3-5 minutes (downloads base image + installs packages)
- **Subsequent builds:** 30 seconds - 1 minute (uses cached layers)

### Successful Build Output
```
 => => naming to docker.io/library/ai-service-ai-service
 => => unpacking to docker.io/library/ai-service-ai-service

Successfully built image: ai-service-ai-service:latest
```

---

## 🚀 Step 3: Run the Container

```powershell
# Start the container in detached mode
docker compose up -d
```

### Startup Process

```
[+] Running 1/1
 ✔ Container ai-service-ai-service-1  Started    2.3s
```

### Verify Container is Running

```powershell
# Check container status
docker compose ps

# Expected output:
# NAME                      IMAGE                    COMMAND                  STATUS
# ai-service-ai-service-1   ai-service-ai-service   "uvicorn inference_a…"   Up 10 seconds
```

### View Container Logs

```powershell
# View live logs
docker compose logs -f ai-service

# Expected output:
# ai-service-1  | INFO:     Started server process [1]
# ai-service-1  | INFO:     Waiting for application startup.
# ai-service-1  | INFO:     Application startup complete.
# ai-service-1  | INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

**Healthy startup indicators:**
- ✅ "Application startup complete"
- ✅ "Uvicorn running on http://0.0.0.0:8000"
- ✅ No error messages about missing modules
- ✅ No database connection errors

---

## 🧪 Step 4: Test the Containerized API

### Test 1: Health Check

```powershell
# Basic health check
curl http://localhost:8000/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "database_connected": true,
  "timestamp": "2026-01-07T14:30:00"
}
```

### Test 2: API Statistics

```powershell
curl http://localhost:8000/api/stats
```

**Expected response:**
```json
{
  "total_shelters": 45,
  "average_occupancy": 67.5,
  "model_info": {
    "algorithm": "HDBSCAN",
    "clusters": 54,
    "features": 555
  }
}
```

### Test 3: Recommendation Request

**Using PowerShell:**
```powershell
$body = @{
    first_name = "Ahmed"
    last_name = "Al-Hassan"
    age = 42
    gender = "M"
    nationality = "Syrian"
    family_size = 1
    has_children = $false
    children_count = 0
    medical_conditions = "none"
    requires_medical_facilities = $false
    has_disability = $false
    languages_spoken = "Arabic,English"
    vulnerability_score = 0
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/recommend" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

**Expected response:**
```json
{
  "refugee_info": {
    "name": "Ahmed Al-Hassan",
    "age": 42,
    "nationality": "Syrian",
    "family_size": 1
  },
  "cluster_id": 23,
  "cluster_label": "Cluster 23",
  "vulnerability_level": "medium",
  "recommendations": [
    {
      "shelter_id": 2,
      "shelter_name": "Refugio Norte",
      "compatibility_score": 78.5,
      "available_space": 40,
      "explanation": "This shelter has a 78% compatibility match with the refugee profile...",
      "matching_reasons": [
        "✓ High availability (40 spaces available)",
        "✓ Has medical facilities",
        "✓ Staff speaks english"
      ]
    },
    {
      "shelter_id": 5,
      "shelter_name": "Centro de Acogida Este",
      "compatibility_score": 72.3,
      "available_space": 25,
      "explanation": "This shelter has a 72% compatibility match...",
      "matching_reasons": [
        "✓ High availability (25 spaces available)",
        "✓ Staff speaks arabic"
      ]
    }
  ],
  "total_shelters_analyzed": 4,
  "timestamp": "2026-01-07T14:30:00"
}
```

### Test 4: API Documentation

Open in browser:
- **Interactive docs:** http://localhost:8000/docs
- **Alternative docs:** http://localhost:8000/redoc

---

## 🎛️ Step 5: Container Management

### View Container Logs

```powershell
# View recent logs
docker compose logs ai-service

# Follow logs in real-time
docker compose logs -f ai-service

# View last 50 lines
docker compose logs --tail=50 ai-service
```

### Restart Container

```powershell
# Restart the service
docker compose restart ai-service

# Or stop and start
docker compose stop ai-service
docker compose start ai-service
```

### Stop Container

```powershell
# Stop the container (keeps it)
docker compose stop

# Stop and remove the container
docker compose down
```

### Rebuild After Code Changes

```powershell
# Stop container
docker compose down

# Rebuild image (no cache to ensure fresh build)
docker compose build --no-cache

# Start with new image
docker compose up -d
```

### Access Container Shell

```powershell
# Open bash inside container
docker compose exec ai-service /bin/bash

# Inside container, you can:
# - Check files: ls -la
# - Test imports: python -c "import hdbscan; print(hdbscan.__version__)"
# - View logs: cat /var/log/*
# - Exit: exit
```

---

## 🔧 Configuration

### Environment Variables

Edit `docker-compose.yml` to configure:

```yaml
environment:
  # Database connection (required)
  - DATABASE_URL=postgresql://root:root@host.docker.internal:5432/shelterai
  
  # API settings (optional)
  - API_HOST=0.0.0.0
  - API_PORT=8000
  
  # Model settings (optional)
  - MODEL_PATH=/app/models/shelter_model.pkl
  
  # Recommendations (optional)
  - TOP_K_RECOMMENDATIONS=3
  - MIN_CAPACITY_THRESHOLD=0.1
```

### Port Mapping

```yaml
ports:
  - "8000:8000"  # host:container
```

To use different port on host:
```yaml
ports:
  - "9000:8000"  # Access via http://localhost:9000
```

### Volume Mounts

For development (auto-reload on code changes):
```yaml
volumes:
  - ./inference_api:/app/inference_api:ro  # Mount code as read-only
  - ./models:/app/models:ro                # Mount models as read-only
```

**Note:** Current setup uses COPY (not volumes) for production stability.

---

## 🛠️ Troubleshooting

### Issue: Container keeps restarting

**Check logs:**
```powershell
docker compose logs ai-service
```

**Common causes:**

**1. Module not found error:**
```
ModuleNotFoundError: No module named 'config'
```
**Solution:** Make sure all imports in `inference_api/` are relative:
```python
# ✅ Correct
from .config import settings
from .schemas import RefugeeProfile
from .database import get_shelters

# ❌ Wrong
from config import settings
from schemas import RefugeeProfile
```

**2. Database connection failed:**
```
psycopg2.OperationalError: could not connect to server
```
**Solution:** Check PostgreSQL is running on host:
```powershell
Test-NetConnection localhost -Port 5432
```

**3. Model file not found:**
```
FileNotFoundError: [Errno 2] No such file or directory: '/app/models/shelter_model.pkl'
```
**Solution:** Train the model first, then rebuild:
```powershell
cd model_training
python train_final_model.py
cd ..
docker compose build --no-cache
```

---

### Issue: Port 8000 already in use

**Error:**
```
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:8000 -> 0.0.0.0:0
```

**Find process using port:**
```powershell
netstat -ano | Select-String "8000"
```

**Kill the process:**
```powershell
# Replace <PID> with actual process ID
Stop-Process -Id <PID> -Force
```

**Or use different port:**
```yaml
# In docker-compose.yml
ports:
  - "9000:8000"  # Use port 9000 on host
```

---

### Issue: Docker build fails on hdbscan

**Error:**
```
error: command 'gcc' failed with exit status 1
  ERROR: Failed building wheel for hdbscan
```

**Solution:** Use version 0.8.38.post1 which has precompiled wheels:

```text
# In requirements_prod.txt
hdbscan==0.8.38.post1  # ✅ Has precompiled wheels
# Not: hdbscan==0.8.33  # ❌ Requires compilation
```

Then rebuild:
```powershell
docker compose build --no-cache
```

---

### Issue: Container running but API not responding

**Check if process is listening:**
```powershell
docker compose exec ai-service netstat -tuln | grep 8000
```

**Check health from inside container:**
```powershell
docker compose exec ai-service curl http://localhost:8000/health
```

**Restart with fresh logs:**
```powershell
docker compose down
docker compose up
```

---

### Issue: Slow API responses

**Possible causes:**
1. **Large model** - UMAP transform takes 1-2 seconds per request
2. **Database queries** - Fetching shelters from PostgreSQL
3. **Container resources** - Limited CPU/RAM

**Solutions:**

**Check container resource usage:**
```powershell
docker stats ai-service-ai-service-1
```

**Increase Docker Desktop resources:**
1. Open Docker Desktop
2. Settings → Resources
3. Increase CPUs: 4+ cores
4. Increase Memory: 4+ GB

**Optimize database queries:**
- Add indexes on frequently queried columns
- Use connection pooling (already enabled in SQLAlchemy)

---

### Issue: Cannot connect to host.docker.internal

**Error:**
```
could not translate host name "host.docker.internal" to address
```

**Solution (Windows):**
Already configured in docker-compose.yml:
```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

**Solution (Linux):**
Replace `host.docker.internal` with `172.17.0.1` (Docker bridge IP):
```yaml
environment:
  - DATABASE_URL=postgresql://root:root@172.17.0.1:5432/shelterai
```

---

## 📊 Monitoring

### View Container Resource Usage

```powershell
# Real-time stats
docker stats ai-service-ai-service-1

# Output:
# CONTAINER ID   NAME                      CPU %   MEM USAGE / LIMIT   MEM %   NET I/O
# abc123         ai-service-ai-service-1   5.2%    450MiB / 8GiB      5.6%    1.2MB / 850kB
```

### Inspect Container Details

```powershell
# Full container configuration
docker compose exec ai-service cat /etc/os-release

# Check Python version
docker compose exec ai-service python --version

# List installed packages
docker compose exec ai-service pip list
```

### Check Disk Usage

```powershell
# View image size
docker images ai-service-ai-service

# Output:
# REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
# ai-service-ai-service    latest    xyz789         10 minutes ago   1.2GB
```

---

## 🚢 Production Deployment

### Security Best Practices

**1. Use environment variables for secrets:**
```yaml
environment:
  - DATABASE_URL=${DATABASE_URL}  # Load from .env file
```

**2. Don't expose unnecessary ports:**
```yaml
# Only expose to localhost
ports:
  - "127.0.0.1:8000:8000"
```

**3. Run as non-root user:**
Add to Dockerfile:
```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

**4. Enable health checks:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Reverse Proxy (Nginx)

For production, use Nginx as reverse proxy:

```nginx
# nginx.conf
upstream ai_service {
    server localhost:8000;
}

server {
    listen 80;
    server_name api.shelterai.com;

    location / {
        proxy_pass http://ai_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 📦 Docker Commands Reference

```powershell
# Build
docker compose build                # Build image
docker compose build --no-cache     # Build without cache

# Run
docker compose up                   # Start in foreground
docker compose up -d                # Start in background
docker compose up --build           # Rebuild and start

# Stop
docker compose stop                 # Stop containers
docker compose down                 # Stop and remove containers
docker compose down -v              # Stop and remove volumes

# Logs
docker compose logs                 # View logs
docker compose logs -f              # Follow logs
docker compose logs --tail=100      # Last 100 lines

# Management
docker compose ps                   # List containers
docker compose restart              # Restart services
docker compose exec ai-service bash # Access shell

# Cleanup
docker system prune                 # Remove unused containers/images
docker volume prune                 # Remove unused volumes
docker image prune                  # Remove dangling images
```

---

## 🎯 Next Steps

Your Docker deployment is now complete! 

**Integration with Node-RED:**
1. Configure Node-RED to make HTTP POST requests to:
   - URL: `http://ai-service:8000/api/recommend` (if Node-RED is in same Docker network)
   - URL: `http://localhost:8000/api/recommend` (if Node-RED is on host)

2. Sample Node-RED HTTP Request node configuration:
   ```json
   {
     "method": "POST",
     "url": "http://localhost:8000/api/recommend",
     "headers": {
       "Content-Type": "application/json"
     }
   }
   ```

3. Parse JSON response and forward to Flutter app

**Further improvements:**
- Set up CI/CD pipeline (GitHub Actions)
- Deploy to cloud (Azure, AWS, GCP)
- Add monitoring (Prometheus, Grafana)
- Implement caching (Redis) for faster responses

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/docker/)
- [Best Practices for Python Docker Images](https://pythonspeed.com/docker/)

---

**🎓 Educational Project** - Universidad del País Vasco (UPV/EHU)
