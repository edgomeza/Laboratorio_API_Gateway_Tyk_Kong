# Solución: Headers de Rate Limit Mostrando 0

## 🔍 Problema

Los headers de rate limiting muestran valores en **0** a pesar de que el rate limiting funciona correctamente:

```
X-RateLimit-Limit: 0
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 0
```

- ✅ El rate limiting **SÍ funciona** (bloquea después de 5 peticiones)
- ❌ Los headers **NO muestran valores correctos**

## 🎯 Causa Raíz

El problema es que las **APIs keyless** (`use_keyless: true`) **no pueden proporcionar headers de rate limit con valores correctos**.

### ¿Por qué?

1. **APIs Keyless no trackean sesiones individuales**
   - Sin autenticación, Tyk no sabe quién está haciendo la petición
   - No puede calcular `X-RateLimit-Remaining` para cada cliente individual

2. **`global_rate_limit` es un límite agregado**
   - Funciona como límite total para TODAS las peticiones combinadas
   - No es un límite por usuario/sesión

3. **Sin sesiones, no hay contadores individuales**
   - Los headers de rate limit requieren tracking por sesión
   - Las APIs keyless no tienen este tracking

### Configuración Keyless (Actual - Headers en 0)

```json
{
  "use_keyless": true,  // ← Sin autenticación
  "global_rate_limit": {
    "rate": 5,
    "per": 60
  }
}
```

**Resultado:**
- ✅ Bloquea después de 5 peticiones totales
- ❌ Headers muestran: `X-RateLimit-Limit: 0, X-RateLimit-Remaining: 0`

## ✅ Solución: Usar API con Autenticación

Para obtener headers de rate limit con valores correctos, necesitas:

1. **Cambiar a API autenticada** (`use_keyless: false`)
2. **Usar políticas** para definir rate limits por usuario
3. **Generar API keys** que apliquen esas políticas

### Arquitectura de la Solución

```
┌─────────────────────────────────────────────────────────┐
│ 1. Política (policies.json)                             │
│    - Define rate limit: 5 req/60s                       │
│    - Se aplica a calc-multiplica-api                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. API Definition (03-calc-multiplica-auth.json)        │
│    - use_keyless: false (requiere autenticación)        │
│    - use_standard_auth: true (usa Authorization header) │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. API Key                                              │
│    - Generada con la política calc-rate-limit           │
│    - Se envía en header Authorization                   │
│    - Tyk trackea cuántas peticiones quedan              │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Pasos para Implementar

### Paso 1: Activar la Nueva API con Autenticación

```bash
# Copiar la API con autenticación a la carpeta activa
cp gateway-configs/tyk/apps-templates/03-calc-multiplica-auth.json \
   gateway-configs/tyk/apps-active/

# Recargar Tyk para que detecte la nueva API
curl -H "x-tyk-authorization: foo" \
     http://localhost:8080/tyk/reload/group
```

### Paso 2: Generar una API Key con Rate Limiting

**Linux/Mac:**
```bash
# Ejecutar el script para crear la API key
./scripts/create-calc-rate-limit-key.sh
```

**Windows PowerShell:**
```powershell
# Ejecutar el script para crear la API key
.\scripts\create-calc-rate-limit-key.ps1
```

El script te dará una **API Key** que se ve así:
```
eyJvcmciOiJkZWZhdWx0IiwiaWQiOiI1ZjY4..."
```

### Paso 3: Probar con la API Key

**Windows PowerShell:**
```powershell
# Guardar la key en una variable
$API_KEY = "TU_API_KEY_AQUI"

# Hacer una petición
curl.exe -i -H "Authorization: $API_KEY" `
  "http://localhost:8080/calc/multiplica?a=7&b=8" | Select-String -Pattern "HTTP|X-RateLimit"
```

**Linux/Mac:**
```bash
# Guardar la key en una variable
API_KEY="TU_API_KEY_AQUI"

# Hacer una petición
curl -i -H "Authorization: $API_KEY" \
  "http://localhost:8080/calc/multiplica?a=7&b=8" | grep -E "HTTP|X-RateLimit"
```

### 📊 Resultado Esperado

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 4
X-RateLimit-Reset: 1733750423
```

### Paso 4: Probar el Rate Limiting

**Windows PowerShell:**
```powershell
1..7 | ForEach-Object {
    Write-Host "Petición $_ :"
    curl.exe -i -s -H "Authorization: $API_KEY" `
      "http://localhost:8080/calc/multiplica?a=5&b=$_" | Select-String -Pattern "HTTP|X-RateLimit|resultado"
    Write-Host "---"
    Start-Sleep -Milliseconds 200
}
```

**Linux/Mac:**
```bash
for i in {1..7}; do
    echo "Petición $i:"
    curl -i -s -H "Authorization: $API_KEY" \
      "http://localhost:8080/calc/multiplica?a=5&b=$i" | grep -E "HTTP|X-RateLimit|resultado"
    echo "---"
    sleep 0.2
done
```

### 📈 Resultado Esperado

```
Petición 1 :
HTTP/1.1 200 OK
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 4
X-RateLimit-Reset: 1733750423
{"estado":"OK","mensaje":"Multiplica realizada correctamente","resultado":5.0}
---
Petición 2 :
HTTP/1.1 200 OK
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 3
X-RateLimit-Reset: 1733750423
{"estado":"OK","mensaje":"Multiplica realizada correctamente","resultado":10.0}
---
...
Petición 5 :
HTTP/1.1 200 OK
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1733750423
{"estado":"OK","mensaje":"Multiplica realizada correctamente","resultado":25.0}
---
Petición 6 :
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1733750423
---
```

## 🎓 Para el Ejercicio del Laboratorio

### Opción A: Mantener Keyless (Simplificado)

**Ventajas:**
- Más simple para estudiantes
- No requiere manejar API keys
- Rate limiting funciona igual

**Desventajas:**
- Headers muestran 0 (no es representativo de producción)
- No enseña autenticación

**Documentar claramente:**
```
⚠️ NOTA: Los headers muestran valores en 0 porque usamos una API
keyless para simplificar el ejercicio. En producción, las APIs
con autenticación muestran valores correctos.
```

### Opción B: Usar Autenticación (Realista)

**Ventajas:**
- Headers muestran valores reales
- Más representativo de producción
- Enseña autenticación + rate limiting juntos

**Desventajas:**
- Requiere generar y usar API keys
- Más complejo para estudiantes

**Combinar con Ejercicio 02 (Autenticación):**
- Usar la API key del ejercicio 02
- Aplicar rate limiting encima

## 📁 Archivos Creados/Modificados

### Nuevos Archivos
1. **`gateway-configs/tyk/apps-templates/03-calc-multiplica-auth.json`**
   - API definition con autenticación para `/calc/multiplica`

2. **`scripts/create-calc-rate-limit-key.sh`**
   - Script para generar API keys con la política de rate limiting

3. **`gateway-configs/tyk/RATE_LIMIT_HEADERS_FIX.md`**
   - Este documento

### Modificados
1. **`gateway-configs/tyk/policies/policies.json`**
   - Agregada política `calc-rate-limit` con límite de 5 req/min

2. **`gateway-configs/tyk/tyk.conf`**
   - Configurado `enable_redis_rolling_limiter: true`
   - Configurado `enable_non_transactional_rate_limiter: false`

## 🔗 Referencias

- [Tyk Documentation: Rate Limiting](https://tyk.io/docs/basic-config-and-security/control-limit-traffic/rate-limiting/)
- [Tyk Documentation: Keyless Access](https://tyk.io/docs/basic-config-and-security/security/authentication-authorization/open-keyless/)
- [GitHub Issue #2261: X-RateLimit headers con keyless APIs](https://github.com/TykTechnologies/tyk/issues/2261)

## 🎯 Resumen

**Problema:** APIs keyless no pueden mostrar headers de rate limit correctos

**Causa:** Sin autenticación = sin tracking de sesiones = sin contadores individuales

**Solución:** Usar API con autenticación + políticas + API keys

**Alternativa para laboratorio:** Documentar que headers en 0 son esperados con keyless
