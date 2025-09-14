#!/bin/bash
set -e
CERTS_DIR="./certs"

echo "[PreDeployment] Creating nginx config and certs folders if not exist..."
mkdir -p "$CERTS_DIR"

echo "[PreDeployment] Applying HTTP-only config to enable certbot validation..."
cp "./conf.d/minio-http.conf" "./conf.d/minio.conf"
