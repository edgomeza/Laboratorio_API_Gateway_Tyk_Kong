#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         🔥 HARD RESET - API Gateway Platform 🔥           ║"
echo "║                                                            ║"
echo "║  Esto borrará COMPLETAMENTE:                               ║"
echo "║  ❌ Todas las configuraciones de Tyk                       ║"
echo "║  ❌ Todas las configuraciones de Kong                      ║"
echo "║  ❌ Base de datos de Kong                                  ║"
echo "║  ❌ Datos de Redis (Tyk)                                   ║"
echo "║  ❌ Archivos de ejercicios activados (.activated)          ║"
echo "║  ❌ Configuraciones en apps-active                         ║"
echo "║                                                            ║"
echo "║  ⚠️  ESTA ACCIÓN NO SE PUEDE DESHACER ⚠️                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Preguntar confirmación
read -p "¿Estás seguro de que quieres hacer un HARD RESET? (escribe 'SI' en mayúsculas): " confirm

if [ "$confirm" != "SI" ]; then
    echo "❌ Reset cancelado."
    exit 0
fi

echo ""
echo "🔥 Iniciando HARD RESET..."
echo ""

# 1. Detener todos los contenedores
echo "⏹️  Deteniendo contenedores..."
docker compose down

# 2. ELIMINAR VOLÚMENES (esto borra todas las bases de datos y Redis)
echo "🗑️  Eliminando volúmenes de Docker (bases de datos)..."
docker volume rm api_gateway_tyk_kong_tyk-redis-data 2>/dev/null || true
docker volume rm api_gateway_tyk_kong_kong-postgres-data 2>/dev/null || true

# También intentar con otros posibles nombres de volúmenes
docker volume rm tyk-redis-data 2>/dev/null || true
docker volume rm kong-postgres-data 2>/dev/null || true

# Listar y eliminar todos los volúmenes del proyecto
docker volume ls | grep -E "(tyk|kong)" | awk '{print $2}' | xargs -r docker volume rm 2>/dev/null || true

# 3. Limpiar carpeta apps-active de Tyk
echo "🧹 Limpiando configuraciones activas de Tyk..."
rm -f ./gateway-configs/tyk/apps-active/*.json 2>/dev/null
# Mantener solo el .gitkeep
ls ./gateway-configs/tyk/apps-active/ | grep -v ".gitkeep" | xargs -I {} rm -f ./gateway-configs/tyk/apps-active/{} 2>/dev/null

# 4. Eliminar archivos .activated de ejercicios
echo "🧹 Eliminando marcadores de ejercicios activados..."
find ./exercises -name ".activated" -type f -delete 2>/dev/null

# 5. Limpiar archivos temporales de Kong
echo "🧹 Limpiando archivos temporales de Kong..."
find ./exercises/kong -name "api-key.txt" -type f -delete 2>/dev/null

# 6. Mostrar instrucciones para borrar localStorage
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ⚠️  IMPORTANTE: Limpiar el navegador manualmente         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Para completar el reset, debes borrar el localStorage del navegador:"
echo ""
echo "1. Abre el navegador y ve a: http://localhost"
echo "2. Presiona F12 para abrir DevTools"
echo "3. Ve a la pestaña 'Console'"
echo "4. Ejecuta este comando:"
echo ""
echo "   localStorage.clear()"
echo ""
echo "5. Recarga la página (Ctrl+R o F5)"
echo ""

# 7. Reiniciar servicios
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          🚀 Reiniciando servicios desde cero...           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

docker compose up -d

echo ""
echo "⏳ Esperando a que los servicios estén listos (30 segundos)..."
sleep 30

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║               ✅ HARD RESET COMPLETADO ✅                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "El sistema está completamente limpio. Ahora puedes:"
echo ""
echo "1. ✅ Borrar localStorage del navegador (ver instrucciones arriba)"
echo "2. ✅ Iniciar el watcher: ./scripts/watch-exercises.sh"
echo "3. ✅ Abrir http://localhost en el navegador"
echo "4. ✅ Comenzar los ejercicios desde cero"
echo ""
echo "Estado de servicios:"
docker compose ps
echo ""
