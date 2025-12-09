# Ejercicio 4: Caché de Respuestas con Kong - Calculadora

## Objetivo
Demostrar de forma visual y cuantificable cómo el caché mejora drásticamente el rendimiento, haciendo respuestas **10-20x más rápidas** para operaciones de suma.

## ¿Qué vas a aprender?
- Cómo funciona el proxy cache en Kong
- Configurar TTL (Time To Live) del caché
- **Ver diferencias reales de performance con métricas**
- Interpretar headers X-Cache-Status (HIT/MISS)
- Cuándo usar y cuándo NO usar caché

## Contexto
Las operaciones matemáticas con los mismos parámetros siempre dan el mismo resultado:
- `15 + 25 = 40` (siempre)
- `100 × 5 = 500` (siempre)

¿Por qué calcular lo mismo mil veces? ¡Cachea el resultado!

El microservicio de **suma** (puerto 8081) es perfecto para caching porque las operaciones son determinísticas.

## Pasos

### 1. Descomentar setup.sh
Abre `setup.sh` y elimina todos los `#` del inicio de las líneas.

### 2. Ejecutar el script
```bash
chmod +x setup.sh
./setup.sh
```

### 3. 🔴 PRUEBA SIN CACHÉ - Baseline

#### Operación única (línea base):

**Linux/Mac:**
```bash
time curl "http://localhost:8081/suma/calculadora/suma?a=15&b=25"
```

**Windows (PowerShell):**
```powershell
Measure-Command { curl.exe "http://localhost:8081/suma/calculadora/suma?a=15&b=25" }
```

Anota el tiempo típico (~50-200ms).

#### 50 peticiones consecutivas (SIN caché):

**Linux/Mac:**
```bash
echo "Haciendo 50 peticiones SIN caché..."
time (for i in {1..50}; do
  curl -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" > /dev/null
done)
```

**Windows (PowerShell):**
```powershell
Write-Host "Haciendo 50 peticiones SIN caché..."
Measure-Command {
  1..50 | ForEach-Object {
    curl.exe -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" | Out-Null
  }
}
```

**Anota el tiempo total** ⏱️ (típicamente: 5-15 segundos)

### 4. 🟢 PRUEBA CON CACHÉ - Kong Gateway

#### Primera petición (genera caché - MISS):

**Linux/Mac:**
```bash
curl -i "http://localhost:8000/calc/suma?a=15&b=25"
```

**Windows (PowerShell):**
```powershell
curl.exe -i "http://localhost:8000/calc/suma?a=15&b=25"
```

Deberías ver:
```
HTTP/1.1 200 OK
Content-Type: application/json
X-Cache-Status: Miss
Cache-Control: max-age=60

{
  "resultado": 40.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

#### Segunda petición (desde caché - HIT):

**Linux/Mac:**
```bash
curl -i "http://localhost:8000/calc/suma?a=15&b=25"
```

**Windows (PowerShell):**
```powershell
curl.exe -i "http://localhost:8000/calc/suma?a=15&b=25"
```

Deberías ver:
```
HTTP/1.1 200 OK
Content-Type: application/json
X-Cache-Status: Hit
Cache-Control: max-age=60

{
  "resultado": 40.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

#### Observar la diferencia de velocidad:

**Linux/Mac:**
```bash
echo "=== PETICIÓN 1 (MISS - primera vez, sin caché) ==="
time curl -s "http://localhost:8000/calc/suma?a=20&b=30" > /dev/null

echo -e "\n=== PETICIÓN 2 (HIT - desde caché) ==="
time curl -s "http://localhost:8000/calc/suma?a=20&b=30" > /dev/null
```

**Windows (PowerShell):**
```powershell
Write-Host "=== PETICIÓN 1 (MISS - primera vez, sin caché) ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=20&b=30" | Out-Null }

Write-Host "`n=== PETICIÓN 2 (HIT - desde caché) ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=20&b=30" | Out-Null }
```

Notarás una **diferencia dramática**: HIT es casi instantáneo.

#### 50 peticiones consecutivas (CON caché):

**Linux/Mac:**
```bash
echo "Haciendo 50 peticiones CON caché..."
time (for i in {1..50}; do
  curl -s "http://localhost:8000/calc/suma?a=15&b=25" > /dev/null
done)
```

**Windows (PowerShell):**
```powershell
Write-Host "Haciendo 50 peticiones CON caché..."
Measure-Command {
  1..50 | ForEach-Object {
    curl.exe -s "http://localhost:8000/calc/suma?a=15&b=25" | Out-Null
  }
}
```

**Anota el tiempo total** ⏱️ (típicamente: 0.2-0.5 segundos)

### 5. 100 peticiones - Mejor comparación:

**Linux/Mac:**
```bash
# SIN caché (directo al microservicio)
echo "=== 100 peticiones SIN CACHÉ (directo) ==="
time (for i in {1..100}; do
  curl -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" > /dev/null
done)

# CON caché (a través de Kong)
echo -e "\n=== 100 peticiones CON CACHÉ (Kong) ==="
time (for i in {1..100}; do
  curl -s "http://localhost:8000/calc/suma?a=15&b=25" > /dev/null
done)
```

**Windows (PowerShell):**
```powershell
# SIN caché (directo al microservicio)
Write-Host "=== 100 peticiones SIN CACHÉ (directo) ===" -ForegroundColor Yellow
Measure-Command {
  1..100 | ForEach-Object {
    curl.exe -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" | Out-Null
  }
}

# CON caché (a través de Kong)
Write-Host "`n=== 100 peticiones CON CACHÉ (Kong) ===" -ForegroundColor Yellow
Measure-Command {
  1..100 | ForEach-Object {
    curl.exe -s "http://localhost:8000/calc/suma?a=15&b=25" | Out-Null
  }
}
```

### 6. 📊 COMPARATIVA VISUAL

Crea una tabla con tus resultados:

| Métrica                  | SIN Caché (directo) | CON Caché (Kong) | Mejora      |
|--------------------------|---------------------|-----------------|-------------|
| 1 petición (primera)     | ~XXms               | ~XXms           | Similar     |
| 1 petición (subsec.)     | ~XXms               | ~1ms            | **XX veces**|
| 50 peticiones            | ~XXXXms             | ~XXms           | **XX veces**|
| 100 peticiones           | ~XXXXms             | ~XXms           | **10-20x**  |
| Carga en backend         | 100 requests        | 1-2 requests    | 98% menos   |

**Ejemplo real esperado:**
- Sin caché: 8000ms para 100 requests
- Con caché: 400ms para 100 requests
- **Mejora: 20x más rápido** 🚀

## ¿Qué hace este script?

```bash
# 1. Crear Service para suma
curl -X POST http://localhost:8001/services \
  --data name=calc-suma \
  --data url=http://calc-suma:8080/suma/calculadora/suma

# 2. Crear Route
curl -X POST http://localhost:8001/services/calc-suma/routes \
  --data 'paths[]=/calc/suma' \
  --data strip_path=true

# 3. Habilitar plugin proxy-cache
curl -X POST http://localhost:8001/services/calc-suma/plugins \
  --data name=proxy-cache \
  --data config.content_type='application/json' \
  --data config.cache_ttl=60 \
  --data config.strategy=memory

# 4. (Opcional) Verificar el plugin
curl http://localhost:8001/services/calc-suma/plugins
```

### Explicación de la configuración:

| Parámetro | Valor | Significado |
|-----------|-------|-------------|
| `name` | `proxy-cache` | Plugin de caché de Kong |
| `config.cache_ttl` | `60` | Cache válido durante 60 segundos |
| `config.strategy` | `memory` | Guardar en RAM (rápido, no persistente) |
| `config.content_type` | `application/json` | Solo cachear JSON |

## Headers de Caché

Kong añade headers informativos sobre el estado del caché:

| Header | Significado | Ejemplo |
|--------|-------------|---------|
| `X-Cache-Status` | **Hit** = desde caché, **Miss** = no estaba, **Bypass** = no cacheable | Hit |
| `Cache-Control` | Información de control de caché | max-age=60 |
| `X-Cache-Key` | Clave usada para almacenar el caché | GET:/calc/suma?a=15&b=25 |

### Entender X-Cache-Status:

- **Miss**: Primera petición, se calcula y se cachea
- **Hit**: Petición subsecuente, respuesta desde caché (muy rápido)
- **Bypass**: No se cachea (POST, DELETE, códigos de error, etc.)

## Flujo de Caché

```
📍 Primera petición (a=15, b=25):
┌─────────┐      ┌──────────┐      ┌────────────┐
│ Cliente │─────▶│   Kong   │─────▶│ Microserv. │
└─────────┘      └────┬─────┘      │ Suma       │
                      │            └──────┬─────┘
                      │◀───────────────────┘
                      │ X-Cache-Status: Miss
                      │ Guarda en caché
                      │ Key: "GET:/calc/suma?a=15&b=25"
                      │ Value: {"resultado": 40, ...}
                      │ TTL: 60s

📍 Segunda petición (mismos parámetros):
┌─────────┐      ┌──────────┐
│ Cliente │─────▶│   Kong   │─────────▶ ¡No llama al microservicio!
└─────────┘      └────┬─────┘
                      │ X-Cache-Status: Hit
                      │ Lee desde caché ⚡ (~1ms)
                      │ Responde inmediatamente
```

## Comparativa: Con vs Sin Gateway

### Sin Gateway (acceso directo):
```bash
# Hacer 100 sumas rápidas
echo "=== DIRECTO AL MICROSERVICIO (sin caché) ==="
time (for i in {1..100}; do
  curl -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" > /dev/null
done)
# Resultado típico: 10-15 segundos
# ✓ Todas las peticiones llegan al microservicio
# ⚠️ Carga 100% en el backend
```

### Con Gateway Kong (CON caché):
```bash
# Hacer 100 sumas rápidas (primero una para calentar caché)
curl -s "http://localhost:8000/calc/suma?a=15&b=25" > /dev/null

echo -e "\n=== A TRAVÉS DE KONG (con caché) ==="
time (for i in {1..100}; do
  curl -s "http://localhost:8000/calc/suma?a=15&b=25" > /dev/null
done)
# Resultado típico: 0.2-0.5 segundos
# ✓ Solo 1 petición llega al microservicio (las otras desde caché)
# ✅ Carga 99% menos en el backend
```

**Ventaja del Gateway**: Reducción dramática de carga, respuestas instantáneas.

## Pruebas avanzadas

### Test 1: Todas las operaciones (Suma, Resta, Multiplica, Divide) con caché

**Linux/Mac:**
```bash
# SUMA (se cachea)
echo "=== SUMA ==="
time curl -s "http://localhost:8000/calc/suma?a=10&b=20" > /dev/null
time curl -s "http://localhost:8000/calc/suma?a=10&b=20" > /dev/null  # ⚡ Desde caché

# RESTA (se cachea independientemente)
echo "=== RESTA ==="
time curl -s "http://localhost:8000/calc/resta?a=50&b=15" > /dev/null
time curl -s "http://localhost:8000/calc/resta?a=50&b=15" > /dev/null  # ⚡ Desde caché

# MULTIPLICACIÓN (se cachea independientemente)
echo "=== MULTIPLICA ==="
time curl -s "http://localhost:8000/calc/multiplica?a=7&b=8" > /dev/null
time curl -s "http://localhost:8000/calc/multiplica?a=7&b=8" > /dev/null  # ⚡ Desde caché

# DIVISIÓN (se cachea independientemente)
echo "=== DIVIDE ==="
time curl -s "http://localhost:8000/calc/divide?a=144&b=12" > /dev/null
time curl -s "http://localhost:8000/calc/divide?a=144&b=12" > /dev/null  # ⚡ Desde caché
```

**Windows (PowerShell):**
```powershell
# SUMA (se cachea)
Write-Host "=== SUMA ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=10&b=20" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=10&b=20" | Out-Null }  # ⚡ Desde caché

# RESTA (se cachea independientemente)
Write-Host "=== RESTA ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/resta?a=50&b=15" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/resta?a=50&b=15" | Out-Null }  # ⚡ Desde caché

# MULTIPLICACIÓN (se cachea independientemente)
Write-Host "=== MULTIPLICA ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/multiplica?a=7&b=8" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/multiplica?a=7&b=8" | Out-Null }  # ⚡ Desde caché

# DIVISIÓN (se cachea independientemente)
Write-Host "=== DIVIDE ===" -ForegroundColor Cyan
Measure-Command { curl.exe -s "http://localhost:8000/calc/divide?a=144&b=12" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/divide?a=144&b=12" | Out-Null }  # ⚡ Desde caché
```

### Test 2: Parámetros diferentes crean cachés diferentes

**Linux/Mac:**
```bash
# Primera suma: 10 + 20 = 30
echo "=== Suma 1: 10 + 20 ==="
curl -i "http://localhost:8000/calc/suma?a=10&b=20" | grep -E "X-Cache-Status|resultado"

# Segunda suma: 15 + 25 = 40 (parámetros diferentes)
echo -e "\n=== Suma 2: 15 + 25 ==="
curl -i "http://localhost:8000/calc/suma?a=15&b=25" | grep -E "X-Cache-Status|resultado"

# Repetir suma 1 (mismo parámetro que antes)
echo -e "\n=== Suma 1 de nuevo: 10 + 20 ==="
curl -i "http://localhost:8000/calc/suma?a=10&b=20" | grep -E "X-Cache-Status|resultado"
# Debería mostrar: Miss, Miss, Hit
```

**Windows (PowerShell):**
```powershell
# Primera suma: 10 + 20 = 30
Write-Host "=== Suma 1: 10 + 20 ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=10&b=20" | Select-String -Pattern "X-Cache-Status|resultado"

# Segunda suma: 15 + 25 = 40 (parámetros diferentes)
Write-Host "`n=== Suma 2: 15 + 25 ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=15&b=25" | Select-String -Pattern "X-Cache-Status|resultado"

# Repetir suma 1 (mismo parámetro que antes)
Write-Host "`n=== Suma 1 de nuevo: 10 + 20 ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=10&b=20" | Select-String -Pattern "X-Cache-Status|resultado"
# Debería mostrar: Miss, Miss, Hit
```

### Test 3: Expiración de caché (60 segundos)

**Linux/Mac:**
```bash
# Primera llamada
echo "=== Petición 1 (crea caché) ==="
curl -i "http://localhost:8000/calc/suma?a=100&b=50" | grep "X-Cache-Status"
# X-Cache-Status: Miss

# Dentro de 60s - usa caché
echo -e "\n=== Petición 2 (dentro de 60s) ==="
curl -i "http://localhost:8000/calc/suma?a=100&b=50" | grep "X-Cache-Status"
# X-Cache-Status: Hit

# Esperar 61 segundos
echo -e "\nEsperando 61 segundos para que expire el caché..."
sleep 61

# Después de 60s - caché expirado, recalcula
echo -e "\n=== Petición 3 (después de 60s) ==="
curl -i "http://localhost:8000/calc/suma?a=100&b=50" | grep "X-Cache-Status"
# X-Cache-Status: Miss (caché expirado, vuelve a calcular)
```

**Windows (PowerShell):**
```powershell
# Primera llamada
Write-Host "=== Petición 1 (crea caché) ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=100&b=50" | Select-String -Pattern "X-Cache-Status"
# X-Cache-Status: Miss

# Dentro de 60s - usa caché
Write-Host "`n=== Petición 2 (dentro de 60s) ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=100&b=50" | Select-String -Pattern "X-Cache-Status"
# X-Cache-Status: Hit

# Esperar 61 segundos
Write-Host "`nEsperando 61 segundos para que expire el caché..."
Start-Sleep -Seconds 61

# Después de 60s - caché expirado, recalcula
Write-Host "`n=== Petición 3 (después de 60s) ===" -ForegroundColor Cyan
curl.exe -i "http://localhost:8000/calc/suma?a=100&b=50" | Select-String -Pattern "X-Cache-Status"
# X-Cache-Status: Miss (caché expirado, vuelve a calcular)
```

### Test 4: Diferentes operaciones (se cachean independientemente)

**Linux/Mac:**
```bash
# Suma tiene caché
time curl -s "http://localhost:8000/calc/suma?a=10&b=20" > /dev/null
time curl -s "http://localhost:8000/calc/suma?a=10&b=20" > /dev/null  # Rápido

# Resta TAMBIÉN tiene caché
time curl -s "http://localhost:8000/calc/resta?a=50&b=15" > /dev/null
time curl -s "http://localhost:8000/calc/resta?a=50&b=15" > /dev/null  # Rápido

# Multiplicación TAMBIÉN tiene caché
time curl -s "http://localhost:8000/calc/multiplica?a=7&b=8" > /dev/null
time curl -s "http://localhost:8000/calc/multiplica?a=7&b=8" > /dev/null  # Rápido

# División TAMBIÉN tiene caché
time curl -s "http://localhost:8000/calc/divide?a=144&b=12" > /dev/null
time curl -s "http://localhost:8000/calc/divide?a=144&b=12" > /dev/null  # Rápido
```

**Windows (PowerShell):**
```powershell
# Suma tiene caché
Write-Host "Suma:" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=10&b=20" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/suma?a=10&b=20" | Out-Null }  # Rápido

# Resta TAMBIÉN tiene caché
Write-Host "Resta:" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8000/calc/resta?a=50&b=15" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/resta?a=50&b=15" | Out-Null }  # Rápido

# Multiplicación TAMBIÉN tiene caché
Write-Host "Multiplica:" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8000/calc/multiplica?a=7&b=8" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/multiplica?a=7&b=8" | Out-Null }  # Rápido

# División TAMBIÉN tiene caché
Write-Host "Divide:" -ForegroundColor Green
Measure-Command { curl.exe -s "http://localhost:8000/calc/divide?a=144&b=12" | Out-Null }
Measure-Command { curl.exe -s "http://localhost:8000/calc/divide?a=144&b=12" | Out-Null }  # Rápido
```

### Test 5: Ver el tamaño del caché

**Linux/Mac:**
```bash
# Hacer varias sumas para llenar caché
for i in {1..10}; do
  curl -s "http://localhost:8000/calc/suma?a=$i&b=$((i+10))" > /dev/null
done

# Ver información del caché (si está disponible)
curl http://localhost:8001/services/calc-suma/plugins | jq '.data[] | select(.name=="proxy-cache")'
```

**Windows (PowerShell):**
```powershell
# Hacer varias sumas para llenar caché
1..10 | ForEach-Object {
  curl.exe -s "http://localhost:8000/calc/suma?a=$_&b=$($_ + 10)" | Out-Null
}

# Ver información del caché (si está disponible)
curl.exe http://localhost:8001/services/calc-suma/plugins | jq '.data[] | select(.name=="proxy-cache")'
```

## ⚠️ Cuándo NO usar caché

**NO cachees:**
1. Operaciones con datos que cambian frecuentemente
2. Resultados personalizados por usuario
3. Operaciones con side effects (crear, actualizar, eliminar)
4. Datos en tiempo real
5. POST, PUT, DELETE (Kong NO los cachea por defecto)

**En calculadora:**
- ✅ Cachea: Operaciones matemáticas (resultado siempre igual)
- ❌ NO cachees: Si agregas timestamp o datos random a la respuesta

## Estrategias de Caché

### Memory (usada en este ejercicio)
```bash
--data config.strategy=memory
```
- ✅ Muy rápido
- ✅ No requiere dependencias externas
- ❌ Se pierde al reiniciar Kong
- ❌ No compartido entre nodos Kong

### Redis (para producción)
```bash
--data config.strategy=redis \
--data config.redis_host=redis \
--data config.redis_port=6379
```
- ✅ Persistente (sobrevive reinicios)
- ✅ Compartido entre nodos Kong
- ✅ Escalable
- ❌ Ligeramente más lento (red)

## Configuración de TTL

Diferentes TTLs para diferentes casos:

```bash
# Cache muy corto (5 segundos) - datos que cambian rápido
--data config.cache_ttl=5

# Cache medio (60 segundos) - datos moderadamente estables
--data config.cache_ttl=60

# Cache largo (1 hora) - datos muy estables
--data config.cache_ttl=3600

# Cache muy largo (1 día) - datos prácticamente inmutables
--data config.cache_ttl=86400
```

## 📈 Beneficios medibles del caché

| Beneficio                | Impacto                        |
|--------------------------|--------------------------------|
| Latencia reducida        | 10-100x más rápido             |
| Carga en backend         | Reducción del 90-99%           |
| Costos de infraestructura| Menos servidores necesarios    |
| Escalabilidad            | Soporta 10x más usuarios       |
| Experiencia de usuario   | Respuestas instantáneas        |

## Verificar la configuración

```bash
# Ver el plugin
curl http://localhost:8001/services/calc-suma/plugins | jq '.data[] | select(.name=="proxy-cache")'

# Ver todas las claves en caché (si es memoria)
curl http://localhost:8001/services/calc-suma/plugins | jq '.data[] | select(.name=="proxy-cache") | .config'
```

## Troubleshooting

### Problema: Veo "Miss" todas las veces
```bash
# Verificar que el plugin está habilitado
curl http://localhost:8001/services/calc-suma/plugins

# Verificar que está en GET (POST no se cachea)
curl -X GET "http://localhost:8000/calc/suma?a=10&b=20" -i | grep "X-Cache"

# Verificar Content-Type es application/json
curl -i "http://localhost:8000/calc/suma?a=10&b=20" | grep "Content-Type"
```

### Problema: Cache no funciona con parámetros
**Nota**: Kong cachea por la URL completa incluyendo parámetros. `a=10&b=20` es diferente a `a=10&b=21`.

### Problema: Quiero limpiar el caché
```bash
# Kong no tiene comando directo. Opciones:
# 1. Esperar a que expire (TTL de 60 segundos)
# 2. Cambiar la estrategia de memory a redis (persistencia controlada)
# 3. Reiniciar Kong (pierde caché si está en memory)
```

## ¡Felicidades!
Has comprobado de forma cuantificable cómo el caché mejora el rendimiento **10-20x o más** 🚀

Has aprendido:
- ✅ Habilitar proxy-cache en Kong
- ✅ Configurar TTL
- ✅ Interpretar headers X-Cache-Status
- ✅ Medir impacto real en performance
- ✅ Comparar con acceso directo

## Siguiente paso
Ejercicio 05: Transformaciones - Enriquecer requests y responses con metadata.
