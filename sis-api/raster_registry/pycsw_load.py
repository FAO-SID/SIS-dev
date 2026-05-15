"""Load a generated XML record into pyCSW.

Strategy:
  1. Always write the XML to /srv/pycsw-records/<layer_id>.xml (bind-mounted
     from sis-metadata/volume, so sis-metadata also sees it). Cheap, durable.
  2. Best-effort: POST a CSW-T Transaction (Insert/Update) to the pyCSW
     service over the docker network so the record is queryable immediately.
     If the HTTP call fails we still return success on the file write and
     surface the error — `deploy.sh` (or a follow-up sync) can pick up
     the file later.
"""

import logging
import os
from typing import Optional

import requests


log = logging.getLogger("raster_registry")

PYCSW_RECORDS_DIR = os.getenv("PYCSW_RECORDS_DIR", "/srv/pycsw-records")
PYCSW_CSW_URL = os.getenv("PYCSW_CSW_URL", "http://sis-metadata:8000/csw")


def _csw_transaction_envelope(xml_record: str, mode: str = "insert") -> str:
    """Wrap a single ISO 19139 record in a CSW-T 2.0.2 Transaction body."""
    op = "Insert" if mode == "insert" else "Update"
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<csw:Transaction xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                 service="CSW" version="2.0.2">
  <csw:{op}>
    {xml_record}
  </csw:{op}>
</csw:Transaction>"""


def delete_record(
    identifier: str,
    *,
    csw_url: Optional[str] = None,
    timeout: float = 10.0,
) -> dict:
    """Best-effort CSW-T Delete by file_identifier. Returns
    {transaction_ok, transaction_error}. Missing records are treated as ok."""
    url = csw_url or PYCSW_CSW_URL
    body = f"""<?xml version="1.0" encoding="UTF-8"?>
<csw:Transaction xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                 xmlns:ogc="http://www.opengis.net/ogc"
                 service="CSW" version="2.0.2">
  <csw:Delete>
    <csw:Constraint version="1.1.0">
      <ogc:Filter>
        <ogc:PropertyIsEqualTo>
          <ogc:PropertyName>dc:identifier</ogc:PropertyName>
          <ogc:Literal>{identifier}</ogc:Literal>
        </ogc:PropertyIsEqualTo>
      </ogc:Filter>
    </csw:Constraint>
  </csw:Delete>
</csw:Transaction>"""
    try:
        resp = requests.post(
            url, data=body.encode("utf-8"),
            headers={"Content-Type": "application/xml"}, timeout=timeout,
        )
    except requests.RequestException as e:
        return {"transaction_ok": False,
                "transaction_error": f"{type(e).__name__}: {e}"}
    ok = (200 <= resp.status_code < 300) and "ExceptionReport" not in resp.text
    return {
        "transaction_ok": ok,
        "transaction_error": None if ok else f"HTTP {resp.status_code}: {resp.text[:400]}",
    }


def write_xml_and_load(
    layer_id: str,
    xml_content: str,
    *,
    records_dir: Optional[str] = None,
    csw_url: Optional[str] = None,
    timeout: float = 10.0,
) -> dict:
    """Persist the XML to disk and best-effort load it into pyCSW.

    Returns a dict with keys:
      xml_path        – the absolute path the record was written to
      transaction_ok  – True if the CSW-T POST returned 2xx
      transaction_error – string describing the failure (None on success)
    """
    rec_dir = records_dir or PYCSW_RECORDS_DIR
    os.makedirs(rec_dir, exist_ok=True)
    xml_path = os.path.join(rec_dir, f"{layer_id}.xml")

    with open(xml_path, "w", encoding="utf-8") as fh:
        fh.write(xml_content)

    url = csw_url or PYCSW_CSW_URL
    tx_ok = False
    tx_err: Optional[str] = None

    # Strip the XML declaration before wrapping (a Transaction has its own).
    record_body = xml_content
    if record_body.lstrip().startswith("<?xml"):
        record_body = record_body.split("?>", 1)[1].lstrip()

    for mode in ("insert", "update"):
        body = _csw_transaction_envelope(record_body, mode=mode)
        try:
            resp = requests.post(
                url,
                data=body.encode("utf-8"),
                headers={"Content-Type": "application/xml"},
                timeout=timeout,
            )
        except requests.RequestException as e:
            tx_err = f"{type(e).__name__}: {e}"
            break

        if 200 <= resp.status_code < 300 and "ExceptionReport" not in resp.text:
            tx_ok = True
            tx_err = None
            break

        # Insert often fails on duplicate identifier — try Update before giving up.
        tx_err = f"HTTP {resp.status_code}: {resp.text[:400]}"
        if mode == "insert" and ("totalInserted>0" in resp.text or
                                  "duplicate" in resp.text.lower() or
                                  "already exists" in resp.text.lower()):
            continue
        else:
            break

    if not tx_ok:
        log.warning("pyCSW transaction failed for %s: %s", layer_id, tx_err)

    return {
        "xml_path": xml_path,
        "transaction_ok": tx_ok,
        "transaction_error": tx_err,
    }
