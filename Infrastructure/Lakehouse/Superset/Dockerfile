FROM apache/superset:latest

USER root

COPY requirements-local.txt requirements-local.txt

RUN pip install -r requirements-local.txt

USER superset
