# ShelterAI - Guía de Integración con Node-RED

## 📋 Instrucciones para agregar los flows de IA y Simulación

Los flows principales de CRUD ya están en `flows.json`. Ahora necesitas agregar los flows de integración con IA siguiendo estos pasos:

### Opción 1: Agregar manualmente desde la interfaz de Node-RED

1. Abre http://localhost:1880
2. Haz clic en el menú (☰) → Import
3. Copia y pega el contenido del archivo `integration-flows.json` (ver abajo)
4. Haz clic en "Import"
5. Despliega los cambios (botón "Deploy" en la esquina superior derecha)

### Opción 2: Agregar los nodos de validación a los flows existentes

Para cada endpoint POST y PUT, añade un nodo Function antes del nodo de preparación con este código:

```javascript
// Validación para POST /api/shelters
const Ajv = require('ajv');
const fs = require('fs');

const ajv = new Ajv();
const schema = JSON.parse(fs.readFileSync('/data/schemas/shelter-schema.json', 'utf8'));
const validate = ajv.compile(schema);

const valid = validate(msg.payload);

if (!valid) {
    msg.statusCode = 400;
    msg.payload = {
        error: "Validation failed",
        details: validate.errors.map(err => ({
            field: err.instancePath.replace('/', ''),
            message: err.message
        }))
    };
    // Enviar directamente a HTTP response
    return [null, msg]; // [siguiente nodo normal, nodo de error]
} else {
    return [msg, null]; // Continuar flujo normal
}
```

**IMPORTANTE:** Cada nodo de validación debe tener 2 outputs:
- Output 1: Flujo normal (cuando la validación pasa)
- Output 2: Error HTTP response (cuando falla)

---

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
