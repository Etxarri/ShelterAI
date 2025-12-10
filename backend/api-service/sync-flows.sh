#!/bin/bash
# Script para sincronizar flows desde el contenedor
# Ejecutar con: ./sync-flows.sh

set -e

echo "🔄 Sincronizando flows desde el contenedor..."

# Verificar que el contenedor esté corriendo
if ! docker ps | grep -q shelterai-nodered; then
    echo "❌ Error: El contenedor shelterai-nodered no está corriendo"
    echo "   Ejecuta ./start.sh primero"
    exit 1
fi

# Crear backup del flows.json actual
if [ -f "node-red-data/flows.json" ]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p backups
    cp node-red-data/flows.json "backups/flows_${timestamp}.json"
    echo "📦 Backup creado: backups/flows_${timestamp}.json"
fi

# Sincronizar flows
docker exec shelterai-nodered cat /data/flows.json > node-red-data/flows.json

# Sincronizar schemas también
docker exec shelterai-nodered cat /data/schemas/shelter-schema.json > node-red-data/schemas/shelter-schema.json 2>/dev/null || true
docker exec shelterai-nodered cat /data/schemas/refugee-schema.json > node-red-data/schemas/refugee-schema.json 2>/dev/null || true
docker exec shelterai-nodered cat /data/schemas/family-schema.json > node-red-data/schemas/family-schema.json 2>/dev/null || true
docker exec shelterai-nodered cat /data/schemas/assignment-schema.json > node-red-data/schemas/assignment-schema.json 2>/dev/null || true

echo "✅ Flows sincronizados correctamente"
echo "📁 Archivo actualizado: node-red-data/flows.json"
