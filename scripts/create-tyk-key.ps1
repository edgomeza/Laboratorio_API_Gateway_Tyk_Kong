# ==========================================
# Script para crear API Keys en Tyk Gateway
# PowerShell Version
# ==========================================

param(
    [string]$ApiId = "auth-api",
    [string]$TykUrl = "http://localhost:8080",
    [string]$TykSecret = "foo"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Tyk Gateway - Crear API Key" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Tyk está corriendo
Write-Host "[INFO] Verificando que Tyk está disponible..." -ForegroundColor Blue
try {
    $null = Invoke-RestMethod -Uri "$TykUrl/hello" -ErrorAction Stop
    Write-Host "[OK] Tyk está corriendo" -ForegroundColor Green
} catch {
    Write-Host "Error: Tyk no está corriendo en $TykUrl" -ForegroundColor Red
    Write-Host "Por favor, ejecuta: docker-compose up -d tyk-gateway" -ForegroundColor Yellow
    exit 1
}

# Crear API Key
Write-Host "[INFO] Creando API Key para '$ApiId'..." -ForegroundColor Blue

$headers = @{
    "x-tyk-authorization" = $TykSecret
    "Content-Type" = "application/json"
}

$body = @{
    allowance = 1000
    rate = 100
    per = 60
    expires = -1
    quota_max = -1
    org_id = "1"
    quota_renews = 1449051461
    quota_remaining = -1
    quota_renewal_rate = 60
    access_rights = @{
        $ApiId = @{
            api_id = $ApiId
            api_name = "API"
            versions = @("Default")
        }
    }
    meta_data = @{
        user_name = "test_user"
        email = "test@example.com"
        created_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "$TykUrl/tyk/keys/create" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -ErrorAction Stop

    $apiKey = $response.key

    if ($null -eq $apiKey) {
        Write-Host "Error al crear la API Key" -ForegroundColor Red
        Write-Host "Respuesta: $response" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "[OK] API Key creada exitosamente" -ForegroundColor Green

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "API Key Creada" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔑 API Key: $apiKey" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Configuración:"
    Write-Host "  - Rate Limit: 100 requests / minuto"
    Write-Host "  - Quota: Ilimitado"
    Write-Host "  - Expiration: Nunca"
    Write-Host "  - API ID: $ApiId"
    Write-Host ""
    Write-Host "🧪 Prueba la key:" -ForegroundColor Yellow
    Write-Host "  `$headers = @{Authorization = '$apiKey'}" -ForegroundColor White
    Write-Host "  Invoke-RestMethod -Uri $TykUrl/secure/health -Headers `$headers" -ForegroundColor White
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan

    # Guardar en archivo
    $keysFile = "api-keys.txt"
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
    Add-Content -Path $keysFile -Value "$timestamp - API: $ApiId - Key: $apiKey"
    Write-Host "[INFO] Key guardada en $keysFile" -ForegroundColor Blue
    Write-Host ""

} catch {
    Write-Host "Error al crear la API Key: $_" -ForegroundColor Red
    exit 1
}
