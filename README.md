# ShelterAI

**AI-Powered Refugee Shelter Management System**

ShelterAI is an intelligent platform designed to improve the allocation of places in reception centers for refugees and asylum seekers. Using HDBSCAN clustering and machine learning, the system classifies individuals by vulnerability levels to support ethical, data-driven decision-making by humanitarian staff.

## Main Objectives

- **Prioritize vulnerable individuals**: Identify those most in need through AI-driven clustering
- **Support ethical decisions**: Provide insights for human decision-makers, not automated assignments
- **Optimize resource allocation**: Improve efficiency in shelter capacity management
- **Ensure transparency**: Explainable AI with clear feature explanations

## Key Features

- **HDBSCAN Clustering**: Classifies refugees into vulnerability/needs clusters
- **Explainable AI**: Provides top 8 key features for each person and cluster profile
- **REST API**: Complete CRUD operations for shelters, refugees, families, and assignments
- **Real-time Database**: PostgreSQL for reliable data management
- **Cross-platform Frontend**: Flutter mobile application
- **Data Validation**: JSON Schema validation for all inputs

## Architecture

```
┌─────────────────┐
│   Flutter App   │  
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
│   AI Service    │ 
│   (Python)      │    
└─────────────────┘    
```

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Python 3.11+ (for model training)
- Flutter SDK (for frontend development)

### Start Backend Services

```powershell
# 1. Build AI Service
cd backend/ai-service
docker build -t shelterai-ai-service:latest .

# 2. Start all services (PostgreSQL, AI Service, Node-RED)
cd ../api-service
docker compose up -d

# 3. Verify services are running
docker ps
```

**Services will be available at:**
- Node-RED API: http://localhost:1880
- AI Service API: http://localhost:8000
- PostgreSQL: localhost:5432

### Start Frontend

```powershell
cd frontend/shelter_ai
flutter pub get
flutter run -d edge  # or your preferred device
```

## Technology Stack

### Backend
- **Node-RED**: API orchestration and workflow automation
- **FastAPI**: AI service (Python)
- **PostgreSQL**: Primary database
- **Docker**: Containerization

### AI/ML
- **HDBSCAN**: Clustering algorithm for vulnerability classification
- **scikit-learn**: Machine learning utilities
- **pandas**: Data processing
- **NumPy**: Numerical computing

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language

## Project Structure

```
ShelterAI/
├── backend/
│   ├── ai-service/          # FastAPI AI clustering service
│   │   ├── inference_api/   # API endpoints
│   │   ├── model_training/  # Model training scripts
│   │   ├── models/          # Trained model files
│   │   └── tests/           # Unit tests
│   ├── api-service/         # Node-RED API gateway
│   │   ├── node-red-data/   # Flows and configurations
│   │   └── compose.yaml     # Docker Compose setup
│   └── simulator-os/        # Event simulation service
├── frontend/
│   └── shelter_ai/          # Flutter mobile application
└── README.md                # This file
```
## Target Audience

- Humanitarian organizations and NGOs managing refugee shelters
- Social workers and case managers
- Shelter coordinators
- Policy makers in refugee assistance programs

### Rebuild Services
```powershell
docker compose down
docker compose up -d --build
```

**For detailed setup instructions, see [backend/api-service/QUICK_START.md](backend/api-service/QUICK_START.md)**

