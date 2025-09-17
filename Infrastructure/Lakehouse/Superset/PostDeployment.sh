docker exec -it superset superset fab create-admin \
   --username admin \
   --firstname Superset \
   --lastname Admin \
   --email admin@open-reporting.dev \
   --password YourStrongPassword

docker exec -it superset superset db upgrade
docker exec -it superset superset init
