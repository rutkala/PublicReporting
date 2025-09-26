#!/bin/bash
set -e

CERTS_DIR="./certs"
WWW_DIR="./www"
CONF_DIR="./conf.d"
DOMAINS=("storage.open-reporting.dev" "storageapi.open-reporting.dev")

echo "[PreDeployment] Creating nginx config, certs, and www folders if not exist..."
mkdir -p "$CERTS_DIR" "$WWW_DIR" "$CONF_DIR"

echo "[PreDeployment] Generating self-signed certificates for initial startup..."

for DOMAIN in "${DOMAINS[@]}"; do
    DOMAIN_DIR="$CERTS_DIR/live/$DOMAIN"
    mkdir -p "$DOMAIN_DIR"

    echo "[PreDeployment] Creating self-signed certificate for $DOMAIN ..."
    openssl req -x509 -nodes -days 7 -newkey rsa:2048 \
      -keyout "$DOMAIN_DIR/privkey.pem" \
      -out "$DOMAIN_DIR/fullchain.pem" \
      -subj "/CN=$DOMAIN"
done

echo "[PreDeployment] Self-signed certificates generated for: ${DOMAINS[*]}"
