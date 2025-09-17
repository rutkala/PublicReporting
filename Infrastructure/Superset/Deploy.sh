git clone https://github.com/apache/superset.git
cd superset
git checkout tags/5.0.0
docker compose -f docker-compose-non-dev.yml up -d
cd ..
