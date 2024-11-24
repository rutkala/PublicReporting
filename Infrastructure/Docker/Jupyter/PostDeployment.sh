#!/bin/bash

# JAR URLs
NESSIE_JAR_URL="https://repo1.maven.org/maven2/org/projectnessie/nessie-integrations/nessie-spark-extensions-3.5_2.12/0.95.0/nessie-spark-extensions-3.5_2.12-0.95.0.jar"
ICEBERG_JAR_URL="https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.5.2/iceberg-spark-runtime-3.5_2.12-1.5.2.jar"
AWS_SDK_JAR_URL="https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.900/aws-java-sdk-bundle-1.11.900.jar"
HADOOP_AWS_JAR_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar"

# Destination directory in Spark container
JARS_DIR="/usr/local/spark/jars"

# Download JARs into the container
docker exec -u root -it jupyter bash -c "curl -O $NESSIE_JAR_URL && mv $(basename $NESSIE_JAR_URL) $JARS_DIR"
docker exec -u root -it jupyter bash -c "curl -O $ICEBERG_JAR_URL && mv $(basename $ICEBERG_JAR_URL) $JARS_DIR"
docker exec -u root -it jupyter bash -c "curl -O $AWS_SDK_JAR_URL && mv $(basename $AWS_SDK_JAR_URL) $JARS_DIR"
docker exec -u root -it jupyter bash -c "curl -O $HADOOP_AWS_JAR_URL && mv $(basename $HADOOP_AWS_JAR_URL) $JARS_DIR"

echo "JAR files have been downloaded and installed in the Jupyter container."
