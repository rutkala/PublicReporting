FROM python:3.11-slim

WORKDIR /app
ENV DAGSTER_HOME=/app

RUN pip install --no-cache-dir --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# configs live in image; user code will be bind-mounted
COPY dagster.yaml /app/dagster.yaml
COPY workspace.yaml /app/workspace.yaml

# expose user-code gRPC port (used by workspace.yaml)
EXPOSE 4000

CMD ["bash", "-lc", "dagster api grpc -h 0.0.0.0 -p 4000 -m orchestration.repos"]
