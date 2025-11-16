# infra/dlt/Dockerfile
FROM python:3.11-slim

# Install system deps for s3fs, pyarrow, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install dlt and useful extras
RUN pip install --no-cache-dir \
    dlt[filesystem,parquet,s3]==0.5.1 \
    boto3==1.34.0 \
    s3fs==2024.6.0

WORKDIR /app

# Copy project files (optional; you can mount instead)
# COPY ../data_ingestion /app/data_ingestion

CMD ["tail", "-f", "/dev/null"]
