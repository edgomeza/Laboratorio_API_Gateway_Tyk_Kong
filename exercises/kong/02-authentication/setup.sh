# #!/bin/bash
# # EJERCICIO 2: Autenticación con Key-Auth - Calculadora (Divide)
# # Descomenta para activar

# # Crear Service para el microservicio de divide
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-divide \
#   --data url=http://calc-divide:8080/divide/calculadora/divide

# # Crear Route
# curl -i -X POST http://localhost:8001/services/calc-divide/routes \
#   --data 'paths[]=/calc/divide' \
#   --data strip_path=true \
#   --data name=calc-divide-route

# # Añadir plugin Key-Auth
# curl -i -X POST http://localhost:8001/services/calc-divide/plugins \
#   --data name=key-auth

# # Añadir plugin CORS
# curl -i -X POST http://localhost:8001/services/calc-divide/plugins \
#   --data name=cors \
#   --data config.origins='*' \
#   --data config.methods=GET \
#   --data config.methods=POST \
#   --data config.methods=OPTIONS \
#   --data config.headers=Accept \
#   --data config.headers=Content-Type \
#   --data config.headers=Authorization \
#   --data config.headers=apikey \
#   --data config.exposed_headers=X-Auth-Token \
#   --data config.credentials=false \
#   --data config.max_age=3600

# # Crear Consumer
# curl -i -X POST http://localhost:8001/consumers \
#   --data username=calculator-user

# # Crear API Key para el Consumer
# curl -i -X POST http://localhost:8001/consumers/calculator-user/key-auth \
#   --data key=calc-secret-key-12345

# echo ""
# echo "=============================================="
# echo "Autenticación configurada correctamente!"
# echo "=============================================="
# echo ""
# echo "API Key: calc-secret-key-12345"
# echo ""
# echo "Prueba con:"
# echo "curl -H 'apikey: calc-secret-key-12345' 'http://localhost:8000/calc/divide?a=100&b=5'"
# echo ""
# echo "Deberías ver:"
# echo '{"resultado": 20.0, "mensaje": "División realizada correctamente", "estado": "OK"}'
# echo ""
