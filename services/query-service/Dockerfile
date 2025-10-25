# syntax=docker/dockerfile:1.6
FROM --platform=$TARGETPLATFORM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /app
COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle ./
RUN chmod +x gradlew && \
    ./gradlew dependencies
# Copy sources before building. Some projects configure bootJar/mainClass dynamically so sources must be present.
COPY src/ src/
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon build -x test

FROM --platform=$TARGETPLATFORM eclipse-temurin:21-jre-jammy AS runtime

# Define build argument for creation date
ARG CREATED_DATE

# Add Spring Boot application information
LABEL org.opencontainers.image.title="BudgetBeam Query Service" \
      org.opencontainers.image.description="Service for querying budget data" \
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

# Copy entrypoint script
COPY --chown=spring:spring docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Configure JVM for containerized environment
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -XX:+OptimizeStringConcat \
               -XX:+UseStringDeduplication \
               -Djava.security.egd=file:/dev/./urandom \
               -Dspring.output.ansi.enabled=ALWAYS"

# Install unzip for validation and validate the jar by extracting application.properties
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

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

# Use entrypoint script to handle Docker secrets
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Security options
STOPSIGNAL SIGTERM
LABEL securitytxt="https://budgetbeam.example.com/.well-known/security.txt"