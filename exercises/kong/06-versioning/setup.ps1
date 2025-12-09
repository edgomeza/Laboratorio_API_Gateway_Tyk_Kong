# # ==========================================
# # EJERCICIO 6: API Versionada con Kong - Calculadora
# # PowerShell Version
# # ==========================================

# Write-Host "Configurando Kong - Ejercicio 6: API Versionada" -ForegroundColor Cyan

# # V1 - Operaciones Básicas
# Write-Host "Creando Service V1 (Básica)..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-v1"
#         url = "http://backend-service:3000"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Service V1 creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Service V1 ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Route V1
# Write-Host "Creando Route V1..." -ForegroundColor Yellow
# try {
#     $body = @{
#         "paths[]" = "/v1"
#         strip_path = "false"
#         name = "calc-v1-route"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services/calc-v1/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Route V1 creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Route V1 ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # V2 - Operaciones Científicas
# Write-Host "Creando Service V2 (Científica)..." -ForegroundColor Yellow
# try {
#     $body = @{
#         name = "calc-v2"
#         url = "http://backend-service:3000"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Service V2 creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Service V2 ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# # Route V2
# Write-Host "Creando Route V2..." -ForegroundColor Yellow
# try {
#     $body = @{
#         "paths[]" = "/v2"
#         strip_path = "false"
#         name = "calc-v2-route"
#     }

#     $response = Invoke-RestMethod -Uri "http://localhost:8001/services/calc-v2/routes" `
#         -Method Post `
#         -Body $body `
#         -ContentType "application/x-www-form-urlencoded"

#     Write-Host "Route V2 creado: $($response.name)" -ForegroundColor Green
# } catch {
#     Write-Host "Route V2 ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
# }

# Write-Host ""
# Write-Host "Configuración completada!" -ForegroundColor Green
# Write-Host ""
# Write-Host "Pruebas:" -ForegroundColor Cyan
# Write-Host "  V1 (básica): Invoke-RestMethod -Uri 'http://localhost:8000/v1/direct/suma?a=15&b=25'" -ForegroundColor White
# Write-Host "  V2 (científica): Invoke-RestMethod -Uri 'http://localhost:8000/v2/direct/raiz?n=25'" -ForegroundColor White
# Write-Host ""
