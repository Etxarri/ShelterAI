# 🚀 QUICK START - ShelterAI Backend

## Prerequisites

- Docker Desktop installed and running
- Trained clustering model (see `backend/ai-service/README_MODEL_TRAINING.md`)

---

## Step 1: Build AI Service Image

```powershell
cd backend/ai-service
docker build -t shelterai-ai-service:latest .
```

This creates the `shelterai-ai-service:latest` image with FastAPI + HDBSCAN clustering for vulnerability classification.

---

## Step 2: Start All Services

```powershell
cd ../api-service
docker compose up -d
```

This starts:
- **PostgreSQL** (port 5432)
- **AI Service** (port 8000) - Cluster Decision Support API
- **Node-RED** (port 1880)

Verify they are running:
```powershell
docker ps
```

You should see 3 containers:
- `shelterai-postgres`
- `shelterai-ai-service`
- `shelterai-nodered`

---

## Step 3: Verify Services

### AI Service
```powershell
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "ml_model_loaded": true,
  "timestamp": "2026-01-22T10:30:00"
}
```

### Node-RED
Open in your browser: **http://localhost:1880**

### PostgreSQL
```powershell
docker exec -it shelterai-postgres psql -U root -d shelterai -c "\dt"
```

You should see the tables: `shelters`, `refugees`, `families`, `assignments`

---

## Step 4: Verify Node-RED Flows

1. Open **http://localhost:1880**
2. Verify that flows are deployed (green button in the upper right corner)
3. Flows are automatically loaded from `node-red-data/flows.json`
4. If you need to reimport:
   - Menu **☰** → **Import**
   - Select `node-red-data/integration-flows.json` or `ai-integration-flows.json`
   - Click **Deploy**

---

## ✅ Test the Integration

### Test 1: Verify expected features list

```powershell
curl http://localhost:8000/api/features
```

This returns the 555 features the model expects (after one-hot encoding).

### Test 2: Assign vulnerability cluster (direct)

```powershell
# This example requires sending the 555 one-hot encoded features
# See model documentation for complete format
curl -X POST http://localhost:8000/api/cluster `
  -H "Content-Type: application/json" `
  -d '{"person_id": "TEST001", ... }'
```

**Note**: The `/api/cluster` endpoint requires transformed features (one-hot encoded). To use raw data, use Node-RED endpoints.

### Test 3: Through Node-RED (recommended)

```powershell
$body = @{
    first_name = "Ahmed"
    last_name = "Al-Hassan"
    age = 42
    gender = "M"
    nationality = "Syrian"
    languages_spoken = "Arabic,English"
    medical_conditions = "none"
    has_disability = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:1880/api/refugees" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

If you receive the assigned cluster with `cluster_id`, cluster profile, and person's key features, **it's working!** 🎉

---

## 🛠️ Useful Commands

```powershell
# View logs of a service
docker logs -f shelterai-ai-service
docker logs -f shelterai-nodered
docker logs -f shelterai-postgres

# Restart a service
docker restart shelterai-ai-service

# Stop all services
docker compose down

# Rebuild and restart
docker compose up -d --build

# View container status
docker ps

# Access real-time logs
docker compose logs -f
```

---

## 📚 Complete Documentation

- **[INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)** - Integration guide with AI service
- **[../ai-service/README_DOCKER.md](../ai-service/README_DOCKER.md)** - AI service deployment
- **[../ai-service/README_MODEL_TRAINING.md](../ai-service/README_MODEL_TRAINING.md)** - Model training
- **[../../docs/API.md](../../docs/API.md)** - Endpoint documentation

---

## 🆘 Troubleshooting

### Error: "Could not connect to shelterai-ai-service"
```powershell
# Verify they are on the same network
docker network inspect shelterai-network

# Verify the service is running
docker ps | Select-String "shelterai-ai-service"
```

### Error: "Model file not found" or "Predictor not initialized"
```powershell
# Train the model
cd backend/ai-service/model_training
python train_final_model.py

# Verify the file exists
ls ../models/shelter_model.pkl
```

### Error: "Database connection failed"
```powershell
# Check PostgreSQL status
docker ps -a | Select-String "postgres"

# View PostgreSQL logs
docker logs shelterai-postgres

# Restart PostgreSQL
docker restart shelterai-postgres
```

### Error: Container stops immediately
```powershell
# View container logs
docker logs shelterai-ai-service

# Verify the model exists before starting
ls backend/ai-service/models/shelter_model.pkl
```

---

**🎓 Educational Project** - Universidad del País Vasco (UPV/EHU)
