# # ==========================================
# # EJERCICIO 4: Proxy Cache - Calculadora (Suma)
# # PowerShell Version
# # Descomenta el bloque <# #> para activar
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 4: Proxy Cache" -ForegroundColor Cyan

# # Crear Service para el microservicio de suma
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-suma"
#         url = "http://calc-suma:8080/suma/calculadora/suma"
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
#         'paths[]' = "/calc/suma"
#         strip_path = "true"
#         name = "calc-suma-route"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-suma/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Route creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Route ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin Proxy Cache
# Write-Host "Añadiendo plugin Proxy Cache..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "proxy-cache"
#         'config.strategy' = "memory"
#         'config.content_type' = "application/json"
#         'config.cache_ttl' = "60"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-suma/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin Proxy Cache añadido (TTL: 60s)" -ForegroundColor Green
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

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-suma/plugins" `
#         -Method Post `
#         -Body ($corsBody -join "&") `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin CORS añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin CORS ya existe o error al crear" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host "Cache configurado!" -ForegroundColor Green
# Write-Host "==========================================" -ForegroundColor Green
# Write-Host ""
# Write-Host "TTL: 60 segundos" -ForegroundColor Cyan
# Write-Host ""
# Write-Host "Prueba con:" -ForegroundColor Cyan
# Write-Host "   curl 'http://localhost:8000/calc/suma?a=15&b=25'" -ForegroundColor White
# Write-Host ""
# Write-Host "Deberías ver:" -ForegroundColor Cyan
# Write-Host "   {`"resultado`": 40.0, `"mensaje`": `"Suma realizada correctamente`", `"estado`": `"OK`"}" -ForegroundColor White
# Write-Host ""
# Write-Host "Nota: La segunda petición será más rápida (respuesta cacheada)" -ForegroundColor Gray
# Write-Host ""
