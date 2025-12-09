# # ==========================================
# # EJERCICIO 3: Rate Limiting - Calculadora (Multiplica)
# # PowerShell Version
# # Descomenta el bloque <# #> para activar
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 3: Rate Limiting" -ForegroundColor Cyan

# # Crear Service para el microservicio de multiplica
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-multiplica"
#         url = "http://calc-multiplica:8080/multiplica/calculadora/multiplica"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Service creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Service ya existe" -ForegroundColor Yellow
# }

# # Crear Route
# Write-Host "Creando Route..." -ForegroundColor Yellow
# try {
#     $body = @{
#         'paths[]' = "/calc/multiplica"
#         strip_path = "true"
#         name = "calc-multiplica-route"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-multiplica/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Route creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Route ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin Rate Limiting
# Write-Host "Añadiendo plugin Rate Limiting..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "rate-limiting"
#         'config.minute' = "5"
#         'config.policy' = "local"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-multiplica/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin Rate Limiting añadido (5 req/min)" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin CORS
# Write-Host "Añadiendo plugin CORS..." -ForegroundColor Yellow
# try {
#     $corsConfig = @{
#         name = "cors"
#         "config.origins" = "*"
#         "config.methods" = @("GET", "POST", "OPTIONS")
#         "config.headers" = @("Accept", "Content-Type", "Authorization", "apikey")
#         "config.exposed_headers" = "X-Auth-Token"
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

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-multiplica/plugins" `
#         -Method Post `
#         -Body ($corsBody -join "&") `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin CORS añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin CORS ya existe o error al crear" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host "Rate limiting configurado!" -ForegroundColor Green
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host ""
# Write-Host "Límite: 5 requests por 60 segundos" -ForegroundColor Cyan
# Write-Host ""
# Write-Host "Prueba con:" -ForegroundColor Cyan
# Write-Host "   curl 'http://localhost:8000/calc/multiplica?a=7&b=8'" -ForegroundColor White
# Write-Host ""
# Write-Host "Deberías ver:" -ForegroundColor Cyan
# Write-Host "   {`"resultado`": 56.0, `"mensaje`": `"Multiplicación realizada correctamente`", `"estado`": `"OK`"}" -ForegroundColor White
# Write-Host ""
