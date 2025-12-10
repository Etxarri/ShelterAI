# Script de inicio para ShelterAI Backend con Node-RED
# Ejecutar con: .\start.ps1

Write-Host ">> Iniciando ShelterAI Backend..." -ForegroundColor Cyan

# Verificar si Docker esta corriendo
try {
    docker info | Out-Null
} catch {
    Write-Host "ERROR: Docker no esta corriendo" -ForegroundColor Red
    Write-Host "Por favor, inicia Docker Desktop y vuelve a intentarlo" -ForegroundColor Yellow
    exit 1
}

# Levantar los contenedores
Write-Host ">> Levantando contenedores..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudieron iniciar los contenedores" -ForegroundColor Red
    exit 1
}

# Esperar a que Node-RED este listo
Write-Host ">> Esperando a que Node-RED este listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar estado
Write-Host ""
Write-Host ">> Verificando estado de los contenedores..." -ForegroundColor Yellow
docker compose ps

# Mostrar logs recientes
Write-Host ""
Write-Host ">> Ultimos logs de Node-RED:" -ForegroundColor Yellow
docker logs shelterai-nodered --tail 10 2>$null

Write-Host ""
Write-Host "OK - Backend iniciado correctamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Node-RED:   http://localhost:1880" -ForegroundColor Cyan
Write-Host "PostgreSQL: localhost:5432" -ForegroundColor Cyan
Write-Host ""
Write-Host "Comandos utiles:" -ForegroundColor Yellow
Write-Host "  .\stop.ps1          - Detener los contenedores"
Write-Host "  .\sync-flows.ps1    - Sincronizar flows del contenedor"
Write-Host "  .\logs.ps1          - Ver logs en tiempo real"
Write-Host "  .\backup.ps1        - Hacer backup completo"
Write-Host ""
