# ShelterAI Backend - Node-RED API

Backend developed in Node-RED for the ShelterAI refugee management system. The system uses HDBSCAN clustering to classify refugees into vulnerability clusters, supporting humanitarian decision-making.

## 🚀 Quick Start

```powershell
cd backend/api-service

# First build the AI service image
cd ../ai-service
docker build -t shelterai-ai-service:latest .

# Return and start all services
cd ../api-service
docker compose up -d
```

**Available services:**
- **Node-RED:** http://localhost:1880 (API Gateway and orchestration)
- **AI Service:** http://localhost:8000 (Cluster Decision Support API)
- **PostgreSQL:** localhost:5432 (Database)

**API Documentation:**
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

## 📚 Documentation

- **[API.md](../../docs/API.md)** - Complete documentation of all endpoints
- **[INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)** - Integration guide with updated AI service

## 🏗️ Architecture

```
┌─────────────────┐
│   Frontend      │
│   (Flutter)     │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐      ┌──────────────┐
│   Node-RED      │◄────►│  PostgreSQL  │
│   (API Layer)   │      │  (Database)  │
└────────┬────────┘      └──────────────┘
         │
         ▼
┌─────────────────┐
│   AI Service    │  ← HDBSCAN Clustering for Vulnerability Classification
│   (FastAPI)     │     • Assigns needs/vulnerability cluster
└─────────────────┘     • Explains person's key features
                        • Provides cluster profile
                        • Does NOT assign shelters automatically
```

## 📦 Services

### Node-RED (Port 1880)
- Complete REST API (CRUD)
- Data validation with JSON Schemas
- Integration with AI service (FastAPI)
- Gateway between frontend and backend services
- Workflow orchestration

### AI Service (Port 8000) - Cluster Decision Support API
- **HDBSCAN Clustering**: Classifies refugees into vulnerability/needs clusters
- **Explanations**: Provides the top 8 key features of each person compared to:
  - The global population
  - Their assigned cluster
- **Cluster Profiles**: Describes the defining characteristics of each cluster
- **Endpoints**:
  - `GET /health` - Service status
  - `GET /api/features` - List of 555 expected features
  - `POST /api/cluster` - Assigns cluster and provides explanations
  - `POST /api/recommend` - Alias for `/api/cluster`
  - `GET /api/clusters` - Lists all available clusters
  - `GET /api/clusters/{id}` - Gets profile of a specific cluster

### PostgreSQL (Port 5432)
- Main database
- Tables: `shelters`, `refugees`, `families`, `assignments`
- Used by Node-RED for CRUD operations

## 🔑 Main Endpoints

### Shelters
- `GET /api/shelters` - List all
- `GET /api/shelters/available` - With available capacity
- `POST /api/shelters` - Create new
- `PUT /api/shelters/:id` - Update
- `DELETE /api/shelters/:id` - Delete

### Refugees
- `GET /api/refugees` - List all
- `GET /api/refugees/high-vulnerability` - High vulnerability
- `POST /api/refugees` - Create new
- `PUT /api/refugees/:id` - Update
- `DELETE /api/refugees/:id` - Delete

### Families
- `GET /api/families` - List all
- `POST /api/families` - Create new
- `PUT /api/families/:id` - Update
- `DELETE /api/families/:id` - Delete

### Assignments
- `GET /api/assignments` - List all
- `GET /api/assignments/status/:status` - By status
- `POST /api/assignments` - Create new
- `PUT /api/assignments/:id` - Update
- `DELETE /api/assignments/:id` - Delete

### AI Integration
- `POST /api/ai/assign-cluster` - Assigns vulnerability cluster to a refugee
- Endpoints through Node-RED for frontend integration

**AI System Operation:**
- **HDBSCAN Clustering**: Identifies vulnerability/needs patterns
- **Assisted Decision-Making**: The system does NOT assign shelters automatically
- **Explainability**: Provides key features of each person and cluster
- **Human Decision Support**: Staff interprets clusters and assigns shelters manually
- **Ethical and Transparent**: Final decisions are made by informed humans

**System Output:**
- `cluster_id`: Assigned cluster (number)
- `person_top_features`: Top 8 person features (vs global and vs cluster)
- `cluster_profile`: Cluster defining features (vs global)
- `n_people_in_cluster`: Number of people in the cluster

See **[INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)** for integration details.

## ✅ Data Validation

All POST/PUT endpoints validate data against JSON Schemas:

- `shelter-schema.json` - Shelters
- `refugee-schema.json` - Refugees
- `family-schema.json` - Families
- `assignment-schema.json` - Assignments

If validation fails, **400 Bad Request** is returned with error details.

## 🛠️ Development

### View logs
```powershell
# Node-RED logs
docker logs shelterai-nodered -f

# AI Service logs
docker logs shelterai-ai-service -f

# PostgreSQL logs
docker logs shelterai-postgres -f

# All logs
docker compose logs -f
```

### Access Node-RED
Open http://localhost:1880 in your browser to view/edit flows.

### Access AI API documentation
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

### Restart services
```powershell
# Restart all
docker compose restart

# Restart a specific one
docker restart shelterai-ai-service
```

### Backup flows
```powershell
docker exec shelterai-nodered cat /data/flows.json > backup-flows.json
```

### Rebuild AI Service after model changes
```powershell
cd ../ai-service
docker build -t shelterai-ai-service:latest .
cd ../api-service
docker compose up -d --force-recreate ai-service
```

## 📊 Database

### Connect to PostgreSQL
```powershell
docker exec -it shelterai-postgres psql -U root -d shelterai
```

### View tables
```sql
\dt
```

### Query examples
```sql
-- View available shelters
SELECT * FROM shelters WHERE current_occupancy < max_capacity;

-- View refugees by cluster (if stored)
SELECT cluster_id, COUNT(*) FROM refugees 
WHERE cluster_id IS NOT NULL 
GROUP BY cluster_id;

-- View active assignments
SELECT * FROM assignments WHERE status = 'active';
```

## 🔧 Configuration

### Environment variables (compose.yaml)
```yaml
environment:
  - TZ=Europe/Madrid
  - FLOWS=flows.json
```

### Database
```yaml
POSTGRES_DB: shelterai
POSTGRES_USER: root
POSTGRES_PASSWORD: root
```

## 📝 Team Notes

### For the Web Team (Frontend)
- Read **[API.md](../../docs/API.md)** to learn how to call the endpoints
- All data is sent/received in JSON format
- Validation is automatic, you'll receive 400 error if data is invalid

### For the AI Team
- Service is exposed at `shelterai-ai-service:8000`
- Implements HDBSCAN clustering for vulnerability classification
- Does NOT assign shelters automatically - provides information for human decisions
- Complete documentation at: http://localhost:8000/docs
- Node-RED calls the service to get clusters and explanations

### For the Simulation Team
- Send your events to `POST /api/simulation/data`
- Check system status at `GET /api/simulation/status`

## 🎯 Rubric Compliance

### Web Engineering II (Level 3)
✅ "Use schemas to validate documents" - JSON Schemas implemented  
✅ "Communications between systems" - Complete REST API  

### Artificial Intelligence (Level 3)
✅ "Services integrated in Node-RED" - AI integration flows  

### Project Management (Level 3)
✅ "Defined interfaces between modules" - API.md documentation  
✅ "Clear communication with team" - Contracts and examples

## 🐛 Troubleshooting

### Error: "Flows stopped due to missing node types"
```powershell
docker exec shelterai-nodered sh -c "cd /data && npm install"
docker restart shelterai-nodered
```

### Error: "EBUSY: resource busy or locked"
Do not edit `flows.json` directly from VS Code while Node-RED is running. Use the Node-RED web interface.

### Cannot connect to PostgreSQL
Verify the container is healthy:
```powershell
docker ps
docker logs shelterai-postgres
```

### Error: "Predictor not initialized" in AI Service
Verify the model is trained:
```powershell
ls backend/ai-service/models/shelter_model.pkl
```
If it doesn't exist, train the model:
```powershell
cd backend/ai-service/model_training
python train_final_model.py
```

### AI Service stops immediately
Check the logs to see the specific error:
```powershell
docker logs shelterai-ai-service
```
Common issues:
- Model not found: train the model first
- Dependency error: rebuild the image with `--no-cache`
- Port busy: verify port 8000 is available

## 📄 License

Academic project - Universidad de Deusto - PBL 2025
