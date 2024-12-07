#!/bin/bash

# Variables
TRINO_CONTAINER="trino"
LOCAL_ICEBERG_PROPERTIES="./iceberg.properties"

echo "Running post-deployment script for Trino..."

# Wait for Trino to be healthy
until [[ "$(docker inspect --format='{{.State.Health.Status}}' $TRINO_CONTAINER)" == "healthy" ]]; do
    echo "Waiting for Trino to be healthy..."
    sleep 5
done

echo "Trino is healthy. Proceeding with configuration..."

# Check if the Trino container is running
if [ "$(docker ps -q -f name=$TRINO_CONTAINER)" ]; then
    echo "Trino container is running."
else
    echo "Trino container is not running. Starting the container..."
    docker-compose up -d $TRINO_CONTAINER
    # Wait for a few seconds to ensure the container starts
    sleep 5
fi

# Copy the iceberg.properties file into the container
if [ -f "$LOCAL_ICEBERG_PROPERTIES" ]; then
    echo "Copying $LOCAL_ICEBERG_PROPERTIES into the Trino container..."
    docker cp "$LOCAL_ICEBERG_PROPERTIES" $TRINO_CONTAINER:/etc/trino/catalog/iceberg.properties

    # Set ownership and permissions
    echo "Setting permissions for iceberg.properties..."
    docker exec -u root -it $TRINO_CONTAINER bash -c "chown trino:trino /etc/trino/catalog/iceberg.properties && chmod 644 /etc/trino/catalog/iceberg.properties"

    # Restart the Trino container to apply the new configuration
    echo "Restarting the Trino container to apply the new configuration..."
    docker restart $TRINO_CONTAINER

    echo "iceberg.properties has been copied to the Trino container and the container has been restarted."
else
    echo "Error: $LOCAL_ICEBERG_PROPERTIES not found. Skipping configuration."
    exit 1
fi

echo "Post-deployment script for Trino completed successfully."
