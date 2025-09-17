FROM apache/superset:latest

USER root

COPY ../docker/requirements-local.txt requirements-local.txt

RUN pip install -r requirements-local.txt

USER superset
