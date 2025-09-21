# Use official Superset image as base
FROM apache/superset:latest

# Install deps into Superset's virtualenv
USER root
RUN /app/.venv/bin/python -m ensurepip \
 && /app/.venv/bin/python -m pip install --upgrade pip setuptools wheel

# Install exactly what's in requirements-local.txt
COPY requirements-local.txt /tmp/requirements-local.txt
RUN /app/.venv/bin/pip install --no-cache-dir -r /tmp/requirements-local.txt

# Back to non-root runtime
USER superset
