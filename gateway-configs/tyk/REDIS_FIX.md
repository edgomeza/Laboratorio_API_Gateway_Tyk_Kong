# Solución: Error de Conexión de Tyk a Redis

## Problema
Tyk Gateway mostraba errores de conexión a Redis:
```
level=error msg="cannot set key in pollerCacheKey" error="storage: Redis is either down or was not configured"
level=error msg="Connection to Redis failed, reconnect in 10s"
```

## Causa
Aunque Redis estaba configurado correctamente, Tyk intentaba conectarse antes de que Redis estuviera completamente listo para aceptar conexiones. Esto es un **problema de timing** en el inicio de contenedores.

## Solución Implementada

### 1. Script de Espera (`wait-for-redis.sh`)
Creado un script que:
- Verifica que Redis esté accesible antes de iniciar Tyk
- Intenta conectarse hasta 30 veces con intervalos de 2 segundos
- Solo inicia Tyk Gateway cuando Redis está confirmadamente disponible

### 2. Modificación de `docker-compose.yml`
- Agregado `command: ["/opt/tyk-gateway/wait-for-redis.sh"]` para usar el script de inicio
- Montado el script como volumen en el contenedor
- Agregado `start_period: 40s` al healthcheck para dar más tiempo de inicio

## Cómo Probar

### 1. Reiniciar los servicios
```bash
docker-compose down
docker-compose up -d tyk-redis
# Esperar 5 segundos
docker-compose up -d tyk-gateway
```

### 2. Verificar logs
```bash
docker logs tyk-gateway --tail 50
```

Deberías ver:
```
Waiting for Redis at tyk-redis:6379...
Redis is ready!
Starting Tyk Gateway...
Tyk API Gateway 5.2.6
```

**NO deberías ver** errores de Redis como:
```
❌ error="storage: Redis is either down or was not configured"
```

### 3. Verificar que todo funciona
```bash
# Test de health check
curl http://localhost:8080/hello

# Test de API
curl http://localhost:8080/calc/suma?a=5&b=3
```

## Archivos Modificados
- ✅ `gateway-configs/tyk/wait-for-redis.sh` (nuevo)
- ✅ `docker-compose.yml` (modificado)

## Notas Técnicas
- El script usa `netcat (nc)` para verificar la conexión TCP a Redis
- El contenedor `tykio/tyk-gateway:v5.2` ya incluye netcat por defecto
- Redis tiene su propio healthcheck que verifica `redis-cli ping`
- El script agrega una verificación adicional a nivel de red antes de arrancar Tyk

## Beneficios
- ✅ Eliminación completa de errores de conexión Redis
- ✅ Inicio más confiable de Tyk Gateway
- ✅ Mejor experiencia en desarrollo y producción
- ✅ Rate limiting funcionará correctamente desde el inicio
