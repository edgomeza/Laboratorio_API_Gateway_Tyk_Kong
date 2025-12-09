#!/bin/bash

# ============================================
# Script para configurar CORS en Kong Gateway
# ============================================

echo "🌐 Configurando CORS en Kong Gateway..."
echo ""

# Esperar a que Kong esté disponible
echo "⏳ Esperando a que Kong esté disponible..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8001/ > /dev/null 2>&1; then
        echo "✅ Kong está disponible!"
        break
    fi
    attempt=$((attempt + 1))
    echo "   Intento $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Error: Kong no está disponible después de $max_attempts intentos"
    exit 1
fi

echo ""
echo "📝 Configurando plugin CORS global..."

# Verificar si ya existe un plugin CORS global
existing_cors=$(curl -s http://localhost:8001/plugins | grep -c '"name":"cors"')

if [ "$existing_cors" -gt 0 ]; then
    echo "⚠️  Plugin CORS global ya existe, eliminando configuración anterior..."
    # Obtener el ID del plugin CORS existente
    cors_id=$(curl -s http://localhost:8001/plugins | grep -B 5 '"name":"cors"' | grep '"id"' | head -1 | cut -d'"' -f4)
    if [ -n "$cors_id" ]; then
        curl -s -X DELETE http://localhost:8001/plugins/$cors_id
        echo "   Plugin anterior eliminado"
    fi
fi

# Crear plugin CORS global
echo "   Creando nuevo plugin CORS global..."
response=$(curl -s -X POST http://localhost:8001/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cors",
    "config": {
      "origins": ["*"],
      "methods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
      "headers": ["Accept", "Accept-Version", "Content-Length", "Content-MD5", "Content-Type", "Date", "Authorization", "apikey", "X-Auth-Token"],
      "exposed_headers": ["X-Auth-Token", "X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"],
      "credentials": true,
      "max_age": 3600,
      "preflight_continue": false
    }
  }')

# Verificar si la configuración fue exitosa
if echo "$response" | grep -q '"name":"cors"'; then
    echo "✅ Plugin CORS global configurado exitosamente!"
    echo ""
    echo "Configuración aplicada:"
    echo "  • Origins: * (todos los orígenes)"
    echo "  • Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS"
    echo "  • Headers: Accept, Content-Type, Authorization, apikey, etc."
    echo "  • Credentials: true"
    echo "  • Max Age: 3600 segundos"
else
    echo "❌ Error al configurar CORS. Respuesta del servidor:"
    echo "$response"
    exit 1
fi

echo ""
echo "🎉 ¡CORS configurado exitosamente en Kong!"
echo "   Ahora el frontend web puede hacer peticiones a Kong desde http://localhost"
echo ""
