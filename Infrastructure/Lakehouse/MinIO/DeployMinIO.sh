#!/bin/bash

chmod +x PreDeployment.sh
chmod +x PostDeployment.sh

echo "Starting PreDeployment..."
./PreDeployment.sh

echo "Starting Docker Compose Up..."
docker-compose -f /opt/publicreporting/Infrastructure/Lakehouse/docker-compose.yml up minio -d

echo "Starting PostDeployment..."
./PostDeployment.sh

echo "Deployment completed."
