
# ShelterAI

ShelterAI is an intelligent refugee assignment system for reception centers, combining AI-powered classification, web services, and operating system concepts to optimize shelter allocation.

**Topic:** Immigration, refugees, NGOs  
**SDGs:** 10 (Reduced Inequalities), 1 (No Poverty), 3 (Good Health and Well-being)

## General Architecture

```
+-------------------+        +-------------------+        +-------------------+
|    FRONTEND       | <----> |     BACKEND       | <----> |    AI SERVICE     |
|   (Flutter App)   |        | (Java/Spring Boot)|        |    (Python)       |
+-------------------+        +-------------------+        +-------------------+
         |                          |                          |
         v                          v                          v
     /frontend                 /backend                   /ai-service
```

## ✔ What does it do?

- **Refugee data**: Manages information about families, ages, and specific needs
- **AI classification**: Assigns vulnerability scores to each person based on their profile
- **Web service assignment**: Allocates each refugee to the most suitable available shelter
- **OS implementation**: Uses threads to simulate refugees competing for available spaces

## 1. FRONTEND (Flutter) – `/frontend`

The mobile/web app allows:
- Registering refugee profiles (families, ages, special needs)
- Displaying real-time shelter availability
- Showing assignment results and recommendations
- Viewing vulnerability classifications
- Managing shelter capacity and occupancy

**Structure:**
```
/frontend
 ├── shelter_ai/
 │        ├── lib/
 │        │   ├── screens/            # screens
 │        │   ├── widgets/            # reusable components
 │        │   ├── services/           # REST calls to backend
 │        │   ├── providers/          # state management
 │        │   └── utils/
 │        └── assets/
```

## 2. BACKEND (Java/Spring Boot) – `/backend`

Main microservices:
- **API Gateway**: Unifies calls, basic authentication, redirection
- **Refugee Service**: Manages refugee profiles, families, and special needs
- **Shelter Service**: Manages shelter information, capacity, services, and availability
- **Assignment Service**: Handles intelligent allocation using threading for concurrent requests
- **Thread Management**: Implements OS concepts - threads represent refugees competing for spaces
- **User Service**: Manages NGO staff profiles, permissions, and preferences

## 3. AI SERVICE (Python) – `/ai-service`

- **Vulnerability classification**: Analyzes refugee profiles to assign priority scores
- **Shelter matching**: Recommends optimal shelter assignments based on needs
- **Predictive analytics**: Forecasts shelter capacity requirements
- **Need analysis**: Identifies special requirements (medical, family size, disabilities)

**Structure:**
```
/ai-service
 ├── model_training/        # notebooks, scripts for model training
 ├── inference_api/         # FastAPI with loaded model
 │   ├── app.py
 │   ├── models/model.pkl
 │   ├── requirements.txt
 └── data/                  # simulated datasets (UNHCR-based)
```

Backend communication via HTTP:
```
POST http://ai-service/classify-vulnerability
POST http://ai-service/recommend-shelter
```

## 4. Documentation – `/docs`

- Problem analysis, design, progress, final delivery
- UML, architecture, sequence diagrams
- SDG-analysis.md (Sustainable Development Goals alignment)
- UNHCR data sources and justification

## ✔ Relevance

This project addresses a critical global challenge supported by UNHCR (United Nations High Commissioner for Refugees) data:
- Over 100 million forcibly displaced people worldwide
- Efficient shelter allocation can save lives and reduce inequalities
- AI-driven classification ensures vulnerable individuals receive priority care
- Thread-based implementation simulates real-world resource competition scenarios

## Technologies Used
- **Frontend:** Flutter, Dart
- **Backend:** Java, Spring Boot, REST, SOA, JWT, Threading
- **AI Service:** Python, FastAPI, scikit-learn, pandas
- **Infrastructure:** Docker, Git, CI/CD

## Basic Execution

### Frontend
```bash
cd frontend/shelter_ai
flutter pub get
flutter run
```

### Backend
```bash
cd backend
# Run each microservice separately
./mvnw spring-boot:run -pl gateway-service
./mvnw spring-boot:run -pl refugee-service
# ...etc
```

### AI Service
```bash
cd ai-service/inference_api
pip install -r requirements.txt
python app.py
```

## Architecture Diagram

![Architecture](docs/diagrams/architecture.png)

## Contribution

1. Clone the repository
2. Install dependencies
3. Follow the recommended structure
4. Document your changes

---

For more details, check the `/docs` folder.
