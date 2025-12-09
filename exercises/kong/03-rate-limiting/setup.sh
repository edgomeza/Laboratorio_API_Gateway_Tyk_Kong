# #!/bin/bash
# # EJERCICIO 3: Rate Limiting - Calculadora (Multiplica)
# # Descomenta para activar

# # Crear Service para el microservicio de multiplica
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-multiplica \
#   --data url=http://calc-multiplica:8080/multiplica/calculadora/multiplica

# # Crear Route
# curl -i -X POST http://localhost:8001/services/calc-multiplica/routes \
#   --data 'paths[]=/calc/multiplica' \
#   --data strip_path=true \
#   --data name=calc-multiplica-route

# # Añadir plugin Rate Limiting (5 requests per 60 seconds)
# curl -i -X POST http://localhost:8001/services/calc-multiplica/plugins \
#   --data name=rate-limiting \
#   --data config.minute=5 \
#   --data config.policy=local

# # Añadir plugin CORS
# curl -i -X POST http://localhost:8001/services/calc-multiplica/plugins \
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

# echo ""
# echo "==========================================="
# echo "Rate limiting configurado!"
# echo "==========================================="
# echo ""
# echo "Límite: 5 requests por 60 segundos"
# echo ""
# echo "Prueba con:"
# echo "curl 'http://localhost:8000/calc/multiplica?a=7&b=8'"
# echo ""
# echo "Deberías ver:"
# echo '{"resultado": 56.0, "mensaje": "Multiplicación realizada correctamente", "estado": "OK"}'
# echo ""
