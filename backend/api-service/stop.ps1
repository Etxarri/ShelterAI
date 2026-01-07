# Script para detener los contenedores de ShelterAI
# Ejecutar con: .\stop.ps1

Write-Host "🛑 Deteniendo ShelterAI Backend..." -ForegroundColor Yellow

# Hacer backup antes de detener
Write-Host "💾 Haciendo backup de flows antes de detener..." -ForegroundColor Cyan
.\sync-flows.ps1

# Detener contenedores
docker compose down

Write-Host "✅ Contenedores detenidos correctamente" -ForegroundColor Green
