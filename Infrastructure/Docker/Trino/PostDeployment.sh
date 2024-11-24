#!/bin/bash

# Path to your local iceberg.properties file
LOCAL_ICEBERG_PROPERTIES="./iceberg.properties"

# Check if the Trino container is running
if [ "$(docker ps -q -f name=trino)" ]; then
    echo "Trino container is running. Proceeding with configuration..."
else
    echo "Trino container is not running. Starting the container..."
    docker-compose up -d trino
    # Wait for a few seconds to ensure the container starts
    sleep 5
fi

# Copy the iceberg.properties file into the container
echo "Copying iceberg.properties into the Trino container..."
docker cp "$LOCAL_ICEBERG_PROPERTIES" trino:/etc/trino/catalog/iceberg.properties

# Set ownership and permissions
echo "Setting permissions for iceberg.properties..."
docker exec -u root -it trino bash -c "chown trino:trino /etc/trino/catalog/iceberg.properties && chmod 644 /etc/trino/catalog/iceberg.properties"

# Restart the Trino container to apply the new configuration
echo "Restarting the Trino container to apply the new configuration..."
docker restart trino

echo "iceberg.properties has been copied to the Trino container and the container has been restarted."
