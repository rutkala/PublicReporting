#!/bin/bash
set -e
NGINX_CONF_DIR="./nginx/conf.d"
DOMAIN="storage.open-reporting.dev"

# Replace with your real email for certbot notifications
EMAIL="r.utkala@gmail.com"

echo "[PostDeployment] Requesting or renewing Let's Encrypt certificate for $DOMAIN..."
docker exec nginx certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL"

echo "[PostDeployment] Applying HTTPS config with SSL certificates..."
cp "$NGINX_CONF_DIR/minio-https.conf" "$NGINX_CONF_DIR/minio.conf"

echo "[PostDeployment] Reloading nginx to apply new config..."
docker exec nginx nginx -s reload

echo "[PostDeployment] HTTPS nginx config applied for $DOMAIN"
