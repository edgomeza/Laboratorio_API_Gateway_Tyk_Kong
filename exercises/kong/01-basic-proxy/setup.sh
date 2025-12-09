# #!/bin/bash
# # EJERCICIO 1: Proxy Básico con Kong - Calculadora
# # Descomenta todas las líneas (elimina los #) para activar este ejercicio

# # Crear el Service para el microservicio de suma
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-suma \
#   --data url=http://calc-suma:8080/suma/calculadora/suma

# # Crear el Route
# curl -i -X POST http://localhost:8001/services/calc-suma/routes \
#   --data 'paths[]=/calc/suma' \
#   --data strip_path=true \
#   --data name=calc-suma-route

# # Añadir plugin CORS
# curl -i -X POST http://localhost:8001/services/calc-suma/plugins \
#   --data name=cors \
#   --data config.origins='*' \
#   --data config.methods=GET \
#   --data config.methods=POST \
#   --data config.methods=OPTIONS \
#   --data config.headers=Accept \
#   --data config.headers=Content-Type \
#   --data config.headers=Authorization \
#   --data config.exposed_headers=X-Gateway \
#   --data config.credentials=false \
#   --data config.max_age=3600

# # Verificar configuración
# echo "✅ Service y Route creados para el microservicio de SUMA!"
# echo ""
# echo "Prueba con:"
# echo "curl \"http://localhost:8000/calc/suma?a=15&b=25\""
# echo ""
# echo "Deberías ver:"
# echo '{"resultado": 40.0, "mensaje": "Suma realizada correctamente", "estado": "OK"}'
