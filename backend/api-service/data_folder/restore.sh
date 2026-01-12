#!/bin/bash
# Script para restaurar un backup
# Ejecutar con: ./restore.sh <directorio_backup>

if [ -z "$1" ]; then
    echo "❌ Error: Debes especificar el directorio de backup"
    echo "Uso: ./restore.sh backups/backup_YYYYMMDD_HHMMSS"
    echo ""
    echo "Backups disponibles:"
    ls -lt backups/ | grep ^d | head -5
    exit 1
fi

BACKUP_DIR=$1

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: El directorio $BACKUP_DIR no existe"
    exit 1
fi

echo "🔄 Restaurando backup desde: $BACKUP_DIR"
echo ""
read -p "⚠️  Esto sobrescribirá los datos actuales. ¿Continuar? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Cancelado"
    exit 0
fi

# Detener contenedores
echo "🛑 Deteniendo contenedores..."
docker compose down

# Restaurar archivos
echo "📄 Restaurando archivos de Node-RED..."
cp "$BACKUP_DIR/flows.json" node-red-data/flows.json
cp "$BACKUP_DIR/package.json" node-red-data/package.json 2>/dev/null || true
cp "$BACKUP_DIR/settings.js" node-red-data/settings.js 2>/dev/null || true

if [ -d "$BACKUP_DIR/schemas" ]; then
    mkdir -p node-red-data/schemas
    cp -r "$BACKUP_DIR/schemas/"* node-red-data/schemas/
fi

# Iniciar contenedores
echo "🚀 Iniciando contenedores..."
docker compose up -d

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a PostgreSQL..."
sleep 10

# Restaurar base de datos si existe
if [ -f "$BACKUP_DIR/database.sql" ]; then
    echo "🗄️  Restaurando base de datos..."
    cat "$BACKUP_DIR/database.sql" | docker exec -i shelterai-postgres psql -U root shelterai
fi

echo ""
echo "✅ Restauración completada!"
echo "🌐 Node-RED: http://localhost:1880"
