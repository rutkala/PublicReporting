# Use official Playwright Python image (includes Chromium + all deps)
FROM mcr.microsoft.com/playwright/python:v1.48.0-jammy

ENV DAGSTER_HOME=/app \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Upgrade pip just in case
RUN pip install --upgrade pip

# Install Python dependencies for Dagster, your project, and Playwright extras
COPY requirements.txt .
RUN pip install -r requirements.txt

# Dagster config baked into image; user code is bind-mounted at /app
COPY dagster.yaml /app/dagster.yaml
COPY workspace.yaml /app/workspace.yaml

# gRPC port for code server
EXPOSE 4000

# Default CMD (compose overrides this for dagster_code anyway, but keep it sane)
CMD ["bash", "-lc", "dagster api grpc -h 0.0.0.0 -p 4000 -m orchestration.definitions"]
