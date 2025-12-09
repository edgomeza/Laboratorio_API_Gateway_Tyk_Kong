# Ejercicio 3: Rate Limiting - Calculadora

## Objetivo
Limitar el número de operaciones matemáticas que se pueden realizar para proteger los microservicios de sobrecarga.

## ¿Qué vas a aprender?
- Cómo implementar rate limiting en Tyk
- Proteger tus microservicios de abuso
- Configurar límites por tiempo
- Interpretar headers de rate limiting

## Contexto
Imagina que tu calculadora se vuelve muy popular:
- Un usuario podría hacer miles de cálculos por segundo
- Esto sobrecarga los microservicios Java
- Necesitas controlar cuántas operaciones puede hacer cada usuario

## Pasos

### 1. Descomentar config.json
Abre `config.json` y elimina todos los `//` de las líneas comentadas.

### 2. Esperar activación (~10 segundos)

### 3. Probar el rate limiting

#### Primera prueba - Verificar que funciona

**Linux/Mac:**
```bash
# Hacer una petición
curl "http://localhost:8080/calc/multiplica?a=7&b=8"
```

**Windows (PowerShell):**
```powershell
# Hacer una petición
curl.exe "http://localhost:8080/calc/multiplica?a=7&b=8"
```

Deberías ver el resultado:
```json
{
  "resultado": 56.0,
  "mensaje": "Multiplicación realizada correctamente",
  "estado": "OK"
}
```

#### Segunda prueba - Exceder el límite

**Linux/Mac:**
```bash
# Hacer 7 peticiones rápidas (límite: 5 por minuto)
for i in {1..7}; do
    echo "Petición $i :"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/calc/multiplica?a=5&b=$i")
    if [ "$status_code" = "200" ]; then
        echo "✅ Aceptada (HTTP $status_code)"
    else
        echo "❌ Bloqueada (HTTP $status_code)"
    fi
    echo "---"
    sleep 0.2
done
```

**Windows (PowerShell):**
```powershell
# Hacer 7 peticiones rápidas (límite: 5 por minuto)
1..7 | ForEach-Object {
    Write-Host "Petición $_ :"
    $response = curl.exe -s -o $null -w "%{http_code}" "http://localhost:8080/calc/multiplica?a=5&b=$_"
    if ($response -eq "200") {
        Write-Host "✅ Aceptada (HTTP $response)" -ForegroundColor Green
    } else {
        Write-Host "❌ Bloqueada (HTTP $response)" -ForegroundColor Red
    }
    Write-Host "---"
    Start-Sleep -Milliseconds 200
}
```

**Resultado esperado:**
- Peticiones 1-5: ✅ Respuesta exitosa (200 OK)
- Peticiones 6-7: ❌ Error 429 (Too Many Requests)

### 4. Ver mensaje de error

Cuando excedes el límite:

**Linux/Mac:**
```bash
curl "http://localhost:8080/calc/multiplica?a=10&b=20"
```

**Windows (PowerShell):**
```powershell
curl.exe "http://localhost:8080/calc/multiplica?a=10&b=20"
```

Respuesta:
```json
{
  "error": "Rate limit exceeded"
}
```

## ¿Qué hace esta configuración?

- **rate**: `5` - Máximo 5 peticiones
- **per**: `60` - Por cada 60 segundos (1 minuto)
- **path**: `/calc/multiplica` - Solo aplica a multiplicaciones
- Después de 5 multiplicaciones en 1 minuto → Error 429

## Headers de Rate Limiting

Tyk incluye headers informativos en cada respuesta:

| Header | Significado | Ejemplo |
|--------|-------------|---------|
| `X-RateLimit-Limit` | Límite máximo de peticiones | 5 |
| `X-RateLimit-Remaining` | Peticiones restantes | 2 |
| `X-RateLimit-Reset` | Timestamp cuando se resetea | 1234567890 |

## Flujo de Rate Limiting

```
📍 Petición 1: 5 × 1
┌─────────┐      ┌──────────────┐      ┌────────────┐
│ Cliente │─────▶│ Tyk Gateway  │─────▶│ Microserv. │
└─────────┘      │ Remaining: 4 │      │ Multiplica │
                 └──────────────┘      └────────────┘
                 ✅ 200 OK - Resultado: 5

📍 Petición 6: 5 × 6 (excede límite)
┌─────────┐      ┌──────────────┐
│ Cliente │─────▶│ Tyk Gateway  │──X──  ¡No llega al microservicio!
└─────────┘      │ Remaining: 0 │
                 └──────────────┘
                 ❌ 429 Too Many Requests
```

## ¿Por qué usar Rate Limiting?

### En calculadora:
1. **Protección de recursos**: Los microservicios Java tienen límites de CPU/RAM
2. **Prevención de abuso**: Evita que alguien haga millones de cálculos
3. **Costos controlados**: Cada petición consume recursos de Wildfly
4. **Fairness**: Todos los usuarios tienen acceso equitativo

### En producción real:
- APIs de pago: Limitar por plan (gratis: 100/día, premium: 10000/día)
- Protección DDoS: Bloquear ataques automatizados
- Costos cloud: Controlar gastos en servicios como AWS Lambda


## Comparativa: Con vs Sin Gateway

### Linux/Mac
```bash
# Directo al microservicio (SIN rate limiting)
for i in {1..100}; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8083/multiplica/calculadora/multiplica?a=5&b=$i")
    echo "Petición $i : HTTP $status_code"
done
# ✓ Todas las peticiones pasan (sin protección)

# A través de Tyk Gateway (CON rate limiting)
for i in {1..100}; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/calc/multiplica?a=5&b=$i")
    if [ "$status_code" = "200" ]; then
        echo "Petición $i : HTTP $status_code (OK)"
    else
        echo "Petición $i : HTTP $status_code (BLOQUEADO)"
    fi
done
# ✓ Solo 5 por minuto (con protección)
```

### Windows (PowerShell)
```powershell
# Directo al microservicio (SIN rate limiting)
1..100 | ForEach-Object {
    $status_code = curl.exe -s -o $null -w "%{http_code}" "http://localhost:8083/multiplica/calculadora/multiplica?a=5&b=$_"
    Write-Host "Petición $_ : HTTP $status_code"
}
# ✓ Todas las peticiones pasan (sin protección)

# A través de Tyk Gateway (CON rate limiting)
1..100 | ForEach-Object {
    $status_code = curl.exe -s -o $null -w "%{http_code}" "http://localhost:8080/calc/multiplica?a=5&b=$_"
    if ($status_code -eq "200") {
        Write-Host "Petición $_ : HTTP $status_code (OK)" -ForegroundColor Green
    } else {
        Write-Host "Petición $_ : HTTP $status_code (BLOQUEADO)" -ForegroundColor Red
    }
}
# ✓ Solo 5 por minuto (con protección)
```

**Ventaja del Gateway**: Protección centralizada sin modificar el microservicio.

## Configuración avanzada

En `config.json` puedes ajustar:

```json
"global_rate_limit": {
  "rate": 10,        // Cambiar a 10 peticiones
  "per": 30          // Por cada 30 segundos
}
```

## Estrategias de Rate Limiting

| Estrategia | Descripción | Cuándo usar |
|------------|-------------|-------------|
| **Por IP** | Limitar peticiones por dirección IP | APIs públicas |
| **Por API Key** | Limitar por usuario autenticado | APIs con autenticación |
| **Por endpoint** | Diferentes límites por operación | Operaciones costosas vs baratas |
| **Burst allowance** | Permitir ráfagas cortas | Tráfico irregular |

## ¡Felicidades!
Ahora sabes cómo proteger tus microservicios con rate limiting ⏱️

## Siguiente paso
Ejercicio 04: Caché de Respuestas - Mejora el performance 20x más rápido.
