# Use official Superset image as base
FROM apache/superset:latest

# Switch to root to install packages in the venv
USER root

# Install pip in the venv if missing
RUN /app/.venv/bin/python -m ensurepip \
    && /app/.venv/bin/python -m pip install --upgrade pip setuptools wheel

# Install Trino packages inside the venv
RUN /app/.venv/bin/pip install --no-cache-dir sqlalchemy-trino==0.5.0 trino

# Switch back to superset user
USER superset
