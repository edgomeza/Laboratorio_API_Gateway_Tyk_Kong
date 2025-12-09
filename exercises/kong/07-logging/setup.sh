#!/bin/bash
# EJERCICIO 7: File Log Plugin con Kong

# Crear Service
echo "Creando Service..."
curl -i -X POST http://localhost:8001/services \
  --data name=calc-resta-logged \
  --data url=http://calc-resta:8080/resta/calculadora/resta

# Crear Route
echo "Creando Route..."
curl -i -X POST http://localhost:8001/services/calc-resta-logged/routes \
  --data 'paths[]=/logged/resta' \
  --data strip_path=true \
  --data name=calc-resta-logged-route

# Añadir File Log Plugin
echo "Añadiendo File Log Plugin..."
curl -i -X POST http://localhost:8001/services/calc-resta-logged/plugins \
  --data name=file-log \
  --data config.path=/tmp/kong-resta.log

# Añadir plugin CORS
curl -i -X POST http://localhost:8001/services/calc-resta-logged/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET \
  --data config.methods=POST \
  --data config.methods=OPTIONS \
  --data config.headers=Accept \
  --data config.headers=Content-Type \
  --data config.headers=Authorization \
  --data config.credentials=false \
  --data config.max_age=3600

echo ""
echo "=============================================="
echo "✅ File Log configurado!"
echo "=============================================="
echo ""
echo "Pruebas:"
echo "  Request: curl 'http://localhost:8000/logged/resta?a=100&b=35'"
echo "  Ver logs: docker exec kong-gateway cat /tmp/kong-resta.log | jq"
echo ""
