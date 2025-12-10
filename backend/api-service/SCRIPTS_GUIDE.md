# 🛠️ Scripts de Gestión del Backend ShelterAI

Esta guía explica cómo usar los scripts de automatización para gestionar el backend de Node-RED de forma eficiente.

---

## 📂 Scripts Disponibles

Todos los scripts están disponibles en **dos versiones**:
- **`.ps1`** - Para Windows (PowerShell)
- **`.sh`** - Para Linux/Mac (Bash)

La funcionalidad es idéntica en ambas versiones.

---

## 🚀 Comandos Básicos

### 1️⃣ Iniciar el Backend

**Windows:**
```powershell
.\start.ps1
```

**Linux/Mac:**
```bash
./start.sh
```

**¿Qué hace?**
- ✅ Verifica que Docker esté corriendo
- ✅ Levanta los contenedores (PostgreSQL + Node-RED)
- ✅ Espera a que los servicios estén listos
- ✅ Muestra el estado de los contenedores
- ✅ Muestra los últimos logs
- ✅ Te da las URLs de acceso:
  - Node-RED: http://localhost:1880
  - PostgreSQL: localhost:5432

**Salida esperada:**
```
🚀 Iniciando ShelterAI Backend...
📦 Levantando contenedores...
⏳ Esperando a que Node-RED esté listo...
✅ Backend iniciado correctamente!

🌐 Node-RED: http://localhost:1880
🗄️  PostgreSQL: localhost:5432
```

---

### 2️⃣ Detener el Backend

**Windows:**
```powershell
.\stop.ps1
```

**Linux/Mac:**
```bash
./stop.sh
```

**¿Qué hace?**
- ✅ **Hace un backup automático** de los flows antes de detener (muy importante!)
- ✅ Detiene los contenedores limpiamente
- ✅ Libera los recursos

**⚠️ Importante:** Siempre usa este script en lugar de `docker compose down` directamente, porque hace backup automático de tus cambios.

---

### 3️⃣ Sincronizar Flows

**Windows:**
```powershell
.\sync-flows.ps1
```

**Linux/Mac:**
```bash
./sync-flows.sh
```

**¿Qué hace?**
- ✅ Crea un backup del `flows.json` actual en `backups/flows_YYYYMMDD_HHMMSS.json`
- ✅ Copia el archivo `flows.json` desde el contenedor Docker → carpeta local
- ✅ Copia también los schemas JSON
- ✅ Los archivos quedan listos para hacer commit en Git

**¿Cuándo usarlo?**
- Después de hacer cambios en Node-RED (añadir/modificar flows)
- Antes de hacer commit en Git
- Al finalizar tu sesión de trabajo

**Ejemplo de uso:**
```powershell
# 1. Trabajas en Node-RED, añades nuevos flows
# 2. Sincronizas:
.\sync-flows.ps1

# 3. Haces commit:
git add node-red-data/flows.json
git commit -m "feat: añadidos flows de validación de refugiados"
git push
```

---

### 4️⃣ Ver Logs en Tiempo Real

**Windows:**
```powershell
# Ver logs de Node-RED
.\logs.ps1

# Ver logs de PostgreSQL
.\logs.ps1 postgres

# Ver logs de todos los servicios
.\logs.ps1 all
```

**Linux/Mac:**
```bash
# Ver logs de Node-RED
./logs.sh

# Ver logs de PostgreSQL
./logs.sh postgres

# Ver logs de todos los servicios
./logs.sh all
```

**¿Qué hace?**
- ✅ Muestra los logs en tiempo real (actualización continua)
- ✅ Útil para debugging y ver errores
- ✅ Presiona `Ctrl+C` para salir

**Ejemplo de salida:**
```
📋 Logs de Node-RED (Ctrl+C para salir)...
10 Dec 08:23:45 - [info] Starting flows
10 Dec 08:23:46 - [info] Started flows
```

---

### 5️⃣ Hacer Backup Completo

**Windows:**
```powershell
.\backup.ps1
```

**Linux/Mac:**
```bash
./backup.sh
```

**¿Qué hace?**
- ✅ Crea un directorio `backups/backup_YYYYMMDD_HHMMSS/`
- ✅ Guarda `flows.json` (todos tus flows de Node-RED)
- ✅ Guarda `package.json` (dependencias instaladas)
- ✅ Guarda `settings.js` (configuración de Node-RED)
- ✅ Guarda todos los schemas JSON de validación
- ✅ **Exporta toda la base de datos PostgreSQL** (`database.sql`)
- ✅ Crea un archivo `backup_info.txt` con información del backup

**¿Cuándo usarlo?**
- Antes de hacer cambios grandes en los flows
- Antes de actualizar dependencias
- Como backup periódico (ej: cada viernes)
- Antes de reconstruir contenedores

**Salida esperada:**
```
💾 Creando backup completo...
📄 Guardando flows.json...
📦 Guardando package.json...
⚙️  Guardando settings.js...
📋 Guardando schemas...
🗄️  Guardando base de datos PostgreSQL...

✅ Backup completo creado en: backups/backup_20251210_153000
📊 Tamaño: 2.5 MB
```

---

### 6️⃣ Restaurar un Backup

**Windows:**
```powershell
# Ver backups disponibles
.\restore.ps1

# Restaurar un backup específico
.\restore.ps1 backups\backup_20251210_153000
```

**Linux/Mac:**
```bash
# Ver backups disponibles
./restore.sh

# Restaurar un backup específico
./restore.sh backups/backup_20251210_153000
```

**¿Qué hace?**
- ✅ Muestra una lista de backups disponibles (si no especificas uno)
- ✅ Pide confirmación antes de restaurar (para evitar accidentes)
- ✅ Detiene los contenedores
- ✅ Restaura todos los archivos de Node-RED
- ✅ Restaura la base de datos PostgreSQL
- ✅ Reinicia los servicios

**⚠️ Advertencia:** Esto sobrescribirá todos los datos actuales. Úsalo con cuidado.

---

## 🔄 Flujo de Trabajo Completo

### Escenario 1: Trabajo Diario

```powershell
# 1. Iniciar el backend
.\start.ps1

# 2. Abrir Node-RED en el navegador
# http://localhost:1880

# 3. Hacer cambios en los flows
# (añadir nodos, modificar endpoints, etc.)

# 4. Al terminar, sincronizar cambios
.\sync-flows.ps1

# 5. Hacer commit en Git
git add node-red-data/flows.json
git commit -m "feat: mejoras en API de refugiados"
git push

# 6. Detener el backend (hace backup automático)
.\stop.ps1
```

---

### Escenario 2: Antes de Cambios Importantes

```powershell
# 1. Hacer backup completo por seguridad
.\backup.ps1

# 2. Trabajar en los cambios
# ...

# 3. Si algo sale mal, restaurar el backup
.\restore.ps1 backups\backup_20251210_153000
```

---

### Escenario 3: Compartir Trabajo con el Equipo

```powershell
# 1. Sincronizar tus cambios
.\sync-flows.ps1

# 2. Hacer commit y push
git add node-red-data/flows.json
git commit -m "feat: añadidos endpoints de IA"
git push

# 3. Tu compañero hace pull
git pull

# 4. Tu compañero reinicia su backend
.\stop.ps1
.\start.ps1
# Los nuevos flows se cargan automáticamente
```

---

## 📁 Estructura de Archivos

```
backend/api-service/
├── start.ps1 / start.sh          # Iniciar backend
├── stop.ps1 / stop.sh            # Detener backend
├── sync-flows.ps1 / sync-flows.sh # Sincronizar flows
├── logs.ps1 / logs.sh            # Ver logs
├── backup.ps1 / backup.sh        # Hacer backup
├── restore.ps1 / restore.sh      # Restaurar backup
├── backups/                      # Carpeta de backups
│   ├── flows_20251210_150000.json
│   ├── flows_20251210_153000.json
│   └── backup_20251210_153000/
│       ├── flows.json
│       ├── package.json
│       ├── settings.js
│       ├── database.sql
│       ├── schemas/
│       └── backup_info.txt
└── node-red-data/
    ├── flows.json               # ← Se sincroniza aquí
    ├── package.json
    ├── settings.js
    └── schemas/
```

---

## 🆘 Problemas Comunes

### ❌ "El contenedor no está corriendo"

**Solución:**
```powershell
.\start.ps1
```

---

### ❌ "Docker no está corriendo"

**Solución:**
1. Abre Docker Desktop
2. Espera a que inicie completamente
3. Ejecuta `.\start.ps1`

---

### ❌ "Los cambios en Node-RED no se guardan en Git"

**Solución:**
Ejecuta `.\sync-flows.ps1` después de hacer cambios en Node-RED. Los cambios solo están en el contenedor hasta que los sincronices.

---

### ❌ "Error: resource busy or locked"

**Solución:**
- Cierra el archivo `flows.json` si lo tienes abierto en VS Code
- No edites `flows.json` directamente, hazlo desde Node-RED
- Usa `.\sync-flows.ps1` para sincronizar

---

### ❌ "Perdí mis flows"

**Solución:**
```powershell
# Listar backups disponibles
.\restore.ps1

# Restaurar el último backup
.\restore.ps1 backups\backup_20251210_153000
```

---

## 💡 Consejos y Mejores Prácticas

### ✅ Hacer backup antes de cambios grandes
```powershell
.\backup.ps1
# Ahora puedes experimentar tranquilo
```

### ✅ Sincronizar antes de hacer commit
```powershell
.\sync-flows.ps1
git add node-red-data/flows.json
git commit -m "feat: nuevos endpoints"
```

### ✅ Usar stop.ps1 en lugar de docker compose down
```powershell
# ❌ NO hacer esto:
docker compose down

# ✅ Hacer esto:
.\stop.ps1  # Hace backup automático
```

### ✅ Revisar logs cuando algo no funciona
```powershell
.\logs.ps1  # Ver qué está pasando
```

---

## 🎯 Comandos Rápidos de Referencia

| Acción | Windows | Linux/Mac |
|--------|---------|-----------|
| Iniciar | `.\start.ps1` | `./start.sh` |
| Detener | `.\stop.ps1` | `./stop.sh` |
| Sincronizar | `.\sync-flows.ps1` | `./sync-flows.sh` |
| Ver logs | `.\logs.ps1` | `./logs.sh` |
| Backup | `.\backup.ps1` | `./backup.sh` |
| Restaurar | `.\restore.ps1` | `./restore.sh` |

---

## 📞 Ayuda Adicional

- **Documentación de la API:** `docs/API.md`
- **Guía de integración:** `INTEGRATION_GUIDE.md`
- **README del servicio:** `README.md`
- **Resumen de implementación:** `IMPLEMENTATION_SUMMARY.md`

---

## ⚙️ Configuración Avanzada

### Ejecutar scripts sin necesidad de extensión

**Windows (PowerShell):**
Los scripts `.ps1` pueden requerir cambiar la política de ejecución:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Linux/Mac (Bash):**
Dar permisos de ejecución a los scripts:
```bash
chmod +x *.sh
```

---

## 🎉 ¡Listo para Usar!

Ahora tu equipo tiene todo lo necesario para gestionar el backend de forma profesional y sin perder datos. 

**Recuerda:**
1. Siempre usa `.\start.ps1` para iniciar
2. Siempre usa `.\stop.ps1` para detener (hace backup automático)
3. Usa `.\sync-flows.ps1` después de cambios en Node-RED
4. Haz backups completos con `.\backup.ps1` antes de cambios importantes

¡Feliz desarrollo! 🚀
