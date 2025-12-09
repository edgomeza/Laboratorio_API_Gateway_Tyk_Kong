# Ejercicio 1: Proxy Básico con Tyk - Calculadora

## Objetivo
Configurar un proxy básico que enrute las peticiones desde Tyk Gateway a los microservicios de calculadora.

## ¿Qué vas a aprender?
- Cómo configurar un proxy básico en Tyk
- Entender la estructura de una API definition en Tyk
- Cómo funciona el enrutamiento de peticiones hacia microservicios

## Contexto
Tenemos 4 microservicios de calculadora independientes:
- **suma** (puerto 8081)
- **resta** (puerto 8082)
- **multiplica** (puerto 8083)
- **divide** (puerto 8084)

Vamos a configurar Tyk para enrutar peticiones hacia el microservicio de **suma**.

## Pasos

### 1. Descomentar la configuración
Abre el archivo `config.json` en esta carpeta y **descomenta todas las líneas** (elimina los `//` del inicio de cada línea).

### 2. Esperar la activación automática
El sistema detectará automáticamente el cambio y copiará la configuración a la carpeta activa de Tyk (espera ~5 segundos).

### 3. Probar el proxy

#### Linux/Mac
```bash
# Suma mediante Tyk Gateway
curl "http://localhost:8080/calc/suma?a=15&b=25"
```

#### Windows (PowerShell)
```powershell
# Suma mediante Tyk Gateway
curl.exe "http://localhost:8080/calc/suma?a=15&b=25"
```

Deberías ver:
```json
{
  "resultado": 40.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

### 4. Comparar con acceso directo

#### Linux/Mac
```bash
# Acceso directo al microservicio (sin gateway)
curl "http://localhost:8081/suma/calculadora/suma?a=15&b=25"
```

#### Windows (PowerShell)
```powershell
# Acceso directo al microservicio (sin gateway)
curl.exe "http://localhost:8081/suma/calculadora/suma?a=15&b=25"
```

¡Misma respuesta! Pero ahora pasa por el gateway.

## ¿Qué hace esta configuración?

- **listen_path**: `/calc/suma` - Tyk escuchará en esta ruta
- **target_url**: `http://calc-suma:8080/suma/calculadora/suma` - Peticiones se reenvían aquí
- **strip_listen_path**: `true` - Elimina `/calc/suma` del path antes de enviarlo
- **use_keyless**: `true` - No requiere autenticación (por ahora)

## Ejemplo de funcionamiento

```
Cliente → http://localhost:8080/calc/suma?a=15&b=25
  ↓
Tyk Gateway (procesa y elimina /calc/suma)
  ↓
Microservicio Suma → http://calc-suma:8080/suma/calculadora/suma?a=15&b=25
  ↓
Respuesta: { "resultado": 40.0, ... }
```

## Arquitectura

```
┌─────────┐     ┌──────────────┐     ┌────────────────┐
│ Cliente │────▶│  Tyk Gateway │────▶│ Microservicio  │
│         │     │ (puerto 8080)│     │ Suma (8081)    │
└─────────┘     └──────────────┘     └────────────────┘
```

## Pruebas adicionales

### Linux/Mac
```bash
# Diferentes operaciones de suma
curl "http://localhost:8080/calc/suma?a=100&b=50"
curl "http://localhost:8080/calc/suma?a=7.5&b=2.5"
curl "http://localhost:8080/calc/suma?a=-10&b=5"
```

### Windows (PowerShell)
```powershell
# Diferentes operaciones de suma
curl.exe "http://localhost:8080/calc/suma?a=100&b=50"
curl.exe "http://localhost:8080/calc/suma?a=7.5&b=2.5"
curl.exe "http://localhost:8080/calc/suma?a=-10&b=5"
```

## ¡Felicidades!
Una vez que veas la respuesta correcta, habrás completado tu primer ejercicio con Tyk y microservicios de calculadora! 🎉

## Siguiente paso
Ejercicio 02: Autenticación - Proteger el acceso a las operaciones.
