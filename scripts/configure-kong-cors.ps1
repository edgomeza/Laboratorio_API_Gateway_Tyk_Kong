# ============================================
# Script para configurar CORS en Kong Gateway (PowerShell)
# ============================================

Write-Host "Configurando CORS en Kong Gateway..." -ForegroundColor Cyan
Write-Host ""

# Esperar a que Kong esté disponible
Write-Host "Esperando a que Kong esté disponible..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$kongAvailable = $false

while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8001/" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "Kong está disponible!" -ForegroundColor Green
            $kongAvailable = $true
            break
        }
    }
    catch {
        # Kong no está disponible aún
    }

    $attempt++
    Write-Host "   Intento $attempt/$maxAttempts..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

if (-not $kongAvailable) {
    Write-Host "Error: Kong no está disponible después de $maxAttempts intentos" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configurando plugin CORS global..." -ForegroundColor Cyan

# Verificar si ya existe un plugin CORS global
try {
    $pluginsResponse = Invoke-RestMethod -Uri "http://localhost:8001/plugins" -Method Get
    $existingCors = $pluginsResponse.data | Where-Object { $_.name -eq "cors" }

    if ($existingCors) {
        Write-Host "Plugin CORS global ya existe, eliminando configuración anterior..." -ForegroundColor Yellow
        foreach ($plugin in $existingCors) {
            Invoke-RestMethod -Uri "http://localhost:8001/plugins/$($plugin.id)" -Method Delete | Out-Null
        }
        Write-Host "   Plugin anterior eliminado" -ForegroundColor Gray
    }
}
catch {
    Write-Host "   No se encontraron plugins CORS anteriores" -ForegroundColor Gray
}

# Crear plugin CORS global
Write-Host "   Creando nuevo plugin CORS global..." -ForegroundColor Gray

$corsConfig = @{
    name = "cors"
    config = @{
        origins = @("*")
        methods = @("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
        headers = @(
            "Accept",
            "Accept-Version",
            "Content-Length",
            "Content-MD5",
            "Content-Type",
            "Date",
            "Authorization",
            "apikey",
            "X-Auth-Token"
        )
        exposed_headers = @(
            "X-Auth-Token",
            "X-RateLimit-Limit",
            "X-RateLimit-Remaining",
            "X-RateLimit-Reset"
        )
        credentials = $true
        max_age = 3600
        preflight_continue = $false
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8001/plugins" `
        -Method Post `
        -Body $corsConfig `
        -ContentType "application/json"

    if ($response.name -eq "cors") {
        Write-Host "Plugin CORS global configurado exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Configuración aplicada:" -ForegroundColor Cyan
        Write-Host "  • Origins: * (todos los orígenes)" -ForegroundColor White
        Write-Host "  • Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS" -ForegroundColor White
        Write-Host "  • Headers: Accept, Content-Type, Authorization, apikey, etc." -ForegroundColor White
        Write-Host "  • Credentials: true" -ForegroundColor White
        Write-Host "  • Max Age: 3600 segundos" -ForegroundColor White
    }
    else {
        Write-Host "Error: Respuesta inesperada del servidor" -ForegroundColor Red
        Write-Host ($response | ConvertTo-Json -Depth 5) -ForegroundColor Gray
        exit 1
    }
}
catch {
    Write-Host "Error al configurar CORS:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "¡CORS configurado exitosamente en Kong!" -ForegroundColor Green
Write-Host "   Ahora el frontend web puede hacer peticiones a Kong desde http://localhost" -ForegroundColor White
Write-Host ""
