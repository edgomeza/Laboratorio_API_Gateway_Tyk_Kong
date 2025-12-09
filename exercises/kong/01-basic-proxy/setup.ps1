# # ==========================================
# # EJERCICIO 1: Proxy Básico con Kong - Calculadora
# # PowerShell Version
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 1: Proxy Básico" -ForegroundColor Cyan

# # Crear el Service para el microservicio de suma
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-suma"
#         url = "http://calc-suma:8080/suma/calculadora/suma"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Service creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Service ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Crear el Route
# Write-Host "Creando Route..." -ForegroundColor Yellow
# try {
#     $body = @{
#         "paths[]" = "/calc/suma"
#         strip_path = "true"
#         name = "calc-suma-route"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services/calc-suma/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Route creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Route ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Añadir plugin CORS
# Write-Host "Añadiendo plugin CORS..." -ForegroundColor Yellow
# try {
#     $corsConfig = @{
#         name = "cors"
#         "config.origins" = "*"
#         "config.methods" = @("GET", "POST", "OPTIONS")
#         "config.headers" = @("Accept", "Content-Type", "Authorization")
#         "config.exposed_headers" = "X-Gateway"
#         "config.credentials" = "false"
#         "config.max_age" = "3600"
#     }

#     $corsBody = @()
#     foreach ($key in $corsConfig.Keys) {
#         if ($corsConfig[$key] -is [array]) {
#             foreach ($value in $corsConfig[$key]) {
#                 $corsBody += "$key=$value"
#             }
#         } else {
#             $corsBody += "$key=$($corsConfig[$key])"
#         }
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-suma/plugins" `
#         -Method Post `
#         -Body ($corsBody -join "&") `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "Plugin CORS añadido" -ForegroundColor Green
# } catch {
#     Write-Host "Plugin CORS ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "Configuración completada!" -ForegroundColor Green
# Write-Host ""
# Write-Host "Prueba con:" -ForegroundColor Cyan
# Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8000/calc/suma?a=15&b=25'" -ForegroundColor White
# Write-Host ""
# Write-Host "Deberías ver:" -ForegroundColor Cyan
# Write-Host "   {`"resultado`": 40.0, `"mensaje`": `"Suma realizada correctamente`", `"estado`": `"OK`"}" -ForegroundColor White
# Write-Host ""