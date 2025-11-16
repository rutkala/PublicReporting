from dagster import asset, Output, MetadataValue

@asset(
    required_resource_keys={"minio"},          # 👈 add this line
    description="Check MinIO connectivity by listing buckets.",
)
def minio_list_buckets(context) -> Output[list[str]]:
    s3 = context.resources.minio  # <- uses our resource
    resp = s3.list_buckets()
    names = [b["Name"] for b in resp.get("Buckets", [])]

    context.log.info(f"Buckets in MinIO: {names}")

    return Output(
        names,
        metadata={"buckets": MetadataValue.json(names)},
    )
