# Ejercicio 6: API Versionada con Kong - Calculadora

## Objetivo
Implementar versionado de API usando routes separadas en Kong para V1 (básica) y V2 (científica).

## ¿Qué vas a aprender?
- Configurar versionado mediante routes en Kong
- Gestionar múltiples versiones con services independientes
- Usar paths para controlar el routing

## Contexto
Kong implementa versionado usando routes separadas. A diferencia de Tyk (headers), Kong usa paths en la URL:
- **V1**: `http://localhost:8000/v1/direct/suma`
- **V2**: `http://localhost:8000/v2/direct/raiz`

## Pasos

### 1. Ejecutar el script de configuración
El archivo `setup.ps1` (Windows) o `setup.sh` (Linux/macOS) YA está descomentado y listo para usar.

**Windows (PowerShell):**
```powershell
cd exercises/kong/06-versioning
.\setup.ps1
```

**Linux/macOS:**
```bash
cd exercises/kong/06-versioning
bash setup.sh
```

### 2. Probar las versiones

#### V1 (Calculadora Básica)
**Windows:**
```powershell
curl.exe "http://localhost:8000/v1/direct/suma?a=15&b=25"
curl.exe "http://localhost:8000/v1/direct/resta?a=100&b=35"
```

**Linux/macOS:**
```bash
curl "http://localhost:8000/v1/direct/suma?a=15&b=25"
curl "http://localhost:8000/v1/direct/resta?a=100&b=35"
```

#### V2 (Calculadora Científica)
**Windows:**
```powershell
curl.exe "http://localhost:8000/v2/direct/raiz?n=25"
curl.exe "http://localhost:8000/v2/direct/potencia?base=2&exponente=10"
curl.exe "http://localhost:8000/v2/direct/seno?angulo=30"
```

**Linux/macOS:**
```bash
curl "http://localhost:8000/v2/direct/raiz?n=25"
curl "http://localhost:8000/v2/direct/potencia?base=2&exponente=10"
curl "http://localhost:8000/v2/direct/seno?angulo=30"
```

## Arquitectura

```
Cliente → /v1/direct/suma → Kong Service V1 → Backend (operaciones básicas)
Cliente → /v2/direct/raiz → Kong Service V2 → Backend (operaciones científicas)
```

## Diferencia con Tyk

| Aspecto | Tyk | Kong |
|---------|-----|------|
| Método | Header `X-API-Version` | Path `/v1` o `/v2` |
| Configuración | Un API con versions | Dos services separados |
| Flexibilidad | Cliente elige por header | Cliente elige por URL |

## ¡Felicidades!
Has implementado versionado con Kong usando routes. 🎉

## Siguiente paso
Ejercicio 07: Circuit Breaker/Retry - Resiliencia con reintentos automáticos.
