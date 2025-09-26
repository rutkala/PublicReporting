#!/bin/bash

# Variables
JUPYTER_CONTAINER="jupyter"
NESSIE_JAR_URL="https://repo1.maven.org/maven2/org/projectnessie/nessie-integrations/nessie-spark-extensions-3.5_2.12/0.95.0/nessie-spark-extensions-3.5_2.12-0.95.0.jar"
ICEBERG_JAR_URL="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.5.2/iceberg-spark-runtime-3.5_2.12-1.5.2.jar"
AWS_SDK_JAR_URL="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.900/aws-java-sdk-bundle-1.11.900.jar"
HADOOP_AWS_JAR_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar"
JARS_DIR="/usr/local/spark/jars"

echo "Running post-deployment script for Jupyter..."

# Wait for Jupyter to be healthy
until [[ "$(docker inspect --format='{{.State.Health.Status}}' $JUPYTER_CONTAINER)" == "healthy" ]]; do
    sleep 5
    echo "Waiting for Jupyter to be healthy..."
done

echo "Jupyter is healthy. Proceeding with JAR installation and kernel setup..."

# Download JARs into the container
docker exec -u root -it $JUPYTER_CONTAINER bash -c "curl -L -o $JARS_DIR/$(basename $NESSIE_JAR_URL) $NESSIE_JAR_URL"
docker exec -u root -it $JUPYTER_CONTAINER bash -c "curl -L -o $JARS_DIR/$(basename $ICEBERG_JAR_URL) $ICEBERG_JAR_URL"
docker exec -u root -it $JUPYTER_CONTAINER bash -c "curl -L -o $JARS_DIR/$(basename $AWS_SDK_JAR_URL) $AWS_SDK_JAR_URL"
docker exec -u root -it $JUPYTER_CONTAINER bash -c "curl -L -o $JARS_DIR/$(basename $HADOOP_AWS_JAR_URL) $HADOOP_AWS_JAR_URL"

echo "JAR files have been downloaded and installed in the Jupyter container."

# Install the 'sparksql-magic' library inside the Jupyter container without dependencies
echo "Installing 'sparksql-magic' library inside the Jupyter container..."
docker exec -it $JUPYTER_CONTAINER bash -c "pip install --no-deps sparksql-magic"
echo "'sparksql-magic' has been installed."

# Create a custom Jupyter kernel with SparkSession configuration
echo "Creating custom Jupyter kernel with SparkSession configuration..."

# Copy SparkSession.py file into the container
docker cp SparkSession.py $JUPYTER_CONTAINER:/home/jovyan/SparkSession.py

# Create the custom kernel directory inside the container
docker exec -u root -it $JUPYTER_CONTAINER bash -c "mkdir -p /home/jovyan/.local/share/jupyter/kernels/pyspark_custom"

# Copy the existing python3 kernel specification
docker exec -u root -it $JUPYTER_CONTAINER bash -c "cp -r /opt/conda/share/jupyter/kernels/python3/* /home/jovyan/.local/share/jupyter/kernels/pyspark_custom/"

# Modify the kernel.json file
cat << EOF > kernel.json
{
  "argv": [
    "/opt/conda/bin/python",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "PySpark (Custom)",
  "language": "python",
  "env": {
    "PYTHONSTARTUP": "/home/jovyan/SparkSession.py"
  }
}
EOF

# Copy kernel.json into the container
docker cp kernel.json $JUPYTER_CONTAINER:/home/jovyan/.local/share/jupyter/kernels/pyspark_custom/kernel.json
rm kernel.json

# Set permissions for SparkSession.py and the kernel directory
docker exec -u root -it $JUPYTER_CONTAINER bash -c "chown jovyan:users /home/jovyan/SparkSession.py && chmod +r /home/jovyan/SparkSession.py"
docker exec -u root -it $JUPYTER_CONTAINER bash -c "chown -R jovyan:users /home/jovyan/.local/share/jupyter/kernels/pyspark_custom"

echo "Custom Jupyter kernel has been created."

# Restart Jupyter container to apply changes
docker restart $JUPYTER_CONTAINER

echo "Post-deployment script for Jupyter completed successfully."