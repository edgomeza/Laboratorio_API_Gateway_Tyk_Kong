# # ==========================================
# # EJERCICIO 5: Request/Response Transformer - Calculadora (Resta)
# # PowerShell Version
# # Descomenta el bloque <# #> para activar
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 5: Transformaciones" -ForegroundColor Cyan

# # Crear Service para el microservicio de resta
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-resta"
#         url = "http://calc-resta:8080/resta/calculadora/resta"
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
#         'paths[]' = "/calc/resta"
#         strip_path = "true"
#         name = "calc-resta-route"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Route creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Route ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin Request Transformer
# Write-Host "Añadiendo plugin Request Transformer..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "request-transformer"
#         'config.add.headers' = @("X-Gateway:Kong", "X-Service:resta")
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin Request Transformer añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin Response Transformer
# Write-Host "Añadiendo plugin Response Transformer..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "response-transformer"
#         'config.add.headers' = "X-Processed-By:Kong-Gateway"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin Response Transformer añadido" -ForegroundColor Green
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

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-resta/plugins" `
#         -Method Post `
#         -Body ($corsBody -join "&") `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin CORS añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin CORS ya existe o error al crear" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host "Transformations configuradas!" -ForegroundColor Green
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host ""
# Write-Host "Headers añadidos por REQUEST-TRANSFORMER:" -ForegroundColor Cyan
# Write-Host "   X-Gateway: Kong" -ForegroundColor White
# Write-Host "   X-Service: resta" -ForegroundColor White
# Write-Host ""
# Write-Host "Headers añadidos por RESPONSE-TRANSFORMER:" -ForegroundColor Cyan
# Write-Host "   X-Processed-By: Kong-Gateway" -ForegroundColor White
# Write-Host ""
# Write-Host "Prueba con:" -ForegroundColor Cyan
# Write-Host "   curl -i 'http://localhost:8000/calc/resta?a=100&b=35'" -ForegroundColor White
# Write-Host ""
# Write-Host "Deberías ver:" -ForegroundColor Cyan
# Write-Host "   {`"resultado`": 65.0, `"mensaje`": `"Resta realizada correctamente`", `"estado`": `"OK`"}" -ForegroundColor White
# Write-Host ""
# Write-Host "Nota: Usa -i para ver los headers" -ForegroundColor Gray
# Write-Host ""
