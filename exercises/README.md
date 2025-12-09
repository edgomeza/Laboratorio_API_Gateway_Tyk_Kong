# 📚 Ejercicios Interactivos - API Gateway

Bienvenido a los ejercicios interactivos de Tyk y Kong!

---

## 🎯 Cómo Funciona

### Concepto Simple

1. ✅ Cada ejercicio tiene archivos con código **comentado**
2. ✅ **Descomenta el código** para activar la funcionalidad
3. ✅ El sistema detecta el cambio **automáticamente**
4. ✅ La funcionalidad se activa y puedes **probarla en vivo**

### No Necesitas

- ❌ Escribir código desde cero
- ❌ Conocer la sintaxis completa
- ❌ Ejecutar comandos complejos
- ❌ Reiniciar servicios manualmente

### Solo Necesitas

- ✅ Abrir un archivo
- ✅ Eliminar los comentarios (`//` o `#`)
- ✅ Guardar el archivo
- ✅ ¡Listo!

---

## 📂 Estructura

```
exercises/
├── tyk/                    # Ejercicios con Tyk Gateway
│   ├── 01-basic-proxy/     # ⭐ Nivel: Básico
│   ├── 02-authentication/  # ⭐ Nivel: Básico
│   ├── 03-rate-limiting/   # ⭐⭐ Nivel: Intermedio
│   ├── 04-caching/         # ⭐⭐ Nivel: Intermedio
│   └── 05-transformations/ # ⭐⭐⭐ Nivel: Avanzado
│
└── kong/                   # Ejercicios con Kong Gateway
    ├── 01-basic-proxy/     # ⭐ Nivel: Básico
    ├── 02-authentication/  # ⭐ Nivel: Básico
    ├── 03-rate-limiting/   # ⭐⭐ Nivel: Intermedio
    ├── 04-caching/         # ⭐⭐ Nivel: Intermedio
    └── 05-transformations/ # ⭐⭐⭐ Nivel: Avanzado
```

---

## 🚀 Empezar

### Opción 1: Desde la Web (Recomendado)

1. Abre **http://localhost** en tu navegador
2. Sigue las instrucciones visuales
3. Los ejercicios se desbloquean progresivamente

### Opción 2: Desde la Terminal

```bash
# 1. Ve a un ejercicio
cd exercises/tyk/01-basic-proxy

# 2. Lee la guía
cat README.md

# 3. Edita el archivo de configuración
nano config.json  # o vim, code, etc.

# 4. Descomenta todo (elimina los //)

# 5. Guarda y espera 5-10 segundos

# 6. Prueba la funcionalidad
curl "http://localhost:8080/calc/suma?a=15&b=25"
```

---

## 📖 Orden Sugerido

### Path 1: Aprendizaje Tyk

```
1. exercises/tyk/01-basic-proxy/
   ↓
2. exercises/tyk/02-authentication/
   ↓
3. exercises/tyk/03-rate-limiting/
   ↓
4. exercises/tyk/04-caching/
   ↓
5. exercises/tyk/05-transformations/
```

### Path 2: Aprendizaje Kong

```
1. exercises/kong/01-basic-proxy/
   ↓
2. exercises/kong/02-authentication/
   ↓
3. exercises/kong/03-rate-limiting/
   ↓
4. exercises/kong/04-caching/
   ↓
5. exercises/kong/05-transformations/
```

### Path 3: Comparativo (Avanzado)

Alterna entre Tyk y Kong para comparar:
```
1. tyk/01 vs kong/01
2. tyk/02 vs kong/02
3. tyk/03 vs kong/03
4. etc.
```

---

## 🎓 Qué Aprenderás

### Ejercicio 1: Proxy Básico
- ✅ Enrutamiento de peticiones
- ✅ Configuración básica de gateway
- ✅ Path stripping y rewriting

**Tiempo estimado:** 5 minutos

### Ejercicio 2: Autenticación
- ✅ API Keys
- ✅ Control de acceso
- ✅ Headers de autenticación

**Tiempo estimado:** 10 minutos

### Ejercicio 3: Rate Limiting
- ✅ Límites por tiempo
- ✅ Protección contra abuso
- ✅ Políticas de rate limiting

**Tiempo estimado:** 10 minutos

### Ejercicio 4: Caching
- ✅ Caché de respuestas
- ✅ TTL (Time To Live)
- ✅ Mejora de rendimiento

**Tiempo estimado:** 15 minutos

### Ejercicio 5: Transformaciones
- ✅ Modificar headers
- ✅ Transformar requests/responses
- ✅ Middleware personalizado

**Tiempo estimado:** 15 minutos

**Total:** ~1 hora por gateway (Tyk o Kong)

---

## 💡 Tips y Trucos

### Para Tyk (archivos JSON)

**Antes de descomentar:**
```json
//{
//  "name": "My API",
//  "api_id": "my-api"
//}
```

**Después de descomentar:**
```json
{
  "name": "My API",
  "api_id": "my-api"
}
```

**⚠️ Importante:** Asegúrate de que el JSON sea válido después de descomentar.

### Para Kong (archivos Shell)

**Antes de descomentar:**
```bash
## Crear service
#curl -X POST http://localhost:8001/services \
#  --data name=my-service
```

**Después de descomentar:**
```bash
## Crear service
curl -X POST http://localhost:8001/services \
  --data name=my-service
```

**⚠️ Importante:** Guarda y luego ejecuta: `bash setup.sh`

---

## 🔍 Verificar tu Progreso

### Desde la Web
- Abre http://localhost
- Ve tu progreso en el dashboard
- Ejercicios completados se marcan en verde

### Desde la Terminal

```bash
# Ver configuraciones activas de Tyk
ls gateway-configs/tyk/apps-active/

# Ver configuraciones de Kong
curl http://localhost:8001/services
curl http://localhost:8001/routes
```

---

## 🐛 Problemas Comunes

### El ejercicio no se activa

**Causas posibles:**
1. No eliminaste **todos** los comentarios
2. El archivo tiene errores de sintaxis
3. Los servicios no están corriendo

**Solución:**
```bash
# 1. Verifica que los servicios estén corriendo
docker-compose ps

# 2. Revisa los logs
docker-compose logs tyk-gateway
docker-compose logs kong

# 3. Revisa el archivo
cat exercises/tyk/01-basic-proxy/config.json
```

### JSON inválido (Tyk)

**Error común:**
```json
// ❌ Incorrecto - coma sobrante
{
  "name": "API",
  "active": true,  // ← Coma extra aquí
}

// ✅ Correcto
{
  "name": "API",
  "active": true
}
```

**Validar JSON:**
```bash
cat config.json | jq .
```

### Script no se ejecuta (Kong)

**Si bash setup.sh no funciona:**
```bash
# Dale permisos de ejecución
chmod +x setup.sh

# Ejecuta con bash explícito
bash setup.sh

# O ejecuta línea por línea
curl -X POST http://localhost:8001/services --data name=my-service
```

---

## 📚 Recursos por Ejercicio

Cada ejercicio incluye:
- ✅ `README.md` - Guía paso a paso
- ✅ `config.json` o `setup.sh` - Archivo de configuración comentado
- ✅ Comandos de prueba
- ✅ Explicación de conceptos
- ✅ Enlaces a documentación

---

## 🎯 Checklist de Completitud

### Tyk
- [ ] 01 - Proxy Básico
- [ ] 02 - Autenticación
- [ ] 03 - Rate Limiting
- [ ] 04 - Caching
- [ ] 05 - Transformaciones

### Kong
- [ ] 01 - Proxy Básico
- [ ] 02 - Autenticación
- [ ] 03 - Rate Limiting
- [ ] 04 - Caching
- [ ] 05 - Transformaciones

---

## 🏆 Certificado de Completitud

Cuando termines todos los ejercicios:

1. Toma screenshot de tu dashboard en http://localhost
2. Muestra tu progreso 100%
3. ¡Compártelo con tus compañeros!

---

## ❓ ¿Necesitas Ayuda?

1. **Lee el README.md del ejercicio** - Tiene toda la info
2. **Revisa los logs** - `docker-compose logs -f`
3. **Consulta la documentación** oficial de Tyk/Kong
4. **Pregunta a tus instructores**

---

**¡Buena suerte y feliz aprendizaje! 🚀**
