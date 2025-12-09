# Ejercicio 6: API Versionada con Tyk - Calculadora

## Objetivo
Implementar versionado de API usando headers HTTP para ofrecer dos versiones de la calculadora: V1 (básica) y V2 (científica).

## ¿Qué vas a aprender?
- Cómo configurar versionado de APIs en Tyk usando headers
- Gestionar diferentes versiones de una API simultáneamente
- Usar headers personalizados para controlar el routing

## Contexto
Ahora tenemos dos tipos de calculadoras:
- **V1 (Básica)**: Operaciones tradicionales (suma, resta, multiplica, divide)
- **V2 (Científica)**: Operaciones avanzadas (raíz cuadrada, potencia, módulo, logaritmo, seno, coseno, tangente)

El versionado permite que ambas versiones coexistan y que los clientes elijan cuál usar.

## Pasos

### 1. Descomentar la configuración
Abre el archivo `config.json` en esta carpeta.

**IMPORTANTE**: El archivo YA está descomentado y listo para usar. Solo necesitas guardarlo si hiciste algún cambio, o simplemente verifica que esté correcto.

### 2. Esperar la activación automática
El sistema detectará automáticamente el cambio y copiará la configuración a la carpeta activa de Tyk (espera ~5 segundos).

### 3. Probar la API Versionada

#### Prueba V2 (Científica) - Con header
**Linux/Mac:**
```bash
# Raíz cuadrada de 25 usando V2
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/raiz?n=25"

# Potencia: 2^10
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/potencia?base=2&exponente=10"

# Seno de 30 grados
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/seno?angulo=30"
```

**Windows (PowerShell):**
```powershell
# Raíz cuadrada de 25 usando V2
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/raiz?n=25"

# Potencia: 2^10
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/potencia?base=2&exponente=10"

# Seno de 30 grados
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/seno?angulo=30"
```

#### Prueba V1 (Básica) - Con header
**Linux/Mac:**
```bash
# Suma usando V1
curl -H "X-API-Version: v1" "http://localhost:8080/versioned/suma?a=15&b=25"
```

**Windows (PowerShell):**
```powershell
# Suma usando V1
curl.exe -H "X-API-Version: v1" "http://localhost:8080/versioned/suma?a=15&b=25"
```

#### Sin header (usa versión por defecto: V2)
**Linux/Mac:**
```bash
# Sin header, usa V2 por defecto
curl "http://localhost:8080/versioned/raiz?n=144"
```

**Windows (PowerShell):**
```powershell
# Sin header, usa V2 por defecto
curl.exe "http://localhost:8080/versioned/raiz?n=144"
```

Deberías ver:
```json
{
  "resultado": 12.0,
  "mensaje": "Raíz cuadrada calculada correctamente",
  "estado": "OK"
}
```

## ¿Qué hace esta configuración?

- **version_data.not_versioned**: `false` - Activa el versionado
- **version_data.default_version**: `"v2"` - V2 es la versión por defecto
- **definition.location**: `"header"` - La versión se especifica en un header
- **definition.key**: `"X-API-Version"` - Nombre del header para la versión
- **definition.fallback_to_default**: `true` - Si no hay header, usa la versión por defecto

## Ejemplo de funcionamiento

### Con V2 (header: X-API-Version: v2)
```
Cliente → http://localhost:8080/versioned/raiz?n=25
  + Header: X-API-Version: v2
  ↓
Tyk Gateway (detecta versión en header)
  ↓
Backend → http://backend-service:3000/direct/raiz?n=25
  ↓
Respuesta: { "resultado": 5.0, ... }
```

### Con V1 (header: X-API-Version: v1)
```
Cliente → http://localhost:8080/versioned/suma?a=10&b=20
  + Header: X-API-Version: v1
  ↓
Tyk Gateway (detecta versión en header)
  ↓
Backend → http://backend-service:3000/direct/suma?a=10&b=20
  ↓
Respuesta: { "resultado": 30.0, ... }
```

## Arquitectura

```
                    ┌──────────────────┐
                    │  Tyk Gateway     │
                    │  (puerto 8080)   │
                    │                  │
                    │  Detecta header  │
                    │  X-API-Version   │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
         [V1 Header]                   [V2 Header]
              │                             │
              v                             v
    ┌─────────────────┐          ┌─────────────────┐
    │  Backend V1     │          │  Backend V2     │
    │  (Básica)       │          │  (Científica)   │
    │  suma, resta... │          │  raíz, potencia │
    └─────────────────┘          └─────────────────┘
```

## Pruebas adicionales

### Operaciones científicas (V2)

**Linux/Mac:**
```bash
# Módulo: 17 % 5
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/modulo?a=17&b=5"

# Logaritmo natural de 10
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/logaritmo?n=10"

# Coseno de 60 grados
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/coseno?angulo=60"

# Tangente de 45 grados
curl -H "X-API-Version: v2" "http://localhost:8080/versioned/tangente?angulo=45"
```

**Windows (PowerShell):**
```powershell
# Módulo: 17 % 5
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/modulo?a=17&b=5"

# Logaritmo natural de 10
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/logaritmo?n=10"

# Coseno de 60 grados
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/coseno?angulo=60"

# Tangente de 45 grados
curl.exe -H "X-API-Version: v2" "http://localhost:8080/versioned/tangente?angulo=45"
```

## ¿Por qué usar versionado?

1. **Retrocompatibilidad**: Los clientes antiguos siguen funcionando con V1
2. **Innovación**: Puedes añadir nuevas funcionalidades en V2 sin romper V1
3. **Migración gradual**: Los clientes pueden migrar a su propio ritmo
4. **Deprecación controlada**: Puedes avisar con tiempo antes de eliminar V1

## ¡Felicidades!
Has implementado versionado de APIs, una práctica esencial para mantener servicios en producción. 🎉

## Siguiente paso
Ejercicio 07: Circuit Breaker - Proteger servicios contra fallos en cascada.
