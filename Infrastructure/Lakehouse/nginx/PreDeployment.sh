#!/bin/bash
set -e
CERTS_DIR="./certs"

echo "[PreDeployment] Creating nginx config and certs folders if not exist..."
mkdir -p "$CERTS_DIR"

echo "[PreDeployment] Applying HTTP-only config to enable certbot validation..."
cp "./conf.d/minio-http.conf" "./conf.d/minio.conf"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./certs/live/storage.open-reporting.dev/privkey.pem \
  -out ./certs/live/storage.open-reporting.dev/fullchain.pem \
  -subj "/CN=storage.open-reporting.dev"
