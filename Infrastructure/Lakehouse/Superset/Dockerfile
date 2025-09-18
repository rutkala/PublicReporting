FROM apache/superset:latest

USER root

COPY requirements-local.txt requirements-local.txt

# Install using system pip
RUN pip install --no-cache-dir -r requirements-local.txt

USER superset
