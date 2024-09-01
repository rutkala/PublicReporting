#!/bin/bash

# Set variables for MinIO
MINIO_ALIAS="myminio"
MINIO_SERVER_URL="http://localhost:9000"
MINIO_ACCESS_KEY="minioadmin"  # Replace with your MinIO access key
MINIO_SECRET_KEY="minioadmin"  # Replace with your MinIO secret key
BUCKET_NAME="warehouse"
MC_PATH="/usr/local/bin/mc"

# Function to install mc (MinIO Client)
install_mc() {
    echo "Installing mc (MinIO Client)..."
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O mc
    chmod +x mc
    sudo mv mc /usr/local/bin/
    echo "mc (MinIO Client) installed successfully."
}

# Check if mc is installed, install if not
if ! command -v mc &> /dev/null
then
    echo "mc (MinIO Client) not found, installing now..."
    install_mc
else
    echo "mc (MinIO Client) is already installed."
fi

# Configure the MinIO client alias
mc alias set $MINIO_ALIAS $MINIO_SERVER_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Check if the bucket already exists
if mc ls $MINIO_ALIAS/$BUCKET_NAME > /dev/null 2>&1; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    # Create the bucket
    echo "Creating bucket '$BUCKET_NAME'..."
    mc mb $MINIO_ALIAS/$BUCKET_NAME
    if [ $? -eq 0 ]; then
        echo "Bucket '$BUCKET_NAME' created successfully."
    else
        echo "Failed to create bucket '$BUCKET_NAME'."
        exit 1
    fi
fi
