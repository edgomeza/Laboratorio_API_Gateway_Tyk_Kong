# Ejercicio 7: File Log Plugin con Kong - Calculadora

## Objetivo
Configurar el plugin file-log en Kong para guardar logs detallados de cada petición al microservicio de resta.

## ¿Qué vas a aprender?
- Activar el plugin file-log en Kong
- Capturar requests y responses completos en formato JSON
- Acceder y analizar logs de archivos

## Contexto
El plugin `file-log` de Kong guarda cada petición en un archivo JSON con toda la información:
- Request (método, path, headers, body, query params)
- Response (status code, headers, body)
- Latencias y tiempos
- IP del cliente y ruta

**Archivo de logs**: `/tmp/kong-resta.log` (dentro del contenedor)

## Pasos

### 1. Ejecutar el script de configuración

**Windows (PowerShell):**
```powershell
cd exercises/kong/07-logging
.\setup.ps1
```

**Linux/macOS:**
```bash
cd exercises/kong/07-logging
bash setup.sh
```

### 2. Hacer peticiones al endpoint

**Windows:**
```powershell
curl.exe "http://localhost:8000/logged/resta?a=100&b=35"
curl.exe "http://localhost:8000/logged/resta?a=50&b=25"
```

**Linux/macOS:**
```bash
curl "http://localhost:8000/logged/resta?a=100&b=35"
curl "http://localhost:8000/logged/resta?a=50&b=25"
```

### 3. Ver los logs guardados

**Windows:**
```powershell
# Ver todo el archivo de log
docker exec kong-gateway cat /tmp/kong-resta.log

# Ver logs en tiempo real
docker exec kong-gateway tail -f /tmp/kong-resta.log
```

**Linux/macOS:**
```bash
# Ver todo el archivo de log
docker exec kong-gateway cat /tmp/kong-resta.log

# Ver logs en tiempo real
docker exec kong-gateway tail -f /tmp/kong-resta.log
```

## Formato del log

Cada línea es un objeto JSON:
```json
{
  "request": {
    "method": "GET",
    "uri": "/logged/resta?a=100&b=35",
    "url": "http://localhost:8000/logged/resta?a=100&b=35",
    "querystring": {"a": "100", "b": "35"},
    "headers": {
      "host": "localhost:8000",
      "user-agent": "curl/7.68.0"
    }
  },
  "response": {
    "status": 200,
    "headers": {
      "content-type": "application/json"
    },
    "body": "{\"resultado\":65.0,\"mensaje\":\"Resta realizada correctamente\",\"estado\":\"OK\"}"
  },
  "latencies": {
    "request": 45,
    "kong": 2,
    "proxy": 43
  },
  "client_ip": "172.19.0.1",
  "started_at": 1701612345000
}
```

## Diferencia con Tyk

| Aspecto | Tyk | Kong |
|---------|-----|------|
| Activación | `enable_detailed_recording` | Plugin `file-log` |
| Ubicación | Logs de Docker | Archivo específico |
| Formato | Logs mezclados | JSON por línea |
| Procesamiento | Manual | Fácil con `jq` |

## Analizar logs con jq

**Linux/macOS:**
```bash
# Ver solo status codes
docker exec kong-gateway cat /tmp/kong-resta.log | jq '.response.status'

# Ver solo resultados
docker exec kong-gateway cat /tmp/kong-resta.log | jq '.response.body | fromjson | .resultado'

# Ver latencias
docker exec kong-gateway cat /tmp/kong-resta.log | jq '.latencies.proxy'
```

## ¡Felicidades!
Has configurado logging detallado a archivo con Kong. 🎉

## Siguiente paso
Ejercicio 09: Request Validator - Validar parámetros con JSON Schema.
