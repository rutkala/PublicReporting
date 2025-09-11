#!/bin/bash
NGINX_CONF_DIR="./nginx/conf.d"
CERTS_DIR="/etc/letsencrypt/live"
DOMAIN="minio.open-reporting.dev"

# Step 1: Request/renew Let's Encrypt cert
docker exec nginx certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m your@email.com

# Step 2: Replace config with HTTPS-enabled version
cat > "$NGINX_CONF_DIR/minio.conf" <<EOF
server {
    server_name $DOMAIN;

    listen 80;
    listen [::]:80;
    return 301 https://\$host\$request_uri;
}

server {
    server_name $DOMAIN;

    listen 443 ssl;
    listen [::]:443 ssl;

    ssl_certificate $CERTS_DIR/$DOMAIN/fullchain.pem;
    ssl_certificate_key $CERTS_DIR/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://minio:9001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Step 3: Reload nginx with new config
docker exec nginx nginx -s reload

echo "[PostDeployment] HTTPS nginx config applied for $DOMAIN"
