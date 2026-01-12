#!/bin/bash
# Script para ver logs en tiempo real
# Ejecutar con: ./logs.sh [servicio]
# Ejemplos: ./logs.sh
#           ./logs.sh nodered
#           ./logs.sh postgres

SERVICE=${1:-nodered}

if [ "$SERVICE" = "nodered" ]; then
    echo "📋 Logs de Node-RED (Ctrl+C para salir)..."
    docker logs shelterai-nodered -f
elif [ "$SERVICE" = "postgres" ]; then
    echo "📋 Logs de PostgreSQL (Ctrl+C para salir)..."
    docker logs shelterai-postgres -f
else
    echo "📋 Logs de todos los servicios (Ctrl+C para salir)..."
    docker compose logs -f
fi
