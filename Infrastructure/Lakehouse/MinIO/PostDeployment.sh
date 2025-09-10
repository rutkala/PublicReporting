#!/bin/bash

# Variables
MINIO_ALIAS="minio"
MINIO_SERVER_URL="http://minio:443"
MINIO_ACCESS_KEY="admin"
MINIO_SECRET_KEY="password"
BUCKET_NAME="warehouse"
MC_CONTAINER_NAME="minio_mc"  # Name of the dedicated mc container

echo "Running post-deployment script for MinIO..."

# Wait for MinIO to be healthy
until [[ "$(docker inspect --format='{{.State.Health.Status}}' minio)" == "healthy" ]]; do
    sleep 5
    echo "Waiting for MinIO to be healthy..."
done

echo "MinIO is healthy. Proceeding with bucket creation..."

# Function to execute mc commands inside the dedicated mc container
execute_mc_command() {
    echo "Executing: mc $*"
    docker exec $MC_CONTAINER_NAME mc "$@"
    if [[ $? -ne 0 ]]; then
        echo "Error: Command 'mc $*' failed." >&2
        exit 1
    fi
}

# Configure the MinIO client alias
execute_mc_command alias set $MINIO_ALIAS $MINIO_SERVER_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Check if the bucket already exists
echo "Checking if bucket '$BUCKET_NAME' exists..."
BUCKET_EXISTS=$(docker exec $MC_CONTAINER_NAME mc ls $MINIO_ALIAS 2>&1 | grep -w $BUCKET_NAME)

if [[ -n "$BUCKET_EXISTS" ]]; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    # Create the bucket
    echo "Bucket '$BUCKET_NAME' does not exist. Creating it..."
    if execute_mc_command mb $MINIO_ALIAS/$BUCKET_NAME; then
        echo "Bucket '$BUCKET_NAME' created successfully."
    else
        echo "Failed to create bucket '$BUCKET_NAME'."
        exit 1
    fi
fi

echo "Post-deployment script completed."
