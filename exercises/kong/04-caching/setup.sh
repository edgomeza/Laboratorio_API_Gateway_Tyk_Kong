# #!/bin/bash
# # EJERCICIO 4: Proxy Cache - Calculadora (Suma)
# # Descomenta para activar

# # Crear Service para el microservicio de suma
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-suma \
#   --data url=http://calc-suma:8080/suma/calculadora/suma

# # Crear Route
# curl -i -X POST http://localhost:8001/services/calc-suma/routes \
#   --data 'paths[]=/calc/suma' \
#   --data strip_path=true \
#   --data name=calc-suma-route

# # Añadir plugin Proxy Cache (60 segundo TTL)
# curl -i -X POST http://localhost:8001/services/calc-suma/plugins \
#   --data name=proxy-cache \
#   --data config.strategy=memory \
#   --data config.content_type='application/json' \
#   --data config.cache_ttl=60

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
#   --data config.headers=apikey \
#   --data config.exposed_headers=X-Auth-Token \
#   --data config.credentials=false \
#   --data config.max_age=3600

# echo ""
# echo "==========================================="
# echo "Cache configurado!"
# echo "==========================================="
# echo ""
# echo "TTL: 60 segundos"
# echo ""
# echo "Prueba con:"
# echo "curl 'http://localhost:8000/calc/suma?a=15&b=25'"
# echo ""
# echo "Deberías ver:"
# echo '{"resultado": 40.0, "mensaje": "Suma realizada correctamente", "estado": "OK"}'
# echo ""
# echo "Nota: La segunda petición será más rápida (respuesta cacheada)"
# echo ""
