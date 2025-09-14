#!/bin/bash

set -e

NGINX_CONF_DIR="./conf.d"
EMAIL="r.utkala@gmail.com"
DOMAINS=("storage.open-reporting.dev" "storageapi.open-reporting.dev")

echo "[PostDeployment] Cleaning old certificates..."
for DOMAIN in "${DOMAINS[@]}"; do
    rm -rf "./certs/live/$DOMAIN"
    rm -rf "./certs/archive/$DOMAIN"
    rm -f "./certs/renewal/$DOMAIN.conf"
done

echo "[PostDeployment] Requesting Let's Encrypt certificates..."
for DOMAIN in "${DOMAINS[@]}"; do
    echo "[PostDeployment] Processing $DOMAIN ..."
    docker exec certbot certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" \
      --cert-name "$DOMAIN" --force-renewal --non-interactive --agree-tos -m "$EMAIL"

    # Check if certificate was created successfully
    if [ -f "./certs/live/$DOMAIN/fullchain.pem" ] && [ -f "./certs/live/$DOMAIN/privkey.pem" ]; then
        echo "[PostDeployment] Certificate for $DOMAIN obtained successfully."
    else
        echo "[PostDeployment] Error: Certificate files for $DOMAIN not found. Check Certbot logs."
        exit 1
    fi
done

echo "[PostDeployment] Reloading nginx to apply new configs..."
docker exec nginx nginx -s reload

echo "[PostDeployment] HTTPS nginx configs applied for: ${DOMAINS[*]}"
