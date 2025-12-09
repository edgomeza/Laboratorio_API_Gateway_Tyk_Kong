#!/bin/bash
# Script para activar el Ejercicio 2 - Autenticación en Tyk

echo "🔑 Configurando autenticación en Tyk..."

# 1. Copiar la configuración de la API
echo "📁 Copiando configuración de API..."
cp config.json ../../gateway-configs/tyk/apps-active/02-auth-config.json

# 2. Crear la API Key
echo "🔐 Creando API Key..."
curl -s -X POST http://localhost:8080/tyk/keys/test-key-123 \
  -H "x-tyk-authorization: foo" \
  -H "Content-Type: application/json" \
  -d @key.json

# 3. Recargar Tyk
echo "🔄 Recargando Tyk Gateway..."
curl -s -H "x-tyk-authorization: foo" \
  -X GET "http://localhost:8080/tyk/reload/group"

echo ""
echo "✅ Autenticación configurada!"
echo ""
echo "🧪 Prueba con:"
echo "curl -H 'Authorization: test-key-123' \"http://localhost:8080/calc/divide?a=100&b=5\""
echo ""
echo "Esperado:"
echo '{"resultado": 20.0, "mensaje": "Division realizada correctamente", "estado": "OK"}'
echo ""
