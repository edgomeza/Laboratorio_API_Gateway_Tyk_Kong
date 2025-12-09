#!/bin/bash

# Script para crear API Keys en Tyk Gateway
# Compatible con Windows (Git Bash), Linux y macOS

set -e

echo "========================================="
echo "Tyk Gateway - Crear API Key"
echo "========================================="
echo ""

# Configuración
TYK_URL=${TYK_URL:-"http://localhost:8080"}
TYK_SECRET=${TYK_SECRET:-"foo"}
API_ID=${1:-"auth-api"}

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Verificar argumentos
if [ -z "$API_ID" ]; then
    echo "Uso: $0 [API_ID]"
    echo "Ejemplo: $0 auth-api"
    exit 1
fi

# Verificar que Tyk está corriendo
log_info "Verificando que Tyk está disponible..."
if ! curl -s "$TYK_URL/hello" > /dev/null; then
    echo "Error: Tyk no está corriendo en $TYK_URL"
    echo "Por favor, ejecuta: docker-compose up -d tyk-gateway"
    exit 1
fi
log_success "Tyk está corriendo"

# Crear API Key
log_info "Creando API Key para '$API_ID'..."

RESPONSE=$(curl -s -X POST "$TYK_URL/tyk/keys/create" \
  -H "x-tyk-authorization: $TYK_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "allowance": 1000,
    "rate": 100,
    "per": 60,
    "expires": -1,
    "quota_max": -1,
    "org_id": "1",
    "quota_renews": 1449051461,
    "quota_remaining": -1,
    "quota_renewal_rate": 60,
    "access_rights": {
      "'"$API_ID"'": {
        "api_id": "'"$API_ID"'",
        "api_name": "API",
        "versions": ["Default"]
      }
    },
    "meta_data": {
      "user_name": "test_user",
      "email": "test@example.com",
      "created_at": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"
    }
  }')

# Extraer la key de la respuesta
API_KEY=$(echo "$RESPONSE" | grep -o '"key":"[^"]*' | cut -d'"' -f4)

if [ -z "$API_KEY" ]; then
    echo "Error al crear la API Key"
    echo "Respuesta: $RESPONSE"
    exit 1
fi

log_success "API Key creada exitosamente"

echo ""
echo "========================================="
echo "API Key Creada"
echo "========================================="
echo ""
echo "🔑 API Key: $API_KEY"
echo ""
echo "📊 Configuración:"
echo "  - Rate Limit: 100 requests / minuto"
echo "  - Quota: Ilimitado"
echo "  - Expiration: Nunca"
echo "  - API ID: $API_ID"
echo ""
echo "🧪 Prueba la key:"
echo "  curl -H \"Authorization: $API_KEY\" $TYK_URL/secure/health"
echo ""
echo "========================================="

# Guardar en archivo
KEYS_FILE="api-keys.txt"
echo "$(date -u +"%Y-%m-%d %H:%M:%S UTC") - API: $API_ID - Key: $API_KEY" >> "$KEYS_FILE"
log_info "Key guardada en $KEYS_FILE"
