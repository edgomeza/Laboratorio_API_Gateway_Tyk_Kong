# Calculadora de Microservicios

## ¿Qué es esto?

Es un proyecto de la asignatura de Arquitectura Orientada a Servicios (AOS). Básicamente, he hecho una calculadora pero de forma distribuida - en lugar de tener todo en un programa, cada operación (suma, resta, etc.) es un servicio independiente. Además hay un servicio que actúa como "director de orquesta" que coordina todo.

## Tecnologías que usé

- **Java 21** - El lenguaje de programación
- **Maven** - Para compilar y empaquetar los proyectos
- **JAX-RS** - El estándar para hacer APIs REST en Java
- **Wildfly** - Servidor de aplicaciones donde se despliegan los servicios
- **GSON** - Librería para trabajar con JSON

## Estructura

Básicamente tengo 5 servicios:

```
servicios/
├── suma/              <- suma dos números
├── resta/             <- resta dos números  
├── multiplica/        <- multiplica dos números
├── divide/            <- divide dos números (con validación de cero)
└── calculadora/       <- orquestador que llama a los otros
```

Cada uno es un proyecto Maven independiente. El de calculadora es especial porque llama a los otros cuatro.

## Para ejecutar esto

### Necesitas tener:

```
- Java 21 instalado
- Maven instalado
- Wildfly 32 descargado y descomprimido
```

### Pasos:

**1. Inicia Wildfly en una terminal:**

```
cd C:\ruta\a\wildfly\bin
standalone.bat
```

**2. En otra terminal, ve a la carpeta del proyecto:**

```
cd C:\Users\...\calculadora-microservicios
```

**3. Ejecuta el script de compilación:**

```powershell
.\compilar_y_ejecutar.ps1
```

Este script hace todo automáticamente: compila los 5 servicios y los despliega en Wildfly.

**4. Ejecuta las pruebas:**

```powershell
.\pruebas.ps1
```

Esto hace pruebas automáticas de todos los servicios.

## URLs de los servicios

Una vez desplegados, los servicios están en:

- Suma: `http://localhost:8080/suma/calculadora/suma?a=10&b=5`
- Resta: `http://localhost:8080/resta/calculadora/resta?a=20&b=8`
- Multiplica: `http://localhost:8080/multiplica/calculadora/multiplica?a=7&b=6`
- Divide: `http://localhost:8080/divide/calculadora/divide?a=100&b=5`

El orquestador (Calculadora):

- `http://localhost:8080/calculadora/calc/suma?a=15&b=25`
- `http://localhost:8080/calculadora/calc/resta?a=50&b=12`
- `http://localhost:8080/calculadora/calc/multiplica?a=9&b=8`
- `http://localhost:8080/calculadora/calc/divide?a=144&b=12`

## Qué hace cada cosa

### Los servicios de operaciones (Suma, Resta, etc.)

Reciben dos parámetros por URL (`a` y `b`), hacen la operación, y devuelven el resultado en JSON o XML.

Ejemplo:
```
GET http://localhost:8080/suma/calculadora/suma?a=10&b=5

Respuesta:
{
  "estado": "OK",
  "mensaje": "Suma realizada correctamente",
  "resultado": 15.0
}
```

### El servicio Divide tiene algo especial

Si intentas dividir por cero, devuelve un error en lugar de fallar:

```
GET http://localhost:8080/divide/calculadora/divide?a=100&b=0

Respuesta:
{
  "estado": "ERROR",
  "mensaje": "Error: División por cero. No permitido.",
  "resultado": -1.0
}
```

### El servicio Calculadora

Es diferente. En lugar de hacer las operaciones, llama a los otros servicios usando HTTP. Así si el servicio Suma no está disponible, Calculadora puede devolver un error apropiado sin romperse todo.

Ejemplo de cómo funciona:
1. Haces una petición a Calculadora: `GET http://localhost:8080/calculadora/calc/suma?a=10&b=5`
2. Calculadora internamente llama a: `GET http://localhost:8080/suma/calculadora/suma?a=10&b=5`
3. Parsea la respuesta
4. Te devuelve el resultado

## Formatos soportados

Todos los servicios devuelven JSON por defecto, pero también soportan XML si lo pides:

```powershell
# JSON (por defecto)
Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=10&b=5" `
    -Headers @{"Accept"="application/json"}

# XML
Invoke-WebRequest -Uri "http://localhost:8080/suma/calculadora/suma?a=10&b=5" `
    -Headers @{"Accept"="application/xml"}
```

## Lo que aprendí haciendo esto

- Cómo crear APIs REST con JAX-RS siguiendo el estándar de Jakarta EE
- A usar Maven para gestionar proyectos Java
- A desplegar aplicaciones en Wildfly
- Cómo hacer que unos servicios llamen a otros de forma tolerante a fallos
- La diferencia entre tener todo en una aplicación monolítica vs. servicios distribuidos

## Comandos útiles

```powershell
# Si necesitas recompilar un servicio específico
cd suma
mvn clean package -DskipTests
mvn wildfly:deploy

# Si Wildfly no está respondiendo
taskkill /F /IM java.exe

# Ver si un puerto está en uso
netstat -ano | findstr :8080
```

## Problemas que tuve (y cómo los arreglé)

**Problema 1:** El primer intento daba Error 404
- **Causa:** Las URLs tenían `-v1` pero Wildfly las registraba sin eso
- **Solución:** Quité el `-v1` de las URLs

**Problema 2:** División por cero fallaba
- **Causa:** No hacía validación
- **Solución:** Agregué un `if (b == 0)` que devuelve un error

**Problema 3:** Calculadora no encontraba los servicios
- **Causa:** El @ApplicationPath estaba mal configurado
- **Solución:** Lo configuré como vacío para que funcionara con @Path("/calc")

## Archivos importantes

- `compilar_y_ejecutar.ps1` - Script para compilar y desplegar todo
- `pruebas.ps1` - Script para ejecutar todas las pruebas
- `calculadora-microservicios/` - Carpeta con los 5 proyectos Maven y los dos scripts enunciados anteriormente

## Vídeo de demostración

Video se encuentra en el archivo .zip entregado

## Notas finales

Este proyecto me ayudó a entender cómo funcionan los microservicios en la realidad. No es trivial - hay muchos detalles pequeños que tienes que tener en cuenta (URLs, formatos, errores, etc.). 

El hecho de que cada servicio esté separado significa que puedes:
- Actualizar uno sin afectar a los otros
- Escalar solo el que necesites
- Usar diferentes tecnologías en cada uno si quisieras

Aunque para una calculadora es "overkill", la idea es entender cómo funcionan los sistemas distribuidos modernos.

---

**Alumno:** Manahen Garcia Garrido
**Asignatura:** Arquitectura Orientada a Servicios (AOS)  
**Fecha:** 18/10/2025
