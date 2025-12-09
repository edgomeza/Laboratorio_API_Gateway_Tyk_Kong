# ============================================
# HARD RESET - API Gateway Platform
# PowerShell Script para Windows
# ============================================
Write-Host ""

# Preguntar confirmación
$confirm = Read-Host "¿Estás seguro de que quieres hacer un HARD RESET? (escribe SI en mayúsculas)"

if ($confirm -ne "SI") {
    Write-Host " Reset cancelado." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host " Iniciando HARD RESET..." -ForegroundColor Yellow
Write-Host ""

# 1. Detener todos los contenedores
Write-Host "  Deteniendo contenedores..." -ForegroundColor Yellow
docker-compose down

# 2. ELIMINAR VOLÚMENES (esto borra todas las bases de datos y Redis)
Write-Host "  Eliminando volúmenes de Docker (bases de datos)..." -ForegroundColor Yellow

# Lista de posibles nombres de volúmenes
$volumeNames = @(
    "api_gateway_tyk_kong_tyk-redis-data",
    "api_gateway_tyk_kong_kong-postgres-data",
    "tyk-redis-data",
    "kong-postgres-data"
)

foreach ($volume in $volumeNames) {
    try {
        docker volume rm $volume 2>$null
        Write-Host "    Eliminado: $volume" -ForegroundColor Green
    } catch {
        # Ignorar errores si el volumen no existe
    }
}

# Eliminar todos los volúmenes que contengan "tyk" o "kong"
Write-Host "   Buscando otros volúmenes de tyk/kong..." -ForegroundColor Gray
try {
    $volumes = docker volume ls --format "{{.Name}}" | Select-String -Pattern "(tyk|kong)"
    foreach ($vol in $volumes) {
        docker volume rm $vol 2>$null
        Write-Host "    Eliminado: $vol" -ForegroundColor Green
    }
} catch {
    # Ignorar errores
}

# 3. Limpiar carpeta apps-active de Tyk
Write-Host " Limpiando configuraciones activas de Tyk..." -ForegroundColor Yellow
Get-ChildItem -Path ".\gateway-configs\tyk\apps-active\" -Filter "*.json" -File | Remove-Item -Force
Write-Host "    Archivos JSON eliminados" -ForegroundColor Green

# 4. Eliminar archivos .activated de ejercicios
Write-Host " Eliminando marcadores de ejercicios activados..." -ForegroundColor Yellow
Get-ChildItem -Path ".\exercises\" -Filter ".activated" -Recurse -File | Remove-Item -Force
Write-Host "    Marcadores .activated eliminados" -ForegroundColor Green

# 5. Limpiar archivos temporales de Kong
Write-Host " Limpiando archivos temporales de Kong..." -ForegroundColor Yellow
Get-ChildItem -Path ".\exercises\kong\" -Filter "api-key.txt" -Recurse -File | Remove-Item -Force
Write-Host "    Archivos temporales eliminados" -ForegroundColor Green

# 6. Mostrar instrucciones para borrar localStorage
Write-Host ""
Write-Host ""
Write-Host "Para completar el reset, debes borrar el localStorage del navegador:" -ForegroundColor White
Write-Host ""
Write-Host "1. Abre el navegador y ve a: http://localhost" -ForegroundColor White
Write-Host "2. Presiona F12 para abrir DevTools" -ForegroundColor White
Write-Host "3. Ve a la pestaña Console" -ForegroundColor White
Write-Host "4. Ejecuta este comando:" -ForegroundColor White
Write-Host ""
Write-Host "   localStorage.clear()" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Recarga la página (Ctrl+R o F5)" -ForegroundColor White
Write-Host ""

# 7. Reiniciar servicios
Write-Host ""

docker-compose up -d

Write-Host ""
Write-Host "Esperando a que los servicios estén listos (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host ""
Write-Host "El sistema está completamente limpio. Ahora puedes:" -ForegroundColor White
Write-Host ""
Write-Host "1.  Borrar localStorage del navegador (ver instrucciones arriba)" -ForegroundColor Green
Write-Host "2.  Iniciar el watcher: .\scripts\watch-exercises.sh" -ForegroundColor Green
Write-Host "3.  Abrir http://localhost en el navegador" -ForegroundColor Green
Write-Host "4.  Comenzar los ejercicios desde cero" -ForegroundColor Green
Write-Host ""
Write-Host "Estado de servicios:" -ForegroundColor Cyan
docker-compose ps
Write-Host ""
