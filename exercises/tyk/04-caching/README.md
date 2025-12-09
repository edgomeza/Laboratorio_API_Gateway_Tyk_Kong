# Ejercicio 4: Caché de Respuestas - Calculadora 🚀⚡

## Objetivo
Demostrar de forma visual y cuantificable cómo el caché mejora drásticamente el rendimiento de las operaciones de calculadora.

## ¿Qué vas a aprender?
- Cómo funciona el caché en un API Gateway
- Configurar tiempo de vida (TTL) del caché
- **Ver diferencias reales de performance con métricas**
- Cuándo usar y cuándo NO usar caché

## Contexto
Las operaciones matemáticas con los mismos parámetros siempre dan el mismo resultado:
- `15 + 25 = 40` (siempre)
- `100 - 35 = 65` (siempre)
- `7 × 8 = 56` (siempre)
- `144 ÷ 12 = 12` (siempre)

¿Por qué calcular lo mismo mil veces? ¡Cachea el resultado! Esto funciona para **todas las operaciones** de calculadora: suma, resta, multiplicación y división.

## Pasos

### 1. Descomentar config.json
Elimina todos los `//` del archivo `config.json`.

### 2. Esperar activación (~10 segundos)

### 3. 🔴 PRUEBA SIN CACHÉ - Baseline

#### Linux/Mac
```bash
# Operación única (tiempo real) - SUMA
time curl "http://localhost:8081/suma/calculadora/suma?a=15&b=25"

# 100 peticiones consecutivas (sin caché)
time for i in {1..100}; do
  curl -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" > /dev/null
done
```

#### Windows (PowerShell)
```powershell
# Operación única (tiempo real) - SUMA
Measure-Command { curl.exe "http://localhost:8081/suma/calculadora/suma?a=15&b=25" }

# 100 peticiones consecutivas (sin caché)
Measure-Command {
  1..100 | ForEach-Object {
    curl.exe -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" | Out-Null
  }
}
```

**Anota el tiempo total** ⏱️

### 4. 🟢 PRUEBA CON CACHÉ - Gateway

#### Primera petición (genera caché):

**Linux/Mac:**
```bash
time curl "http://localhost:8080/calc/suma/cached?a=15&b=25"
```

**Windows (PowerShell):**
```powershell
Measure-Command { curl.exe "http://localhost:8080/calc/suma/cached?a=15&b=25" }
```

#### Observa el header de respuesta:

**Linux/Mac:**
```bash
curl -i "http://localhost:8080/calc/suma/cached?a=15&b=25" | grep -i "cache"
```

**Windows (PowerShell):**
```powershell
curl.exe -i "http://localhost:8080/calc/suma/cached?a=15&b=25" | Select-String -Pattern "cache"
```

Deberías ver:
```
X-Tyk-Cached-Response: 1  ← ¡Respuesta desde caché!
Cache-Control: public, max-age=60
```

#### 100 peticiones consecutivas (CON caché):

**Linux/Mac:**
```bash
time for i in {1..100}; do
  curl -s "http://localhost:8080/calc/suma/cached?a=15&b=25" > /dev/null
done
```

**Windows (PowerShell):**
```powershell
Measure-Command {
  1..100 | ForEach-Object {
    curl.exe -s "http://localhost:8080/calc/suma/cached?a=15&b=25" | Out-Null
  }
}
```

**Anota el tiempo total** ⏱️

###  5. 📊 COMPARATIVA VISUAL

Crea una tabla con tus resultados:

| Métrica                  | SIN Caché (directo) | CON Caché (Tyk) | Mejora      |
|--------------------------|---------------------|-----------------|-------------|
| 1 petición               | ~XXms               | ~XXms           | Similar     |
| 100 peticiones           | ~XXXXms             | ~XXms           | **XX veces**|
| Carga en backend         | 100 requests        | 1 request       | 99% menos   |

**Ejemplo real esperado:**
- Sin caché: ~2000ms para 100 requests
- Con caché: ~100ms para 100 requests
- **Mejora: 20x más rápido** 🚀

## ¿Qué hace esta configuración?

- **enable_cache**: `true` - Activa el caché
- **cache_timeout**: `60` - Las respuestas se cachean 60 segundos
- **cache_all_safe_requests**: `true` - Cachea GET, HEAD, OPTIONS
- **cache_response_codes**: `[200]` - Solo cachea respuestas exitosas

## Flujo de caché

```
📍 Primera petición (a=15, b=25):
┌─────────┐      ┌──────────┐      ┌────────────┐
│ Cliente │─────▶│   Tyk    │─────▶│ Microserv. │
└─────────┘      └────┬─────┘      │ Suma       │
                      │            └──────┬─────┘
                      │◀───────────────────┘
                      │ Guarda en caché
                      │ Key: "GET:/calc/suma?a=15&b=25"
                      │ Value: {"resultado": 40, ...}
                      │ TTL: 60s

📍 Segunda petición (mismos parámetros):
┌─────────┐      ┌──────────┐
│ Cliente │─────▶│   Tyk    │─────────▶ ¡No llama al microservicio!
└─────────┘      └────┬─────┘
                      │ Lee desde caché ⚡
                      │ Responde inmediatamente
```

## Pruebas avanzadas

### Test 1: Todas las operaciones (Suma, Resta, Multiplica, Divide)

**Linux/Mac:**
```bash
# SUMA (se cachea)
echo "=== SUMA ==="
time curl "http://localhost:8080/calc/suma/cached?a=10&b=20"
time curl "http://localhost:8080/calc/suma/cached?a=10&b=20"  # ⚡ Desde caché

# RESTA (se cachea independientemente)
echo "=== RESTA ==="
time curl "http://localhost:8080/calc/resta/cached?a=50&b=15"
time curl "http://localhost:8080/calc/resta/cached?a=50&b=15"  # ⚡ Desde caché

# MULTIPLICACIÓN (se cachea independientemente)
echo "=== MULTIPLICA ==="
time curl "http://localhost:8080/calc/multiplica/cached?a=7&b=8"
time curl "http://localhost:8080/calc/multiplica/cached?a=7&b=8"  # ⚡ Desde caché

# DIVISIÓN (se cachea independientemente)
echo "=== DIVIDE ==="
time curl "http://localhost:8080/calc/divide/cached?a=144&b=12"
time curl "http://localhost:8080/calc/divide/cached?a=144&b=12"  # ⚡ Desde caché
```

**Windows (PowerShell):**
```powershell
# SUMA (se cachea)
Write-Host "=== SUMA ===" -ForegroundColor Cyan
Measure-Command { curl.exe "http://localhost:8080/calc/suma/cached?a=10&b=20" }
Measure-Command { curl.exe "http://localhost:8080/calc/suma/cached?a=10&b=20" }  # ⚡ Desde caché

# RESTA (se cachea independientemente)
Write-Host "=== RESTA ===" -ForegroundColor Cyan
Measure-Command { curl.exe "http://localhost:8080/calc/resta/cached?a=50&b=15" }
Measure-Command { curl.exe "http://localhost:8080/calc/resta/cached?a=50&b=15" }  # ⚡ Desde caché

# MULTIPLICACIÓN (se cachea independientemente)
Write-Host "=== MULTIPLICA ===" -ForegroundColor Cyan
Measure-Command { curl.exe "http://localhost:8080/calc/multiplica/cached?a=7&b=8" }
Measure-Command { curl.exe "http://localhost:8080/calc/multiplica/cached?a=7&b=8" }  # ⚡ Desde caché

# DIVISIÓN (se cachea independientemente)
Write-Host "=== DIVIDE ===" -ForegroundColor Cyan
Measure-Command { curl.exe "http://localhost:8080/calc/divide/cached?a=144&b=12" }
Measure-Command { curl.exe "http://localhost:8080/calc/divide/cached?a=144&b=12" }  # ⚡ Desde caché
```

### Test 2: Parámetros diferentes (NO usa caché anterior)

**Linux/Mac:**
```bash
curl "http://localhost:8080/calc/suma/cached?a=10&b=20"  # Caché: 30
curl "http://localhost:8080/calc/suma/cached?a=15&b=25"  # Caché: 40 (diferente)
curl "http://localhost:8080/calc/suma/cached?a=10&b=20"  # ⚡ Lee caché de 30
```

**Windows (PowerShell):**
```powershell
curl.exe "http://localhost:8080/calc/suma/cached?a=10&b=20"  # Caché: 30
curl.exe "http://localhost:8080/calc/suma/cached?a=15&b=25"  # Caché: 40 (diferente)
curl.exe "http://localhost:8080/calc/suma/cached?a=10&b=20"  # ⚡ Lee caché de 30
```

### Test 3: Expiración de caché (60 segundos)

**Linux/Mac:**
```bash
# Primera llamada
curl "http://localhost:8080/calc/suma/cached?a=100&b=50"

# Dentro de 60s - usa caché
curl "http://localhost:8080/calc/suma/cached?a=100&b=50"  # ⚡ Caché

# Esperar 61 segundos
sleep 61

# Después de 60s - caché expirado, llama de nuevo al microservicio
curl "http://localhost:8080/calc/suma/cached?a=100&b=50"  # 🔄 Recalcula
```

**Windows (PowerShell):**
```powershell
# Primera llamada
curl.exe "http://localhost:8080/calc/suma/cached?a=100&b=50"

# Dentro de 60s - usa caché
curl.exe "http://localhost:8080/calc/suma/cached?a=100&b=50"  # ⚡ Caché

# Esperar 61 segundos
Start-Sleep -Seconds 61

# Después de 60s - caché expirado, llama de nuevo al microservicio
curl.exe "http://localhost:8080/calc/suma/cached?a=100&b=50"  # 🔄 Recalcula
```

### Test 4: Comparativa de performance entre operaciones

**Linux/Mac:**
```bash
echo "=== Comparando performance CON caché entre operaciones ==="

# Primera llamada (genera caché)
time curl -s "http://localhost:8080/calc/suma/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/resta/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/multiplica/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/divide/cached?a=100&b=50" > /dev/null

# Segunda llamada (desde caché - debe ser igual de rápido para todas)
echo "Segunda llamada (desde caché):"
time curl -s "http://localhost:8080/calc/suma/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/resta/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/multiplica/cached?a=100&b=50" > /dev/null
time curl -s "http://localhost:8080/calc/divide/cached?a=100&b=50" > /dev/null

# ⚡ Todas deberían tener tiempo similar desde caché
```

**Windows (PowerShell):**
```powershell
Write-Host "=== Comparando performance CON caché entre operaciones ===" -ForegroundColor Yellow

# Primera llamada (genera caché)
Write-Host "Primera llamada (genera caché):" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8080/calc/suma/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/resta/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/multiplica/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/divide/cached?a=100&b=50" | Out-Null }

# Segunda llamada (desde caché - debe ser igual de rápido para todas)
Write-Host "Segunda llamada (desde caché):" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8080/calc/suma/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/resta/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/multiplica/cached?a=100&b=50" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8080/calc/divide/cached?a=100&b=50" | Out-Null }

# ⚡ Todas deberían tener tiempo similar desde caché
```

## ⚠️ Cuándo NO usar caché

**NO cachees:**
1. Operaciones con datos que cambian frecuentemente
2. Resultados personalizados por usuario
3. Operaciones con side effects (crear, actualizar, eliminar)
4. Datos en tiempo real

**En calculadora:**
- ✅ Cachea: Suma, resta, multiplicación y división (resultado siempre igual para mismos parámetros)
- ❌ NO cachees: Si agregas timestamp o datos random a la respuesta
- ✅ Ventaja: Todas las operaciones matemáticas son idempotentes, perfectas para caché

## 📈 Beneficios medibles del caché

| Beneficio                | Impacto                        |
|--------------------------|--------------------------------|
| Latencia reducida        | 10-100x más rápido             |
| Carga en backend         | Reducción del 90-99%           |
| Costos de infraestructura| Menos servidores necesarios    |
| Escalabilidad            | Soporta 10x más usuarios       |
| Experiencia de usuario   | Respuestas instantáneas        |

## Métricas en producción

**Linux/Mac:**
```bash
# Ver estadísticas de caché en Tyk
curl http://localhost:8080/hello

# Logs del gateway
docker logs tyk-gateway | grep -i cache
```

**Windows (PowerShell):**
```powershell
# Ver estadísticas de caché en Tyk
curl.exe http://localhost:8080/hello

# Logs del gateway
docker logs tyk-gateway | Select-String -Pattern "cache"
```

## ¡Felicidades!
Has comprobado de forma cuantificable cómo el caché mejora el rendimiento **20x o más**! 🎉

## Siguiente paso
Ejercicio 05: Transformaciones - Modificar requests y responses al vuelo.
