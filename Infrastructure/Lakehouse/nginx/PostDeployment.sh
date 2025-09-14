#!/bin/bash
set -e

NGINX_CONF_DIR="./conf.d"
DOMAIN="storage.open-reporting.dev"
EMAIL="r.utkala@gmail.com"

echo "[PostDeployment] Requesting Let's Encrypt certificate for $DOMAIN..."
docker exec certbot certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL"

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
