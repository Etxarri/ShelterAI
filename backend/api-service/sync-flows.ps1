# Script para sincronizar flows desde el contenedor
# Ejecutar con: .\sync-flows.ps1

Write-Host "🔄 Sincronizando flows desde el contenedor..." -ForegroundColor Cyan

# Verificar que el contenedor esté corriendo
$running = docker ps --filter "name=shelterai-nodered" --format "{{.Names}}"
if (-not $running) {
    Write-Host "❌ Error: El contenedor shelterai-nodered no está corriendo" -ForegroundColor Red
    Write-Host "   Ejecuta .\start.ps1 primero" -ForegroundColor Yellow
    exit 1
}

# Crear backup del flows.json actual
if (Test-Path "node-red-data/flows.json") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = "backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
    Copy-Item "node-red-data/flows.json" "$backupDir/flows_$timestamp.json"
    Write-Host "📦 Backup creado: backups/flows_$timestamp.json" -ForegroundColor Green
}

# Sincronizar flows
docker exec shelterai-nodered cat /data/flows.json | Out-File -Encoding UTF8 node-red-data/flows.json

# Sincronizar schemas también
try {
    docker exec shelterai-nodered cat /data/schemas/shelter-schema.json | Out-File -Encoding UTF8 node-red-data/schemas/shelter-schema.json
    docker exec shelterai-nodered cat /data/schemas/refugee-schema.json | Out-File -Encoding UTF8 node-red-data/schemas/refugee-schema.json
    docker exec shelterai-nodered cat /data/schemas/family-schema.json | Out-File -Encoding UTF8 node-red-data/schemas/family-schema.json
    docker exec shelterai-nodered cat /data/schemas/assignment-schema.json | Out-File -Encoding UTF8 node-red-data/schemas/assignment-schema.json
} catch {
    # Ignorar errores si los schemas no existen todavía
}

Write-Host "✅ Flows sincronizados correctamente" -ForegroundColor Green
Write-Host "📁 Archivo actualizado: node-red-data/flows.json" -ForegroundColor Cyan
