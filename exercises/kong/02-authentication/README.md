# Ejercicio 2: Autenticación con Kong - Calculadora

## Objetivo
Proteger el microservicio de división usando el plugin Key-Auth de Kong, ya que es una operación sensible (puede fallar con división por cero).

## ¿Qué vas a aprender?
- Cómo habilitar el plugin Key-Auth en Kong
- Crear consumidores y API keys
- Proteger endpoints específicos
- Entender el flujo de autenticación

## Contexto
El microservicio de **división** necesita protección:
- Puede generar errores si el divisor es cero
- Queremos controlar quién puede usar esta operación
- Solo usuarios autenticados pueden dividir

## Pasos

### 1. Descomentar setup.sh
Abre `setup.sh` y elimina todos los `#` del inicio de las líneas.

### 2. Ejecutar el script
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Probar SIN autenticación (debe fallar)
```bash
curl "http://localhost:8000/calc/divide?a=100&b=5"
```

Respuesta esperada:
```json
{
  "message": "No API key found in request"
}
```

### 4. Probar CON autenticación (debe funcionar)
```bash
curl.exe -H "apikey: calc-secret-key-12345" "http://localhost:8000/calc/divide?a=100&b=5"
```

Respuesta esperada:
```json
{
  "resultado": 20.0,
  "mensaje": "Division realizada correctamente",
  "estado": "OK"
}
```

### 5. Probar división por cero (con autenticación)
```bash
curl.exe -H "apikey: calc-secret-key-12345" "http://localhost:8000/calc/divide?a=100&b=0"
```

El servicio responderá con error controlado:
```json
{
  "resultado": -1.0,
  "mensaje": "Error: División por cero. No permitido.",
  "estado": "ERROR"
}
```

## ¿Qué hace este script?

```bash
# 1. Crear Service para división
curl -X POST http://localhost:8001/services \
  --data name=calc-divide \
  --data url=http://calc-divide:8080/divide/calculadora/divide

# 2. Crear Route
curl -X POST http://localhost:8001/services/calc-divide/routes \
  --data 'paths[]=/calc/divide' \
  --data strip_path=true

# 3. Habilitar plugin Key-Auth en el servicio
curl -X POST http://localhost:8001/services/calc-divide/plugins \
  --data name=key-auth \
  --data config.key_names=apikey

# 4. Crear un Consumer (usuario)
curl -X POST http://localhost:8001/consumers \
  --data username=calculator-user

# 5. Crear una API Key para el consumer
curl -X POST http://localhost:8001/consumers/calculator-user/key-auth \
  --data key=calc-secret-key-12345
```

## Flujo de autenticación

```
📍 Petición SIN API key
┌─────────┐
│ Cliente │ ─────▶ GET /calc/divide?a=100&b=5
└─────────┘
               ↓
        ┌──────────────┐
        │ Kong Gateway │ ──X── ❌ No API key found
        └──────────────┘

📍 Petición CON API key
┌─────────┐
│ Cliente │ ─────▶ GET /calc/divide?a=100&b=5
└─────────┘        Header: apikey: calc-secret-key-12345
               ↓
        ┌──────────────┐
        │ Kong Gateway │
        │ 1. Verifica  │
        │ 2. ✓ Válida  │
        └──────┬───────┘
               │
               ▼
        ┌─────────────┐
        │ Microserv.  │ ─────▶ Resultado: 20.0
        │   Divide    │
        └─────────────┘
```

## Comparativa: Con vs Sin Gateway

```bash
# Acceso directo al microservicio (SIN protección)
curl "http://localhost:8084/divide/calculadora/divide?a=100&b=5"
# ✓ Funciona (sin seguridad)

# A través de Kong Gateway (CON protección)
curl "http://localhost:8000/calc/divide?a=100&b=5"
# ❌ Requiere autenticación
```

**Ventaja del Gateway**: Centralizas la seguridad sin modificar el microservicio Java.

## Pruebas avanzadas

### Test 1: Operaciones válidas con autenticación
```bash
# División normal
curl.exe -H "apikey: calc-secret-key-12345" "http://localhost:8000/calc/divide?a=144&b=12"  # = 12

# División con decimales
curl.exe -H "apikey: calc-secret-key-12345" "http://localhost:8000/calc/divide?a=7.5&b=2.5"  # = 3
```

### Test 2: Intentar con token incorrecto
```bash
curl.exe -H "apikey: token-invalido" "http://localhost:8000/calc/divide?a=100&b=5"
```

Respuesta:
```json
{
  "message": "Invalid authentication credentials"
}
```

## ¡Felicidades!
Has aprendido a proteger microservicios con autenticación por API Keys en Kong 🔐

## Siguiente paso
Ejercicio 03: Rate Limiting - Limitar el número de peticiones por usuario.
