# 🚀 INICIO RÁPIDO - ShelterAI Backend

## Requisitos Previos

- Docker Desktop instalado y corriendo
- Modelo de IA entrenado (ver `backend/ai-service/README_MODEL_TRAINING.md`)

---

## Paso 1: Construir Imagen del AI Service

```bash
cd backend/ai-service
docker compose build --no-cache
```

Esto crea la imagen `shelterai-ai-service:latest` con FastAPI + HDBSCAN.

---

## Paso 2: Levantar Todos los Servicios

```bash
cd ../api-service
docker compose up -d
```

Esto inicia:
- **PostgreSQL** (puerto 5432)
- **AI Service** (puerto 8000)
- **Node-RED** (puerto 1880)

Verificar que estén corriendo:
```bash
docker ps
```

Deberías ver 3 contenedores:
- `shelterai-postgres`
- `shelterai-ai-service`
- `shelterai-nodered`

---

## Paso 3: Verificar Servicios

### AI Service
```bash
curl http://localhost:8000/health
```

Respuesta esperada:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "database_connected": true
}
```

### Node-RED
Abre en tu navegador: **http://localhost:1880**

### PostgreSQL
```bash
docker exec -it shelterai-postgres psql -U root -d shelterai -c "\dt"
```

Deberías ver las tablas: `shelters`, `refugees`, `families`, `assignments`

---

## Paso 4: Importar Flows de IA (Si es necesario)

Si los flows de IA no están activos en Node-RED:

1. Abre **http://localhost:1880**
2. Click en el menú **☰** → **Import**
3. Selecciona el archivo: `node-red-data/ai-integration-flows.json`
4. Click **Import**
5. Click en **Deploy**

---

## ✅ Probar la Integración

### Test 1: Recomendación de refugio directa

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

### Test 2: A través de Node-RED

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
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:1880/api/ai/assign-shelter" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

Si recibes recomendaciones con `compatibility_score` y `explanation`, **¡está funcionando!** 🎉

---

## 🛠️ Comandos Útiles

```bash
# Ver logs de un servicio
docker logs -f shelterai-ai-service
docker logs -f shelterai-nodered

# Reiniciar un servicio
docker restart shelterai-ai-service

# Detener todos los servicios
docker compose down

# Reconstruir y reiniciar
docker compose up -d --build
```

---

## 📚 Documentación Completa

- **[INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)** - Guía de integración con el servicio IA
- **[../ai-service/README_DOCKER.md](../ai-service/README_DOCKER.md)** - Deployment del servicio IA
- **[../ai-service/README_MODEL_TRAINING.md](../ai-service/README_MODEL_TRAINING.md)** - Entrenamiento del modelo
- **[../../docs/API.md](../../docs/API.md)** - Documentación de endpoints

---

## 🆘 Troubleshooting

### Error: "Could not connect to shelterai-ai-service"
```bash
# Verificar que están en la misma red
docker network inspect shelterai-network
```

### Error: "Model file not found"
```bash
cd backend/ai-service/model_training
python train_final_model.py
```

### Error: "Database connection failed"
```bash
# Reiniciar PostgreSQL
docker restart shelterai-postgres
```

---

**🎓 Educational Project** - Universidad del País Vasco (UPV/EHU)
