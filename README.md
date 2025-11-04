# PublicReporting

Project Overview

PublicReporting is built to leverage open-source technologies for creating and managing a Data Lakehouse, allowing the aggregation, processing, and visualization of public data from various Polish sources such as GUS (Główny Urząd Statystyczny). The project is designed with a focus on flexibility and scalability, allowing it to be deployed both in development environments (e.g., personal PC) and production environments (e.g., on-premise VPS servers).

Technical Infrastructure

PublicReporting's architecture is based on the following components:

Object Storage: MinIO
Data Ingestion: dlt
Big Data Engineering: Apache Spark with Jupyter and PySpark
SQL Data Transfirmations: dbt
Tabular Format: Apache Iceberg
Data Catalog: Project Nessie
Query Engine: Trino
Data Visualization: Metabase
Orchestration: Dagster
Web hosting: Nginx
