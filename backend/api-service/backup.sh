#!/bin/bash
# Script para hacer backup completo
# Ejecutar con: ./backup.sh

set -e

timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="backups/backup_${timestamp}"

echo "💾 Creando backup completo..."

# Crear directorio de backup
mkdir -p "$backup_dir"

# Verificar que los contenedores estén corriendo
if docker ps | grep -q shelterai-nodered; then
    # Backup de flows desde el contenedor
    echo "📄 Guardando flows.json..."
    docker exec shelterai-nodered cat /data/flows.json > "$backup_dir/flows.json"
    
    # Backup de package.json
    echo "📦 Guardando package.json..."
    docker exec shelterai-nodered cat /data/package.json > "$backup_dir/package.json"
    
    # Backup de settings.js
    echo "⚙️  Guardando settings.js..."
    docker exec shelterai-nodered cat /data/settings.js > "$backup_dir/settings.js"
    
    # Backup de schemas
    echo "📋 Guardando schemas..."
    mkdir -p "$backup_dir/schemas"
    docker exec shelterai-nodered cat /data/schemas/shelter-schema.json > "$backup_dir/schemas/shelter-schema.json" 2>/dev/null || true
    docker exec shelterai-nodered cat /data/schemas/refugee-schema.json > "$backup_dir/schemas/refugee-schema.json" 2>/dev/null || true
    docker exec shelterai-nodered cat /data/schemas/family-schema.json > "$backup_dir/schemas/family-schema.json" 2>/dev/null || true
    docker exec shelterai-nodered cat /data/schemas/assignment-schema.json > "$backup_dir/schemas/assignment-schema.json" 2>/dev/null || true
else
    echo "⚠️  Advertencia: Contenedor no corriendo, usando archivos locales"
    cp -r node-red-data/* "$backup_dir/"
fi

# Backup de la base de datos
if docker ps | grep -q shelterai-postgres; then
    echo "🗄️  Guardando base de datos PostgreSQL..."
    docker exec shelterai-postgres pg_dump -U root shelterai > "$backup_dir/database.sql"
fi

# Crear archivo de información
cat > "$backup_dir/backup_info.txt" << EOF
ShelterAI Backend Backup
========================
Fecha: $(date)
Usuario: $(whoami)
Hostname: $(hostname)

Contenido:
- flows.json (Node-RED flows)
- package.json (dependencias)
- settings.js (configuración)
- schemas/ (validación JSON)
- database.sql (PostgreSQL dump)

Para restaurar:
1. Copiar archivos a node-red-data/
2. Restaurar DB: cat database.sql | docker exec -i shelterai-postgres psql -U root shelterai
3. Reiniciar: ./start.sh
EOF

echo ""
echo "✅ Backup completo creado en: $backup_dir"
echo "📊 Tamaño: $(du -sh $backup_dir | cut -f1)"
echo ""
echo "Para restaurar este backup:"
echo "  ./restore.sh $backup_dir"
