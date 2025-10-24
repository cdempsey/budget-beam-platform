# syntax=docker/dockerfile:1.6
FROM --platform=$TARGETPLATFORM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /app
COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle ./
RUN chmod +x gradlew && \
    ./gradlew dependencies

COPY src/ src/
# Build (download dependencies will happen during build; avoid running assemble before sources are copied
# because some projects configure bootJar/mainClass dynamically which fails when sources are missing)
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon build -x test

FROM --platform=$TARGETPLATFORM eclipse-temurin:21-jre-jammy AS runtime

# Define build argument for creation date
ARG CREATED_DATE

# Add Spring Boot application information
LABEL org.opencontainers.image.title="BudgetBeam Enrichment Service" \
      org.opencontainers.image.description="Service for enriching budget data" \
      org.opencontainers.image.source="https://github.com/cdempsey/budget-beam-platform" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.created=${CREATED_DATE} \
      org.opencontainers.image.vendor="BudgetBeam"

# Create a non-root user (create group if missing, tolerate existing user)
RUN groupadd -r spring || true && \
    useradd -r -u 1000 -g spring -s /usr/sbin/nologin spring || true

WORKDIR /app

# Copy the jar from builder stage
COPY --from=builder --chown=spring:spring /app/build/libs/*.jar app.jar

# Install unzip (used to validate packaged properties) and configure JVM for containerized environment
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Configure JVM for containerized environment
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -XX:+OptimizeStringConcat \
               -XX:+UseStringDeduplication \
               -Djava.security.egd=file:/dev/./urandom \
               -Dspring.output.ansi.enabled=ALWAYS"

# Validate the jar (extract application.properties and ensure the application name is set)
RUN mkdir -p BOOT-INF/classes && \
    unzip -p app.jar BOOT-INF/classes/application.properties > BOOT-INF/classes/application.properties && \
    grep -q "spring.application.name=" BOOT-INF/classes/application.properties

# Set up container configuration
EXPOSE 8080
USER spring:spring
WORKDIR /app
VOLUME ["/tmp", "/logs"]

# Health check using Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set read-only filesystem
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]

# Security options
STOPSIGNAL SIGTERM
LABEL securitytxt="https://budgetbeam.example.com/.well-known/security.txt"