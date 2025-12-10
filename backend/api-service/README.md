# ShelterAI Backend - Node-RED API

Backend desarrollado en Node-RED para el sistema de gestión de refugiados ShelterAI.

## 🚀 Inicio Rápido

```bash
cd backend/api-service
docker compose up -d
```

El backend estará disponible en: **http://localhost:1880**

## 📚 Documentación

- **[API.md](../../docs/API.md)** - Documentación completa de todos los endpoints
- **[INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)** - Guía para integrar IA y Simulación

## 🏗️ Arquitectura

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
         ├──► AI Service (puerto 5000)
         └──► Simulator (eventos)
```

## 📦 Servicios

### Node-RED (Puerto 1880)
- API REST completa (CRUD)
- Validación de datos con JSON Schemas
- Integración con servicios de IA
- Recepción de datos del simulador

### PostgreSQL (Puerto 5432)
- Base de datos principal
- Tablas: shelters, refugees, families, assignments

## 🔑 Endpoints Principales

### Albergues
- `GET /api/shelters` - Listar todos
- `GET /api/shelters/available` - Con capacidad disponible
- `POST /api/shelters` - Crear nuevo
- `PUT /api/shelters/:id` - Actualizar
- `DELETE /api/shelters/:id` - Eliminar

### Refugiados
- `GET /api/refugees` - Listar todos
- `GET /api/refugees/high-vulnerability` - Alta vulnerabilidad
- `POST /api/refugees` - Crear nuevo
- `PUT /api/refugees/:id` - Actualizar
- `DELETE /api/refugees/:id` - Eliminar

### Familias
- `GET /api/families` - Listar todas
- `POST /api/families` - Crear nueva
- `PUT /api/families/:id` - Actualizar
- `DELETE /api/families/:id` - Eliminar

### Asignaciones
- `GET /api/assignments` - Listar todas
- `GET /api/assignments/status/:status` - Por estado
- `POST /api/assignments` - Crear nueva
- `PUT /api/assignments/:id` - Actualizar
- `DELETE /api/assignments/:id` - Eliminar

### Integración IA
- `POST /api/ai/predict/vulnerability` - Predecir vulnerabilidad
- `POST /api/ai/predict/assignment` - Recomendar albergue

### Simulación
- `POST /api/simulation/data` - Recibir eventos
- `GET /api/simulation/status` - Estado del sistema

Ver **[API.md](../../docs/API.md)** para detalles completos.

## ✅ Validación de Datos

Todos los endpoints POST/PUT validan datos contra JSON Schemas:

- `shelter-schema.json` - Albergues
- `refugee-schema.json` - Refugiados
- `family-schema.json` - Familias
- `assignment-schema.json` - Asignaciones

Si la validación falla, se retorna **400 Bad Request** con detalles del error.

## 🛠️ Desarrollo

### Ver logs
```bash
docker logs shelterai-nodered -f
```

### Acceder a Node-RED
Abre http://localhost:1880 en tu navegador para ver/editar los flows.

### Reiniciar servicios
```bash
docker compose restart
```

### Backup de flows
```bash
docker exec shelterai-nodered cat /data/flows.json > backup-flows.json
```

## 📊 Base de Datos

### Conectar a PostgreSQL
```bash
docker exec -it shelterai-postgres psql -U root -d shelterai
```

### Ver tablas
```sql
\dt
```

### Ejemplo de consulta
```sql
SELECT * FROM shelters WHERE current_occupancy < max_capacity;
```

## 🔧 Configuración

### Variables de entorno (compose.yaml)
```yaml
environment:
  - TZ=Europe/Madrid
  - FLOWS=flows.json
```

### Base de datos
```yaml
POSTGRES_DB: shelterai
POSTGRES_USER: root
POSTGRES_PASSWORD: root
```

## 📝 Notas para el Equipo

### Para el equipo de Web (Frontend)
- Lee **[API.md](../../docs/API.md)** para saber cómo llamar a los endpoints
- Todos los datos se envían/reciben en formato JSON
- La validación es automática, recibirás error 400 si los datos son inválidos

### Para el equipo de IA
- Tu contenedor debe exponerse como `shelterai-ai:5000`
- Implementa los endpoints documentados en API.md sección "IA"
- Node-RED te llamará automáticamente cuando sea necesario

### Para el equipo de Simulación
- Envía tus eventos a `POST /api/simulation/data`
- Consulta el estado del sistema en `GET /api/simulation/status`

## 🎯 Cumplimiento de Rúbrica

### Ingeniería Web II (Nivel 3)
✅ "Use schemas to validate documents" - JSON Schemas implementados  
✅ "Communications between systems" - API REST completa  

### Inteligencia Artificial (Nivel 3)
✅ "Services integrated in Node-RED" - Flows de integración con IA  

### Gestión de Proyectos (Nivel 3)
✅ "Defined interfaces between modules" - Documentación API.md  
✅ "Clear communication with team" - Contratos y ejemplos

## 🐛 Troubleshooting

### Error: "Flows stopped due to missing node types"
```bash
docker exec shelterai-nodered sh -c "cd /data && npm install"
docker restart shelterai-nodered
```

### Error: "EBUSY: resource busy or locked"
No edites `flows.json` directamente desde VS Code. Usa la interfaz web de Node-RED.

### No se conecta a PostgreSQL
Verifica que el contenedor esté healthy:
```bash
docker ps
```

## 📄 Licencia

Proyecto académico - Universidad de Deusto - PBL 2025
