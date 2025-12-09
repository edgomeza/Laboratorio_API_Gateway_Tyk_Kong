# #!/bin/bash
# # EJERCICIO 6: API Versionada con Kong - Calculadora

# # V1 - Operaciones Básicas
# echo "Creando Service V1 (Básica)..."
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-v1 \
#   --data url=http://backend-service:3000

# echo "Creando Route V1..."
# curl -i -X POST http://localhost:8001/services/calc-v1/routes \
#   --data 'paths[]=/v1' \
#   --data strip_path=false \
#   --data name=calc-v1-route

# # V2 - Operaciones Científicas
# echo "Creando Service V2 (Científica)..."
# curl -i -X POST http://localhost:8001/services \
#   --data name=calc-v2 \
#   --data url=http://backend-service:3000

# echo "Creando Route V2..."
# curl -i -X POST http://localhost:8001/services/calc-v2/routes \
#   --data 'paths[]=/v2' \
#   --data strip_path=false \
#   --data name=calc-v2-route

# echo ""
# echo "=============================================="
# echo "✅ Versionado configurado!"
# echo "=============================================="
# echo ""
# echo "Pruebas:"
# echo "  V1 (básica): curl 'http://localhost:8000/v1/direct/suma?a=15&b=25'"
# echo "  V2 (científica): curl 'http://localhost:8000/v2/direct/raiz?n=25'"
# echo ""
