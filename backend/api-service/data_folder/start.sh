#!/bin/bash
# Script de inicio para ShelterAI Backend con Node-RED
# Ejecutar con: ./start.sh

set -e  # Detener si hay errores

echo "🚀 Iniciando ShelterAI Backend..."

# Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo"
    exit 1
fi

# Levantar los contenedores
echo "📦 Levantando contenedores..."
docker compose up -d

# Esperar a que Node-RED esté listo
echo "⏳ Esperando a que Node-RED esté listo..."
sleep 5

# Verificar estado
echo "🔍 Verificando estado de los contenedores..."
docker compose ps

# Mostrar logs recientes
echo ""
echo "📋 Últimos logs de Node-RED:"
docker logs shelterai-nodered --tail 10

echo ""
echo "✅ Backend iniciado correctamente!"
echo ""
echo "🌐 Node-RED: http://localhost:1880"
echo "🗄️  PostgreSQL: localhost:5432"
echo ""
echo "💡 Comandos útiles:"
echo "  ./stop.sh          - Detener los contenedores"
echo "  ./sync-flows.sh    - Sincronizar flows del contenedor"
echo "  ./logs.sh          - Ver logs en tiempo real"
echo "  ./backup.sh        - Hacer backup completo"
echo ""
