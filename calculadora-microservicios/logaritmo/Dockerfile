FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar pom.xml y descargar dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código fuente y compilar
COPY src ./src
RUN mvn clean package -DskipTests

# Imagen final con Wildfly
FROM quay.io/wildfly/wildfly:31.0.0.Final-jdk17

# Copiar el WAR compilado al directorio de deployments de Wildfly
COPY --from=builder /app/target/logaritmo.war /opt/jboss/wildfly/standalone/deployments/

# Exponer puerto de Wildfly
EXPOSE 8080

# Iniciar Wildfly en modo standalone
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
