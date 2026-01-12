# Script para restaurar un backup
# Ejecutar con: .\restore.ps1 <directorio_backup>

param(
    [string]$BackupDir
)

if (-not $BackupDir) {
    Write-Host "❌ Error: Debes especificar el directorio de backup" -ForegroundColor Red
    Write-Host "Uso: .\restore.ps1 backups\backup_YYYYMMDD_HHMMSS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Backups disponibles:" -ForegroundColor Cyan
    Get-ChildItem backups -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | Format-Table Name, LastWriteTime
    exit 1
}

if (-not (Test-Path $BackupDir)) {
    Write-Host "❌ Error: El directorio $BackupDir no existe" -ForegroundColor Red
    exit 1
}

Write-Host "🔄 Restaurando backup desde: $BackupDir" -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "⚠️  Esto sobrescribirá los datos actuales. ¿Continuar? (s/n)"
if ($confirm -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# Detener contenedores
Write-Host "🛑 Deteniendo contenedores..." -ForegroundColor Yellow
docker compose down

# Restaurar archivos
Write-Host "📄 Restaurando archivos de Node-RED..." -ForegroundColor Yellow
Copy-Item "$BackupDir/flows.json" "node-red-data/flows.json" -Force
if (Test-Path "$BackupDir/package.json") {
    Copy-Item "$BackupDir/package.json" "node-red-data/package.json" -Force
}
if (Test-Path "$BackupDir/settings.js") {
    Copy-Item "$BackupDir/settings.js" "node-red-data/settings.js" -Force
}

if (Test-Path "$BackupDir/schemas") {
    if (-not (Test-Path "node-red-data/schemas")) {
        New-Item -ItemType Directory -Path "node-red-data/schemas" -Force | Out-Null
    }
    Copy-Item "$BackupDir/schemas/*" "node-red-data/schemas/" -Force -Recurse
}

# Iniciar contenedores
Write-Host "🚀 Iniciando contenedores..." -ForegroundColor Yellow
docker compose up -d

# Esperar a que PostgreSQL esté listo
Write-Host "⏳ Esperando a PostgreSQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Restaurar base de datos si existe
if (Test-Path "$BackupDir/database.sql") {
    Write-Host "🗄️  Restaurando base de datos..." -ForegroundColor Yellow
    Get-Content "$BackupDir/database.sql" | docker exec -i shelterai-postgres psql -U root shelterai
}

Write-Host ""
Write-Host "✅ Restauración completada!" -ForegroundColor Green
Write-Host "🌐 Node-RED: http://localhost:1880" -ForegroundColor Cyan
