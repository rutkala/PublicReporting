FROM apache/superset:latest

USER root

COPY requirements-local.txt requirements-local.txt

# Install into Superset's venv if it exists, otherwise fallback to system pip
RUN if [ -x /app/.venv/bin/pip ]; then \
      /app/.venv/bin/pip install --no-cache-dir -r requirements-local.txt ; \
    else \
      pip install --no-cache-dir -r requirements-local.txt ; \
    fi

USER superset
