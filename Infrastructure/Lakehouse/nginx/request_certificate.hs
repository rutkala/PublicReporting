docker exec certbot certbot certonly \
  --webroot -w /var/www/certbot \
  -d storage.open-reporting.dev \
  -d storageapi.open-reporting.dev \
  --cert-name open-reporting.dev \
  --expand \
  --force-renewal \
  --non-interactive \
  --agree-tos \
  -m r.utkala@gmail.com
