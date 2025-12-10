# 🚀 INICIO RÁPIDO - Activar Flows de IA

## Paso 1: Abrir Node-RED
Abre en tu navegador: **http://localhost:1880**

## Paso 2: Importar Flows de Integración

1. Click en el menú **☰** (arriba a la derecha)
2. Click en **Import**
3. Abre el archivo: `backend/api-service/node-red-data/integration-flows.json`
4. **Copia TODO el contenido** del archivo
5. Pega en la ventana de importación de Node-RED
6. Click **Import**
7. Verás 2 nuevas pestañas:
   - **AI Integration**
   - **Simulation Integration**

## Paso 3: Desplegar los Cambios

1. Click en el botón rojo **Deploy** (arriba a la derecha)
2. Espera el mensaje "Successfully deployed"

## ✅ Verificar que Funciona

Abre una nueva terminal y ejecuta:

```bash
# Probar endpoint de IA (devolverá error porque el servicio IA no está activo, pero el endpoint existe)
curl -X POST http://localhost:1880/api/ai/predict/vulnerability \
  -H "Content-Type: application/json" \
  -d "{\"age\":65,\"gender\":\"FEMALE\",\"has_medical_conditions\":true}"

# Probar endpoint de simulación
curl http://localhost:1880/api/simulation/status
```

Si recibes una respuesta JSON, **¡está funcionando!** 🎉

## 📝 Siguientes Pasos

1. **Coordina con el equipo de IA** para configurar su contenedor
2. **Comparte `docs/API.md`** con tus compañeros
3. **Prueba los endpoints** desde Postman o curl

---

Para más detalles, lee:
- `INTEGRATION_GUIDE.md` - Guía completa de integración
- `docs/API.md` - Documentación de todos los endpoints
