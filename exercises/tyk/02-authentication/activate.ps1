# ==========================================
# Script para activar el Ejercicio 2 - Autenticación en Tyk
# PowerShell Version
# ==========================================

Write-Host "Configurando autenticación en Tyk..." -ForegroundColor Cyan
Write-Host ""

# 2. Crear la API Key
Write-Host "Creando API Key..." -ForegroundColor Yellow
try {
    $keyData = Get-Content "key.json" -Raw
    $headers = @{
        "x-tyk-authorization" = "foo"
        "Content-Type" = "application/json"
    }

    Invoke-RestMethod -Uri "http://localhost:8080/tyk/keys/test-key-123" `
        -Method Post `
        -Headers $headers `
        -Body $keyData `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "API Key creada: test-key-123" -ForegroundColor Green
} catch {
    Write-Host "API Key ya existe o error: $_" -ForegroundColor Yellow
}

# 3. Recargar Tyk
Write-Host "Recargando Tyk Gateway..." -ForegroundColor Yellow
try {
    $headers = @{
        "x-tyk-authorization" = "foo"
    }

    Invoke-RestMethod -Uri "http://localhost:8080/tyk/reload/group" `
        -Method Get `
        -Headers $headers `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Tyk recargado" -ForegroundColor Green
} catch {
    Write-Host "Error recargando Tyk" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Autenticación configurada!" -ForegroundColor Green
Write-Host ""
Write-Host "Prueba con:" -ForegroundColor Cyan
Write-Host '   $headers = @{Authorization = "test-key-123"}' -ForegroundColor White
Write-Host '   Invoke-RestMethod -Uri "http://localhost:8080/calc/divide?a=100&b=5" -Headers $headers' -ForegroundColor White
Write-Host ""
Write-Host "Esperado:" -ForegroundColor Cyan
Write-Host '   {"resultado": 20.0, "mensaje": "Division realizada correctamente", "estado": "OK"}' -ForegroundColor White
Write-Host ""
