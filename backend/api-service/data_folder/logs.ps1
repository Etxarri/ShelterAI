# Script para ver logs en tiempo real
# Ejecutar con: .\logs.ps1 [servicio]
# Ejemplos: .\logs.ps1
#           .\logs.ps1 nodered
#           .\logs.ps1 postgres

param(
    [string]$Service = "nodered"
)

if ($Service -eq "nodered") {
    Write-Host "📋 Logs de Node-RED (Ctrl+C para salir)..." -ForegroundColor Cyan
    docker logs shelterai-nodered -f
} elseif ($Service -eq "postgres") {
    Write-Host "📋 Logs de PostgreSQL (Ctrl+C para salir)..." -ForegroundColor Cyan
    docker logs shelterai-postgres -f
} else {
    Write-Host "📋 Logs de todos los servicios (Ctrl+C para salir)..." -ForegroundColor Cyan
    docker compose logs -f
}
