"""Render an ISO 19139 XML record for a given layer.

Port of /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/04_table2xml.py.
The original processes all mapsets within a (country, project); we render one
layer at a time. We still update soil_data.mapset.xml so the legacy
pipeline / SPA continues to see the same record.

The XML is built by reading soil_data.mapset + soil_data.layer +
soil_data.proj_x_org_x_ind + soil_data.url and string-replacing
placeholders in template.xml.
"""

import os
import re
from datetime import datetime
from typing import Optional
from xml.sax.saxutils import escape as xml_escape


TEMPLATE_PATH = os.path.join(os.path.dirname(__file__), "template.xml")


def _multireplace(string: str, replacements: dict) -> str:
    """Single-pass replacement (longest substrings first to avoid partial-match
    clobbering). Mirrors 04_table2xml.py.multireplace."""
    substrs = sorted(replacements, key=len, reverse=True)
    regexp = re.compile("|".join(map(re.escape, substrs)))
    return regexp.sub(lambda m: replacements[m.group(0)], string)


def _x(v) -> str:
    """XML-escape a value coerced to str. None → empty string."""
    if v is None:
        return ""
    return xml_escape(str(v))


def _mapset_id_for_layer(cur, layer_id: str) -> Optional[str]:
    cur.execute(
        "SELECT mapset_id FROM soil_data.layer WHERE layer_id = %s",
        (layer_id,),
    )
    row = cur.fetchone()
    return row[0] if row else None


def _build_keyword_block(keyword_csv: Optional[str]) -> str:
    if not keyword_csv:
        return ""
    out = ""
    for k in str(keyword_csv).split(","):
        k = k.strip(" []'\"")
        if not k:
            continue
        out += (
            "\n          <gmd:keyword>"
            f"\n            <gco:CharacterString>{_x(k)}</gco:CharacterString>"
            "\n          </gmd:keyword>"
        )
    return out


def _build_topic_category_block(topic_csv: Optional[str]) -> str:
    if not topic_csv:
        return ""
    out = ""
    for k in str(topic_csv).split(","):
        k = k.strip(" []'\"")
        if not k:
            continue
        out += (
            "\n      <gmd:topicCategory>"
            f"\n        <gmd:MD_TopicCategoryCode>{_x(k)}</gmd:MD_TopicCategoryCode>"
            "\n      </gmd:topicCategory>"
        )
    return out


def _build_responsible_party_block(
    cur, mapset_id: str, tag: str, wrapper: str
) -> str:
    """Build <gmd:contact> or <gmd:pointOfContact> blocks for each row in
    proj_x_org_x_ind matching tag."""
    cur.execute(
        """
        SELECT o.organisation_id, o.country, o.city, o.postal_code, o.delivery_point,
               i.individual_id, i.email, x.role, x.position
        FROM soil_data.proj_x_org_x_ind x
        LEFT JOIN soil_data.organisation o ON o.organisation_id = x.organisation_id
        LEFT JOIN soil_data.individual   i ON i.individual_id   = x.individual_id
        LEFT JOIN soil_data.mapset       m
               ON x.country_id = m.country_id AND x.project_id = m.project_id
        WHERE m.mapset_id = %s AND x.tag = %s
        ORDER BY i.individual_id
        """,
        (mapset_id, tag),
    )
    rows = cur.fetchall()
    out = ""
    code_list = (
        "http://standards.iso.org/ittf/PubliclyAvailableStandards/"
        "ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode"
    )
    for r in rows:
        (organisation_id, country, city, postal_code, delivery_point,
         individual_id, i_email, role, position) = r
        if tag == "contact":
            role_value = "metadataProvider"
        else:
            role_value = role or "pointOfContact"
        block = f"""
  <{wrapper}>
    <gmd:CI_ResponsibleParty>
      <gmd:individualName>
        <gco:CharacterString>{_x(individual_id)}</gco:CharacterString>
      </gmd:individualName>
      <gmd:organisationName>
        <gco:CharacterString>{_x(organisation_id)}</gco:CharacterString>
      </gmd:organisationName>
      <gmd:positionName>
        <gco:CharacterString>{_x(position)}</gco:CharacterString>
      </gmd:positionName>
      <gmd:contactInfo>
        <gmd:CI_Contact>
          <gmd:phone>
            <gmd:CI_Telephone>
              <gmd:voice gco:nilReason="missing"><gco:CharacterString /></gmd:voice>
              <gmd:facsimile gco:nilReason="missing"><gco:CharacterString /></gmd:facsimile>
            </gmd:CI_Telephone>
          </gmd:phone>
          <gmd:address>
            <gmd:CI_Address>
              <gmd:deliveryPoint><gco:CharacterString>{_x(delivery_point)}</gco:CharacterString></gmd:deliveryPoint>
              <gmd:city><gco:CharacterString>{_x(city)}</gco:CharacterString></gmd:city>
              <gmd:administrativeArea gco:nilReason="missing"><gco:CharacterString /></gmd:administrativeArea>
              <gmd:postalCode><gco:CharacterString>{_x(postal_code)}</gco:CharacterString></gmd:postalCode>
              <gmd:country><gco:CharacterString>{_x(country)}</gco:CharacterString></gmd:country>
              <gmd:electronicMailAddress><gco:CharacterString>{_x(i_email)}</gco:CharacterString></gmd:electronicMailAddress>
            </gmd:CI_Address>
          </gmd:address>
        </gmd:CI_Contact>
      </gmd:contactInfo>
      <gmd:role>
        <gmd:CI_RoleCode codeList="{code_list}" codeListValue="{_x(role_value)}" />
      </gmd:role>
    </gmd:CI_ResponsibleParty>
  </{wrapper}>"""
        out += block
    return out


def _build_online_resource_block(cur, mapset_id: str) -> str:
    cur.execute(
        """
        SELECT url, protocol, url_name
        FROM soil_data.url
        WHERE mapset_id = %s
          AND protocol IN ('OGC:WMS','OGC:WMTS',
                           'WWW:LINK-1.0-http--link',
                           'WWW:LINK-1.0-http--related')
        ORDER BY protocol, url
        """,
        (mapset_id,),
    )
    rows = cur.fetchall()
    out = ""
    code_list = (
        "http://standards.iso.org/ittf/PubliclyAvailableStandards/"
        "ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml"
        "#CI_OnLineFunctionCode"
    )
    for url, protocol, url_name in rows:
        if protocol in ("OGC:WMS", "OGC:WMTS"):
            function = "information"
        elif protocol in ("WWW:LINK-1.0-http--link",
                          "WWW:LINK-1.0-http--related"):
            function = "download"
        else:
            function = "UNKNOWN"
        out += f"""
          <gmd:onLine>
            <gmd:CI_OnlineResource>
              <gmd:linkage><gmd:URL>{_x(url)}</gmd:URL></gmd:linkage>
              <gmd:protocol><gco:CharacterString>{_x(protocol)}</gco:CharacterString></gmd:protocol>
              <gmd:name><gco:CharacterString>{_x(url_name)}</gco:CharacterString></gmd:name>
              <gmd:description gco:nilReason="missing"><gco:CharacterString /></gmd:description>
              <gmd:function>
                <gmd:CI_OnLineFunctionCode codeList="{code_list}" codeListValue="{function}" />
              </gmd:function>
            </gmd:CI_OnlineResource>
          </gmd:onLine>"""
    return out


def render_xml(conn, layer_id: str) -> str:
    """Build an ISO 19139 record for the layer's mapset and return the XML.

    Side effect: writes the rendered XML into soil_data.mapset.xml
    for the corresponding mapset row (existing pattern from 04_table2xml.py),
    so the legacy SPA / export pipeline still picks it up.
    """
    with conn.cursor() as cur:
        mapset_id = _mapset_id_for_layer(cur, layer_id)
        if mapset_id is None:
            raise ValueError(
                f"render_xml: no soil_data.layer row for layer_id={layer_id!r}"
            )

        cur.execute(
            """
            SELECT parent_identifier, file_identifier, language_code,
                   metadata_standard_name, metadata_standard_version,
                   reference_system_identifier_code_space,
                   title, creation_date, publication_date, revision_date,
                   edition,
                   citation_md_identifier_code, citation_md_identifier_code_space,
                   abstract, status, update_frequency, md_browse_graphic,
                   keyword_theme, keyword_place, keyword_discipline,
                   access_constraints, use_constraints, other_constraints,
                   spatial_representation_type_code, presentation_form,
                   topic_category, time_period_begin, time_period_end,
                   scope_code, lineage_statement
            FROM soil_data.mapset
            WHERE mapset_id = %s
            """,
            (mapset_id,),
        )
        m = cur.fetchone()
        if m is None:
            raise ValueError(
                f"render_xml: no soil_data.mapset row for mapset_id={mapset_id!r}"
            )
        (parent_identifier, file_identifier, language_code,
         metadata_standard_name, metadata_standard_version,
         reference_system_identifier_code_space,
         title, creation_date, publication_date, revision_date,
         edition,
         citation_md_identifier_code, citation_md_identifier_code_space,
         abstract, status, update_frequency, md_browse_graphic,
         keyword_theme, keyword_place, keyword_discipline,
         access_constraints, use_constraints, other_constraints,
         spatial_representation_type_code, presentation_form,
         topic_category, time_period_begin, time_period_end,
         scope_code, lineage_statement) = m

        # Defaults matching 04_table2xml.py
        file_identifier = file_identifier or layer_id
        language_code = language_code or "eng"
        metadata_standard_name = metadata_standard_name or "ISO 19115"
        metadata_standard_version = metadata_standard_version or "2003/Cor.1:2006"
        reference_system_identifier_code_space = reference_system_identifier_code_space or "EPSG"
        title = title or layer_id
        creation_date = creation_date or "1900-01-01"
        publication_date = publication_date or "1900-01-01"
        revision_date = revision_date or datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")
        abstract = abstract or "UNKNOWN"
        status = status or "completed"
        update_frequency = update_frequency or "asNeeded"
        md_browse_graphic = md_browse_graphic or ""
        access_constraints = access_constraints or "otherRestrictions"
        use_constraints = use_constraints or "otherRestrictions"
        other_constraints = other_constraints or "UNKNOWN"
        spatial_representation_type_code = spatial_representation_type_code or "grid"
        presentation_form = presentation_form or "mapDigital"
        time_period_begin = time_period_begin or "1900-01-01"
        time_period_end = time_period_end or "1900-01-01"
        scope_code = scope_code or "dataset"
        lineage_statement = lineage_statement or "Data quality information not available"

        # Read the layer-side fields off the actual layer row.
        cur.execute(
            """
            SELECT reference_system_identifier_code, distance, distance_uom,
                   west_bound_longitude, east_bound_longitude,
                   south_bound_latitude, north_bound_latitude,
                   distribution_format
            FROM soil_data.layer
            WHERE layer_id = %s
            """,
            (layer_id,),
        )
        lr = cur.fetchone()
        (reference_system_identifier_code, distance, distance_uom,
         west_bound_longitude, east_bound_longitude,
         south_bound_latitude, north_bound_latitude,
         distribution_format) = lr or (None,) * 8
        reference_system_identifier_code = reference_system_identifier_code or "-1"
        distance = distance if distance is not None else 0
        distance_uom = distance_uom or "UNKNOWN"
        west_bound_longitude = west_bound_longitude if west_bound_longitude is not None else 0
        east_bound_longitude = east_bound_longitude if east_bound_longitude is not None else 0
        south_bound_latitude = south_bound_latitude if south_bound_latitude is not None else 0
        north_bound_latitude = north_bound_latitude if north_bound_latitude is not None else 0
        distribution_format = distribution_format or "GeoTIFF"

        # Optional sub-blocks
        edition_xml = ""
        if edition:
            edition_xml = (
                "\n          <gmd:edition>"
                f"\n            <gco:CharacterString>{_x(edition)}</gco:CharacterString>"
                "\n          </gmd:edition>"
            )

        citation_md_identifier_doi_xml = ""
        if citation_md_identifier_code:
            citation_md_identifier_doi_xml = f"""
          <gmd:identifier>
           <gmd:MD_Identifier>
            <gmd:code><gco:CharacterString>{_x(citation_md_identifier_code)}</gco:CharacterString></gmd:code>
            <gmd:codeSpace><gco:CharacterString>{_x(citation_md_identifier_code_space or 'doi')}</gco:CharacterString></gmd:codeSpace>
           </gmd:MD_Identifier>
          </gmd:identifier>"""

        # MD_Resolution must contain either equivalentScale or distance.
        # Raster (grid) → pixel distance + uom. Vector point data has no
        # uniform resolution, so emit no <gmd:spatialResolution> at all
        # (the element is optional [0..*] in MD_DataIdentification).
        if spatial_representation_type_code == "vector":
            spatial_resolution_xml = ""
        else:
            spatial_resolution_xml = f"""      <gmd:spatialResolution>
        <gmd:MD_Resolution>
          <gmd:distance>
            <gco:Distance uom="{_x(distance_uom)}">{_x(distance)}</gco:Distance>
          </gmd:distance>
        </gmd:MD_Resolution>
      </gmd:spatialResolution>"""

        keyword_theme_xml = _build_keyword_block(keyword_theme)
        keyword_discipline_xml = _build_keyword_block(keyword_discipline)
        keyword_place_xml = _build_keyword_block(keyword_place)
        topic_category_xml = _build_topic_category_block(topic_category)
        contact_xml = _build_responsible_party_block(cur, mapset_id, "contact", "gmd:contact")
        poc_xml = _build_responsible_party_block(cur, mapset_id, "pointOfContact", "gmd:pointOfContact")
        online_resource = _build_online_resource_block(cur, mapset_id)

        replace = {
            "***file_identifier***": _x(file_identifier),
            "***language_code***": _x(language_code),
            "***contact_ci_responsible_party_xml***": contact_xml,
            "***revision_date***": _x(revision_date),
            "***metadata_standard_name***": _x(metadata_standard_name),
            "***metadata_standard_version***": _x(metadata_standard_version),
            "***reference_system_identifier_code***": _x(reference_system_identifier_code),
            "***reference_system_identifier_code_space***": _x(reference_system_identifier_code_space),
            "***title***": _x(title),
            "***creation_date***": _x(creation_date),
            "***publication_date***": _x(publication_date),
            "***edition_xml***": edition_xml,
            "***citation_md_identifier_doi_xml***": citation_md_identifier_doi_xml,
            "***abstract***": _x(abstract),
            "***status***": _x(status),
            "***update_frequency***": _x(update_frequency),
            "***point_of_contact_ci_responsible_party_xml***": poc_xml,
            "***md_browse_graphic***": _x(md_browse_graphic),
            "***keyword_theme_xml***": keyword_theme_xml,
            "***keyword_discipline_xml***": keyword_discipline_xml,
            "***keyword_place_xml***": keyword_place_xml,
            "***access_constraints***": _x(access_constraints),
            "***use_constraints***": _x(use_constraints),
            "***other_constraints***": _x(other_constraints),
            "***spatial_representation_type_code***": _x(spatial_representation_type_code),
            "***presentation_form***": _x(presentation_form),
            "***spatial_resolution_xml***": spatial_resolution_xml,
            "***topic_category_xml***": topic_category_xml,
            "***time_period_begin***": _x(time_period_begin),
            "***time_period_end***": _x(time_period_end),
            "***west_bound_longitude***": _x(west_bound_longitude),
            "***east_bound_longitude***": _x(east_bound_longitude),
            "***south_bound_latitude***": _x(south_bound_latitude),
            "***north_bound_latitude***": _x(north_bound_latitude),
            "***distribution_format***": _x(distribution_format),
            "***online_resource***": online_resource,
            "***scope_code***": _x(scope_code),
            "***lineage_statement***": _x(lineage_statement),
        }

        with open(TEMPLATE_PATH, "r", encoding="utf-8") as fh:
            template = fh.read()
        xml = _multireplace(template, replace)

        cur.execute(
            "UPDATE soil_data.mapset SET xml = %s WHERE mapset_id = %s",
            (xml, mapset_id),
        )

    return xml
