"""Pre-flight validation of a candidate GeoTIFF.

Reports problems (errors that block registration) and warnings (non-blocking
hints). Reads the file with rasterio; the caller is responsible for cleanup.

Currently a stub — the actual checks land in the next implementation pass.
"""

from typing import Optional, List
from pydantic import BaseModel


class ValidationReport(BaseModel):
    ok: bool
    errors: List[str] = []
    warnings: List[str] = []
    extracted: dict = {}      # what inspect.py pulled out — handy for the UI


def validate_geotiff(tif_path: str, country_code: Optional[str] = None) -> ValidationReport:
    """Validate a GeoTIFF candidate for registration.

    Checks (when implemented):
      - readable by GDAL/rasterio
      - has a declared NoData value
      - SRS present and recognised
      - COG-shaped (tiled, has overviews)
      - bounding box intersects soil_data.country.geom_convexhull
        for the given country_code (warning, not error)
    """
    # TODO: implement after rasterio is added to requirements
    return ValidationReport(ok=False, errors=["validate_geotiff: not yet implemented"])
