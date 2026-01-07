# Script para hacer backup completo
# Ejecutar con: .\backup.ps1

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/backup_$timestamp"

Write-Host "💾 Creando backup completo..." -ForegroundColor Cyan

# Crear directorio de backup
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Verificar que los contenedores estén corriendo
$running = docker ps --filter "name=shelterai-nodered" --format "{{.Names}}"

if ($running) {
    # Backup de flows desde el contenedor
    Write-Host "📄 Guardando flows.json..." -ForegroundColor Yellow
    docker exec shelterai-nodered cat /data/flows.json | Out-File -Encoding UTF8 "$backupDir/flows.json"
    
    # Backup de package.json
    Write-Host "📦 Guardando package.json..." -ForegroundColor Yellow
    docker exec shelterai-nodered cat /data/package.json | Out-File -Encoding UTF8 "$backupDir/package.json"
    
    # Backup de settings.js
    Write-Host "⚙️  Guardando settings.js..." -ForegroundColor Yellow
    docker exec shelterai-nodered cat /data/settings.js | Out-File -Encoding UTF8 "$backupDir/settings.js"
    
    # Backup de schemas
    Write-Host "📋 Guardando schemas..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$backupDir/schemas" -Force | Out-Null
    try {
        docker exec shelterai-nodered cat /data/schemas/shelter-schema.json | Out-File -Encoding UTF8 "$backupDir/schemas/shelter-schema.json"
        docker exec shelterai-nodered cat /data/schemas/refugee-schema.json | Out-File -Encoding UTF8 "$backupDir/schemas/refugee-schema.json"
        docker exec shelterai-nodered cat /data/schemas/family-schema.json | Out-File -Encoding UTF8 "$backupDir/schemas/family-schema.json"
        docker exec shelterai-nodered cat /data/schemas/assignment-schema.json | Out-File -Encoding UTF8 "$backupDir/schemas/assignment-schema.json"
    } catch {
        Write-Host "⚠️  Algunos schemas no se pudieron copiar" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Advertencia: Contenedor no corriendo, usando archivos locales" -ForegroundColor Yellow
    Copy-Item -Path "node-red-data/*" -Destination $backupDir -Recurse
}

# Backup de la base de datos
$postgresRunning = docker ps --filter "name=shelterai-postgres" --format "{{.Names}}"
if ($postgresRunning) {
    Write-Host "🗄️  Guardando base de datos PostgreSQL..." -ForegroundColor Yellow
    docker exec shelterai-postgres pg_dump -U root shelterai | Out-File -Encoding UTF8 "$backupDir/database.sql"
}

# Crear archivo de información
$backupInfo = @"
ShelterAI Backend Backup
========================
Fecha: $(Get-Date)
Usuario: $env:USERNAME
Hostname: $env:COMPUTERNAME

Contenido:
- flows.json (Node-RED flows)
- package.json (dependencias)
- settings.js (configuración)
- schemas/ (validación JSON)
- database.sql (PostgreSQL dump)

Para restaurar:
1. Copiar archivos a node-red-data/
2. Restaurar DB: Get-Content database.sql | docker exec -i shelterai-postgres psql -U root shelterai
3. Reiniciar: .\start.ps1
"@

$backupInfo | Out-File -Encoding UTF8 "$backupDir/backup_info.txt"

$size = (Get-ChildItem $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host ""
Write-Host "✅ Backup completo creado en: $backupDir" -ForegroundColor Green
Write-Host "📊 Tamaño: $([math]::Round($size, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para restaurar este backup:" -ForegroundColor Yellow
Write-Host "  .\restore.ps1 $backupDir"
