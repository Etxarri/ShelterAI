# ShelterAI - API Documentation

> **Contrato de Integración para los equipos de Web, IA y Simulación**  
> Versión: 1.0  
> Última actualización: 10 de diciembre de 2025

## 📋 Información General

- **URL Base**: `http://localhost:1880`
- **Base de Datos**: PostgreSQL en `postgres:5432`
- **Formato**: JSON
- **Validación**: Todos los endpoints POST/PUT validan datos con JSON Schema

---

## 🏠 API de Albergues (Shelters)

### GET /api/shelters
Obtener lista de todos los albergues.

**Response 200:**
```json
[
  {
    "id": 1,
    "name": "Albergue Central Madrid",
    "address": "Calle Mayor 1, Madrid",
    "phone_number": "+34 912345678",
    "email": "central@shelterai.org",
    "max_capacity": 200,
    "current_occupancy": 150,
    "has_medical_facilities": true,
    "has_childcare": true,
    "has_disability_access": true,
    "languages_spoken": "Español, Inglés, Árabe",
    "latitude": 40.4168,
    "longitude": -3.7038,
    "shelter_type": "PERMANENT",
    "services_offered": "Alojamiento, comida, atención médica",
    "created_at": "2025-01-15T10:00:00Z",
    "updated_at": "2025-12-10T08:00:00Z"
  }
]
```

### GET /api/shelters/:id
Obtener un albergue específico por ID.

**Response 200:** Objeto shelter  
**Response 404:** `{"error": "Shelter not found"}`

### GET /api/shelters/available
Obtener albergues con capacidad disponible (current_occupancy < max_capacity).

**Response 200:** Array de shelters

### POST /api/shelters
Crear un nuevo albergue.

**Request Body (requerido):**
```json
{
  "name": "Nuevo Albergue",
  "max_capacity": 100,
  "address": "Calle Ejemplo 123",
  "phone_number": "+34 600000000",
  "email": "contacto@ejemplo.com",
  "latitude": 40.4168,
  "longitude": -3.7038,
  "shelter_type": "TEMPORARY",
  "has_medical_facilities": false,
  "has_childcare": true,
  "has_disability_access": true
}
```

**Validaciones:**
- `name`: string, obligatorio, 1-100 caracteres
- `max_capacity`: integer, obligatorio, 1-10000
- `latitude`: number, -90 a 90
- `longitude`: number, -180 a 180
- `shelter_type`: enum ["TEMPORARY", "PERMANENT", "EMERGENCY", "TRANSIT"]

**Response 201:** Objeto shelter creado  
**Response 400:** Error de validación

### PUT /api/shelters/:id
Actualizar albergue existente.

**Request Body:** Mismo formato que POST  
**Response 200:** Objeto shelter actualizado  
**Response 404:** Shelter no encontrado

### DELETE /api/shelters/:id
Eliminar un albergue.

**Response 204:** Sin contenido (éxito)

---

## 👥 API de Refugiados (Refugees)

### GET /api/refugees
Obtener lista de todos los refugiados.

**Response 200:**
```json
[
  {
    "id": 1,
    "first_name": "Ahmed",
    "last_name": "Hassan",
    "age": 35,
    "gender": "MALE",
    "nationality": "Siria",
    "languages_spoken": "Árabe, Inglés",
    "phone_number": "+34 611222333",
    "email": "ahmed@example.com",
    "family_id": 5,
    "medical_conditions": "Diabetes",
    "special_needs": "Dieta especial",
    "vulnerability_score": 7.5,
    "education_level": "UNIVERSITY",
    "employment_status": "UNEMPLOYED",
    "registration_date": "2025-01-10",
    "created_at": "2025-01-10T12:00:00Z",
    "updated_at": "2025-12-10T09:00:00Z"
  }
]
```

### GET /api/refugees/:id
Obtener un refugiado específico.

**Response 200:** Objeto refugee  
**Response 404:** `{"error": "Refugee not found"}`

### GET /api/refugees/family/:familyId
Obtener todos los refugiados de una familia.

**Response 200:** Array de refugees

### GET /api/refugees/high-vulnerability?minScore=7.0
Obtener refugiados con alta vulnerabilidad.

**Query Parameters:**
- `minScore` (opcional): número decimal, default 7.0

**Response 200:** Array de refugees ordenados por vulnerability_score DESC

### POST /api/refugees
Crear un nuevo refugiado.

**Request Body (requerido):**
```json
{
  "first_name": "Fatima",
  "last_name": "Ali",
  "age": 28,
  "gender": "FEMALE",
  "nationality": "Afganistán",
  "languages_spoken": "Dari, Inglés",
  "vulnerability_score": 8.0,
  "medical_conditions": "Embarazada - 7 meses",
  "special_needs": "Atención prenatal",
  "education_level": "SECONDARY",
  "employment_status": "UNEMPLOYED",
  "registration_date": "2025-12-10"
}
```

**Validaciones:**
- `first_name`, `last_name`: string, obligatorios, 1-100 caracteres
- `age`: integer, obligatorio, 0-150
- `gender`: enum ["MALE", "FEMALE", "OTHER", "UNKNOWN"]
- `vulnerability_score`: number, 0-10
- `education_level`: enum ["NONE", "PRIMARY", "SECONDARY", "UNIVERSITY", "POSTGRADUATE"]
- `employment_status`: enum ["UNEMPLOYED", "EMPLOYED", "STUDENT", "RETIRED", "UNABLE_TO_WORK"]

**Response 201:** Objeto refugee creado  
**Response 400:** Error de validación

### PUT /api/refugees/:id
Actualizar refugiado existente.

**Response 200:** Objeto refugee actualizado  
**Response 404:** Refugee no encontrado

### DELETE /api/refugees/:id
Eliminar un refugiado.

**Response 204:** Sin contenido

---

## 👨‍👩‍👧‍👦 API de Familias (Families)

### GET /api/families
Obtener todas las familias.

**Response 200:**
```json
[
  {
    "id": 1,
    "family_name": "Hassan",
    "family_size": 5,
    "head_of_family_id": 1,
    "notes": "Familia completa, 3 niños pequeños",
    "created_at": "2025-01-10T10:00:00Z",
    "updated_at": "2025-12-10T08:00:00Z"
  }
]
```

### GET /api/families/:id
Obtener una familia específica.

**Response 200:** Objeto family  
**Response 404:** `{"error": "Family not found"}`

### GET /api/families/size/:size
Obtener familias por tamaño.

**Response 200:** Array de families

### POST /api/families
Crear una nueva familia.

**Request Body:**
```json
{
  "family_name": "Ali",
  "family_size": 4,
  "head_of_family_id": 10,
  "notes": "2 adultos, 2 niños"
}
```

**Validaciones:**
- `family_size`: integer, obligatorio, 1-50

**Response 201:** Objeto family creado

### PUT /api/families/:id
Actualizar familia.

**Response 200:** Objeto family actualizado

### DELETE /api/families/:id
Eliminar familia.

**Response 204:** Sin contenido

---

## 🔗 API de Asignaciones (Assignments)

### GET /api/assignments
Obtener todas las asignaciones.

**Response 200:**
```json
[
  {
    "id": 1,
    "refugee_id": 1,
    "shelter_id": 3,
    "assignment_date": "2025-12-15",
    "status": "CONFIRMED",
    "priority_score": 8.5,
    "notes": "Asignación prioritaria por condición médica",
    "created_at": "2025-12-10T10:00:00Z",
    "updated_at": "2025-12-10T14:00:00Z"
  }
]
```

### GET /api/assignments/:id
Obtener asignación específica.

**Response 200:** Objeto assignment  
**Response 404:** `{"error": "Assignment not found"}`

### GET /api/assignments/refugee/:refugeeId
Obtener asignaciones de un refugiado.

**Response 200:** Array de assignments

### GET /api/assignments/shelter/:shelterId
Obtener asignaciones de un albergue.

**Response 200:** Array de assignments

### GET /api/assignments/status/:status
Obtener asignaciones por estado.

**Valores válidos:** PENDING, CONFIRMED, COMPLETED, CANCELLED

**Response 200:** Array de assignments

### POST /api/assignments
Crear una nueva asignación.

**Request Body:**
```json
{
  "refugee_id": 15,
  "shelter_id": 3,
  "assignment_date": "2025-12-15",
  "status": "PENDING",
  "priority_score": 7.5,
  "notes": "Urgente - familia con niños"
}
```

**Validaciones:**
- `refugee_id`: integer, obligatorio, mínimo 1
- `shelter_id`: integer, obligatorio, mínimo 1
- `assignment_date`: string, obligatorio, formato YYYY-MM-DD
- `status`: enum ["PENDING", "CONFIRMED", "COMPLETED", "CANCELLED"]
- `priority_score`: number, 0-10

**Response 201:** Objeto assignment creado

### PUT /api/assignments/:id
Actualizar asignación.

**Response 200:** Objeto assignment actualizado

### DELETE /api/assignments/:id
Eliminar asignación.

**Response 204:** Sin contenido

---

## 🤖 API de Integración con IA

### POST /api/ai/predict/vulnerability
Predecir score de vulnerabilidad para un refugiado.

**Request Body:**
```json
{
  "age": 35,
  "gender": "MALE",
  "has_medical_conditions": true,
  "family_size": 5,
  "education_level": "UNIVERSITY"
}
```

**Response 200:**
```json
{
  "vulnerability_score": 7.5,
  "risk_level": "HIGH",
  "recommendations": [
    "Asignación prioritaria",
    "Seguimiento médico"
  ]
}
```

### POST /api/ai/predict/assignment
Recomendar mejor albergue para un refugiado.

**Request Body:**
```json
{
  "refugee_id": 15,
  "requirements": {
    "medical_facilities": true,
    "childcare": true,
    "max_distance_km": 50
  }
}
```

**Response 200:**
```json
{
  "recommended_shelter_id": 3,
  "shelter_name": "Albergue San José",
  "confidence": 0.92,
  "match_score": 8.7
}
```

**Nota para el equipo de IA:** El contenedor debe exponerse como `shelterai-ai:5000` en la red Docker.

---

## 📊 API de Integración con Simulación (Sistemas Operativos)

### POST /api/simulation/data
Recibir datos del simulador de eventos.

**Request Body:**
```json
{
  "event_type": "NEW_ARRIVALS",
  "timestamp": "2025-12-10T15:30:00Z",
  "data": {
    "count": 25,
    "demographics": {
      "adults": 15,
      "children": 10
    },
    "urgent_cases": 5
  }
}
```

**Response 200:**
```json
{
  "status": "received",
  "processed": true,
  "message": "Datos del simulador procesados correctamente"
}
```

### GET /api/simulation/status
Obtener estado actual del sistema para el simulador.

**Response 200:**
```json
{
  "total_shelters": 15,
  "total_capacity": 3000,
  "current_occupancy": 2100,
  "available_spaces": 900,
  "refugees_pending_assignment": 45
}
```

---

## 🔒 Códigos de Estado HTTP

| Código | Significado |
|--------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado exitosamente |
| 204 | No Content - Eliminación exitosa |
| 400 | Bad Request - Validación fallida |
| 404 | Not Found - Recurso no encontrado |
| 500 | Internal Server Error - Error del servidor |

---

## ✅ Validación de Datos

Todos los endpoints POST y PUT validan los datos contra JSON Schemas. Si los datos no cumplen con las validaciones, se retorna un **400 Bad Request** con detalles del error:

```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "age",
      "message": "must be <= 150"
    },
    {
      "field": "email",
      "message": "must match format 'email'"
    }
  ]
}
```

---

## 🚀 Ejemplos de Uso desde el Frontend

### JavaScript/Fetch
```javascript
// Obtener albergues disponibles
const response = await fetch('http://localhost:1880/api/shelters/available');
const shelters = await response.json();

// Crear nuevo refugiado
const newRefugee = {
  first_name: "Maria",
  last_name: "Garcia",
  age: 42,
  nationality: "Venezuela",
  vulnerability_score: 6.5
};

const response = await fetch('http://localhost:1880/api/refugees', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(newRefugee)
});

if (response.ok) {
  const created = await response.json();
  console.log('Refugiado creado:', created);
} else {
  const error = await response.json();
  console.error('Error de validación:', error);
}
```

### Python (para el equipo de IA)
```python
import requests

# Llamar a la API desde el contenedor de IA
def predict_vulnerability(refugee_data):
    response = requests.post(
        'http://shelterai-nodered:1880/api/ai/predict/vulnerability',
        json=refugee_data
    )
    return response.json()
```

---

## 📞 Contacto y Soporte

Para dudas sobre la API, contactar al equipo de Backend/Node-RED.

**Importante:** Esta documentación debe actualizarse cuando se añadan nuevos endpoints o se modifiquen los existentes.
