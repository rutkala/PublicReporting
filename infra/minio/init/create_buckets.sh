#!/bin/sh
set -e

echo "Running MinIO bucket initialization..."

# Use env vars passed from docker-compose.yml
MINIO_ALIAS="minio"
MINIO_SERVER_URL=${MINIO_SERVER_URL}
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
BUCKET_NAME=${MINIO_BUCKET_NAME}

# Configure mc alias
echo "Setting mc alias..."
mc alias set $MINIO_ALIAS $MINIO_SERVER_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Check if bucket exists
echo "Checking if bucket '$BUCKET_NAME' exists..."
if mc ls $MINIO_ALIAS/$BUCKET_NAME >/dev/null 2>&1; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    echo "Bucket '$BUCKET_NAME' does not exist. Creating..."
    mc mb $MINIO_ALIAS/$BUCKET_NAME
    echo "Bucket '$BUCKET_NAME' created."
fi

echo "MinIO initialization completed."
