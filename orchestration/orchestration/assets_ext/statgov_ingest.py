from dagster import asset, Output, MetadataValue
from data_ingestion.pipelines.statgov import run_statgov

@asset(
    description="Incrementally ingest DBW bulk ZIPs into MinIO per category (Playwright)."
)
def statgov_ingest(context) -> Output[str]:
    # start simple: small range while testing
    id_start = 1
    id_end = 10
    dry_run = False
    sleep = 0.5
    debug = False

    context.log.info(f"Running statgov incremental ingest: {id_start}..{id_end}")
    run_statgov(
        id_start=id_start,
        id_end=id_end,
        sleep=sleep,
        debug=debug,
        dry_run=dry_run,
    )

    return Output(
        "ok",
        metadata={
            "id_start": MetadataValue.int(id_start),
            "id_end": MetadataValue.int(id_end),
            "dry_run": MetadataValue.bool(dry_run),
        },
    )
