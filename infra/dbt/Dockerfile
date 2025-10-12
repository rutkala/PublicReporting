FROM python:3.11-slim

# Install system deps for psycopg2 & Trino client libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install dbt with Trino adapter
RUN pip install --no-cache-dir dbt-trino==1.8.1  # pick latest matching dbt-core

# Set working dir for dbt project
WORKDIR /usr/app
