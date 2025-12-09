# # ==========================================
# # EJERCICIO 2: Autenticación con Key-Auth - Calculadora (Divide)
# # PowerShell Version
# # Descomenta el bloque <# #> para activar
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 2: Autenticación" -ForegroundColor Cyan
# Write-Host ""

# $API_KEY = "calc-secret-key-12345"
# Write-Host "API Key: $API_KEY" -ForegroundColor Yellow
# Write-Host ""

# # Crear Service para el microservicio de divide
# Write-Host "Creando Service..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-divide"
#         url = "http://calc-divide:8080/divide/calculadora/divide"
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
# Write-Host ""
# Write-Host "Creando Route..." -ForegroundColor Yellow
# try {
#     $body = @{
#         "paths[]" = "/calc/divide"
#         strip_path = "true"
#         name = "calc-divide-route"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-divide/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Route creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Route ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin Key-Auth
# Write-Host ""
# Write-Host "Añadiendo plugin Key-Auth..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "key-auth"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-divide/plugins" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin Key-Auth añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin ya existe" -ForegroundColor Yellow
# }

# # Añadir plugin CORS
# Write-Host ""
# Write-Host "Añadiendo plugin CORS..." -ForegroundColor Yellow
# try {
#     # Crear el plugin CORS
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

#     Invoke-RestMethod -Uri "http://localhost:8001/services/calc-divide/plugins" `
#         -Method Post `
#         -Body ($corsBody -join "&") `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Plugin CORS añadido" -ForegroundColor Green
# } catch {
#     Write-Host "   Plugin CORS ya existe o error al crear" -ForegroundColor Yellow
# }

# # Crear Consumer
# Write-Host ""
# Write-Host "Creando Consumer..." -ForegroundColor Yellow
# try {
#     $body = @{
#         username = "calculator-user"
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/consumers" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   Consumer creado" -ForegroundColor Green
# } catch {
#     Write-Host "   Consumer ya existe" -ForegroundColor Yellow
# }

# # Crear API Key
# Write-Host ""
# Write-Host "Creando API Key para el Consumer..." -ForegroundColor Yellow
# try {
#     $body = @{
#         key = $API_KEY
#     }

#     Invoke-RestMethod -Uri "http://localhost:8001/consumers/calculator-user/key-auth" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded" | Out-Null

#     Write-Host "   API Key creada" -ForegroundColor Green
# } catch {
#     Write-Host "   API Key ya existe" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "==============================================" -ForegroundColor Green
# Write-Host "Autenticación configurada correctamente!" -ForegroundColor Green
# Write-Host "==============================================" -ForegroundColor Green
# Write-Host ""
# Write-Host "API Key: " -NoNewline -ForegroundColor Cyan
# Write-Host $API_KEY -ForegroundColor Yellow
# Write-Host ""
# Write-Host "Prueba con:" -ForegroundColor Cyan
# Write-Host "   curl -H 'apikey: $API_KEY' 'http://localhost:8000/calc/divide?a=100&b=5'" -ForegroundColor White
# Write-Host ""
# Write-Host "Deberías ver:" -ForegroundColor Cyan
# Write-Host "   {`"resultado`": 20.0, `"mensaje`": `"División realizada correctamente`", `"estado`": `"OK`"}" -ForegroundColor White
# Write-Host ""
