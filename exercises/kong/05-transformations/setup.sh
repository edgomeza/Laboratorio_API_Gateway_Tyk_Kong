# #!/bin/bash
# # EJERCICIO 5: Request/Response Transformer - Calculadora (Resta)
# # Descomenta para activar

# # Crear Service para el microservicio de resta
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-resta \
#   --data url=http://calc-resta:8080/resta/calculadora/resta

# # Crear Route
# curl -i -X POST http://localhost:8001/services/calc-resta/routes \
#   --data 'paths[]=/calc/resta' \
#   --data strip_path=true \
#   --data name=calc-resta-route

# # Añadir plugin Request Transformer
# curl -i -X POST http://localhost:8001/services/calc-resta/plugins \
#   --data name=request-transformer \
#   --data 'config.add.headers=X-Gateway:Kong' \
#   --data 'config.add.headers=X-Service:resta'

# # Añadir plugin Response Transformer
# curl -i -X POST http://localhost:8001/services/calc-resta/plugins \
#   --data name=response-transformer \
#   --data 'config.add.headers=X-Processed-By:Kong-Gateway'

# # Añadir plugin CORS
# curl -i -X POST http://localhost:8001/services/calc-resta/plugins \
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
# echo "=========================================================="
# echo "Request/Response Transformations configuradas!"
# echo "=========================================================="
# echo ""
# echo "Headers añadidos por REQUEST-TRANSFORMER:"
# echo "  - X-Gateway: Kong"
# echo "  - X-Service: resta"
# echo ""
# echo "Headers añadidos por RESPONSE-TRANSFORMER:"
# echo "  - X-Processed-By: Kong-Gateway"
# echo ""
# echo "Prueba con:"
# echo "curl -i 'http://localhost:8000/calc/resta?a=100&b=35'"
# echo ""
# echo "Deberías ver:"
# echo '{"resultado": 65.0, "mensaje": "Resta realizada correctamente", "estado": "OK"}'
# echo ""
# echo "Nota: Usa -i para ver los headers"
# echo ""
