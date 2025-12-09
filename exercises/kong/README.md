# Ejercicios Kong

Esta carpeta contiene 5 ejercicios prácticos para aprender Kong Gateway.

## Estructura

Cada ejercicio tiene:
- `setup.sh` - Script con comandos comentados
- `README.md` - Guía detallada del ejercicio

## Cómo funcionan

1. Abre el archivo `setup.sh` del ejercicio
2. Descomenta todas las líneas (elimina los `#` del inicio)
3. Ejecuta el script: `bash setup.sh`
4. Prueba la funcionalidad

## Lista de Ejercicios

### 01 - Proxy Básico
Aprende a crear Services y Routes en Kong.

### 02 - Autenticación
Protege tus APIs con el plugin Key-Auth.

### 03 - Rate Limiting
Limita las peticiones con el plugin Rate Limiting.

### 04 - Caching
Mejora el rendimiento con Proxy Cache.

### 05 - Transformations
Modifica requests y responses en tiempo real.

## Comandos útiles de Kong

```bash
# Ver todos los services
curl http://localhost:8001/services

# Ver todas las routes
curl http://localhost:8001/routes

# Ver todos los plugins
curl http://localhost:8001/plugins

# Ver todos los consumers
curl http://localhost:8001/consumers

# Eliminar un service
curl -X DELETE http://localhost:8001/services/{service-name}

# Eliminar una route
curl -X DELETE http://localhost:8001/routes/{route-id}
```

## Recursos

- [Documentación oficial de Kong](https://docs.konghq.com/)
- [Kong Admin API Reference](https://docs.konghq.com/gateway/api/admin-ee/latest/)
- [Kong Plugins](https://docs.konghq.com/hub/)
