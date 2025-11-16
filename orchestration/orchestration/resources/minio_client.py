import os
import boto3
from dagster import resource

@resource
def minio_resource(_):
    """
    Boto3 S3 client configured for MinIO.

    Uses env vars set on the dagster_code container:
    MINIO_SERVER_URL, ADMIN_USER, ADMIN_PASSWORD.
    """
    return boto3.client(
        "s3",
        endpoint_url=os.environ["MINIO_SERVER_URL"],     # e.g. http://minio:9000
        aws_access_key_id=os.environ["ADMIN_USER"],
        aws_secret_access_key=os.environ["ADMIN_PASSWORD"],
        region_name="us-east-1",
        config=boto3.session.Config(signature_version="s3v4"),
    )
