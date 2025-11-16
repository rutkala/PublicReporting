from dagster import Definitions, load_assets_from_modules

from orchestration import assets as scaffold_assets          # existing examples
from orchestration import assets_ext                         # your custom assets
from orchestration.resources.minio_client import minio_resource

all_assets = load_assets_from_modules([scaffold_assets, assets_ext])

defs = Definitions(
    assets=all_assets,
    resources={
        "minio": minio_resource,
    },
)
