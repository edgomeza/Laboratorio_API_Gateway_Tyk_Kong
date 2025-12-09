# ========================================================================
# PRUEBAS DE SERVICIOS - POWERSHELL EN WINDOWS - URLs CORRECTAS
# ========================================================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "PRUEBAS DE SERVICIOS - CALCULADORA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# ========================================================================
# 1. PRUEBAS DE SERVICIOS INDIVIDUALES
# ========================================================================

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "1. PRUEBAS DE SERVICIOS INDIVIDUALES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# 1.1 SUMA
Write-Host "[1.1] SUMA: 10 + 5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=10&b=5" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 1.2 RESTA
Write-Host "[1.2] RESTA: 20 - 8" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/resta/calculadora/resta?a=20&b=8" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 1.3 MULTIPLICA
Write-Host "[1.3] MULTIPLICA: 7 * 6" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/multiplica/calculadora/multiplica?a=7&b=6" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 1.4 DIVIDE
Write-Host "[1.4] DIVIDE: 100 / 5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/divide/calculadora/divide?a=100&b=5" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 1.5 DIVIDE ERROR (Fallback)
Write-Host "[1.5] DIVIDE ERROR: 100 / 0 (Fallback)" -ForegroundColor Red
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/divide/calculadora/divide?a=100&b=0" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""
Write-Host ""

# ========================================================================
# 2. PRUEBAS A TRAVÉS DE CALCULADORA
# ========================================================================

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "2. PRUEBAS A TRAVÉS DE CALCULADORA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# 2.1 CALCULADORA SUMA
Write-Host "[2.1] CALCULADORA SUMA: 15 + 25" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/calculadora/calc/suma?a=15&b=25" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 2.2 CALCULADORA RESTA
Write-Host "[2.2] CALCULADORA RESTA: 50 - 12" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/calculadora/calc/resta?a=50&b=12" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 2.3 CALCULADORA MULTIPLICA
Write-Host "[2.3] CALCULADORA MULTIPLICA: 9 * 8" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/calculadora/calc/multiplica?a=9&b=8" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 2.4 CALCULADORA DIVIDE
Write-Host "[2.4] CALCULADORA DIVIDE: 144 / 12" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/calculadora/calc/divide?a=144&b=12" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 2.5 CALCULADORA DIVIDE DECIMALES
Write-Host "[2.5] CALCULADORA DIVIDE: 100 / 3 (decimales)" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/calculadora/calc/divide?a=100&b=3" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""
Write-Host ""

# ========================================================================
# 3. PRUEBAS CON DIFERENTES FORMATOS
# ========================================================================

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "3. PRUEBAS CON DIFERENTES FORMATOS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# 3.1 JSON
Write-Host "[3.1] JSON - SUMA: 10 + 5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=10&b=5" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 3.2 XML
Write-Host "[3.2] XML - SUMA: 10 + 5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=10&b=5" -Headers @{"Accept"="application/xml"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""
Write-Host ""

# ========================================================================
# 4. PRUEBAS DE CASOS ESPECIALES
# ========================================================================

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "4. PRUEBAS DE CASOS ESPECIALES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# 4.1 Números negativos
Write-Host "[4.1] Números negativos - SUMA: -5 + (-10)" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=-5&b=-10" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 4.2 Números decimales
Write-Host "[4.2] Números decimales - MULTIPLICA: 3.5 * 2.5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/multiplica/calculadora/multiplica?a=3.5&b=2.5" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 4.3 Números grandes
Write-Host "[4.3] Números grandes - SUMA: 999999 + 1" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=999999&b=1" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""

# 4.4 Cero
Write-Host "[4.4] Cero - DIVIDE: 0 / 5" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/divide/calculadora/divide?a=0&b=5" -Headers @{"Accept"="application/json"} -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
Write-Host ""
Write-Host ""

# ========================================================================
# 5. RESUMEN
# ========================================================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs de los servicios:" -ForegroundColor Yellow
Write-Host "  Suma:       http://localhost:8080/suma/calculadora/suma" -ForegroundColor Gray
Write-Host "  Resta:      http://localhost:8080/resta/calculadora/resta" -ForegroundColor Gray
Write-Host "  Multiplica: http://localhost:8080/multiplica/calculadora/multiplica" -ForegroundColor Gray
Write-Host "  Divide:     http://localhost:8080/divide/calculadora/divide" -ForegroundColor Gray
Write-Host ""
Write-Host "URLs de Calculadora (orquestador):" -ForegroundColor Yellow
Write-Host "  Suma:       http://localhost:8080/calculadora/calc/suma" -ForegroundColor Gray
Write-Host "  Resta:      http://localhost:8080/calculadora/calc/resta" -ForegroundColor Gray
Write-Host "  Multiplica: http://localhost:8080/calculadora/calc/multiplica" -ForegroundColor Gray
Write-Host "  Divide:     http://localhost:8080/calculadora/calc/divide" -ForegroundColor Gray
Write-Host ""
Write-Host "Dashboard Wildfly: http://localhost:8080/" -ForegroundColor Yellow
Write-Host ""