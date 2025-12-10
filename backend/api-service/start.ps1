# Script de inicio para ShelterAI Backend con Node-RED
# Ejecutar con: .\start.ps1

Write-Host "🚀 Iniciando ShelterAI Backend..." -ForegroundColor Cyan

# Verificar si Docker está corriendo
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker no está corriendo" -ForegroundColor Red
    exit 1
}

# Levantar los contenedores
Write-Host "📦 Levantando contenedores..." -ForegroundColor Yellow
docker compose up -d

# Esperar a que Node-RED esté listo
Write-Host "⏳ Esperando a que Node-RED esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar estado
Write-Host "`n🔍 Verificando estado de los contenedores..." -ForegroundColor Yellow
docker compose ps

# Mostrar logs recientes
Write-Host "`n📋 Últimos logs de Node-RED:" -ForegroundColor Yellow
docker logs shelterai-nodered --tail 10

Write-Host "`n✅ Backend iniciado correctamente!" -ForegroundColor Green
Write-Host "`n🌐 Node-RED: http://localhost:1880" -ForegroundColor Cyan
Write-Host "🗄️  PostgreSQL: localhost:5432" -ForegroundColor Cyan
Write-Host "`n💡 Comandos útiles:" -ForegroundColor Yellow
Write-Host "  .\stop.ps1          - Detener los contenedores"
Write-Host "  .\sync-flows.ps1    - Sincronizar flows del contenedor"
Write-Host "  .\logs.ps1          - Ver logs en tiempo real"
Write-Host "  .\backup.ps1        - Hacer backup completo"
Write-Host ""
