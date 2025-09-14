#!/bin/bash

rm -rf ./certs/live/storage.open-reporting.dev
rm -rf ./certs/archive/storage.open-reporting.dev
rm -f ./certs/renewal/storage.open-reporting.dev.conf

set -e

NGINX_CONF_DIR="./conf.d"
DOMAIN="storage.open-reporting.dev"
EMAIL="r.utkala@gmail.com"

echo "[PostDeployment] Requesting Let's Encrypt certificate for $DOMAIN..."

# Force renewal and specify cert-name to overwrite existing certificates without creating -0001 folder
docker exec certbot certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" \
  --cert-name "$DOMAIN" --force-renewal --non-interactive --agree-tos -m "$EMAIL"

# Check if certificate was created successfully
if [ -f "./certs/live/$DOMAIN/fullchain.pem" ] && [ -f "./certs/live/$DOMAIN/privkey.pem" ]; then
    echo "[PostDeployment] Certificate obtained successfully."
else
    echo "[PostDeployment] Error: Certificate files not found. Check Certbot logs."
    exit 1
fi

echo "[PostDeployment] Applying HTTPS config with SSL certificates..."
cp "$NGINX_CONF_DIR/minio-https.conf" "$NGINX_CONF_DIR/minio.conf"

echo "[PostDeployment] Reloading nginx to apply new config..."
docker exec nginx nginx -s reload

echo "[PostDeployment] HTTPS nginx config applied for $DOMAIN"
