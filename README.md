# 🧮 Calculadora Microservicios - API Gateway

**Plataforma Interactiva para Aprender Tyk y Kong con Microservicios Reales**

Una experiencia de aprendizaje donde descubres las funcionalidades de API Gateways usando una arquitectura real de microservicios de calculadora.

---

## ✨ ¿Qué es esto?

Un proyecto educativo completo que combina:

- 🧮 **5 Microservicios Java**: Suma, Resta, Multiplicación, División y Orquestador
- 🚪 **2 API Gateways**: Tyk y Kong configurados y listos
- 🌐 **Frontend Interactivo**: Calculadora visual con métricas en tiempo real
- 📚 **Ejercicios Prácticos**: Aprende proxy, autenticación, rate limiting, caché y más
- 📊 **Comparativas Reales**: Ve la diferencia de performance con y sin caché

---

## 🏗️ Arquitectura

```
┌─────────────┐
│   Cliente   │ (Tu navegador)
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│      API Gateways          │
│  ┌─────┐ ┌──────┐ ┌───────┐│
│  │ Tyk │ │ Kong │ │Backend││
│  │8080 │ │ 8000 │ │ 3000  ││
│  └─────┘ └──────┘ └───────┘│
└──────────────┬──────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│         Microservicios (Java + Wildfly)   │
│  ┌──────┐ ┌──────┐ ┌───────┐ ┌────────┐  │
│  │ Suma │ │Resta │ │Multipl│ │Divide  │  │
│  │ 8081 │ │ 8082 │ │  8083 │ │  8084  │  │
│  └──────┘ └──────┘ └───────┘ └────────┘  │
│                                            │
│              ┌────────────────┐            │
│              │  Orquestador   │            │
│              │      8085      │            │
│              └────────────────┘            │
└────────────────────────────────────────────┘
```

---

## 🚀 Inicio Rápido

### 1. Requisitos

- **Docker Desktop** (20.10+)
- **Docker Compose** (2.0+)
- **10 GB RAM** disponibles
- **Puertos libres**: 80, 3000, 8080-8085, 8000-8002, 5432, 6379

### 2. Iniciar Todo

```bash
# Clonar el repositorio
git clone <repo-url>
cd Api_Gateway_Tyk_Kong

# Iniciar toda la plataforma (tarda ~3 minutos)
docker-compose up -d

# Ver logs (opcional)
docker-compose logs -f
```

### 3. Abrir la Plataforma

**🌐 Frontend**: http://localhost
**📊 Métricas Backend**: http://localhost:3000/metrics
**🔷 Tyk Gateway**: http://localhost:8080
**🦍 Kong Admin**: http://localhost:8001

---

## 🧮 Microservicios de Calculadora

Cada operación es un microservicio independiente en Java:

| Servicio       | Puerto | Endpoint                                        | Ejemplo                                          |
|----------------|--------|-------------------------------------------------|--------------------------------------------------|
| **Suma**       | 8081   | `/suma/calculadora/suma?a=10&b=5`               | `curl localhost:8081/suma/calculadora/suma?a=10&b=5` |
| **Resta**      | 8082   | `/resta/calculadora/resta?a=20&b=8`             | `curl localhost:8082/resta/calculadora/resta?a=20&b=8` |
| **Multiplica** | 8083   | `/multiplica/calculadora/multiplica?a=7&b=6`    | `curl localhost:8083/multiplica/calculadora/multiplica?a=7&b=6` |
| **Divide**     | 8084   | `/divide/calculadora/divide?a=100&b=5`          | `curl localhost:8084/divide/calculadora/divide?a=100&b=5` |
| **Orquestador**| 8085   | `/calculadora/calc/{operacion}?a=X&b=Y`         | `curl localhost:8085/calculadora/calc/suma?a=15&b=25` |

**Respuesta JSON:**
```json
{
  "resultado": 15.0,
  "mensaje": "Suma realizada correctamente",
  "estado": "OK"
}
```

---

## 📚 Ejercicios Prácticos

### Para Tyk y Kong (5 ejercicios cada uno)

| #  | Ejercicio            | Concepto                     | Nivel        | Tiempo  |
|----|----------------------|------------------------------|--------------|---------|
| 01 | Proxy Básico         | Enrutamiento                 | Básico       | 5 min   |
| 02 | Autenticación        | API Keys                     | Básico       | 10 min  |
| 03 | Rate Limiting        | Límites de peticiones        | Intermedio   | 10 min  |
| 04 | Caché                | Performance 20x más rápido   | Intermedio   | 15 min  |
| 05 | Transformaciones     | Modificar requests/responses | Avanzado     | 15 min  |

### ¿Cómo completar un ejercicio?

#### Para Tyk:

1. Navega a `exercises/tyk/01-basic-proxy/`
2. Abre `config.json` y **descomenta todas las líneas** (elimina `//`)
3. Guarda y espera 5-10 segundos
4. Prueba con: `curl "http://localhost:8080/calc/suma?a=15&b=25"`

#### Para Kong:

1. Navega a `exercises/kong/01-basic-proxy/`
2. Abre `setup.sh` y **descomenta los comandos curl**
3. Ejecuta: `bash setup.sh`
4. Prueba con: `curl "http://localhost:8000/calc/suma?a=15&b=25"`

---

## ⚡ Comparativa de Performance (Ejercicio 04)

El ejercicio de caché es especial porque incluye **pruebas cuantificables**:

```bash
# 🔴 SIN caché - 100 peticiones
time for i in {1..100}; do
  curl -s "http://localhost:8081/suma/calculadora/suma?a=15&b=25" > /dev/null
done
# Resultado esperado: ~2000ms

# 🟢 CON caché - 100 peticiones
time for i in {1..100}; do
  curl -s "http://localhost:8080/calc/suma/cached?a=15&b=25" > /dev/null
done
# Resultado esperado: ~100ms

# 🚀 Mejora: 20x más rápido!
```

---

## 🎨 Frontend Interactivo

El frontend en **http://localhost** incluye:

✅ **Calculadora Visual**
- Botones grandes para suma, resta, multiplicación y división
- Selector de gateway (Backend, Tyk, Kong, Directo)
- Display con operación y resultado

✅ **Métricas en Tiempo Real**
- Total de peticiones
- Tiempo promedio de respuesta
- Tasa de éxito
- Gráfico por tipo de operación

✅ **Arquitectura Visual**
- Diagrama de microservicios
- Estado de cada servicio (activo/inactivo)

✅ **Sección de Ejercicios**
- Cards por cada ejercicio
- Links directos a READMEs
- Tags de dificultad y tiempo estimado

✅ **Comparativas de Performance**
- Botones para probar 50 requests con/sin caché
- Resultados en tiempo real
- Factor de mejora calculado automáticamente

---

## 🛠️ Tecnologías Utilizadas

### Backend
- **Java 21** + **Maven** - Microservicios
- **Wildfly 31** - Servidor de aplicaciones
- **JAX-RS** - APIs REST
- **Node.js + Express** - Gateway backend
- **Docker** - Containerización

### API Gateways
- **Tyk Gateway 5.2** - Kong
- **Kong Gateway 3.5** - Con PostgreSQL

### Frontend
- **HTML5 + CSS3** - Diseño moderno con gradientes
- **Vanilla JavaScript** - Sin frameworks
- **Nginx** - Servidor web

---

## 📂 Estructura del Proyecto

```
Api_Gateway_Tyk_Kong/
├── calculadora-microservicios/     # 5 microservicios Java
│   ├── suma/                        # Microservicio de suma
│   ├── resta/                       # Microservicio de resta
│   ├── multiplica/                  # Microservicio de multiplicación
│   ├── divide/                      # Microservicio de división
│   └── calculadora/                 # Orquestador
├── api/                             # Backend Gateway (Node.js)
│   ├── server.js                    # Proxy a microservicios
│   ├── package.json
│   └── Dockerfile
├── web/                             # Frontend
│   ├── index.html                   # Calculadora visual
│   ├── css/styles.css               # Estilos modernos
│   └── js/app.js                    # Lógica interactiva
├── exercises/                       # Ejercicios prácticos
│   ├── tyk/                         # 5 ejercicios Tyk
│   │   ├── 01-basic-proxy/
│   │   ├── 02-authentication/
│   │   ├── 03-rate-limiting/
│   │   ├── 04-caching/              # Con comparativas!
│   │   └── 05-transformations/
│   └── kong/                        # 5 ejercicios Kong (mismos conceptos)
├── gateway-configs/                 # Configuraciones
│   ├── tyk/
│   └── kong/
├── docker-compose.yml               # Orquestación completa
└── README.md                        # Este archivo
```

---

## 🔧 Comandos Útiles

```bash
# Iniciar todo
docker-compose up -d

# Ver logs de un servicio específico
docker-compose logs -f calc-suma
docker-compose logs -f tyk-gateway
docker-compose logs -f kong

# Reiniciar un servicio
docker-compose restart calc-suma

# Ver estado de servicios
docker-compose ps

# Detener todo
docker-compose down

# Detener y limpiar volúmenes (RESET COMPLETO)
docker-compose down -v
```

---

## 📊 Endpoints Disponibles

### Backend Gateway (3000)

| Endpoint                      | Descripción                        |
|-------------------------------|------------------------------------|
| `GET /health`                 | Health check                       |
| `GET /metrics`                | Métricas completas                 |
| `GET /calc/{op}?a=X&b=Y`      | Operación vía gateway              |
| `GET /direct/{op}?a=X&b=Y`    | Operación directa a microservicio  |
| `GET /orchestrator/{op}?a=X&b=Y` | Vía orquestador                 |

### Microservicios Directos

```bash
# Suma
curl "http://localhost:8081/suma/calculadora/suma?a=10&b=5"

# Resta
curl "http://localhost:8082/resta/calculadora/resta?a=20&b=8"

# Multiplicación
curl "http://localhost:8083/multiplica/calculadora/multiplica?a=7&b=6"

# División
curl "http://localhost:8084/divide/calculadora/divide?a=100&b=5"

# Orquestador
curl "http://localhost:8085/calculadora/calc/suma?a=15&b=25"
```

---

## 🎓 Conceptos que Aprenderás

### 1. **Microservicios**
- Arquitectura distribuida
- Independencia de servicios
- Escalabilidad horizontal
- Resiliencia

### 2. **API Gateways**
- Proxy y enrutamiento
- Autenticación centralizada
- Rate limiting
- Caché de respuestas
- Transformación de datos

### 3. **DevOps**
- Containerización con Docker
- Orquestación con Docker Compose
- Health checks
- Logs y monitoreo

### 4. **Performance**
- Medición de tiempos de respuesta
- Comparativas con/sin caché
- Optimización de latencia

---

## 🤝 Autores

**Eduardo Gómez Almendral**
**Manahen García Garrido**

**Asignatura**: Arquitectura Orientada a Servicios (AOS)
**Universidad**: Universidad de Extremadura
**Año**: 2025

---

## 📝 Licencia

MIT License - Proyecto educativo

---

## 🆘 Troubleshooting

### Problema: Puertos ocupados

```bash
# Ver qué está usando el puerto
lsof -i :8080
netstat -ano | findstr :8080  # Windows

# Cambiar puertos en docker-compose.yml si es necesario
```

### Problema: Servicios no inician

```bash
# Ver logs
docker-compose logs

# Reiniciar servicios
docker-compose restart

# Reset completo
docker-compose down -v
docker-compose up -d
```

### Problema: Microservicios tardan en iniciar

Los microservicios Java con Wildfly tardan ~60-90 segundos en estar completamente operativos. Espera a que los health checks pasen:

```bash
# Ver estado
docker-compose ps

# Debería mostrar "healthy" en todos los servicios
```

---

## 🎯 Próximos Pasos

1. ✅ Completa los 5 ejercicios de Tyk
2. ✅ Completa los 5 ejercicios de Kong
3. ✅ Compara diferencias entre Tyk y Kong
4. ✅ Experimenta con la calculadora interactiva
5. ✅ Realiza pruebas de performance
6. ✅ Modifica configuraciones y observa cambios

---

**¡Feliz aprendizaje! 🚀**
