# # ==========================================
# # EJERCICIO 7: File Log Plugin con Kong
# # PowerShell Version
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 7: Logging Detallado" -ForegroundColor Cyan

# # Crear Service
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-resta-logged"
#         url = "http://calc-resta:8080/resta/calculadora/resta"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Service creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Service ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Crear Route
# Write-Host "Creando Route..." -ForegroundColor Yellow
# try {
#     $body = @{
#         "paths[]" = "/logged/resta"
#         strip_path = "true"
#         name = "calc-resta-logged-route"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta-logged/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Route creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Route ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Añadir File Log Plugin
# Write-Host "Añadiendo File Log Plugin..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "file-log"
#         "config.path" = "/tmp/kong-resta.log"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta-logged/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "Plugin File Log añadido" -ForegroundColor Green
# } catch {
#     Write-Host "Plugin File Log ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Añadir plugin CORS
# Write-Host "Añadiendo plugin CORS..." -ForegroundColor Yellow
# try {
#     $corsConfig = @{
#         name = "cors"
#         "config.origins" = "*"
#         "config.methods" = @("GET", "POST", "OPTIONS")
#         "config.headers" = @("Accept", "Content-Type", "Authorization")
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

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta-logged/plugins" `
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
# Write-Host "Pruebas:" -ForegroundColor Cyan
# Write-Host "  Request: Invoke-RestMethod -Uri 'http://localhost:8000/logged/resta?a=100&b=35'" -ForegroundColor White
# Write-Host "  Ver logs: docker exec kong-gateway cat /tmp/kong-resta.log" -ForegroundColor White
# Write-Host ""
