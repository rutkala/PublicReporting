#!/bin/bash
set -e

# Run from your project directory (where docker-compose.yml lives)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/.."
NGINX_CONF_DIR="$BASE_DIR/nginx/conf.d"
NGINX_CERT_DIR="$BASE_DIR/nginx/certs"

echo "[PreDeployment] Creating nginx folders..."
mkdir -p "$NGINX_CONF_DIR"
mkdir -p "$NGINX_CERT_DIR"

echo "[PreDeployment] Directories prepared:"
echo "  - $NGINX_CONF_DIR"
echo "  - $NGINX_CERT_DIR"

echo "[PreDeployment] Skipping self-signed certificate generation. We'll use Let's Encrypt (via certbot or companion container)."
