FROM apache/superset:latest

USER root

# Recreate pip in the venv and install drivers
RUN /app/.venv/bin/python -m ensurepip --upgrade && \
    /app/.venv/bin/python -m pip install --upgrade pip && \
    /app/.venv/bin/python -m pip install --no-cache-dir sqlalchemy-trino==0.5.0 trino

USER superset
