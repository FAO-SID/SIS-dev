"""DST engine — turn a recipe JSON into a GeoTIFF.

Recipe shape (see RASTER-AND-DST-PLAN.md for full details):

    {
      "steps": [
        { "step_id": 1, "layer_id": "BT-...",
          "op": ">",       "threshold": 50,
          "true_score": 1, "false_score": 0, "weight": 1 },
        { "step_id": 2, "layer_id": "BT-...",
          "op": "between", "low": 5.5, "high": 7.0,
          "true_score": 1, "false_score": 0, "weight": 2 }
      ],
      "aggregation":      "sum",       # sum | min | max | mean | product
      "no_data_handling": "propagate", # propagate | treat_as_zero
      "metadata": { ... }              # passed through to register_raster
    }

v1 constraints:
- All input layers must share grid + CRS (no on-the-fly reprojection).
- Single-band rasters only (we read band 1).
"""

import logging
import os
from typing import Optional

import numpy as np
import rasterio

log = logging.getLogger("raster_registry")


SUPPORTED_OPS = {">", ">=", "<", "<=", "==", "!=", "between"}
SUPPORTED_AGG = {"sum", "min", "max", "mean", "product"}
RASTER_DIR = os.getenv("RASTER_DIR", "/srv/rasters")


def _resolve_input_path(cur, layer_id: str) -> Optional[str]:
    """Return the on-disk path for a layer's TIFF, or None if not found."""
    cur.execute(
        """
        SELECT file_path, file_extension
        FROM soil_data.layer
        WHERE layer_id = %s
        """,
        (layer_id,),
    )
    row = cur.fetchone()
    if not row:
        return None
    file_path, file_extension = row
    ext = (file_extension or "tif").lstrip(".")
    if file_path:
        candidate = os.path.join(file_path, f"{layer_id}.{ext}")
        if os.path.exists(candidate):
            return candidate
    fallback = os.path.join(RASTER_DIR, f"{layer_id}.{ext}")
    return fallback if os.path.exists(fallback) else None


def validate_recipe(conn, recipe: dict) -> dict:
    """Dry-run: confirm shape, that input layers exist on disk, and that all
    grids match. Returns {ok, warnings, errors, n_steps, grid}."""
    errors = []
    warnings = []
    steps = recipe.get("steps") or []
    if not steps:
        errors.append("recipe has no steps")
    agg = recipe.get("aggregation", "sum")
    if agg not in SUPPORTED_AGG:
        errors.append(f"unsupported aggregation: {agg!r}")

    grid = None
    with conn.cursor() as cur:
        for i, step in enumerate(steps):
            op = step.get("op")
            if op not in SUPPORTED_OPS:
                errors.append(f"step {i}: unsupported op {op!r}")
            layer_id = step.get("layer_id")
            if not layer_id:
                errors.append(f"step {i}: missing layer_id")
                continue
            path = _resolve_input_path(cur, layer_id)
            if not path:
                errors.append(f"step {i}: input layer {layer_id!r} not found on disk")
                continue
            try:
                with rasterio.open(path) as src:
                    here = (src.width, src.height, tuple(src.transform[:6]),
                            str(src.crs))
            except Exception as e:
                errors.append(f"step {i}: cannot open {layer_id!r}: {e}")
                continue
            if grid is None:
                grid = here
            elif here != grid:
                errors.append(
                    f"step {i}: grid mismatch — {layer_id!r} does not align "
                    "with earlier inputs (CRS / transform / size differ)"
                )

    return {
        "ok": not errors,
        "errors": errors,
        "warnings": warnings,
        "n_steps": len(steps),
        "grid": (
            {"width": grid[0], "height": grid[1],
             "transform": list(grid[2]), "crs": grid[3]}
            if grid else None
        ),
    }


def _apply_op(arr: np.ndarray, step: dict) -> np.ndarray:
    op = step["op"]
    ts = float(step.get("true_score", 1))
    fs = float(step.get("false_score", 0))
    w = float(step.get("weight", 1))

    if op == "between":
        lo = float(step["low"])
        hi = float(step["high"])
        cond = (arr >= lo) & (arr <= hi)
    else:
        thr = float(step["threshold"])
        if op == ">":
            cond = arr > thr
        elif op == ">=":
            cond = arr >= thr
        elif op == "<":
            cond = arr < thr
        elif op == "<=":
            cond = arr <= thr
        elif op == "==":
            cond = arr == thr
        elif op == "!=":
            cond = arr != thr
        else:
            raise ValueError(f"unsupported op {op!r}")

    out = np.where(cond, ts, fs).astype(np.float32)
    if w != 1:
        out *= w
    return out


def _aggregate(stack: np.ndarray, agg: str) -> np.ndarray:
    if agg == "sum":
        return stack.sum(axis=0)
    if agg == "product":
        return stack.prod(axis=0)
    if agg == "min":
        return stack.min(axis=0)
    if agg == "max":
        return stack.max(axis=0)
    if agg == "mean":
        return stack.mean(axis=0)
    raise ValueError(f"unsupported aggregation {agg!r}")


def execute_recipe(
    conn,
    recipe: dict,
    *,
    output_layer_id: str,
    output_dir: str = RASTER_DIR,
) -> str:
    """Apply the recipe pixel-wise. Writes a GeoTIFF and returns its path.

    Caller is responsible for the surrounding transaction / status updates.
    """
    steps = recipe["steps"]
    if not steps:
        raise ValueError("recipe has no steps")
    agg = recipe.get("aggregation", "sum")
    if agg not in SUPPORTED_AGG:
        raise ValueError(f"unsupported aggregation {agg!r}")
    no_data_mode = recipe.get("no_data_handling", "propagate")

    layer_paths = []
    with conn.cursor() as cur:
        for i, step in enumerate(steps):
            path = _resolve_input_path(cur, step["layer_id"])
            if not path:
                raise FileNotFoundError(
                    f"step {i}: input layer {step['layer_id']!r} not on disk"
                )
            layer_paths.append(path)

    profile = None
    score_stack = []

    # NULL (no-data) pixels are excluded per-layer from the aggregation
    # rather than propagated. We carry a mask alongside each scored layer
    # so np.ma.stack().sum()/.mean()/etc. naturally skips masked entries:
    # the output is NULL only at pixels where EVERY input was NULL.
    # `no_data_mode` is kept on the recipe for back-compat but is now a
    # no-op — "skip" is the only mode.
    for step, path in zip(steps, layer_paths):
        with rasterio.open(path) as src:
            if profile is None:
                profile = src.profile.copy()
            arr = src.read(1, masked=True)
            mask = np.ma.getmaskarray(arr)
            data = np.ma.filled(arr, fill_value=0).astype(np.float32)
            scored = _apply_op(data, step)
            score_stack.append(np.ma.array(scored, mask=mask))

    stacked = np.ma.stack(score_stack, axis=0)
    result_masked = _aggregate(stacked, agg).astype(np.float32)

    nodata_value = -9999.0
    result = np.ma.filled(result_masked, fill_value=nodata_value).astype(np.float32)

    os.makedirs(output_dir, exist_ok=True)
    out_path = os.path.join(output_dir, f"{output_layer_id}.tif")

    profile.update(
        dtype="float32",
        count=1,
        nodata=nodata_value,
        compress="deflate",
        tiled=True,
        blockxsize=256,
        blockysize=256,
    )

    with rasterio.open(out_path, "w", **profile) as dst:
        dst.write(result, 1)

    log.info("DST engine wrote %s (%d steps, agg=%s)", out_path, len(steps), agg)
    return out_path
