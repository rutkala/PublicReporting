chmod +x PreDeployment.sh
chmod +x PostDeployment.sh
./PreDeployment.sh
docker-compose up minio -d
./PostDeployment.sh
