from pyspark.sql import SparkSession

# Configure Spark session to use Iceberg with Nessie as the catalog and MinIO as the storage backend
spark = SparkSession.builder \
    .appName("Iceberg_Nessie_Spark") \
    .config("spark.jars", "/usr/local/spark/jars/iceberg-spark-runtime-3.5_2.12-1.5.2.jar,/usr/local/spark/jars/nessie-spark-extensions-3.5_2.12-0.95.0.jar") \
    .config("spark.sql.catalog.my_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.my_catalog.catalog-impl", "org.apache.iceberg.nessie.NessieCatalog") \
    .config("spark.sql.catalog.my_catalog.uri", "http://nessie:19120/api/v2") \
    .config("spark.sql.catalog.my_catalog.ref", "main") \
    .config("spark.sql.catalog.my_catalog.credentials-provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.sql.catalog.my_catalog.warehouse", "s3a://warehouse/iceberg") \
    .config("spark.hadoop.fs.s3a.access.key", "admin") \
    .config("spark.hadoop.fs.s3a.secret.key", "password") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()