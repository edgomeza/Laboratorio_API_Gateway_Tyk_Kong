# Ejercicio 7: Logging Detallado con Tyk - Calculadora

## Objetivo
Activar logging completo (detailed recording) en Tyk para capturar todos los detalles de requests y responses del microservicio de resta.

## ¿Qué vas a aprender?
- Cómo activar detailed recording en Tyk
- Capturar logs completos de peticiones y respuestas
- Usar logs para auditoría y debugging

## Contexto
El detailed recording en Tyk captura información completa de cada petición incluyendo:
- Headers de request y response
- Query parameters
- Request y response bodies
- Timestamps y duración
- IP del cliente
- Información de la sesión

Esto es esencial para:
- **Debugging**: Investigar problemas en producción
- **Auditoría**: Cumplimiento regulatorio y trazabilidad
- **Análisis**: Entender patrones de uso

## Pasos

### 1. Descomentar la configuración
Abre el archivo `config.json` en esta carpeta y elimina todos los `//` de las líneas comentadas para activar la configuración.

### 2. Esperar la activación automática
El sistema detectará automáticamente el cambio y copiará la configuración a la carpeta activa de Tyk (espera ~5 segundos).

### 3. Probar el logging

**Linux/Mac:**
```bash
# Resta con logging activado
curl "http://localhost:8080/logged/resta?a=100&b=35"
```

**Windows (PowerShell):**
```powershell
# Resta con logging activado
curl.exe "http://localhost:8080/logged/resta?a=100&b=35"
```

Deberías ver:
```json
{
  "resultado": 65.0,
  "mensaje": "Resta realizada correctamente",
  "estado": "OK"
}
```

### 4. Ver los logs

**Linux/Mac:**
```bash
# Ver los últimos 50 logs de Tyk
docker logs tyk-gateway --tail 50

# Filtrar solo logs de nuestra API
docker logs tyk-gateway --tail 100 | grep "calc-logged"
```

**Windows (PowerShell):**
```powershell
# Ver los últimos 50 logs de Tyk
docker logs tyk-gateway --tail 50

# Filtrar solo logs de nuestra API
docker logs tyk-gateway --tail 100 | Select-String "calc-logged"
```

## ¿Qué hace esta configuración?

- **enable_detailed_recording**: `true` - Activa el logging detallado
- **enable_context_vars**: `true` - Captura variables de contexto
- **listen_path**: `/logged/` - Ruta protegida con logging
- **target_url**: Microservicio de resta

## Información capturada en logs

Cada petición logueada incluye:

```json
{
  "timestamp": "2025-12-03T10:30:45Z",
  "method": "GET",
  "path": "/logged/resta",
  "raw_path": "/logged/resta?a=100&b=35",
  "request_headers": {
    "Content-Type": "application/json",
    "User-Agent": "curl/7.68.0",
    "Accept": "*/*"
  },
  "response_headers": {
    "Content-Type": "application/json",
    "X-Gateway": "tyk"
  },
  "response_code": 200,
  "response_time_ms": 45,
  "client_ip": "172.18.0.1",
  "api_id": "calc-logged",
  "request_body": "",
  "response_body": "{\"resultado\":65.0,\"mensaje\":\"Resta realizada correctamente\",\"estado\":\"OK\"}"
}
```

## Arquitectura

```
┌──────────┐
│ Cliente  │
└─────┬────┘
      │ GET /logged/resta?a=100&b=35
      v
┌──────────────────────────┐
│   Tyk Gateway            │
│                          │
│  📝 Detailed Recording   │
│  • Captura request       │
│  • Captura response      │
│  • Mide tiempo           │
│  • Guarda en logs        │
└─────────┬────────────────┘
          │
          v
┌─────────────────────┐
│  Microservicio Resta│
│  Calcula: 100 - 35  │
└─────────────────────┘
```

## Pruebas adicionales

### Generar diferentes tipos de logs

**Linux/Mac:**
```bash
# Operaciones válidas
curl "http://localhost:8080/logged/resta?a=100&b=35"
curl "http://localhost:8080/logged/resta?a=50&b=25"
curl "http://localhost:8080/logged/resta?a=200&b=75"

# Operaciones con números negativos
curl "http://localhost:8080/logged/resta?a=10&b=50"

# Operaciones con decimales
curl "http://localhost:8080/logged/resta?a=15.5&b=7.3"
```

**Windows (PowerShell):**
```powershell
# Operaciones válidas
curl.exe "http://localhost:8080/logged/resta?a=100&b=35"
curl.exe "http://localhost:8080/logged/resta?a=50&b=25"
curl.exe "http://localhost:8080/logged/resta?a=200&b=75"

# Operaciones con números negativos
curl.exe "http://localhost:8080/logged/resta?a=10&b=50"

# Operaciones con decimales
curl.exe "http://localhost:8080/logged/resta?a=15.5&b=7.3"
```

### Ver logs en tiempo real

**Linux/Mac:**
```bash
# Seguir logs en tiempo real
docker logs -f tyk-gateway

# En otra terminal, hacer peticiones
curl "http://localhost:8080/logged/resta?a=100&b=35"
```

**Windows (PowerShell):**
```powershell
# Seguir logs en tiempo real
docker logs -f tyk-gateway

# En otra terminal PowerShell, hacer peticiones
curl.exe "http://localhost:8080/logged/resta?a=100&b=35"
```

## Casos de uso del detailed logging

1. **Debugging en producción**
   - Investigar errores intermitentes
   - Reproducir problemas reportados por usuarios
   - Analizar cadenas de peticiones fallidas

2. **Auditoría y compliance**
   - Cumplir regulaciones (GDPR, SOX, HIPAA)
   - Trazabilidad completa de operaciones
   - Evidencia forense en caso de incidentes

3. **Análisis de rendimiento**
   - Identificar endpoints lentos
   - Analizar tiempos de respuesta
   - Detectar patrones de uso

4. **Monitoreo de seguridad**
   - Detectar intentos de acceso no autorizado
   - Identificar patrones de ataque
   - Rastrear origen de peticiones sospechosas

## Consideraciones de seguridad

⚠️ **Advertencia**: El detailed recording captura TODA la información incluyendo:
- Datos sensibles en query parameters
- Tokens de autenticación en headers
- Información personal en request/response bodies

**Buenas prácticas:**
1. Usa logging detallado solo en endpoints que lo necesiten
2. Configura rotación de logs para evitar llenar el disco
3. Protege los archivos de log con permisos adecuados
4. Considera enmascarar datos sensibles antes de loguear
5. Cumple con políticas de retención de datos

## ¡Felicidades!
Has configurado logging detallado, esencial para operar servicios en producción. 🎉

## Siguiente paso
Ejercicio 09: Custom Middleware - Implementar lógica personalizada con JavaScript.
