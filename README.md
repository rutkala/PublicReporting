# PublicReporting

Project Overview

PublicReporting is built to leverage open-source technologies for creating and managing a Data Lakehouse, allowing the aggregation, processing, and visualization of public data from various Polish sources such as GUS (Główny Urząd Statystyczny). The project is designed with a focus on flexibility and scalability, allowing it to be deployed both in development environments (e.g., personal PC) and production environments (e.g., on-premise VPS servers).

Technical Infrastructure

PublicReporting's architecture is based on the following components:
Object Storage: MinIO - Scalable, high-performance object storage.
Data Ingestion: Airbyte - Tool for extracting and loading public data.
Data Processing: Apache Spark with Jupyter and PySpark - Processing and analytics engine.
Tabular Format: Apache Iceberg - Optimized tabular format for large datasets.
Data Catalog: Project Nessie - Version control for Apache Iceberg.
Query Engine: Trino - SQL-based query engine for data analysis.
Data Visualization: Apache Superset - Data visualization and dashboarding tool.
Orchestration: Apache Airflow - Workflow automation and scheduling.

Folder Structure
The repository is organized as follows:

publicreporting/
├── infrastructure/
│   ├── docker/
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   ├── scripts/
│   │   │   ├── post_install.py
│   │   │   ├── setup_airbyte.sh
│   │   │   └── init_trino.sql
│   │   ├── configs/
│   │   │   ├── minio.env
│   │   │   ├── trino.properties
│   │   │   ├── airflow/
│   │   │   │   ├── dags/
│   │   │   │   │   ├── data_ingestion_dag.py
│   │   │   │   ├── airflow.cfg
│   │   │   ├── superset_config.py
│   │   │   └── nessie.properties
│   ├── terraform/ (optional, if using infrastructure as code)
│   └── README.md
├── data/
│   ├── raw/
│   ├── processed/
│   ├── analytics/
│   └── README.md
├── code/
│   ├── notebooks/
│   │   ├── data_processing.ipynb
│   │   └── analysis.ipynb
│   ├── airflow/
│   │   ├── dags/
│   │   │   ├── data_ingestion_dag.py
│   │   └── plugins/
│   ├── spark/
│   │   ├── jobs/
│   │   │   ├── data_transformation.py
│   ├── superset/
│   │   ├── dashboards/
│   │   └── charts/
│   └── README.md
├── ci-cd/
│   ├── workflows/
│   │   ├── github-actions.yml
│   │   └── gitlab-ci.yml
│   ├── scripts/
│   │   ├── deployment.sh
│   │   └── rollback.sh
│   └── README.md
├── docs/
│   ├── infrastructure_design.md
│   ├── setup_guide_windows.md
│   ├── setup_guide_linux.md
│   └── README.md
└── README.md
