# ShelterAI - Guía de Integración con el Servicio de IA

## 📋 Nuevo Servicio de IA Implementado

El servicio de IA ahora está completamente implementado usando **FastAPI** con **HDBSCAN clustering** para clasificación de vulnerabilidad y un sistema de matching multi-criterio para recomendación de refugios.

---

## 🚀 Arquitectura Actualizada

```
Frontend (Flutter) 
    ↓
Node-RED (puerto 1880)
    ↓
AI Service (FastAPI - puerto 8000) → PostgreSQL
    ↓
HDBSCAN Model + Matching System
```

**Servicios Docker:**
- `shelterai-postgres` - Base de datos PostgreSQL (puerto 5432)
- `shelterai-ai-service` - Servicio de IA FastAPI (puerto 8000)
- `shelterai-nodered` - Node-RED API Gateway (puerto 1880)

Todos los servicios están en la red `shelterai-network` y pueden comunicarse entre sí usando sus nombres de contenedor.

---

## 🔄 Endpoints del Servicio de IA

### `POST /api/recommend`

Obtiene recomendaciones de refugios para un refugiado usando clustering HDBSCAN y scoring multi-criterio.

**Request Body:**
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

**Response:**
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
      "compatibility_score": 87.5,
      "available_space": 40,
      "explanation": "This shelter has a 87% compatibility match...",
      "matching_reasons": [
        "✓ High availability (40 spaces available)",
        "✓ Has medical facilities",
        "✓ Staff speaks english"
      ]
    }
  ],
  "total_shelters_analyzed": 4,
  "timestamp": "2026-01-07T14:30:00"
}
```

**Criterios de Matching:**
1. **Availability** (0-25 puntos) - Espacios disponibles vs tamaño de familia
2. **Medical needs** (0-30 puntos) - Instalaciones médicas si son requeridas
3. **Childcare** (0-25 puntos) - Servicios de cuidado infantil
4. **Disability access** (0-20 puntos) - Accesibilidad
5. **Languages** (0-15 puntos) - Idiomas en común
6. **Shelter type** (0-15 puntos) - Tipo apropiado según vulnerabilidad

---

## 📝 Flows de Node-RED Actualizados

### Flow 1: POST /api/ai/assign-shelter

**Endpoint:** `POST /api/ai/assign-shelter`

**Propósito:** Obtener recomendación de refugio para un refugiado individual.

**Nodos:**
1. **HTTP IN** - Recibe request
2. **Preparar datos para IA** - Transforma datos al formato requerido
3. **Llamar servicio IA** - HTTP Request a `http://shelterai-ai-service:8000/api/recommend`
4. **Procesar respuesta IA** - Extrae mejor recomendación
5. **HTTP Response** - Retorna resultado

**Código del nodo "Preparar datos para IA":**
```javascript
// Guardar datos originales del refugiado
const refugeeData = msg.payload;

// Calcular family_size y children_count
let familySize = 1;
let hasChildren = false;
let childrenCount = 0;

if (refugeeData.family_id) {
    familySize = refugeeData.family_size || 1;
}

if (refugeeData.age && refugeeData.age < 18) {
    hasChildren = false;
    childrenCount = 0;
} else if (refugeeData.family_id && familySize > 1) {
    hasChildren = true;
    childrenCount = Math.max(0, familySize - 2);
}

// Preparar payload según el nuevo formato de la API
msg.payload = {
    first_name: refugeeData.first_name,
    last_name: refugeeData.last_name,
    age: refugeeData.age,
    gender: refugeeData.gender,
    nationality: refugeeData.nationality,
    family_size: familySize,
    has_children: hasChildren,
    children_count: childrenCount,
    medical_conditions: refugeeData.medical_conditions || 'none',
    requires_medical_facilities: refugeeData.has_disability || 
        (refugeeData.medical_conditions && 
         refugeeData.medical_conditions.toLowerCase() !== 'none'),
    has_disability: refugeeData.has_disability || false,
    languages_spoken: refugeeData.languages_spoken,
    vulnerability_score: refugeeData.vulnerability_score || 0
};

msg.refugeeData = refugeeData;
return msg;
```

**Código del nodo "Procesar respuesta IA":**
```javascript
const aiResponse = msg.payload;

if (!aiResponse.recommendations || aiResponse.recommendations.length === 0) {
    msg.statusCode = 404;
    msg.payload = { error: "No se encontraron refugios disponibles" };
    return msg;
}

// Tomar el mejor refugio (primera recomendación)
const bestShelter = aiResponse.recommendations[0];

msg.payload = {
    shelter_id: bestShelter.shelter_id,
    shelter_name: bestShelter.shelter_name,
    confidence_score: bestShelter.compatibility_score / 100,
    compatibility_score: bestShelter.compatibility_score,
    available_space: bestShelter.available_space,
    explanation: bestShelter.explanation,
    matching_reasons: bestShelter.matching_reasons,
    vulnerability_level: aiResponse.vulnerability_level,
    cluster_id: aiResponse.cluster_id,
    alternative_shelters: aiResponse.recommendations.slice(1).map(rec => ({
        shelter_id: rec.shelter_id,
        shelter_name: rec.shelter_name,
        compatibility_score: rec.compatibility_score,
        available_space: rec.available_space
    }))
};

msg.statusCode = 200;
return msg;
```

---

### Flow 2: POST /api/refugees-with-assignment

**Endpoint:** `POST /api/refugees-with-assignment`

**Propósito:** Crear un refugiado Y asignarle un refugio automáticamente.

**Flujo:**
1. Guardar refugiado en BD → Obtener ID
2. Llamar servicio IA con datos del refugiado
3. Crear asignación con el refugio recomendado
4. Retornar refugiado + asignación + alternativas

**Cambios importantes:**
- Ya NO se envía la lista de refugios disponibles al servicio IA
- El servicio IA consulta directamente la base de datos PostgreSQL
- El servicio retorna top 3 recomendaciones con scores de compatibilidad
- Se toma la primera recomendación como asignación principal

---

## 🐳 Deployment con Docker Compose

### Opción 1: Deploy completo (desde api-service)

```powershell
cd backend/api-service

# Primero construir imagen de AI service
cd ../ai-service
docker compose build --no-cache

# Volver a api-service y levantar todo
cd ../api-service
docker compose up -d
```

**Servicios levantados:**
- PostgreSQL (puerto 5432)
- AI Service (puerto 8000)  
- Node-RED (puerto 1880)

### Opción 2: Deploy separado

**Terminal 1 - AI Service:**
```powershell
cd backend/ai-service
docker compose up -d
```

**Terminal 2 - API Service + Node-RED:**
```powershell
cd backend/api-service
docker compose up -d
```

---

## 🧪 Testing

### 1. Verificar servicios activos

```powershell
# AI Service health check
curl http://localhost:8000/health

# Node-RED interfaz
# Abrir http://localhost:1880

# PostgreSQL connection
docker exec -it shelterai-postgres psql -U root -d shelterai
```

### 2. Test directo al servicio IA

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

### 3. Test a través de Node-RED

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
    vulnerability_score = 0
    family_id = $null
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:1880/api/ai/assign-shelter" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

---

## 🔧 Troubleshooting

### Error: "Could not connect to ai-service"

**Causa:** Servicios no están en la misma red Docker

**Solución:**
```powershell
# Verificar que ambos contenedores están en shelterai-network
docker network inspect shelterai-network

# Deben aparecer: shelterai-postgres, shelterai-ai-service, shelterai-nodered
```

### Error: "Model file not found"

**Causa:** Modelo no está entrenado

**Solución:**
```powershell
cd backend/ai-service
conda activate ai-service
cd model_training
python train_final_model.py
```

### Error: "Database connection failed"

**Causa:** PostgreSQL no está accesible

**Solución:**
```powershell
# Verificar postgres está corriendo
docker ps | Select-String "shelterai-postgres"

# Ver logs
docker logs shelterai-postgres

# Reiniciar si es necesario
docker restart shelterai-postgres
```

---

## 📚 Documentación Adicional

- **[README_MODEL_TRAINING.md](../ai-service/README_MODEL_TRAINING.md)** - Cómo entrenar el modelo
- **[README_DOCKER.md](../ai-service/README_DOCKER.md)** - Deployment detallado del servicio IA
- **[API.md](../../docs/API.md)** - Documentación completa de endpoints

---

## ✅ Checklist de Integración

- [x] Modelo HDBSCAN entrenado (`models/shelter_model.pkl`)
- [x] Servicio IA dockerizado y funcionando
- [x] PostgreSQL con datos de refugios
- [x] Node-RED flows actualizados
- [x] Servicios en misma red Docker (`shelterai-network`)
- [x] Endpoints probados y funcionando
- [x] Documentación actualizada

---

**🎓 Educational Project** - Universidad del País Vasco (UPV/EHU)

## 🤖 Flows de Integración con IA

### Flow para Predicción de Vulnerabilidad

Crea un nuevo tab llamado "AI Integration" y añade:

**1. HTTP IN:** `POST /api/ai/predict/vulnerability`

**2. Function Node "Preparar Request IA":**
```javascript
// Formatear datos para el servicio de IA
msg.payload = {
    age: msg.payload.age,
    gender: msg.payload.gender,
    has_medical_conditions: msg.payload.has_medical_conditions || false,
    family_size: msg.payload.family_size || 1,
    education_level: msg.payload.education_level || "UNKNOWN"
};

msg.headers = {
    'Content-Type': 'application/json'
};

return msg;
```

**3. HTTP Request Node:**
- Method: POST
- URL: `http://shelterai-ai:5000/predict/vulnerability`
- Return: a parsed JSON object

**4. Function Node "Formatear Respuesta":**
```javascript
// Adaptar respuesta de la IA al formato esperado
msg.statusCode = 200;
msg.payload = {
    vulnerability_score: msg.payload.score || 0,
    risk_level: msg.payload.risk_level || "UNKNOWN",
    recommendations: msg.payload.recommendations || []
};
return msg;
```

**5. HTTP Response**

**6. Catch Node (para errores):**
```javascript
msg.statusCode = 500;
msg.payload = {
    error: "Error comunicándose con el servicio de IA",
    message: msg.error.message
};
return msg;
```

---

### Flow para Recomendación de Asignación

**1. HTTP IN:** `POST /api/ai/predict/assignment`

**2. Function "Obtener datos del refugiado":**
```javascript
// Preparar query para obtener datos completos del refugiado
const refugeeId = msg.payload.refugee_id;
msg.refugeeId = refugeeId;
msg.requirements = msg.payload.requirements;

msg.queryParameters = [refugeeId];
msg.payload = "SELECT * FROM refugees WHERE id = $1";
return msg;
```

**3. PostgreSQL Node:** Query del refugiado

**4. Function "Preparar Request para IA":**
```javascript
if (!msg.payload || msg.payload.length === 0) {
    msg.statusCode = 404;
    msg.payload = { error: "Refugee not found" };
    return [null, msg]; // Ir directo a error response
}

const refugee = msg.payload[0];

msg.payload = {
    refugee: {
        age: refugee.age,
        medical_conditions: refugee.medical_conditions,
        special_needs: refugee.special_needs,
        vulnerability_score: refugee.vulnerability_score,
        family_id: refugee.family_id
    },
    requirements: msg.requirements
};

return [msg, null]; // Continuar flujo normal
```

**5. HTTP Request Node:**
- Method: POST
- URL: `http://shelterai-ai:5000/predict/assignment`

**6. HTTP Response**

---

## 📊 Flows de Integración con Simulación

### Recibir datos del simulador

**1. HTTP IN:** `POST /api/simulation/data`

**2. Function "Validar datos del simulador":**
```javascript
const data = msg.payload;

if (!data.event_type || !data.timestamp) {
    msg.statusCode = 400;
    msg.payload = {
        error: "Missing required fields: event_type, timestamp"
    };
    return [null, msg]; // Error
}

// Guardar en contexto global para procesamiento
global.set('last_simulation_event', data);

msg.statusCode = 200;
msg.payload = {
    status: "received",
    processed: true,
    message: "Datos del simulador procesados correctamente"
};

return [msg, null];
```

**3. HTTP Response**

---

### Obtener estado del sistema

**1. HTTP IN:** `GET /api/simulation/status`

**2. PostgreSQL Node:**
Query: 
```sql
SELECT 
    COUNT(*) as total_shelters,
    SUM(max_capacity) as total_capacity,
    SUM(current_occupancy) as current_occupancy,
    SUM(max_capacity - current_occupancy) as available_spaces
FROM shelters
```

**3. Function "Formatear estado":**
```javascript
const stats = msg.payload[0];

msg.statusCode = 200;
msg.payload = {
    total_shelters: parseInt(stats.total_shelters) || 0,
    total_capacity: parseInt(stats.total_capacity) || 0,
    current_occupancy: parseInt(stats.current_occupancy) || 0,
    available_spaces: parseInt(stats.available_spaces) || 0,
    refugees_pending_assignment: 0 // TODO: calcular con otra query
};

return msg;
```

**4. HTTP Response**

---

## 🔧 Configuración del contenedor de IA

Asegúrate de que en tu `compose.yaml` tengas:

```yaml
services:
  ai-service:
    build: ../ai-service
    container_name: shelterai-ai
    ports:
      - "5000:5000"
    networks:
      - shelterai-network
    environment:
      - MODEL_PATH=/app/models
      - API_PORT=5000

networks:
  shelterai-network:
    driver: bridge
```

Y que Node-RED esté en la misma red para comunicarse.

---

## ✅ Checklist de Implementación

- [x] Schemas JSON creados (shelter, refugee, family, assignment)
- [x] Documentación de API creada (API.md)
- [ ] Nodos de validación añadidos a endpoints POST/PUT
- [ ] Flows de IA creados (predict/vulnerability, predict/assignment)
- [ ] Flows de simulación creados (data, status)
- [ ] Contenedor de IA configurado y expuesto
- [ ] Pruebas de integración realizadas

---

## 🧪 Pruebas

### Probar validación:
```bash
# Debe fallar (age > 150)
curl -X POST http://localhost:1880/api/refugees \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","last_name":"User","age":200}'

# Debe funcionar
curl -X POST http://localhost:1880/api/refugees \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","last_name":"User","age":30}'
```

### Probar integración con IA:
```bash
curl -X POST http://localhost:1880/api/ai/predict/vulnerability \
  -H "Content-Type: application/json" \
  -d '{"age":65,"gender":"FEMALE","has_medical_conditions":true,"family_size":1}'
```

---

Para más información, consulta `API.md` en la carpeta `docs/`.
