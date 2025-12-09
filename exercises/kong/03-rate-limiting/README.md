# Ejercicio 3: Rate Limiting con Kong - Calculadora

## Objetivo
Limitar el número de operaciones de multiplicación para proteger el microservicio de sobrecarga, permitiendo solo 5 peticiones por minuto.

## ¿Qué vas a aprender?
- Cómo habilitar el plugin Rate Limiting en Kong
- Configurar límites por tiempo (minuto, segundo, hora)
- Interpretar headers de rate limiting
- Proteger microservicios de abuso sin modificar el código Java
- Diferencia entre rate limiting en Kong vs acceso directo

## Contexto
Imagina que tu calculadora se vuelve muy popular:
- Un usuario podría hacer miles de multiplicaciones por segundo
- Esto sobrecarga el microservicio Java en Wildfly
- Necesitas controlar cuántas operaciones puede hacer cada usuario

El microservicio de **multiplicación** (puerto 8083) es el más costoso computacionalmente, así que lo protegeremos con rate limiting.

## Pasos

### 1. Descomentar setup.sh
Abre `setup.sh` y elimina todos los `#` del inicio de las líneas.

### 2. Ejecutar el script
```bash
chmod +x setup.sh
./setup.sh
```

O ejecutar manualmente:
```bash
bash setup.sh
```

### 3. Probar SIN exceder el límite

#### Primera petición - Ver los límites en headers:
```bash
curl.exe -i "http://localhost:8000/calc/multiplica?a=7&b=8"
```

Deberías ver headers de rate limiting:
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 79
Connection: keep-alive
X-RateLimit-Limit-Minute: 5
RateLimit-Reset: 47
X-RateLimit-Remaining-Minute: 4
RateLimit-Remaining: 4
RateLimit-Limit: 5
Date: Wed, 03 Dec 2025 13:01:17 GMT
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: X-Auth-Token
X-Kong-Upstream-Latency: 4
X-Kong-Proxy-Latency: 3632
Via: kong/3.5.0.7-enterprise-edition
X-Kong-Request-Id: 938304777a72147fae888e31208efa38

{
  "estado":"OK",
  "mensaje":"Multiplica realizada correctamente",
  "resultado":56.0
}
```

#### Prueba con múltiples valores (dentro del límite):
```bash
# Petición 2
curl "http://localhost:8000/calc/multiplica?a=3&b=4"  # Remaining: 3

# Petición 3
curl "http://localhost:8000/calc/multiplica?a=10&b=5"  # Remaining: 2

# Petición 4
curl "http://localhost:8000/calc/multiplica?a=2&b=2"  # Remaining: 1

# Petición 5 (última permitida)
curl "http://localhost:8000/calc/multiplica?a=100&b=2"  # Remaining: 0
```

### 4. Probar EXCEDIENDO el límite

#### Petición 6 (debería fallar):
```bash
curl.exe -i "http://localhost:8000/calc/multiplica?a=50&b=50"
```

Respuesta esperada:
```
HTTP/1.1 429 Too Many Requests
Date: Wed, 03 Dec 2025 13:02:51 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
RateLimit-Reset: 9
X-RateLimit-Limit-Minute: 5
Retry-After: 9
X-RateLimit-Remaining-Minute: 0
RateLimit-Remaining: 0
RateLimit-Limit: 5
Content-Length: 92
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: X-Auth-Token
X-Kong-Response-Latency: 4
Server: kong/3.5.0.7-enterprise-edition
X-Kong-Request-Id: d52b353ac65d86218a30a71cfcdec942

{
  "message":"API rate limit exceeded",
  "request_id":"d52b353ac65d86218a30a71cfcdec942"
}
```

### 5. Script automatizado para probar (recomendado)

```bash
Write-Host "=== Haciendo 7 peticiones rápidas (límite: 5 por minuto) ===" -ForegroundColor Cyan

1..7 | ForEach-Object {
    Write-Host "Request $_ :" -ForegroundColor Yellow
    
    # Ejecutamos curl.exe y filtramos la salida buscando HTTP, RateLimit o resultado
    curl.exe -s -i "http://localhost:8000/calc/multiplica?a=5&b=$_" | Select-String -Pattern "HTTP|RateLimit|resultado"
    
    Write-Host "---"
}
```

## ¿Qué hace este script?

```bash
# 1. Crear Service para multiplicación
curl -X POST http://localhost:8001/services \
  --data name=calc-multiplica \
  --data url=http://calc-multiplica:8080/multiplica/calculadora/multiplica

# 2. Crear Route
curl -X POST http://localhost:8001/services/calc-multiplica/routes \
  --data 'paths[]=/calc/multiplica' \
  --data strip_path=true

# 3. Habilitar plugin rate-limiting
curl -X POST http://localhost:8001/services/calc-multiplica/plugins \
  --data name=rate-limiting \
  --data config.minute=5 \
  --data config.policy=local

# 4. (Opcional) Verificar el plugin
curl http://localhost:8001/services/calc-multiplica/plugins
```

### Explicación de la configuración:

| Parámetro | Valor | Significado |
|-----------|-------|-------------|
| `name` | `rate-limiting` | Plugin de Kong |
| `config.minute` | `5` | Máximo 5 peticiones por minuto |
| `config.policy` | `local` | Políticas almacenadas localmente en Kong |

## Headers de Rate Limiting

Kong añade headers informativos en cada respuesta:

| Header | Significado | Ejemplo |
|--------|-------------|---------|
| `RateLimit-Limit` | Límite máximo de peticiones | 5 |
| `RateLimit-Remaining` | Peticiones restantes en el periodo | 2 |
| `RateLimit-Reset` | Timestamp Unix cuando se resetea | 1704067200 |
| `Retry-After` | Segundos que esperar (si rechazado) | 30 |

## Flujo de Rate Limiting

```
📍 Petición 1 a 5: Dentro del límite
┌─────────┐      ┌──────────────┐      ┌────────────┐
│ Cliente │─────▶│ Kong Gateway │─────▶│ Microserv. │
└─────────┘      │ Remaining: 4 │      │ Multiplica │
                 └──────────────┘      └────────────┘
                 ✅ 200 OK - Resultado: 35

📍 Petición 6: Excede el límite
┌─────────┐      ┌──────────────┐
│ Cliente │─────▶│ Kong Gateway │──X──  ¡No llega al microservicio!
└─────────┘      │ Remaining: 0 │
                 └──────────────┘
                 ❌ 429 Too Many Requests
```

## Comparativa: Con vs Sin Gateway

### Sin Gateway (acceso directo):
```bash
# Hacer 100 multiplicaciones rápidas
1..100 | ForEach-Object {
    # Hacemos la petición (-I pide solo headers) y buscamos la línea que dice "HTTP"
    $codigo = curl.exe -s -I "http://localhost:8083/multiplica/calculadora/multiplica?a=5&b=$_" | Select-String "HTTP"
    
    # Escribimos el resultado en pantalla
    Write-Host "Petición $_ : $codigo"
}
# ✓ Todas las peticiones pasan (sin protección)
# ⚠️ El microservicio se sobrecarga
```

### Con Gateway Kong (CON rate limiting):
```bash
# Hacer 100 multiplicaciones rápidas
1..100 | ForEach-Object {
    # Hacemos la petición (Head request para ir rápido) y capturamos la línea del código HTTP
    $resultado = curl.exe -s -I "http://localhost:8000/calc/multiplica?a=5&b=$_" | Select-String "HTTP"
    
    # Imprimimos el número de petición y el resultado
    Write-Host "Petición $_ : $resultado"
}
# ✓ Solo 5 por minuto pasan
# ✅ El microservicio está protegido
```

**Ventaja del Gateway**: Protección centralizada sin modificar el código Java. Kong rechaza automáticamente peticiones en exceso.

## ¿Por qué usar Rate Limiting?

### En calculadora:
1. **Protección de recursos**: Los microservicios Java tienen límites de CPU/RAM
2. **Prevención de abuso**: Evita que alguien haga millones de multiplicaciones
3. **Costos controlados**: Cada petición consume recursos de Wildfly
4. **Fairness**: Todos los usuarios tienen acceso equitativo
5. **Estabilidad**: Previene que una aplicación loca derribe el servicio

### En producción real:
- **APIs de pago**: Limitar por plan (gratis: 100/día, premium: 10000/día)
- **Protección DDoS**: Bloquear ataques automatizados
- **Costos cloud**: Controlar gastos en servicios como AWS Lambda
- **SLA**: Garantizar performance consistente para todos

## Configuración avanzada

Kong soporta múltiples límites simultáneamente:

```bash
# Rate limit por segundo, minuto, hora y día
curl -X POST http://localhost:8001/services/calc-multiplica/plugins \
  --data name=rate-limiting \
  --data config.second=10 \
  --data config.minute=100 \
  --data config.hour=5000 \
  --data config.day=50000 \
  --data config.policy=local
```

## Políticas de Rate Limiting

| Política | Descripción | Caso de uso |
|----------|-------------|------------|
| **local** | Contador en memoria del nodo Kong | Desarrollo, testing, single-node |
| **cluster** | Sincronizado entre nodos Kong | Producción sin Redis |
| **redis** | Usando Redis como storage | Producción con alta disponibilidad |

## Verificar la configuración

```bash
# Ver el plugin creado
curl http://localhost:8001/services/calc-multiplica/plugins

# Filtrar solo rate-limiting
curl http://localhost:8001/services/calc-multiplica/plugins | jq '.data[] | select(.name=="rate-limiting")'

# Ver todas las rutas con rate limiting
curl http://localhost:8001/plugins | jq '.data[] | select(.name=="rate-limiting")'
```

## Troubleshooting

### Problema: "Rate limit exceeded" pero creí haber esperado
**Solución**: El contador reinicia según el timestamp de reset, no según tiempo real. Si iniciaste en segundo 30 del minuto, se resetea 60 segundos después.

### Problema: Rate limit no funciona
```bash
# Verificar que el plugin existe
curl http://localhost:8001/services/calc-multiplica/plugins

# Verificar que el servicio existe
curl http://localhost:8001/services/calc-multiplica

# Probar la configuración
curl -X GET http://localhost:8001/services/calc-multiplica/plugins | jq '.data[] | select(.name=="rate-limiting") | .config'
```

### Problema: El límite se resetea muy rápido
**Nota**: Kong usa ventana deslizante basada en timestamp. Cada petición tiene su propio contador de tiempo.

## ¡Felicidades!
Ahora sabes cómo proteger microservicios con rate limiting en Kong ⏱️

Has aprendido:
- ✅ Habilitar plugin rate-limiting
- ✅ Configurar límites por tiempo
- ✅ Interpretar headers de rate limiting
- ✅ Comparar con acceso directo

## Siguiente paso
Ejercicio 04: Caché - Mejora el performance **20x más rápido**.
