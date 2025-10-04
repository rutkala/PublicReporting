from pyspark.sql import SparkSession
import os

minio_access_key = os.environ["MINIO_ROOT_USER"]
minio_secret_key = os.environ["MINIO_ROOT_PASSWORD"]
minio_endpoint = os.environ["MINIO_SERVER_URL"]
nessie_endpoint = os.environ["NESSIE_SERVER_URL"]
minio_bucket = os.getenv("MINIO_BUCKET_NAME")
nessie_catalog = os.getenv("NESSIE_CATALOG_NAME")
catalog_uri = f"s3a://{minio_bucket}/{nessie_catalog}"

# Configure Spark session to use Iceberg with Nessie as the catalog and MinIO as the storage backend
spark = SparkSession.builder \
    .appName("Iceberg_Nessie_Spark") \
    .config("spark.jars", "/usr/local/spark/jars/iceberg-spark-runtime-3.5_2.12-1.5.2.jar,/usr/local/spark/jars/nessie-spark-extensions-3.5_2.12-0.95.0.jar") \
    .config("spark.sql.catalog.tables", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.tables.catalog-impl", "org.apache.iceberg.nessie.NessieCatalog") \
    .config("spark.sql.catalog.tables.uri", nessie_endpoint) \
    .config("spark.sql.catalog.tables.ref", "main") \
    .config("spark.sql.catalog.tables.credentials-provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.sql.catalog.tables.warehouse", catalog_uri) \
    .config("spark.hadoop.fs.s3a.access.key", minio_access_key) \
    .config("spark.hadoop.fs.s3a.secret.key", minio_secret_key) \
    .config("spark.hadoop.fs.s3a.endpoint", minio_endpoint) \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Load the 'sparksql-magic' extension programmatically
try:
    from IPython import get_ipython
    ipython = get_ipython()
    if ipython is not None:
        ipython.magic("load_ext sparksql_magic")
except Exception as e:
    print(f"Error loading sparksql_magic extension: {e}")