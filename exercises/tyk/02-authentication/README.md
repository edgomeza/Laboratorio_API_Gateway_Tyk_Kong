# Ejercicio 2: Autenticación con API Keys - Calculadora

## Objetivo
Proteger el acceso al microservicio de división usando API Keys, ya que es una operación sensible (puede fallar con división por cero).

## ¿Qué vas a aprender?
- Cómo habilitar autenticación por API Key en Tyk
- Crear y gestionar claves de API
- Entender el control de acceso a microservicios

## Contexto
El microservicio de **división** necesita protección:
- Puede generar errores si el divisor es cero
- Queremos controlar quién puede usar esta operación
- Solo usuarios autenticados pueden dividir

## Pasos

### 1. Descomentar la configuración de la API
Abre `config.json` y descomenta todas las líneas.

**Nota importante**: Esta configuración tiene `"use_keyless": false` y `"use_standard_auth": true`.

### 2. Descomentar la clave de API
Abre `key.json` y descomenta todas las líneas.

Esta clave te permitirá acceder a la API de división.

### 3. Esperar la activación (~10 segundos)

### 4. Probar SIN autenticación (debe fallar)

#### Linux/Mac
```bash
curl "http://localhost:8080/calc/divide?a=100&b=5"
```

#### Windows (PowerShell)
```powershell
curl.exe "http://localhost:8080/calc/divide?a=100&b=5"
```

Respuesta esperada:
```json
{
  "error": "Access to this API has been disallowed"
}
```

### 5. Probar CON autenticación (debe funcionar)

#### Linux/Mac
```bash
curl -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=100&b=5"
```

#### Windows (PowerShell)
```powershell
curl.exe -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=100&b=5"
```

Respuesta esperada:
```json
{
  "resultado": 20.0,
  "mensaje": "Division realizada correctamente",
  "estado": "OK"
}
```

### 6. Probar división por cero (con autenticación)

#### Linux/Mac
```bash
curl -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=100&b=0"
```

#### Windows (PowerShell)
```powershell
curl.exe -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=100&b=0"
```

El servicio responderá con error controlado:
```json
{
  "resultado": -1.0,
  "mensaje": "Error: División por cero. No permitido.",
  "estado": "ERROR"
}
```

## ¿Qué hace esta configuración?

- **use_keyless**: `false` - Requiere autenticación
- **use_standard_auth**: `true` - Usa autenticación por API Key
- **auth_configs**: Define que el token viene en el header `Authorization`

## Flujo de autenticación

```
Cliente sin token → Tyk Gateway → ❌ Acceso Denegado

Cliente con token válido → Tyk Gateway ✓ → Microservicio Divide
                                              ↓
                                         Respuesta
```

## Pruebas adicionales

### Linux/Mac
```bash
# Operaciones válidas con autenticación
curl -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=144&b=12"  # = 12
curl -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=7.5&b=2.5"  # = 3

# Intentar con token incorrecto (debe fallar)
curl -H "Authorization: token-invalido" "http://localhost:8080/calc/divide?a=100&b=5"
```

### Windows (PowerShell)
```powershell
# Operaciones válidas con autenticación
curl.exe -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=144&b=12"  # = 12
curl.exe -H "Authorization: test-key-123" "http://localhost:8080/calc/divide?a=7.5&b=2.5"  # = 3

# Intentar con token incorrecto (debe fallar)
curl.exe -H "Authorization: token-invalido" "http://localhost:8080/calc/divide?a=100&b=5"
```

## Comparativa: Con vs Sin Gateway

### Linux/Mac
```bash
# Acceso directo al microservicio (SIN protección)
curl "http://localhost:8084/divide/calculadora/divide?a=100&b=5"
# ✓ Funciona (sin seguridad)

# A través de Tyk Gateway (CON protección)
curl "http://localhost:8080/calc/divide?a=100&b=5"
# ❌ Requiere autenticación
```

### Windows (PowerShell)
```powershell
# Acceso directo al microservicio (SIN protección)
curl.exe "http://localhost:8084/divide/calculadora/divide?a=100&b=5"
# ✓ Funciona (sin seguridad)

# A través de Tyk Gateway (CON protección)
curl.exe "http://localhost:8080/calc/divide?a=100&b=5"
# ❌ Requiere autenticación
```

**Ventaja del Gateway**: Centralizas la seguridad sin modificar el microservicio.

## ¡Felicidades!
Has aprendido a proteger microservicios con autenticación por API Keys! 🔐

## Siguiente paso
Ejercicio 03: Rate Limiting - Limitar el número de peticiones.
