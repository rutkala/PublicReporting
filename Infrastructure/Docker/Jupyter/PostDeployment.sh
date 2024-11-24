#!/bin/bash

# JAR URLs
NESSIE_JAR_URL="https://repo1.maven.org/maven2/org/projectnessie/nessie-spark-extensions-3.5_2.12/0.95.0/nessie-spark-extensions-3.5_2.12-0.95.0.jar"
ICEBERG_JAR_URL="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.5.2/iceberg-spark-runtime-3.5_2.12-1.5.2.jar"
AWS_SDK_JAR_URL="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.900/aws-java-sdk-bundle-1.11.900.jar"
HADOOP_AWS_JAR_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar"

# Destination directory in Spark container
JARS_DIR="/usr/local/spark/jars"

echo "Downloading JAR files into the Jupyter container..."

# Download JARs into the container
docker exec -u root -it jupyter bash -c "curl -L -o $JARS_DIR/$(basename $NESSIE_JAR_URL) $NESSIE_JAR_URL"
docker exec -u root -it jupyter bash -c "curl -L -o $JARS_DIR/$(basename $ICEBERG_JAR_URL) $ICEBERG_JAR_URL"
docker exec -u root -it jupyter bash -c "curl -L -o $JARS_DIR/$(basename $AWS_SDK_JAR_URL) $AWS_SDK_JAR_URL"
docker exec -u root -it jupyter bash -c "curl -L -o $JARS_DIR/$(basename $HADOOP_AWS_JAR_URL) $HADOOP_AWS_JAR_URL"

echo "JAR files have been downloaded and installed in the Jupyter container."

# Install the 'sparksql-magic' library inside the Jupyter container without dependencies
echo "Installing 'sparksql-magic' library inside the Jupyter container..."

docker exec -it jupyter bash -c "pip install --no-deps sparksql-magic"

echo "'sparksql-magic' has been installed."

# Now, create a custom Jupyter kernel with the SparkSession configuration

echo "Creating custom Jupyter kernel with SparkSession configuration..."

# Step 1: Copy the SparkSession.py file into the Jupyter container

# Adjust the path to SparkSession.py as needed. Assuming it's in the same directory as this script.

docker cp SparkSession.py jupyter:/home/jovyan/SparkSession.py

# Step 2: Create the custom kernel directory inside the container

docker exec -u root -it jupyter bash -c "mkdir -p /home/jovyan/.local/share/jupyter/kernels/pyspark_custom"

# Step 3: Copy the existing python3 kernel specification

docker exec -u root -it jupyter bash -c "cp -r /opt/conda/share/jupyter/kernels/python3/* /home/jovyan/.local/share/jupyter/kernels/pyspark_custom/"

# Step 4: Modify the kernel.json file to use the SparkSession.py and correct python path

# Create a kernel.json file locally

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

# Step 5: Copy the kernel.json file into the container

docker cp kernel.json jupyter:/home/jovyan/.local/share/jupyter/kernels/pyspark_custom/kernel.json

# Clean up the local kernel.json file

rm kernel.json

# Step 6: Ensure the SparkSession.py file has appropriate permissions

docker exec -u root -it jupyter bash -c "chown jovyan:users /home/jovyan/SparkSession.py && chmod +r /home/jovyan/SparkSession.py"

# Step 7: Ensure the kernel directory has correct ownership

docker exec -u root -it jupyter bash -c "chown -R jovyan:users /home/jovyan/.local/share/jupyter/kernels/pyspark_custom"

echo "Custom Jupyter kernel has been created."

# Step 8: Restart the Jupyter container to pick up the new kernel

docker restart jupyter

echo "Jupyter container has been restarted. The new kernel 'PySpark (Custom)' is now available."
