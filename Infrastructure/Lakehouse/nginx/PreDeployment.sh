#!/bin/bash
set -e
NGINX_CONF_DIR="./nginx/conf.d"
CERTS_DIR="./nginx/certs"

echo "[PreDeployment] Creating nginx config and certs folders if not exist..."
mkdir -p "$NGINX_CONF_DIR" "$CERTS_DIR"

echo "[PreDeployment] Applying HTTP-only config to enable certbot validation..."
cp "$NGINX_CONF_DIR/minio-http.conf" "$NGINX_CONF_DIR/minio.conf"
