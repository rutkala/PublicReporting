FROM apache/superset:latest

USER root

COPY requirements-local.txt .

# Install inside Superset’s venv explicitly
RUN . /app/.venv/bin/activate && pip install -r requirements-local.txt

USER superset
