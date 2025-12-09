# ========================================================================
# SCRIPT: Compilar y Desplegar Calculadora con Maven en Wildfly
# Sistema: Windows PowerShell
# ========================================================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "CALCULADORA MICROSERVICIOS - MAVEN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$servicios = @("suma", "resta", "multiplica", "divide", "calculadora")
$total = $servicios.Count
$actual = 1

foreach ($servicio in $servicios) {
    Write-Host "[$actual/$total] Compilando $servicio..." -ForegroundColor Cyan
    cd $servicio
    mvn clean package -DskipTests
    
    Write-Host "[$actual/$total] Desplegando $servicio..." -ForegroundColor Cyan
    mvn wildfly:deploy
    
    Write-Host "OK: $servicio desplegado correctamente" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 3
    
    cd ..
    $actual++
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "OK: TODOS LOS SERVICIOS DESPLEGADOS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "URLs disponibles:" -ForegroundColor Yellow
Write-Host "  Dashboard Wildfly: http://localhost:8080/" -ForegroundColor Gray
Write-Host "  Suma: http://localhost:8080/suma/calculadora/suma" -ForegroundColor Gray
Write-Host "  Resta: http://localhost:8080/resta/calculadora/resta" -ForegroundColor Gray
Write-Host "  Multiplica: http://localhost:8080/multiplica/calculadora/multiplica" -ForegroundColor Gray
Write-Host "  Divide: http://localhost:8080/divide/calculadora/divide" -ForegroundColor Gray
Write-Host "  Calculadora: http://localhost:8080/calculadora/calc" -ForegroundColor Gray
Write-Host ""

Write-Host "Esperando 15 segundos para que se registren todos los servicios..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "Listo! Ahora puedes ejecutar las pruebas:" -ForegroundColor Cyan
Write-Host "  .\pruebas.ps1" -ForegroundColor Cyan
Write-Host ""