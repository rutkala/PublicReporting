#!/bin/bash
set -e
CERTS_DIR="./certs"
WWW_DIR="./www"
CONF_DIR="./conf.d"

echo "[PreDeployment] Creating nginx config, certs, and www folders if not exist..."
mkdir -p "$CERTS_DIR" "$WWW_DIR" "$CONF_DIR"

echo "[PreDeployment] Applying HTTP-only config to enable certbot validation..."
cp "$CONF_DIR/minio-http.conf" "$CONF_DIR/minio.conf"
