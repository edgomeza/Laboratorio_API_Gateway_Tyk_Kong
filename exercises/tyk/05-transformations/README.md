# Ejercicio 5: Transformaciones - Calculadora

## Objetivo
Modificar requests y responses en tiempo real para enriquecer las operaciones matemáticas con metadata útil.

## ¿Qué vas a aprender?
- Cómo transformar headers automáticamente en Tyk
- Añadir información sin modificar los microservicios
- Casos de uso prácticos de transformaciones
- Headers de seguridad y tracking

## Contexto
A veces necesitas:
- Añadir metadata a las respuestas (versión del API, tiempo de proceso)
- Headers de seguridad sin tocar el código Java
- Información de auditoría (quién hizo qué operación)
- Identificadores únicos para tracking

¡Todo esto sin modificar los microservicios!

## Pasos

### 1. Descomentar config.json
Abre `config.json` y elimina todos los `//` de las líneas comentadas.

### 2. Esperar activación (~10 segundos)

### 3. Probar las transformaciones

#### Ver headers añadidos

**Linux/Mac:**
```bash
curl -i "http://localhost:8080/calc/resta?a=100&b=35" | grep -E "X-Gateway|X-Processed-By|X-Service|resultado"
```

**Windows (PowerShell):**
```powershell
curl.exe -i "http://localhost:8080/calc/resta?a=100&b=35" | Select-String -Pattern "X-Gateway|X-Processed-By|X-Service|resultado"
```

Deberías ver headers adicionales como:
```
X-Gateway: Tyk
X-Processed-By: API-Gateway
X-Service: resta
X-Calculator-Version: 1.0
```

#### Ver respuesta completa

**Linux/Mac:**
```bash
curl "http://localhost:8080/calc/resta?a=100&b=35"
```

**Windows (PowerShell):**
```powershell
curl.exe "http://localhost:8080/calc/resta?a=100&b=35"
```

Respuesta:
```json
{
  "resultado": 65.0,
  "mensaje": "Resta realizada correctamente",
  "estado": "OK"
}
```

Con headers extra de transformación visibles con la opción `-i`.

## ¿Qué hace esta configuración?

### Headers añadidos a la response (hacia el cliente):
- **X-Gateway**: `Tyk` - Identifica que pasó por el gateway Tyk
- **X-Processed-By**: `API-Gateway` - Confirma que fue procesado por el gateway
- **X-Service**: `resta` - Indica qué microservicio procesó la operación
- **X-Calculator-Version**: `1.0` - Versión del API de calculadora

Estos headers se configuran con `global_response_headers` y se añaden automáticamente a **todas las respuestas** sin modificar el código Java del microservicio.

## Flujo de Transformación

```
📍 Request del cliente
┌─────────┐
│ Cliente │ ────▶ GET /calc/resta?a=100&b=35
└─────────┘

📍 Tyk añade headers al REQUEST
┌──────────────────┐
│   Tyk Gateway    │
│ + X-Gateway: Tyk │
│ + X-Request-ID   │
└─────────┬────────┘
          │
          ▼
┌────────────────────┐
│  Microservicio     │
│  Resta             │
│  Procesa: 100 - 35 │
└─────────┬──────────┘
          │ {"resultado": 65, ...}
          ▼
┌──────────────────────────┐
│   Tyk Gateway            │
│ + X-Processed-By: Gateway│
│ + X-Cache-Status: MISS   │
└─────────┬────────────────┘
          │
          ▼
┌─────────┐
│ Cliente │ ◀──── Respuesta con headers extra
└─────────┘
```

## Casos de uso reales

### 1. Metadata de tracking
Útil para debugging y monitoreo:
```
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
X-Response-Time: 45ms
X-Gateway-Version: Tyk-5.2
X-Service: resta-8082
```

### 2. Headers de seguridad
Protección sin modificar Java:
```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000
X-XSS-Protection: 1; mode=block
```

### 3. CORS automático
Permitir acceso desde navegadores:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST
Access-Control-Allow-Headers: Content-Type
```

### 4. Información de auditoría
Quién y cuándo:
```
X-User-IP: 192.168.1.100
X-Operation: resta
X-Timestamp: 2025-01-15T10:30:00Z
X-Gateway-Instance: tyk-01
```

## Comparativa: Con vs Sin Gateway

### Sin transformaciones (directo):
```bash
curl -i "http://localhost:8082/resta/calculadora/resta?a=100&b=35"
```

Respuesta:
```
HTTP/1.1 200 OK
Content-Type: application/json

{"resultado": 65.0, ...}
```

Solo lo mínimo del microservicio.

### Con transformaciones (Tyk):
```bash
curl -i "http://localhost:8080/calc/resta?a=100&b=35"
```

Respuesta:
```
HTTP/1.1 200 OK
Content-Type: application/json
X-Gateway: Tyk
X-Processed-By: API-Gateway
X-Request-ID: abc-123-def
X-Response-Time: 45ms
X-Service: resta

{"resultado": 65.0, ...}
```

Headers adicionales sin tocar el código Java.

## Transformaciones avanzadas que Tyk puede hacer

### 1. Modificar JSON del body
```json
// Original del microservicio
{"resultado": 40}

// Transformado por Tyk
{
  "resultado": 40,
  "metadata": {
    "gateway": "Tyk",
    "timestamp": "2025-01-15T10:30:00Z",
    "service": "suma"
  }
}
```

### 2. Cambiar URLs
```
Cliente pide: /calc/suma
Tyk transforma a: /suma/calculadora/suma
Microservicio recibe el path correcto
```

### 3. Convertir formatos
```
Cliente envía: XML
Tyk convierte a: JSON
Microservicio recibe: JSON
Tyk convierte respuesta: JSON → XML
Cliente recibe: XML
```

### 4. Añadir parámetros
```
Cliente: /calc/suma?a=10&b=20
Tyk añade: /calc/suma?a=10&b=20&version=2&source=gateway
Microservicio recibe los parámetros extra
```

## Pruebas prácticas

### Test 1: Comparar headers (Con vs Sin Gateway)

**Linux/Mac:**
```bash
echo "=== DIRECTO AL MICROSERVICIO (sin transformaciones) ==="
curl -i "http://localhost:8082/resta/calculadora/resta?a=50&b=15" | grep -E "^X-"

echo -e "\n=== A TRAVÉS DE TYK (con transformaciones) ==="
curl -i "http://localhost:8080/calc/resta?a=50&b=15" | grep -E "^X-"
```

**Windows (PowerShell):**
```powershell
Write-Host "=== DIRECTO AL MICROSERVICIO (sin transformaciones) ===" -ForegroundColor Yellow
curl.exe -i "http://localhost:8082/resta/calculadora/resta?a=50&b=15" | Select-String -Pattern "^X-"

Write-Host "`n=== A TRAVÉS DE TYK (con transformaciones) ===" -ForegroundColor Yellow
curl.exe -i "http://localhost:8080/calc/resta?a=50&b=15" | Select-String -Pattern "^X-"
```

**Resultado esperado:**
- **Directo**: Sin headers `X-Gateway`, `X-Processed-By`, ni `X-Service`
- **Tyk**: Con todos los headers custom añadidos automáticamente

### Test 2: Ver todos los headers custom

**Linux/Mac:**
```bash
# Ver SOLO los headers custom añadidos por Tyk
curl -i "http://localhost:8080/calc/resta?a=100&b=35" 2>/dev/null | grep -E "X-Gateway|X-Processed-By|X-Service|X-Calculator-Version"
```

**Windows (PowerShell):**
```powershell
# Ver SOLO los headers custom añadidos por Tyk
curl.exe -i "http://localhost:8080/calc/resta?a=100&b=35" 2>$null | Select-String -Pattern "X-Gateway|X-Processed-By|X-Service|X-Calculator-Version"
```

## ¿Por qué transformar?

### En calculadora:
1. **Auditoría**: Saber qué operación hizo cada IP
2. **Debugging**: Request ID para rastrear errores
3. **Métricas**: Tiempo de respuesta por operación
4. **Seguridad**: Headers de protección

### En producción real:
1. **Migración de APIs**: Adaptar respuestas antiguas a nuevos formatos
2. **Múltiples consumidores**: Mismo backend, diferentes formatos de respuesta
3. **Seguridad centralizada**: Añadir headers de seguridad a todas las APIs
4. **Compliance**: Añadir información requerida por regulaciones

## Ventajas de las transformaciones en el Gateway

| Ventaja | Descripción |
|---------|-------------|
| **Sin código** | No modificas los microservicios Java |
| **Centralizado** | Una configuración para todas las APIs |
| **Rápido** | Cambios sin redeployar microservicios |
| **Consistente** | Mismos headers en todas las respuestas |
| **Flexible** | Diferentes transformaciones por endpoint |

## Configuración avanzada

En `config.json` puedes configurar diferentes tipos de transformaciones:

### 1. Headers globales de respuesta (lo que usamos en este ejercicio)
```json
{
  "global_response_headers": {
    "X-Gateway": "Tyk",
    "X-Processed-By": "API-Gateway",
    "X-Service": "resta",
    "X-Custom-Header": "YourValue"
  }
}
```

Estos headers se añaden a **todas las respuestas** automáticamente.

### 2. Headers de request (hacia el backend)
```json
{
  "version_data": {
    "not_versioned": true,
    "versions": {
      "Default": {
        "global_headers": {
          "X-Internal-Request": "from-gateway",
          "X-Gateway-Instance": "tyk-01"
        }
      }
    }
  }
}
```

Estos se añaden a las peticiones **hacia el microservicio**, no al cliente.

### 3. CORS - Exponer headers custom
```json
{
  "CORS": {
    "enable": true,
    "exposed_headers": ["X-Gateway", "X-Processed-By", "X-Service"]
  }
}
```

Esto permite que los navegadores vean los headers custom en peticiones CORS.

## ¡Felicidades!
Has completado todos los ejercicios de Tyk 🎉🎊

Ahora dominas:
- ✅ Proxy Básico - Enrutamiento de peticiones
- ✅ Autenticación - Protección con API Keys
- ✅ Rate Limiting - Control de sobrecarga
- ✅ Caché - Performance 20x más rápido
- ✅ Transformaciones - Metadata y headers

## Siguiente paso
¡Continúa con los ejercicios de Kong para comparar ambas tecnologías!
