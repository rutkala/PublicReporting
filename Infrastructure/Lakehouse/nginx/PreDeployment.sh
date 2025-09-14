#!/bin/bash
set -e
CERTS_DIR="./certs"
WWW_DIR="./www"
CONF_DIR="./conf.d"

echo "[PreDeployment] Creating nginx config, certs, and www folders if not exist..."
mkdir -p "$CERTS_DIR" "$WWW_DIR" "$CONF_DIR"

echo "[PreDeployment] Generating self-signed certificate..."
mkdir -p "$CERTS_DIR/live/storage.open-reporting.dev"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERTS_DIR/live/storage.open-reporting.dev/privkey.pem" \
  -out "$CERTS_DIR/live/storage.open-reporting.dev/fullchain.pem" \
  -subj "/CN=storage.open-reporting.dev"
