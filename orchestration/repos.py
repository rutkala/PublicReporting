from dagster import Definitions, load_assets_from_modules
from . import assets as assets_pkg

all_assets = load_assets_from_modules([assets_pkg])
defs = Definitions(assets=all_assets)
