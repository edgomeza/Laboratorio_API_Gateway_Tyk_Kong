# Backend CORS Proxy (Port 3000)

## 🎯 Propósito

Este es un **servidor Node.js Express** que actúa como **proxy CORS** para permitir que la interfaz web (localhost:80) acceda a los microservicios Java sin problemas de CORS.

## ⚠️ ¿Por qué existe?

Los navegadores web bloquean peticiones cross-origin por razones de seguridad. Cuando la interfaz web (servida por Nginx en puerto 80) intenta hacer `fetch()` a los microservicios directamente (puertos 8081-8085), el navegador **bloquea la petición** con error:

```
Access to fetch at 'http://localhost:8081/...' from origin 'http://localhost' has been blocked by CORS policy
```

**Solución:** Este proxy tiene CORS habilitado, así que la web SÍ puede acceder a él, y él se encarga de llamar a los microservicios.

---

## 🏗️ Arquitectura

```
┌──────────────┐         ┌──────────────┐         ┌─────────────────┐
│   Navegador  │────────▶│ Backend:3000 │────────▶│  Microservicio  │
│ (localhost)  │   ✅    │  (CORS proxy)│   ✅    │  (8081-8085)    │
└──────────────┘         └──────────────┘         └─────────────────┘

Sin proxy:
┌──────────────┐                                  ┌─────────────────┐
│   Navegador  │─────────────────X──────────────▶│  Microservicio  │
│ (localhost)  │        ❌ CORS blocked           │  (8081-8085)    │
└──────────────┘                                  └─────────────────┘
```

---

## 📡 Endpoints Disponibles

### 1. Acceso Directo (sin gateway)
Estos endpoints permiten a la web acceder a los microservicios **sin pasar por Tyk ni Kong**:

- `GET /direct/suma?a=10&b=5` → Suma directa
- `GET /direct/resta?a=20&b=8` → Resta directa
- `GET /direct/multiplica?a=7&b=6` → Multiplicación directa
- `GET /direct/divide?a=100&b=5` → División directa

### 2. Orquestador
Acceso al microservicio orquestador:

- `GET /orchestrator/suma?a=10&b=5`
- `GET /orchestrator/resta?a=20&b=8`
- `GET /orchestrator/multiplica?a=7&b=6`
- `GET /orchestrator/divide?a=100&b=5`

### 3. Sistema
- `GET /health` - Health check
- `GET /metrics` - Métricas de uso

---

## 🎓 Para Estudiantes

Este proxy **NO** es un API Gateway como Tyk o Kong. No tiene:
- ❌ Autenticación
- ❌ Rate limiting
- ❌ Caching
- ❌ Transformaciones
- ❌ Circuit breakers

**Es solo un proxy simple para evitar CORS.**

Para aprender sobre API Gateways de verdad, usa:
- **Tyk Gateway** → `http://localhost:8080`
- **Kong Gateway** → `http://localhost:8000`

---

## 🔄 Diferencia: Con Gateway vs Sin Gateway

### Sin Gateway (a través de este proxy)
```bash
curl "http://localhost:3000/direct/suma?a=10&b=5"
```
✅ Funciona (acceso directo al microservicio)
❌ Sin protección, sin caché, sin rate limiting

### Con Gateway (Tyk o Kong)
```bash
curl "http://localhost:8080/calc/suma?a=10&b=5"  # Tyk
curl "http://localhost:8000/calc/suma?a=10&b=5"  # Kong
```
✅ Con autenticación
✅ Con rate limiting
✅ Con caché
✅ Con transformaciones

---

## 📊 Métricas

El proxy recopila métricas básicas:
- Total de peticiones
- Peticiones exitosas/fallidas
- Tiempo promedio de respuesta
- Uso por operación (suma, resta, multiplica, divide)
- Detección de origen (Tyk, Kong, o directo)

Acceso: `GET /metrics`

---

## 🛠️ Variables de Entorno

```bash
PORT=3000  # Puerto del proxy (default: 3000)
CALC_SUMA_URL=http://localhost:8081
CALC_RESTA_URL=http://localhost:8082
CALC_MULTIPLICA_URL=http://localhost:8083
CALC_DIVIDE_URL=http://localhost:8084
CALC_ORQUESTADOR_URL=http://localhost:8085
```

---

## 🚀 Ejecución

```bash
# Instalar dependencias
npm install

# Ejecutar
npm start

# O con Docker Compose (recomendado)
docker-compose up backend
```

---

## 📝 Notas Técnicas

1. **CORS está habilitado para todos los orígenes** (`*`)
2. **Timeout de peticiones:** 10 segundos
3. **Usa Axios** para hacer peticiones HTTP a los microservicios
4. **Express + CORS middleware** para permitir acceso desde el navegador

---

## ❓ Preguntas Frecuentes

### ¿Por qué no habilitar CORS directamente en los microservicios Java?

Porque:
1. Los microservicios son Java/Wildfly → requeriría modificar código
2. Es más realista tener un proxy en el ambiente de desarrollo
3. Separa las responsabilidades (los microservicios no saben de CORS)

### ¿Este proxy se usa en producción?

**NO**. En producción usarías:
- Un API Gateway real (Tyk, Kong, AWS API Gateway, etc.)
- O habilitarías CORS en los microservicios
- O servirías el frontend desde el mismo dominio que el backend

Este proxy **solo existe para el ambiente educativo**.

### ¿Puedo eliminarlo?

No, porque la web necesita acceder a los microservicios y el navegador bloquearía las peticiones directas.

---

## 📚 Ver También

- [Ejercicios Tyk](../exercises/tyk/)
- [Ejercicios Kong](../exercises/kong/)
- [Documentación completa](../README.md)
