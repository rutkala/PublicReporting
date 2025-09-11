#!/bin/bash
NGINX_CONF_DIR="./nginx/conf.d"
CERTS_DIR="./nginx/certs"
DOMAIN="minio.open-reporting.dev"

mkdir -p "$NGINX_CONF_DIR" "$CERTS_DIR"

# Step 1: Create temporary HTTP-only config for nginx
cat > "$NGINX_CONF_DIR/minio.conf" <<EOF
server {
    server_name $DOMAIN;

    listen 80;
    listen [::]:80;

    location / {
        proxy_pass http://minio:9001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "[PreDeployment] Temporary HTTP nginx config created for $DOMAIN"
