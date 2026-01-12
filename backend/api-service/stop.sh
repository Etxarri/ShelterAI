#!/bin/bash
# Script para detener los contenedores de ShelterAI
# Ejecutar con: ./stop.sh

echo "🛑 Deteniendo ShelterAI Backend..."

# Hacer backup antes de detener
echo "💾 Haciendo backup de flows antes de detener..."
./sync-flows.sh

# Detener contenedores
docker compose down

echo "✅ Contenedores detenidos correctamente"
