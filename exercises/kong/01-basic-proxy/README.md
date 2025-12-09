# Ejercicio 1: Proxy Básico con Kong - Calculadora

## Objetivo
Crear un Service y Route en Kong para enrutar peticiones al microservicio de suma.

## ¿Qué vas a aprender?
- Concveptos fundamentales de Kong (Service y Route)
- Cómo configurar Kong mediante su Admin API
- Diferencia entre Service y Route
- Proxy de operaciones matemáticas

## Conceptos de Kong

### Service
Un **Service** es la abstracción del backend. Define:
- URL del microservicio backend
- Protocolo (HTTP/HTTPS)
- Nombre del servicio

En nuestro caso: el microservicio de **suma** en el puerto 8081.

### Route
Un **Route** define cómo los clientes acceden al service:
- Path (ej: `/calc/suma`)
- Métodos HTTP permitidos
- Headers requeridos
- Hosts aceptados

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

### 3. Probar el proxy

#### Petición directa al microservicio (sin Kong):
```bash
curl "http://localhost:8081/suma/calculadora/suma?a=15&b=25"
```

Respuesta:
```json
{
  "resultado": 40.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

#### Petición a través de Kong:
```bash
curl "http://localhost:8000/calc/suma?a=15&b=25"
```

Respuesta (idéntica):
```json
{
  "resultado": 40.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

## ¿Qué hace este script?

```bash
# 1. Crea un Service llamado "calc-suma"
curl -X POST http://localhost:8001/services \
  --data name=calc-suma \
  --data url=http://calc-suma:8080/suma/calculadora/suma

# 2. Crea un Route asociado al Service
curl -X POST http://localhost:8001/services/calc-suma/routes \
  --data 'paths[]=/calc/suma' \
  --data strip_path=true
```

### Explicación:
- **Service**: Apunta a `calc-suma:8080` (nombre del contenedor Docker)
- **Path completo**: `/suma/calculadora/suma` (endpoint del microservicio)
- **Route**: Escucha en `/calc/suma`
- **strip_path=true**: Elimina `/calc/suma` antes de enviar al backend

## Verificar la configuración

### Ver todos los services:
```bash
curl http://localhost:8001/services
```

Deberías ver `calc-suma` en la lista.

### Ver todas las routes:
```bash
curl http://localhost:8001/routes
```

Deberías ver la route `/calc/suma`.

### Ver routes de un service específico:
```bash
curl http://localhost:8001/services/calc-suma/routes
```

## Flujo de la petición

```
Cliente
  ↓
http://localhost:8000/calc/suma?a=15&b=25
  ↓
Kong Gateway (puerto 8000)
  ↓ (encuentra el Route que coincide con /calc/suma)
  ↓ (strip_path=true elimina /calc/suma del path)
  ↓
Service: calc-suma
  ↓
http://calc-suma:8080/suma/calculadora/suma?a=15&b=25
  ↓
Microservicio Suma (Wildfly, Java)
  ↓ Procesa: 15 + 25 = 40
  ↓
Respuesta JSON
  ↓
Kong Gateway
  ↓
Cliente recibe: {"resultado": 40.0, ...}
```

## Pruebas adicionales

### Test 1: Diferentes operaciones
```bash
# Suma: 10 + 20
curl "http://localhost:8000/calc/suma?a=10&b=20"  # → 30

# Suma: 100 + 50
curl "http://localhost:8000/calc/suma?a=100&b=50"  # → 150

# Suma con decimales: 7.5 + 2.5
curl "http://localhost:8000/calc/suma?a=7.5&b=2.5"  # → 10.0
```

### Test 2: Ver tiempo de respuesta
```bash
Measure-Command { curl.exe "http://localhost:8000/calc/suma?a=999&b=1" }
```

### Test 3: Comparar con acceso directo
```bash
echo "=== A través de Kong ==="
Measure-Command { curl.exe "http://localhost:8000/calc/suma?a=15&b=25" }

echo "=== Directo al microservicio ==="
Measure-Command { curl.exe "http://localhost:8081/suma/calculadora/suma?a=15&b=25" }
```

Deberías ver tiempos similares (Kong añade ~1-5ms).

## Ventajas de usar Kong como proxy

| Ventaja | Descripción |
|---------|-------------|
| **URL simplificada** | `/calc/suma` vs `/suma/calculadora/suma` |
| **Centralización** | Un solo punto de entrada para todos los microservicios |
| **Escalabilidad** | Kong puede hacer load balancing entre múltiples instancias |
| **Monitoreo** | Kong registra todas las peticiones |
| **Seguridad** | Añadir autenticación sin tocar el código Java |

## Diferencias entre Service y Route

```
┌─────────────────────────────────────────────┐
│              ROUTE                          │
│  "Cómo los clientes llegan"                 │
│  - Path: /calc/suma                         │
│  - Methods: GET, POST                       │
│  - Headers: X-Custom-Header                 │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│              SERVICE                        │
│  "Dónde está el backend"                    │
│  - URL: http://calc-suma:8080               │
│  - Path: /suma/calculadora/suma             │
│  - Retries, timeouts, etc.                  │
└─────────────────────────────────────────────┘
```

**Analogía**:
- **Route** = Dirección postal y número de apartamento
- **Service** = El edificio y la puerta específica

## Troubleshooting

### Error: "no Route matched with those values"
```bash
# Verificar que la route existe
curl http://localhost:8001/routes

# Verificar el path exacto
curl "http://localhost:8000/calc/suma?a=1&b=1"  # ✓ Correcto
curl "http://localhost:8000/suma?a=1&b=1"      # ✗ Incorrecto
```

### Error: "failure to get a peer from the ring-balancer"
```bash
# El servicio no está accesible, verificar:
docker ps | Select-String "calc-suma"
docker logs calc-suma

# Probar acceso directo:
curl "http://localhost:8081/suma/calculadora/suma?a=1&b=1"
```

## ¡Completado!
Has configurado tu primer proxy con Kong 🎉

Ahora las peticiones fluyen:
```
Cliente → Kong → Microservicio Suma → Kong → Cliente
```

## Siguiente paso
Ejercicio 02: Autenticación - Proteger el acceso con API Keys.
