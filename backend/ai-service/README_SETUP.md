# 🏠 ShelterAI - AI Service Setup Guide

Intelligent system that recommends shelters to refugees based on **machine learning clustering** and **multi-criteria matching**.

---

## 📚 Documentation

This README provides a quick overview. For detailed guides, see:

- **[README_MODEL_TRAINING.md](README_MODEL_TRAINING.md)** - Complete guide to training the HDBSCAN clustering model
- **[README_DOCKER.md](README_DOCKER.md)** - Complete guide to Docker containerization and deployment

---

## 📋 What does this system do?

1. **Receives refugee data** (age, family, medical needs, languages, etc.)
2. **Classifies the refugee** into a vulnerability cluster using HDBSCAN
3. **Queries available shelters** from the PostgreSQL database
4. **Calculates compatibility** between the refugee and each shelter
5. **Returns top 3 recommended shelters** with detailed explanations

---

## 🏗️ Architecture

```
Frontend (Flutter) 
    ↓
Node-RED (Docker)
    ↓
AI Service (FastAPI) → PostgreSQL
    ↓
HDBSCAN Model + Matching System
```

---

## 📦 Project Structure

```
ai-service/
├── data/                          # Training data
│   ├── data.csv                   # Main dataset
│   ├── train_data.csv
│   └── test_data.csv
│
├── model_training/                # Model training
│   ├── train_final_model.py      # Training script
│   └── *.ipynb                    # Exploration notebooks
│
├── models/                        # Trained models (created during training)
│   ├── shelter_model.pkl          # Saved model
│   └── model_metadata.txt         # Model information
│
├── inference_api/                 # Inference API (FastAPI)
│   ├── main.py                    # Main FastAPI application
│   ├── schemas.py                 # Data models (Pydantic)
│   ├── database.py                # PostgreSQL connection
│   ├── predictor.py               # Prediction and matching logic
│   └── config.py                  # Configuration
│
├── requirements.txt               # Python dependencies (development)
├── requirements_prod.txt          # Python dependencies (production)
├── Dockerfile                     # Docker image
├── docker-compose.yml             # Service orchestration
├── .env.example                   # Environment variables
├── README_SETUP.md                # This guide (overview)
├── README_MODEL_TRAINING.md       # Model training guide
└── README_DOCKER.md               # Docker deployment guide
```

---

## 🚀 Quick Start

### For Model Training
See **[README_MODEL_TRAINING.md](README_MODEL_TRAINING.md)** for complete instructions on:
- Creating Python environment (conda/venv)
- Installing dependencies
- Training the HDBSCAN clustering model
- Understanding model parameters
- Troubleshooting training issues

**Quick summary:**
```powershell
# 1. Create environment
conda create -n ai-service python=3.11
conda activate ai-service

# 2. Install dependencies
pip install -r requirements.txt

# 3. Train model
cd model_training
python train_final_model.py
```

---

### For Docker Deployment
See **[README_DOCKER.md](README_DOCKER.md)** for complete instructions on:
- Building the Docker image
- Running with Docker Compose
- Testing the containerized API
- Managing containers
- Troubleshooting deployment issues

**Quick summary:**
```powershell
# 1. Build image
docker compose build --no-cache

# 2. Start container
docker compose up -d

# 3. Test API
curl http://localhost:8000/health
```

---

## 📊 Model Information

**Algorithm:** HDBSCAN (Hierarchical Density-Based Spatial Clustering)
- **Min cluster size:** 60
- **Min samples:** 5
- **Dimensionality reduction:** UMAP (555 → 10 dimensions)
- **Features:** 555 (after one-hot encoding)
- **Clusters found:** 54
- **Training samples:** 8,957

**Matching Criteria:**
1. **Availability** (0-25 points) - Available spaces vs family size
2. **Medical needs** (0-30 points) - Medical facilities if required
3. **Childcare** (0-25 points) - Childcare services for families with children
4. **Disability access** (0-20 points) - Accessibility for disabled refugees
5. **Languages** (0-15 points) - Common languages between staff and refugee
6. **Shelter type** (0-15 points) - Appropriate shelter type for vulnerability level

**Total:** 0-100 compatibility score

---

## 🔧 Configuration

Environment variables (create `.env` file):

```bash
# Database
DATABASE_URL=postgresql://root:root@host.docker.internal:5432/shelterai

# Model
MODEL_PATH=../models/shelter_model.pkl

# API
API_HOST=0.0.0.0
API_PORT=8000

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:1880

# Recommendations
TOP_K_RECOMMENDATIONS=3
MIN_CAPACITY_THRESHOLD=0.1
```

---

## 📝 API Endpoints

### `GET /health`
Health check endpoint
- Returns: System status, model loaded, database connected

### `GET /api/stats`
System statistics
- Returns: Total shelters, average occupancy, model metadata

### `POST /api/recommend`
Get shelter recommendations for a refugee
- Input: Refugee profile (JSON)
- Returns: Top 3 shelter recommendations with compatibility scores and explanations

**Example Request:**
```json
{
  "first_name": "Ahmed",
  "last_name": "Al-Hassan",
  "age": 42,
  "gender": "M",
  "nationality": "Syrian",
  "family_size": 1,
  "has_children": false,
  "children_count": 0,
  "medical_conditions": "none",
  "requires_medical_facilities": false,
  "has_disability": false,
  "languages_spoken": "Arabic,English",
  "vulnerability_score": 0
}
```

**API Documentation:** http://localhost:8000/docs

---

## ✅ System Status

**Current Status:** ✅ Fully operational

- [x] Model trained (54 clusters, 555 features)
- [x] FastAPI API running
- [x] PostgreSQL integration working
- [x] Docker containerization complete
- [x] Recommendation engine functional
- [x] Multi-criteria matching implemented
- [x] Natural language explanations generated

**Performance:**
- Prediction time: ~2 seconds (including UMAP transform)
- Typical compatibility scores: 40-90%
- Recommendations returned: Top 3 shelters

---

## 🎯 Integration with Node-RED

To integrate with Node-RED:
1. Node-RED receives refugee data from Flutter frontend
2. Makes HTTP POST to `http://ai-service:8000/api/recommend` (or `http://localhost:8000` for local testing)
3. Parses JSON response
4. Returns recommendations to Flutter app

---

## 📚 Additional Resources

- **[README_MODEL_TRAINING.md](README_MODEL_TRAINING.md)** - Detailed model training guide
- **[README_DOCKER.md](README_DOCKER.md)** - Detailed Docker deployment guide
- [HDBSCAN Documentation](https://hdbscan.readthedocs.io/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Documentation](https://docs.docker.com/)

---

## 📄 License

Educational project - Universidad del País Vasco (UPV/EHU)
    nationality = "Syrian"
    family_size = 5
    has_children = $true
    children_count = 3
    medical_conditions = "diabetes"
    requires_medical_facilities = $true
    has_disability = $false
    languages_spoken = "Arabic,English"
    vulnerability_score = 8
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/recommend" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

**Expected Response:**
```json
{
    "refugee_info": {
        "name": "Ahmed Al-Hassan",
        "age": 42,
        "nationality": "Syrian",
        "family_size": 5
    },
    "cluster_id": 23,
    "cluster_label": "Cluster 23",
    "vulnerability_level": "high",
    "recommendations": [
        {
            "shelter_id": 2,
            "shelter_name": "Refugio Norte",
            "compatibility_score": 87.5,
            "available_space": 40,
            "explanation": "This shelter has a 87% compatibility match with the refugee profile...",
            "matching_reasons": [
                "✓ High availability (40 spaces available)",
                "✓ Medical facilities available (required)",
                "✓ Childcare services for 3 child(ren)",
                "✓ Staff speaks english"
            ]
        }
    ],
    "total_shelters_analyzed": 4,
    "timestamp": "2026-01-07T14:30:00"
}
```

---

## 🐳 Docker Deployment

### **Step 6: Build Docker Image**

```powershell
# Make sure you're in ai-service folder
cd backend\ai-service

# Build the image (no cache to ensure fresh build)
docker compose build --no-cache
```

**Build process:**
1. Uses Python 3.11-slim base image
2. Installs system dependencies (gcc, g++, gfortran, libpq-dev)
3. Installs Python packages from `requirements_prod.txt`
4. Copies inference_api code and trained model
5. Exposes port 8000

---

### **Step 7: Run with Docker Compose**

```powershell
# Start the container
docker compose up -d

# Check container status
docker compose ps

# View logs
docker compose logs -f ai-service

# Stop the container
docker compose down
```

**Docker Compose Configuration:**
- Service name: `ai-service`
- Port mapping: `8000:8000`
- Database connection: `host.docker.internal:5432` (connects to PostgreSQL on host)
- Volumes: mounts `models/` and `inference_api/` as read-only
- Restart policy: `unless-stopped`

---

### **Step 8: Test Containerized API**

Once the container is running:

```powershell
# Health check
curl http://localhost:8000/health

# Get statistics
curl http://localhost:8000/api/stats

# Make recommendation request (same as Step 5)
```

**Using Postman:**
1. Method: `POST`
2. URL: `http://localhost:8000/api/recommend`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
    "first_name": "Ahmed",
    "last_name": "Al-Hassan",
    "age": 42,
    "gender": "M",
    "nationality": "Syrian",
    "family_size": 1,
    "has_children": false,
    "children_count": 0,
    "medical_conditions": "none",
    "requires_medical_facilities": false,
    "languages_spoken": "Arabic,English",
    "vulnerability_score": 0
}
```

---

## 📊 Model Information

**Algorithm:** HDBSCAN (Hierarchical Density-Based Spatial Clustering)
- **Min cluster size:** 60
- **Min samples:** 5
- **Dimensionality reduction:** UMAP (555 → 10 dimensions)
- **Features:** 555 (after one-hot encoding)
- **Clusters found:** 54
- **Training samples:** 8957

**Matching Criteria:**
1. **Availability** (0-25 points) - Available spaces vs family size
2. **Medical needs** (0-30 points) - Medical facilities if required
3. **Childcare** (0-25 points) - Childcare services for families with children
4. **Disability access** (0-20 points) - Accessibility for disabled refugees
5. **Languages** (0-15 points) - Common languages between staff and refugee
6. **Shelter type** (0-15 points) - Appropriate shelter type for vulnerability level

**Total:** 0-100 compatibility score

---

## 🔧 Configuration

Environment variables (create `.env` file):

```bash
# Database
DATABASE_URL=postgresql://root:root@host.docker.internal:5432/shelterai

# Model
MODEL_PATH=../models/shelter_model.pkl

# API
API_HOST=0.0.0.0
API_PORT=8000

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:1880

# Recommendations
TOP_K_RECOMMENDATIONS=3
MIN_CAPACITY_THRESHOLD=0.1
```

---

## 🛠️ Troubleshooting

### **Issue: Port 8000 already in use**
```powershell
# Find process using port 8000
netstat -ano | Select-String "8000"

# Kill the process (replace PID)
Stop-Process -Id <PID> -Force
```

### **Issue: ModuleNotFoundError**
Make sure you're using relative imports (`.config`, `.schemas`, etc.) in all `inference_api/` modules.

### **Issue: Database connection failed**
- Check PostgreSQL is running: `pg_isready -h localhost -p 5432`
- Verify credentials in `DATABASE_URL`
- For Docker: use `host.docker.internal` instead of `localhost`

### **Issue: Model file not found**
```powershell
# Retrain the model
cd model_training
python train_final_model.py

# Verify model exists
ls ..\models\shelter_model.pkl
```

### **Issue: Docker build fails on hdbscan**
The `requirements_prod.txt` uses hdbscan==0.8.38.post1 which has precompiled wheels. If it still fails, check you're using Python 3.11 base image.

---

## ✅ System Status

**Current Status:** ✅ Fully operational

- [x] Model trained (54 clusters, 555 features)
- [x] FastAPI API running
- [x] PostgreSQL integration working
- [x] Docker containerization complete
- [x] Recommendation engine functional
- [x] Multi-criteria matching implemented
- [x] Natural language explanations generated

**Performance:**
- Prediction time: ~2 seconds (including UMAP transform)
- Typical compatibility scores: 40-90%
- Recommendations returned: Top 3 shelters

---

## 📝 API Endpoints

### `GET /health`
Health check endpoint
- Returns: System status, model loaded, database connected

### `GET /api/stats`
System statistics
- Returns: Total shelters, average occupancy, model metadata

### `POST /api/recommend`
Get shelter recommendations for a refugee
- Input: Refugee profile (JSON)
- Returns: Top 3 shelter recommendations with compatibility scores and explanations

---

## 🎯 Next Steps

To integrate with Node-RED:
1. Node-RED receives refugee data from Flutter frontend
2. Makes HTTP POST to `http://ai-service:8000/api/recommend` (or `http://localhost:8000` for local testing)
3. Parses JSON response
4. Returns recommendations to Flutter app

---

## 📄 License

Educational project - Universidad del País Vasco (UPV/EHU)
   ✓ Columnas numéricas: 240
   ✓ Columnas categóricas: 7
   ✓ Valores faltantes imputados
   ✓ Variables categóricas codificadas: 350 features finales

[3/6] Escalando features...
   ✓ Features escaladas: shape (8957, 350)

[4/6] Aplicando UMAP...
   ✓ UMAP aplicado: 350 → 10 dimensiones

[5/6] Entrenando modelo HDBSCAN...
   ✓ Clustering completado:
     - Clusters encontrados: 4
     - Puntos de ruido: 450 (5.0%)

[6/6] Guardando modelos...
   ✓ Modelo guardado

✅ ENTRENAMIENTO COMPLETADO EXITOSAMENTE
```

### **Paso 3: Opción A - Ejecutar Localmente (Desarrollo)**

```powershell
# Asegurarse de que PostgreSQL esté corriendo
# (debe estar en localhost:5432 con datos cargados)

# Ejecutar API
cd inference_api
python main.py
```

La API estará disponible en:
- **API**: http://localhost:8000
- **Documentación interactiva**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### **Paso 3: Opción B - Ejecutar con Docker (Producción)**

```powershell
# Desde la carpeta ai-service
docker compose up -d

# Ver logs
docker compose logs -f ai-service

# Detener servicios
docker compose down
```

Esto levanta:
- **PostgreSQL** (puerto 5432)
- **AI Service** (puerto 8000)
- **Node-RED** (puerto 1880)

---

## 🧪 Probar la API

### **1. Health Check**

```bash
curl http://localhost:8000/health
```

### **2. Recomendar Refugio**

**Desde PowerShell:**
```powershell
$body = @{
    first_name = "Ahmed"
    last_name = "Al-Hassan"
    age = 42
    gender = "M"
    nationality = "Syrian"
    family_size = 5
    has_children = $true
    children_count = 3
    medical_conditions = "Diabetes"
    requires_medical_facilities = $true
    languages_spoken = "Arabic,English"
    vulnerability_score = 7.5
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/recommend" -Method POST -Body $body -ContentType "application/json"
```

**Desde Node-RED:**
```javascript
// HTTP Request Node
POST http://ai-service:8000/api/recommend

{
  "first_name": "Ahmed",
  "last_name": "Al-Hassan",
  "age": 42,
  "gender": "M",
  "nationality": "Syrian",
  "family_size": 5,
  "has_children": true,
  "children_count": 3,
  "medical_conditions": "Diabetes",
  "requires_medical_facilities": true,
  "languages_spoken": "Arabic,English",
  "vulnerability_score": 7.5
}
```

### **3. Ver Estadísticas**

```bash
curl http://localhost:8000/api/stats
```

---

## 📊 Respuesta de la API

```json
{
  "refugee_info": {
    "name": "Ahmed Al-Hassan",
    "age": 42,
    "nationality": "Syrian",
    "family_size": 5
  },
  "cluster_id": 2,
  "cluster_label": "Familias con necesidades médicas",
  "vulnerability_level": "high",
  "recommendations": [
    {
      "shelter_id": 1,
      "shelter_name": "Centro Acogida Madrid Norte",
      "compatibility_score": 92.5,
      "available_space": 105,
      "has_medical_facilities": true,
      "has_childcare": true,
      "explanation": "Este refugio tiene una compatibilidad del 92% con el perfil del refugiado...",
      "matching_reasons": [
        "✓ Instalaciones médicas disponibles (requerido por condición médica)",
        "✓ Servicio de cuidado infantil para 3 niños",
        "✓ Personal que habla árabe e inglés",
        "✓ Alta disponibilidad (70% espacios libres)"
      ]
    }
  ],
  "total_shelters_analyzed": 5,
  "model_version": "1.0"
}
```

---

## 🔧 Cómo Funciona el Sistema de Matching

### **1. Clasificación (Clustering)**
- HDBSCAN clasifica al refugiado en clusters de vulnerabilidad
- UMAP reduce dimensionalidad para mejor clustering
- Se identifican patrones de vulnerabilidad similares

### **2. Scoring de Compatibilidad (0-100 puntos)**

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| **Disponibilidad** | 0-25 | Espacios libres vs tamaño familia |
| **Necesidades Médicas** | 0-30 | ¿Tiene instalaciones médicas? |
| **Cuidado Infantil** | 0-25 | ¿Ofrece cuidado para niños? |
| **Accesibilidad** | 0-20 | ¿Accesible para discapacidad? |
| **Idiomas** | 0-15 | ¿Personal habla idiomas del refugiado? |
| **Tipo de Refugio** | 0-15 | ¿Apropiado según vulnerabilidad? |

### **3. Generación de Explicaciones**
- Texto en lenguaje natural
- Lista de razones específicas
- Transparencia en la decisión

---

## 🛠️ Solución de Problemas

### **Error: Modelo no encontrado**
```
FileNotFoundError: Modelo no encontrado en: ../models/shelter_model.pkl
```
**Solución:** Ejecutar `python train_final_model.py` primero

### **Error: No se puede conectar a la base de datos**
```
could not connect to server: Connection refused
```
**Solución:** 
- Verificar que PostgreSQL esté corriendo
- En Docker: `docker compose up -d postgres`
- Localmente: Iniciar servicio de PostgreSQL

### **Error: ImportError**
```
ModuleNotFoundError: No module named 'hdbscan'
```
**Solución:** `pip install -r requirements.txt`

---

## 📝 Configuración Avanzada

### **Variables de Entorno**

Crear `.env` basado en `.env.example`:

```env
DATABASE_URL=postgresql://root:root@localhost:5432/shelterai
MODEL_PATH=../models/shelter_model.pkl
API_HOST=0.0.0.0
API_PORT=8000
TOP_K_RECOMMENDATIONS=3
```

### **Ajustar Parámetros del Modelo**

En `train_final_model.py`:
```python
# UMAP
reducer = umap.UMAP(
    n_components=10,    # Cambiar dimensiones
    n_neighbors=30,     # Ajustar vecinos
    min_dist=0.1,       # Ajustar distancia mínima
)

# HDBSCAN
clusterer = hdbscan.HDBSCAN(
    min_cluster_size=60,  # Tamaño mínimo de cluster
    min_samples=5,        # Muestras mínimas
)
```

### **Ajustar Sistema de Scoring**

En `predictor.py`, método `calculate_shelter_compatibility`:
```python
# Cambiar pesos de cada criterio
if refugee.requires_medical_facilities:
    if shelter.has_medical_facilities:
        score += 30  # Cambiar este valor
```

---

## 🎯 Próximos Pasos

1. ✅ **Entrenar el modelo** con vuestros datos
2. ✅ **Probar la API** localmente
3. ✅ **Integrar con Node-RED**
4. ⏳ **Afinar parámetros** del modelo según resultados
5. ⏳ **Añadir más refugios** a la base de datos
6. ⏳ **Conectar con Frontend Flutter**

---

## 📚 Documentación Adicional

- **FastAPI Docs**: http://localhost:8000/docs
- **API Reference**: http://localhost:8000/redoc
- **PostgreSQL Admin**: Usar pgAdmin o DBeaver

---

## 👥 Soporte

Si tenéis problemas:
1. Revisar logs: `docker compose logs -f ai-service`
2. Verificar health: `curl http://localhost:8000/health`
3. Consultar esta guía

---

## 📄 Licencia

Este proyecto es parte de PBL5 - Universidad del País Vasco
