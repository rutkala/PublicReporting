#!/bin/bash
chmod +x PostDeployment.sh

echo "Starting Docker Compose Up..."
docker compose -f /opt/publicreporting/Infrastructure/Lakehouse/docker-compose.yml up minio mc -d

echo "Starting PostDeployment..."
./PostDeployment.sh

echo "Deployment completed."
