#!/bin/bash
CERT_DIR="/opt/publicreporting/Infrastructure/Lakehouse/minio-certs"

mkdir -p "$CERT_DIR"

if [ ! -f "$CERT_DIR/private.key" ] || [ ! -f "$CERT_DIR/public.crt" ]; then
  echo "[PreDeployment] Generating self-signed TLS certificates..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DIR/private.key" \
    -out "$CERT_DIR/public.crt" \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=yourdomain.com"
else
  echo "[PreDeployment] Certificates already exist, skipping generation."
fi
