# Script de prueba rápida para notificación de login de refugiados
# Ejecutar desde: backend/api-service/

Write-Host "🧪 Probando notificación de login de refugiado..." -ForegroundColor Cyan

$loginPayload = @{
    email = "refugiado@test.com"
    password = "pass456"
} | ConvertTo-Json

Write-Host "`n📤 Enviando request POST /api/login..." -ForegroundColor Yellow
Write-Host "Email: refugiado@test.com" -ForegroundColor Gray
Write-Host "Password: pass456" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:1880/api/login" `
                                   -Method Post `
                                   -Body $loginPayload `
                                   -ContentType "application/json"
    
    Write-Host "`n✅ Login exitoso!" -ForegroundColor Green
    Write-Host "User ID: $($response.user_id)" -ForegroundColor White
    Write-Host "Nombre: $($response.name)" -ForegroundColor White
    Write-Host "Role: $($response.role)" -ForegroundColor White
    Write-Host "Token: $($response.token)" -ForegroundColor White
    
    if ($response.role -eq "refugee") {
        Write-Host "`n📧 Se debería enviar email de notificación a: $($response.email)" -ForegroundColor Magenta
        Write-Host "⏳ Verifica la bandeja de entrada en unos segundos..." -ForegroundColor Yellow
    } else {
        Write-Host "`n⚠️  Role es '$($response.role)', no se enviará email" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ Error en el login:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Message -like "*No se pudo conectar*") {
        Write-Host "`n💡 Tip: Asegúrate de que Node-RED esté ejecutándose:" -ForegroundColor Yellow
        Write-Host "   docker ps | findstr nodered" -ForegroundColor Gray
    }
}

Write-Host "`n---" -ForegroundColor Gray
Write-Host "Para probar con trabajador (NO debe enviar email):" -ForegroundColor Cyan
Write-Host '  $payload = @{ email = "trabajador@test.com"; password = "pass123" } | ConvertTo-Json' -ForegroundColor Gray
Write-Host '  Invoke-RestMethod -Uri "http://localhost:1880/api/login" -Method Post -Body $payload -ContentType "application/json"' -ForegroundColor Gray
