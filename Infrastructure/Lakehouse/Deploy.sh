docker-compose up -d
cd ./MinIO
chmod +x PostDeployment.sh
./PostDeployment.sh
cd ../Jupyter
chmod +x PostDeployment.sh
./PostDeployment.sh
cd ../Trino
chmod +x PostDeployment.sh
./PostDeployment.sh
cd ..