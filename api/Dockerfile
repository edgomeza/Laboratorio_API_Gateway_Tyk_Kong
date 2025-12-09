FROM node:18-alpine

# Metadata
LABEL maintainer="Eduardo Gómez Almendral y Manahen García Garrido"
LABEL description="Backend service de ejemplo para ejercicios de API Gateway"

# Crear directorio de trabajo
WORKDIR /app

# Instalar wget para healthcheck
RUN apk add --no-cache wget

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción
RUN npm install --production && \
    npm cache clean --force

# Copiar código fuente
COPY . .

# Exponer puerto
EXPOSE 3000

# Usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Comando de inicio
CMD ["node", "server.js"]
