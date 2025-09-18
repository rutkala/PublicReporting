FROM apache/superset:latest

USER root

COPY requirements-local.txt requirements-local.txt
RUN /app/.venv/bin/pip install -r requirements-local.txt

USER superset
