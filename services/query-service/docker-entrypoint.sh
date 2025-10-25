#!/bin/sh
set -e

# Read password from Docker secret file if PASSWORD_FILE is set
if [ -n "$SPRING_DATASOURCE_PASSWORD_FILE" ] && [ -f "$SPRING_DATASOURCE_PASSWORD_FILE" ]; then
    export DB_PASSWORD=$(cat "$SPRING_DATASOURCE_PASSWORD_FILE")
fi

# Execute the main command
exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar
