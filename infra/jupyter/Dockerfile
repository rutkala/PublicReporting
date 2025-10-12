FROM jupyter/pyspark-notebook:latest

USER root

# Install JARs
RUN curl -L -o /usr/local/spark/jars/nessie-spark-extensions.jar https://repo1.maven.org/maven2/org/projectnessie/nessie-integrations/nessie-spark-extensions-3.5_2.12/0.95.0/nessie-spark-extensions-3.5_2.12-0.95.0.jar \
    && curl -L -o /usr/local/spark/jars/iceberg-spark-runtime.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.5.2/iceberg-spark-runtime-3.5_2.12-1.5.2.jar \
    && curl -L -o /usr/local/spark/jars/aws-sdk-bundle.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.900/aws-java-sdk-bundle-1.11.900.jar \
    && curl -L -o /usr/local/spark/jars/hadoop-aws.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar

# Install Python dependencies
RUN pip install pyspark
RUN pip install --no-deps sparksql-magic

# Install Python dependencies
RUN pip install boto3 minio

# Copy SparkSession bootstrap
# COPY jupyter/spark_session.py /home/jovyan/spark_session.py

# Create custom kernel
RUN mkdir -p /home/jovyan/.local/share/jupyter/kernels/pyspark \
    && cp -r /opt/conda/share/jupyter/kernels/python3/* /home/jovyan/.local/share/jupyter/kernels/pyspark/ \
    && chown -R jovyan:users /home/jovyan/.local

# Copy kernel.json definition
COPY kernel.json /home/jovyan/.local/share/jupyter/kernels/pyspark/kernel.json

USER jovyan
