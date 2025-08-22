--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-2.pgdg22.04+1)
-- Dumped by pg_dump version 16.2

-- Started on 2025-08-22 13:39:47 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3972 (class 0 OID 54916003)
-- Dependencies: 221
-- Data for Name: property; Type: TABLE DATA; Schema: spatial_metadata; Owner: sis
--

INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ACEXC', 'Acidity - exchangeable', 'cmol/kg', NULL, NULL, 'Acidity - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ACEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ACEXT', 'Acidity - extractable', 'cmol/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ACEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ALEXC', 'Aluminium (Al+++) - exchangeable', 'cmol/kg', NULL, NULL, 'Aluminium (Al+++) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ALEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ALEXT', 'Aluminium (Al) - dithionite extractable', '%', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ALEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ALSAT', 'Aluminium (Al+++) - saturation (ESP)', '%', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ALSAT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('AWCV', 'Available water capacity - volumetric', 'm³/100 m³', NULL, NULL, 'Available water capacity - volumetric (FC to WP)', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>AWCV</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BASAT', 'Base saturation', '%', 6.13658, 225.368, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BASAT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="6.14" color="#f4e7d3" opacity="1" label="6.14 - 28.06"/>
             <sld:ColorMapEntry quantity="28.06" color="#e4d5c2" opacity="1" label="28.06 - 49.98"/>
             <sld:ColorMapEntry quantity="49.98" color="#d3c2b0" opacity="1" label="49.98 - 71.91"/>
             <sld:ColorMapEntry quantity="71.91" color="#c2b09e" opacity="1" label="71.91 - 93.83"/>
             <sld:ColorMapEntry quantity="93.83" color="#b19d8c" opacity="1" label="93.83 - 115.75"/>
             <sld:ColorMapEntry quantity="115.75" color="#a08b7b" opacity="1" label="115.75 - 137.68"/>
             <sld:ColorMapEntry quantity="137.68" color="#8f7869" opacity="1" label="137.68 - 159.60"/>
             <sld:ColorMapEntry quantity="159.6" color="#7e6657" opacity="1" label="159.60 - 181.52"/>
             <sld:ColorMapEntry quantity="181.52" color="#6d5345" opacity="1" label="181.52 - 203.44"/>
             <sld:ColorMapEntry quantity="203.44" color="#5c4033" opacity="1" label="203.44 - 225.37"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BASATSD', 'Base saturation standard deviation', '%', 7.753395, 179.3147, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BASATSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="7.75" color="#f4e7d3" opacity="1" label="7.75 - 24.91"/>
             <sld:ColorMapEntry quantity="24.91" color="#e4d5c2" opacity="1" label="24.91 - 42.07"/>
             <sld:ColorMapEntry quantity="42.07" color="#d3c2b0" opacity="1" label="42.07 - 59.22"/>
             <sld:ColorMapEntry quantity="59.22" color="#c2b09e" opacity="1" label="59.22 - 76.38"/>
             <sld:ColorMapEntry quantity="76.38" color="#b19d8c" opacity="1" label="76.38 - 93.53"/>
             <sld:ColorMapEntry quantity="93.53" color="#a08b7b" opacity="1" label="93.53 - 110.69"/>
             <sld:ColorMapEntry quantity="110.69" color="#8f7869" opacity="1" label="110.69 - 127.85"/>
             <sld:ColorMapEntry quantity="127.85" color="#7e6657" opacity="1" label="127.85 - 145.00"/>
             <sld:ColorMapEntry quantity="145" color="#6d5345" opacity="1" label="145.00 - 162.16"/>
             <sld:ColorMapEntry quantity="162.16" color="#5c4033" opacity="1" label="162.16 - 179.31"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BEXT', 'Boron (B) - extractable', '%', NULL, NULL, 'Boron (B) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BKD', 'Bulk density', 'kg/dm³', 0.60972, 1.67693, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BKD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.61" color="#f4e7d3" opacity="1" label="0.61 - 0.72"/>
             <sld:ColorMapEntry quantity="0.72" color="#e4d5c2" opacity="1" label="0.72 - 0.82"/>
             <sld:ColorMapEntry quantity="0.82" color="#d3c2b0" opacity="1" label="0.82 - 0.93"/>
             <sld:ColorMapEntry quantity="0.93" color="#c2b09e" opacity="1" label="0.93 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#b19d8c" opacity="1" label="1.04 - 1.14"/>
             <sld:ColorMapEntry quantity="1.14" color="#a08b7b" opacity="1" label="1.14 - 1.25"/>
             <sld:ColorMapEntry quantity="1.25" color="#8f7869" opacity="1" label="1.25 - 1.36"/>
             <sld:ColorMapEntry quantity="1.36" color="#7e6657" opacity="1" label="1.36 - 1.46"/>
             <sld:ColorMapEntry quantity="1.46" color="#6d5345" opacity="1" label="1.46 - 1.57"/>
             <sld:ColorMapEntry quantity="1.57" color="#5c4033" opacity="1" label="1.57 - 1.68"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BKDSD', 'Bulk density standard deviation', 'kg/dm³', 0.049058978, 0.33765602, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BKDSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.05" color="#f4e7d3" opacity="1" label="0.05 - 0.08"/>
             <sld:ColorMapEntry quantity="0.08" color="#e4d5c2" opacity="1" label="0.08 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#d3c2b0" opacity="1" label="0.11 - 0.14"/>
             <sld:ColorMapEntry quantity="0.14" color="#c2b09e" opacity="1" label="0.14 - 0.16"/>
             <sld:ColorMapEntry quantity="0.16" color="#b19d8c" opacity="1" label="0.16 - 0.19"/>
             <sld:ColorMapEntry quantity="0.19" color="#a08b7b" opacity="1" label="0.19 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#8f7869" opacity="1" label="0.22 - 0.25"/>
             <sld:ColorMapEntry quantity="0.25" color="#7e6657" opacity="1" label="0.25 - 0.28"/>
             <sld:ColorMapEntry quantity="0.28" color="#6d5345" opacity="1" label="0.28 - 0.31"/>
             <sld:ColorMapEntry quantity="0.31" color="#5c4033" opacity="1" label="0.31 - 0.34"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BREXT', 'Bromite (Br-) - extractable', 'mg/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BREXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BSATC', 'Base saturation - calculated', '%', NULL, NULL, 'Base saturation - calculated', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSATC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BSATS', 'Base saturation - sum of cations', '%', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSATS</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BSEXC', 'Bases - exchangeable', 'cmol/kg', 1.55468, 23.99518, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1.55" color="#f4e7d3" opacity="1" label="1.55 - 3.80"/>
             <sld:ColorMapEntry quantity="3.8" color="#e4d5c2" opacity="1" label="3.80 - 6.04"/>
             <sld:ColorMapEntry quantity="6.04" color="#d3c2b0" opacity="1" label="6.04 - 8.29"/>
             <sld:ColorMapEntry quantity="8.29" color="#c2b09e" opacity="1" label="8.29 - 10.53"/>
             <sld:ColorMapEntry quantity="10.53" color="#b19d8c" opacity="1" label="10.53 - 12.77"/>
             <sld:ColorMapEntry quantity="12.77" color="#a08b7b" opacity="1" label="12.77 - 15.02"/>
             <sld:ColorMapEntry quantity="15.02" color="#8f7869" opacity="1" label="15.02 - 17.26"/>
             <sld:ColorMapEntry quantity="17.26" color="#7e6657" opacity="1" label="17.26 - 19.51"/>
             <sld:ColorMapEntry quantity="19.51" color="#6d5345" opacity="1" label="19.51 - 21.75"/>
             <sld:ColorMapEntry quantity="21.75" color="#5c4033" opacity="1" label="21.75 - 24.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BSEXCSD', 'Exchangeable bases standard deviation', 'cmol/kg', 1.7161336, 21.35204, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1.72" color="#f4e7d3" opacity="1" label="1.72 - 3.68"/>
             <sld:ColorMapEntry quantity="3.68" color="#e4d5c2" opacity="1" label="3.68 - 5.64"/>
             <sld:ColorMapEntry quantity="5.64" color="#d3c2b0" opacity="1" label="5.64 - 7.61"/>
             <sld:ColorMapEntry quantity="7.61" color="#c2b09e" opacity="1" label="7.61 - 9.57"/>
             <sld:ColorMapEntry quantity="9.57" color="#b19d8c" opacity="1" label="9.57 - 11.53"/>
             <sld:ColorMapEntry quantity="11.53" color="#a08b7b" opacity="1" label="11.53 - 13.50"/>
             <sld:ColorMapEntry quantity="13.5" color="#8f7869" opacity="1" label="13.50 - 15.46"/>
             <sld:ColorMapEntry quantity="15.46" color="#7e6657" opacity="1" label="15.46 - 17.42"/>
             <sld:ColorMapEntry quantity="17.42" color="#6d5345" opacity="1" label="17.42 - 19.39"/>
             <sld:ColorMapEntry quantity="19.39" color="#5c4033" opacity="1" label="19.39 - 21.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('BTOT', 'Boron (B) - total', '%', NULL, NULL, 'Boron (B) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CAEXC', 'Calcium (Ca++) - exchangeable', 'cmol/kg', 0.74556, 15.55444, 'Calcium (Ca++) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CAEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.75" color="#f4e7d3" opacity="1" label="0.75 - 2.23"/>
             <sld:ColorMapEntry quantity="2.23" color="#e4d5c2" opacity="1" label="2.23 - 3.71"/>
             <sld:ColorMapEntry quantity="3.71" color="#d3c2b0" opacity="1" label="3.71 - 5.19"/>
             <sld:ColorMapEntry quantity="5.19" color="#c2b09e" opacity="1" label="5.19 - 6.67"/>
             <sld:ColorMapEntry quantity="6.67" color="#b19d8c" opacity="1" label="6.67 - 8.15"/>
             <sld:ColorMapEntry quantity="8.15" color="#a08b7b" opacity="1" label="8.15 - 9.63"/>
             <sld:ColorMapEntry quantity="9.63" color="#8f7869" opacity="1" label="9.63 - 11.11"/>
             <sld:ColorMapEntry quantity="11.11" color="#7e6657" opacity="1" label="11.11 - 12.59"/>
             <sld:ColorMapEntry quantity="12.59" color="#6d5345" opacity="1" label="12.59 - 14.07"/>
             <sld:ColorMapEntry quantity="14.07" color="#5c4033" opacity="1" label="14.07 - 15.55"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CAEXCSD', 'Calcium (Ca++) - exchangeable standard deviation', 'cmol/kg', 0.9116583, 17.663277, 'Calcium (Ca++) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CAEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.91" color="#f4e7d3" opacity="1" label="0.91 - 2.59"/>
             <sld:ColorMapEntry quantity="2.59" color="#e4d5c2" opacity="1" label="2.59 - 4.26"/>
             <sld:ColorMapEntry quantity="4.26" color="#d3c2b0" opacity="1" label="4.26 - 5.94"/>
             <sld:ColorMapEntry quantity="5.94" color="#c2b09e" opacity="1" label="5.94 - 7.61"/>
             <sld:ColorMapEntry quantity="7.61" color="#b19d8c" opacity="1" label="7.61 - 9.29"/>
             <sld:ColorMapEntry quantity="9.29" color="#a08b7b" opacity="1" label="9.29 - 10.96"/>
             <sld:ColorMapEntry quantity="10.96" color="#8f7869" opacity="1" label="10.96 - 12.64"/>
             <sld:ColorMapEntry quantity="12.64" color="#7e6657" opacity="1" label="12.64 - 14.31"/>
             <sld:ColorMapEntry quantity="14.31" color="#6d5345" opacity="1" label="14.31 - 15.99"/>
             <sld:ColorMapEntry quantity="15.99" color="#5c4033" opacity="1" label="15.99 - 17.66"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CAEXT', 'Calcium (Ca++) - extractable', 'cmol/kg', NULL, NULL, 'Calcium (Ca++) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CAEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CASOL', 'Calcium (Ca++) - soluble', 'cmol/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CASOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CATOT', 'Calcium (Ca++) - total', 'cmol/kg', NULL, NULL, 'Calcium (Ca++) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CATOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CCEFRA', 'Calcium carbonate equivalent - fraction', 'g/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CCEFRA</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CCETOT', 'Calcium carbonate equivalent - total', 'g/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CCETOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CEC', 'Cation exchange capacity', 'cmol/kg', 7.76284, 69.35965, 'cationExchangeCapacitycSoilProperty', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CEC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="7.76" color="#f4e7d3" opacity="1" label="7.76 - 13.92"/>
             <sld:ColorMapEntry quantity="13.92" color="#e4d5c2" opacity="1" label="13.92 - 20.08"/>
             <sld:ColorMapEntry quantity="20.08" color="#d3c2b0" opacity="1" label="20.08 - 26.24"/>
             <sld:ColorMapEntry quantity="26.24" color="#c2b09e" opacity="1" label="26.24 - 32.40"/>
             <sld:ColorMapEntry quantity="32.4" color="#b19d8c" opacity="1" label="32.40 - 38.56"/>
             <sld:ColorMapEntry quantity="38.56" color="#a08b7b" opacity="1" label="38.56 - 44.72"/>
             <sld:ColorMapEntry quantity="44.72" color="#8f7869" opacity="1" label="44.72 - 50.88"/>
             <sld:ColorMapEntry quantity="50.88" color="#7e6657" opacity="1" label="50.88 - 57.04"/>
             <sld:ColorMapEntry quantity="57.04" color="#6d5345" opacity="1" label="57.04 - 63.20"/>
             <sld:ColorMapEntry quantity="63.2" color="#5c4033" opacity="1" label="63.20 - 69.36"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CECSD', 'Cation exchange capacity standard deviation', 'cmol/kg', 2.3901253, 21.455622, 'cationExchangeCapacitycSoilProperty', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CECSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.39" color="#f4e7d3" opacity="1" label="2.39 - 4.30"/>
             <sld:ColorMapEntry quantity="4.3" color="#e4d5c2" opacity="1" label="4.30 - 6.20"/>
             <sld:ColorMapEntry quantity="6.2" color="#d3c2b0" opacity="1" label="6.20 - 8.11"/>
             <sld:ColorMapEntry quantity="8.11" color="#c2b09e" opacity="1" label="8.11 - 10.02"/>
             <sld:ColorMapEntry quantity="10.02" color="#b19d8c" opacity="1" label="10.02 - 11.92"/>
             <sld:ColorMapEntry quantity="11.92" color="#a08b7b" opacity="1" label="11.92 - 13.83"/>
             <sld:ColorMapEntry quantity="13.83" color="#8f7869" opacity="1" label="13.83 - 15.74"/>
             <sld:ColorMapEntry quantity="15.74" color="#7e6657" opacity="1" label="15.74 - 17.64"/>
             <sld:ColorMapEntry quantity="17.64" color="#6d5345" opacity="1" label="17.64 - 19.55"/>
             <sld:ColorMapEntry quantity="19.55" color="#5c4033" opacity="1" label="19.55 - 21.46"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CEXT', 'Carbon (C) - extractable', '%', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CFRAGF', 'Coarse fragments - field class', '%', 0.91008, 43.33096, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFRAGF</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.91" color="#f4e7d3" opacity="1" label="0.91 - 5.15"/>
             <sld:ColorMapEntry quantity="5.15" color="#e4d5c2" opacity="1" label="5.15 - 9.39"/>
             <sld:ColorMapEntry quantity="9.39" color="#d3c2b0" opacity="1" label="9.39 - 13.64"/>
             <sld:ColorMapEntry quantity="13.64" color="#c2b09e" opacity="1" label="13.64 - 17.88"/>
             <sld:ColorMapEntry quantity="17.88" color="#b19d8c" opacity="1" label="17.88 - 22.12"/>
             <sld:ColorMapEntry quantity="22.12" color="#a08b7b" opacity="1" label="22.12 - 26.36"/>
             <sld:ColorMapEntry quantity="26.36" color="#8f7869" opacity="1" label="26.36 - 30.60"/>
             <sld:ColorMapEntry quantity="30.6" color="#7e6657" opacity="1" label="30.60 - 34.85"/>
             <sld:ColorMapEntry quantity="34.85" color="#6d5345" opacity="1" label="34.85 - 39.09"/>
             <sld:ColorMapEntry quantity="39.09" color="#5c4033" opacity="1" label="39.09 - 43.33"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CFRAGFSD', 'Coarse fragments - field class standard deviation', '%', 2.1456983, 31.633741, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFRAGFSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.15" color="#f4e7d3" opacity="1" label="2.15 - 5.09"/>
             <sld:ColorMapEntry quantity="5.09" color="#e4d5c2" opacity="1" label="5.09 - 8.04"/>
             <sld:ColorMapEntry quantity="8.04" color="#d3c2b0" opacity="1" label="8.04 - 10.99"/>
             <sld:ColorMapEntry quantity="10.99" color="#c2b09e" opacity="1" label="10.99 - 13.94"/>
             <sld:ColorMapEntry quantity="13.94" color="#b19d8c" opacity="1" label="13.94 - 16.89"/>
             <sld:ColorMapEntry quantity="16.89" color="#a08b7b" opacity="1" label="16.89 - 19.84"/>
             <sld:ColorMapEntry quantity="19.84" color="#8f7869" opacity="1" label="19.84 - 22.79"/>
             <sld:ColorMapEntry quantity="22.79" color="#7e6657" opacity="1" label="22.79 - 25.74"/>
             <sld:ColorMapEntry quantity="25.74" color="#6d5345" opacity="1" label="25.74 - 28.68"/>
             <sld:ColorMapEntry quantity="28.68" color="#5c4033" opacity="1" label="28.68 - 31.63"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CHA', 'Carbon (C) - humic acid', 'g/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CHA</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CLAWRB', 'World reference base', 'class', 1, 7, NULL, 'categorical', 7, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAWRB</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="values">
             <sld:ColorMapEntry quantity="-1" color="#000000" opacity="1" label="-1 - No Data"/>
             <sld:ColorMapEntry quantity="1" color="#800080" opacity="1" label="1 - Anthraquic Cambisols"/>
             <sld:ColorMapEntry quantity="2" color="#f84040" opacity="1" label="2 - Dystric Cambisols"/>
             <sld:ColorMapEntry quantity="3" color="#da70d6" opacity="1" label="3 - Eutric Cambisols"/>
             <sld:ColorMapEntry quantity="4" color="#f08080" opacity="1" label="4 - Haplic Acrisols"/>
             <sld:ColorMapEntry quantity="5" color="#00ffff" opacity="1" label="5 - Haplic Alisols"/>
             <sld:ColorMapEntry quantity="6" color="#f5deb3" opacity="1" label="6 - Haplic Lixisols"/>
             <sld:ColorMapEntry quantity="7" color="#ee82ee" opacity="1" label="7 - Skeletic Cambisols"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CLAY', 'Clay texture fraction', '%', 5.75786, 67.1589, 'Clay texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAY</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.76" color="#f4e7d3" opacity="1" label="5.76 - 11.90"/>
             <sld:ColorMapEntry quantity="11.9" color="#e4d5c2" opacity="1" label="11.90 - 18.04"/>
             <sld:ColorMapEntry quantity="18.04" color="#d3c2b0" opacity="1" label="18.04 - 24.18"/>
             <sld:ColorMapEntry quantity="24.18" color="#c2b09e" opacity="1" label="24.18 - 30.32"/>
             <sld:ColorMapEntry quantity="30.32" color="#b19d8c" opacity="1" label="30.32 - 36.46"/>
             <sld:ColorMapEntry quantity="36.46" color="#a08b7b" opacity="1" label="36.46 - 42.60"/>
             <sld:ColorMapEntry quantity="42.6" color="#8f7869" opacity="1" label="42.60 - 48.74"/>
             <sld:ColorMapEntry quantity="48.74" color="#7e6657" opacity="1" label="48.74 - 54.88"/>
             <sld:ColorMapEntry quantity="54.88" color="#6d5345" opacity="1" label="54.88 - 61.02"/>
             <sld:ColorMapEntry quantity="61.02" color="#5c4033" opacity="1" label="61.02 - 67.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CLAYSD', 'Clay texture fraction standard deviation', '%', 4.136444, 22.87752, 'Clay texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAYSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.14" color="#f4e7d3" opacity="1" label="4.14 - 6.01"/>
             <sld:ColorMapEntry quantity="6.01" color="#e4d5c2" opacity="1" label="6.01 - 7.88"/>
             <sld:ColorMapEntry quantity="7.88" color="#d3c2b0" opacity="1" label="7.88 - 9.76"/>
             <sld:ColorMapEntry quantity="9.76" color="#c2b09e" opacity="1" label="9.76 - 11.63"/>
             <sld:ColorMapEntry quantity="11.63" color="#b19d8c" opacity="1" label="11.63 - 13.51"/>
             <sld:ColorMapEntry quantity="13.51" color="#a08b7b" opacity="1" label="13.51 - 15.38"/>
             <sld:ColorMapEntry quantity="15.38" color="#8f7869" opacity="1" label="15.38 - 17.26"/>
             <sld:ColorMapEntry quantity="17.26" color="#7e6657" opacity="1" label="17.26 - 19.13"/>
             <sld:ColorMapEntry quantity="19.13" color="#6d5345" opacity="1" label="19.13 - 21.00"/>
             <sld:ColorMapEntry quantity="21" color="#5c4033" opacity="1" label="21.00 - 22.88"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORG', 'Carbon (C) - organic', '%', 0.66854, 76.38958, 'Carbon (C) - organic', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORG</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.67" color="#f4e7d3" opacity="1" label="0.67 - 8.24"/>
             <sld:ColorMapEntry quantity="8.24" color="#e4d5c2" opacity="1" label="8.24 - 15.81"/>
             <sld:ColorMapEntry quantity="15.81" color="#d3c2b0" opacity="1" label="15.81 - 23.38"/>
             <sld:ColorMapEntry quantity="23.38" color="#c2b09e" opacity="1" label="23.38 - 30.96"/>
             <sld:ColorMapEntry quantity="30.96" color="#b19d8c" opacity="1" label="30.96 - 38.53"/>
             <sld:ColorMapEntry quantity="38.53" color="#a08b7b" opacity="1" label="38.53 - 46.10"/>
             <sld:ColorMapEntry quantity="46.1" color="#8f7869" opacity="1" label="46.10 - 53.67"/>
             <sld:ColorMapEntry quantity="53.67" color="#7e6657" opacity="1" label="53.67 - 61.25"/>
             <sld:ColorMapEntry quantity="61.25" color="#6d5345" opacity="1" label="61.25 - 68.82"/>
             <sld:ColorMapEntry quantity="68.82" color="#5c4033" opacity="1" label="68.82 - 76.39"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGADBAU', 'Organic carbon sequestration potential - absolute difference business as usual', 't/(ha·a)', -196.64186, 48.971775, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-196.64" color="#f4e7d3" opacity="1" label="-196.64 - -172.08"/>
             <sld:ColorMapEntry quantity="-172.08" color="#e4d5c2" opacity="1" label="-172.08 - -147.52"/>
             <sld:ColorMapEntry quantity="-147.52" color="#d3c2b0" opacity="1" label="-147.52 - -122.96"/>
             <sld:ColorMapEntry quantity="-122.96" color="#c2b09e" opacity="1" label="-122.96 - -98.40"/>
             <sld:ColorMapEntry quantity="-98.4" color="#b19d8c" opacity="1" label="-98.40 - -73.84"/>
             <sld:ColorMapEntry quantity="-73.84" color="#a08b7b" opacity="1" label="-73.84 - -49.27"/>
             <sld:ColorMapEntry quantity="-49.27" color="#8f7869" opacity="1" label="-49.27 - -24.71"/>
             <sld:ColorMapEntry quantity="-24.71" color="#7e6657" opacity="1" label="-24.71 - -0.15"/>
             <sld:ColorMapEntry quantity="-0.15" color="#6d5345" opacity="1" label="-0.15 - 24.41"/>
             <sld:ColorMapEntry quantity="24.41" color="#5c4033" opacity="1" label="24.41 - 48.97"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGADSSM1', 'Organic carbon sequestration potential - absolute difference SSM1', 't/(ha·a)', -194.49391, 53.177586, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-194.49" color="#f4e7d3" opacity="1" label="-194.49 - -169.73"/>
             <sld:ColorMapEntry quantity="-169.73" color="#e4d5c2" opacity="1" label="-169.73 - -144.96"/>
             <sld:ColorMapEntry quantity="-144.96" color="#d3c2b0" opacity="1" label="-144.96 - -120.19"/>
             <sld:ColorMapEntry quantity="-120.19" color="#c2b09e" opacity="1" label="-120.19 - -95.43"/>
             <sld:ColorMapEntry quantity="-95.43" color="#b19d8c" opacity="1" label="-95.43 - -70.66"/>
             <sld:ColorMapEntry quantity="-70.66" color="#a08b7b" opacity="1" label="-70.66 - -45.89"/>
             <sld:ColorMapEntry quantity="-45.89" color="#8f7869" opacity="1" label="-45.89 - -21.12"/>
             <sld:ColorMapEntry quantity="-21.12" color="#7e6657" opacity="1" label="-21.12 - 3.64"/>
             <sld:ColorMapEntry quantity="3.64" color="#6d5345" opacity="1" label="3.64 - 28.41"/>
             <sld:ColorMapEntry quantity="28.41" color="#5c4033" opacity="1" label="28.41 - 53.18"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGADSSM2', 'Organic carbon sequestration potential - absolute difference SSM2', 't/(ha·a)', -192.34596, 57.3834, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-192.35" color="#f4e7d3" opacity="1" label="-192.35 - -167.37"/>
             <sld:ColorMapEntry quantity="-167.37" color="#e4d5c2" opacity="1" label="-167.37 - -142.40"/>
             <sld:ColorMapEntry quantity="-142.4" color="#d3c2b0" opacity="1" label="-142.40 - -117.43"/>
             <sld:ColorMapEntry quantity="-117.43" color="#c2b09e" opacity="1" label="-117.43 - -92.45"/>
             <sld:ColorMapEntry quantity="-92.45" color="#b19d8c" opacity="1" label="-92.45 - -67.48"/>
             <sld:ColorMapEntry quantity="-67.48" color="#a08b7b" opacity="1" label="-67.48 - -42.51"/>
             <sld:ColorMapEntry quantity="-42.51" color="#8f7869" opacity="1" label="-42.51 - -17.54"/>
             <sld:ColorMapEntry quantity="-17.54" color="#7e6657" opacity="1" label="-17.54 - 7.44"/>
             <sld:ColorMapEntry quantity="7.44" color="#6d5345" opacity="1" label="7.44 - 32.41"/>
             <sld:ColorMapEntry quantity="32.41" color="#5c4033" opacity="1" label="32.41 - 57.38"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGADSSM3', 'Organic carbon sequestration potential - absolute difference SSM3', 't/(ha·a)', -188.05006, 65.79502, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-188.05" color="#f4e7d3" opacity="1" label="-188.05 - -162.67"/>
             <sld:ColorMapEntry quantity="-162.67" color="#e4d5c2" opacity="1" label="-162.67 - -137.28"/>
             <sld:ColorMapEntry quantity="-137.28" color="#d3c2b0" opacity="1" label="-137.28 - -111.90"/>
             <sld:ColorMapEntry quantity="-111.9" color="#c2b09e" opacity="1" label="-111.90 - -86.51"/>
             <sld:ColorMapEntry quantity="-86.51" color="#b19d8c" opacity="1" label="-86.51 - -61.13"/>
             <sld:ColorMapEntry quantity="-61.13" color="#a08b7b" opacity="1" label="-61.13 - -35.74"/>
             <sld:ColorMapEntry quantity="-35.74" color="#8f7869" opacity="1" label="-35.74 - -10.36"/>
             <sld:ColorMapEntry quantity="-10.36" color="#7e6657" opacity="1" label="-10.36 - 15.03"/>
             <sld:ColorMapEntry quantity="15.03" color="#6d5345" opacity="1" label="15.03 - 40.41"/>
             <sld:ColorMapEntry quantity="40.41" color="#5c4033" opacity="1" label="40.41 - 65.80"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRBAU', 'Organic carbon sequestration potential - ASR business as usual', 't/(ha·a)', -49.95, 2.4485886, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.71"/>
             <sld:ColorMapEntry quantity="-44.71" color="#e4d5c2" opacity="1" label="-44.71 - -39.47"/>
             <sld:ColorMapEntry quantity="-39.47" color="#d3c2b0" opacity="1" label="-39.47 - -34.23"/>
             <sld:ColorMapEntry quantity="-34.23" color="#c2b09e" opacity="1" label="-34.23 - -28.99"/>
             <sld:ColorMapEntry quantity="-28.99" color="#b19d8c" opacity="1" label="-28.99 - -23.75"/>
             <sld:ColorMapEntry quantity="-23.75" color="#a08b7b" opacity="1" label="-23.75 - -18.51"/>
             <sld:ColorMapEntry quantity="-18.51" color="#8f7869" opacity="1" label="-18.51 - -13.27"/>
             <sld:ColorMapEntry quantity="-13.27" color="#7e6657" opacity="1" label="-13.27 - -8.03"/>
             <sld:ColorMapEntry quantity="-8.03" color="#6d5345" opacity="1" label="-8.03 - -2.79"/>
             <sld:ColorMapEntry quantity="-2.79" color="#5c4033" opacity="1" label="-2.79 - 2.45"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRBAUU', 'Organic carbon sequestration potential - ASR business as usual uncertainty', 't/(ha·a)', 13.839993, 434.46436, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRBAUU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="13.84" color="#f4e7d3" opacity="1" label="13.84 - 55.90"/>
             <sld:ColorMapEntry quantity="55.9" color="#e4d5c2" opacity="1" label="55.90 - 97.96"/>
             <sld:ColorMapEntry quantity="97.96" color="#d3c2b0" opacity="1" label="97.96 - 140.03"/>
             <sld:ColorMapEntry quantity="140.03" color="#c2b09e" opacity="1" label="140.03 - 182.09"/>
             <sld:ColorMapEntry quantity="182.09" color="#b19d8c" opacity="1" label="182.09 - 224.15"/>
             <sld:ColorMapEntry quantity="224.15" color="#a08b7b" opacity="1" label="224.15 - 266.21"/>
             <sld:ColorMapEntry quantity="266.21" color="#8f7869" opacity="1" label="266.21 - 308.28"/>
             <sld:ColorMapEntry quantity="308.28" color="#7e6657" opacity="1" label="308.28 - 350.34"/>
             <sld:ColorMapEntry quantity="350.34" color="#6d5345" opacity="1" label="350.34 - 392.40"/>
             <sld:ColorMapEntry quantity="392.4" color="#5c4033" opacity="1" label="392.40 - 434.46"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSD', 'Carbon (C) - organic standard deviation', '%', 0.17059721, 4.543123, 'Carbon (C) - organic', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.17" color="#f4e7d3" opacity="1" label="0.17 - 0.61"/>
             <sld:ColorMapEntry quantity="0.61" color="#e4d5c2" opacity="1" label="0.61 - 1.05"/>
             <sld:ColorMapEntry quantity="1.05" color="#d3c2b0" opacity="1" label="1.05 - 1.48"/>
             <sld:ColorMapEntry quantity="1.48" color="#c2b09e" opacity="1" label="1.48 - 1.92"/>
             <sld:ColorMapEntry quantity="1.92" color="#b19d8c" opacity="1" label="1.92 - 2.36"/>
             <sld:ColorMapEntry quantity="2.36" color="#a08b7b" opacity="1" label="2.36 - 2.79"/>
             <sld:ColorMapEntry quantity="2.79" color="#8f7869" opacity="1" label="2.79 - 3.23"/>
             <sld:ColorMapEntry quantity="3.23" color="#7e6657" opacity="1" label="3.23 - 3.67"/>
             <sld:ColorMapEntry quantity="3.67" color="#6d5345" opacity="1" label="3.67 - 4.11"/>
             <sld:ColorMapEntry quantity="4.11" color="#5c4033" opacity="1" label="4.11 - 4.54"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSOCBAU', 'Organic carbon sequestration potential - SOC business as usual', 't/(ha·a)', 5.6508374, 254.41446, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.65" color="#f4e7d3" opacity="1" label="5.65 - 30.53"/>
             <sld:ColorMapEntry quantity="30.53" color="#e4d5c2" opacity="1" label="30.53 - 55.40"/>
             <sld:ColorMapEntry quantity="55.4" color="#d3c2b0" opacity="1" label="55.40 - 80.28"/>
             <sld:ColorMapEntry quantity="80.28" color="#c2b09e" opacity="1" label="80.28 - 105.16"/>
             <sld:ColorMapEntry quantity="105.16" color="#b19d8c" opacity="1" label="105.16 - 130.03"/>
             <sld:ColorMapEntry quantity="130.03" color="#a08b7b" opacity="1" label="130.03 - 154.91"/>
             <sld:ColorMapEntry quantity="154.91" color="#8f7869" opacity="1" label="154.91 - 179.79"/>
             <sld:ColorMapEntry quantity="179.79" color="#7e6657" opacity="1" label="179.79 - 204.66"/>
             <sld:ColorMapEntry quantity="204.66" color="#6d5345" opacity="1" label="204.66 - 229.54"/>
             <sld:ColorMapEntry quantity="229.54" color="#5c4033" opacity="1" label="229.54 - 254.41"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSOCSSM1', 'Organic carbon sequestration potential - SOC SSM1', 't/(ha·a)', 5.7626433, 259.8814, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.76" color="#f4e7d3" opacity="1" label="5.76 - 31.17"/>
             <sld:ColorMapEntry quantity="31.17" color="#e4d5c2" opacity="1" label="31.17 - 56.59"/>
             <sld:ColorMapEntry quantity="56.59" color="#d3c2b0" opacity="1" label="56.59 - 82.00"/>
             <sld:ColorMapEntry quantity="82" color="#c2b09e" opacity="1" label="82.00 - 107.41"/>
             <sld:ColorMapEntry quantity="107.41" color="#b19d8c" opacity="1" label="107.41 - 132.82"/>
             <sld:ColorMapEntry quantity="132.82" color="#a08b7b" opacity="1" label="132.82 - 158.23"/>
             <sld:ColorMapEntry quantity="158.23" color="#8f7869" opacity="1" label="158.23 - 183.65"/>
             <sld:ColorMapEntry quantity="183.65" color="#7e6657" opacity="1" label="183.65 - 209.06"/>
             <sld:ColorMapEntry quantity="209.06" color="#6d5345" opacity="1" label="209.06 - 234.47"/>
             <sld:ColorMapEntry quantity="234.47" color="#5c4033" opacity="1" label="234.47 - 259.88"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSOCSSM2', 'Organic carbon sequestration potential - SOC SSM2', 't/(ha·a)', 5.8744497, 265.34833, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.87" color="#f4e7d3" opacity="1" label="5.87 - 31.82"/>
             <sld:ColorMapEntry quantity="31.82" color="#e4d5c2" opacity="1" label="31.82 - 57.77"/>
             <sld:ColorMapEntry quantity="57.77" color="#d3c2b0" opacity="1" label="57.77 - 83.72"/>
             <sld:ColorMapEntry quantity="83.72" color="#c2b09e" opacity="1" label="83.72 - 109.66"/>
             <sld:ColorMapEntry quantity="109.66" color="#b19d8c" opacity="1" label="109.66 - 135.61"/>
             <sld:ColorMapEntry quantity="135.61" color="#a08b7b" opacity="1" label="135.61 - 161.56"/>
             <sld:ColorMapEntry quantity="161.56" color="#8f7869" opacity="1" label="161.56 - 187.51"/>
             <sld:ColorMapEntry quantity="187.51" color="#7e6657" opacity="1" label="187.51 - 213.45"/>
             <sld:ColorMapEntry quantity="213.45" color="#6d5345" opacity="1" label="213.45 - 239.40"/>
             <sld:ColorMapEntry quantity="239.4" color="#5c4033" opacity="1" label="239.40 - 265.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSOCSSM3', 'Organic carbon sequestration potential - SOC SSM3', 't/(ha·a)', 6.098062, 276.2822, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="6.1" color="#f4e7d3" opacity="1" label="6.10 - 33.12"/>
             <sld:ColorMapEntry quantity="33.12" color="#e4d5c2" opacity="1" label="33.12 - 60.13"/>
             <sld:ColorMapEntry quantity="60.13" color="#d3c2b0" opacity="1" label="60.13 - 87.15"/>
             <sld:ColorMapEntry quantity="87.15" color="#c2b09e" opacity="1" label="87.15 - 114.17"/>
             <sld:ColorMapEntry quantity="114.17" color="#b19d8c" opacity="1" label="114.17 - 141.19"/>
             <sld:ColorMapEntry quantity="141.19" color="#a08b7b" opacity="1" label="141.19 - 168.21"/>
             <sld:ColorMapEntry quantity="168.21" color="#8f7869" opacity="1" label="168.21 - 195.23"/>
             <sld:ColorMapEntry quantity="195.23" color="#7e6657" opacity="1" label="195.23 - 222.25"/>
             <sld:ColorMapEntry quantity="222.25" color="#6d5345" opacity="1" label="222.25 - 249.26"/>
             <sld:ColorMapEntry quantity="249.26" color="#5c4033" opacity="1" label="249.26 - 276.28"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGSSMU', 'Organic carbon sequestration potential - SSM uncertainty', 't/(ha·a)', 9.564035, 62.000046, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSSMU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="9.56" color="#f4e7d3" opacity="1" label="9.56 - 14.81"/>
             <sld:ColorMapEntry quantity="14.81" color="#e4d5c2" opacity="1" label="14.81 - 20.05"/>
             <sld:ColorMapEntry quantity="20.05" color="#d3c2b0" opacity="1" label="20.05 - 25.29"/>
             <sld:ColorMapEntry quantity="25.29" color="#c2b09e" opacity="1" label="25.29 - 30.54"/>
             <sld:ColorMapEntry quantity="30.54" color="#b19d8c" opacity="1" label="30.54 - 35.78"/>
             <sld:ColorMapEntry quantity="35.78" color="#a08b7b" opacity="1" label="35.78 - 41.03"/>
             <sld:ColorMapEntry quantity="41.03" color="#8f7869" opacity="1" label="41.03 - 46.27"/>
             <sld:ColorMapEntry quantity="46.27" color="#7e6657" opacity="1" label="46.27 - 51.51"/>
             <sld:ColorMapEntry quantity="51.51" color="#6d5345" opacity="1" label="51.51 - 56.76"/>
             <sld:ColorMapEntry quantity="56.76" color="#5c4033" opacity="1" label="56.76 - 62.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGT0', 'Organic carbon sequestration potential - time zero', 't/(ha·a)', 0, 283.11313, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGT0</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 28.31"/>
             <sld:ColorMapEntry quantity="28.31" color="#e4d5c2" opacity="1" label="28.31 - 56.62"/>
             <sld:ColorMapEntry quantity="56.62" color="#d3c2b0" opacity="1" label="56.62 - 84.93"/>
             <sld:ColorMapEntry quantity="84.93" color="#c2b09e" opacity="1" label="84.93 - 113.25"/>
             <sld:ColorMapEntry quantity="113.25" color="#b19d8c" opacity="1" label="113.25 - 141.56"/>
             <sld:ColorMapEntry quantity="141.56" color="#a08b7b" opacity="1" label="141.56 - 169.87"/>
             <sld:ColorMapEntry quantity="169.87" color="#8f7869" opacity="1" label="169.87 - 198.18"/>
             <sld:ColorMapEntry quantity="198.18" color="#7e6657" opacity="1" label="198.18 - 226.49"/>
             <sld:ColorMapEntry quantity="226.49" color="#6d5345" opacity="1" label="226.49 - 254.80"/>
             <sld:ColorMapEntry quantity="254.8" color="#5c4033" opacity="1" label="254.80 - 283.11"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CUEXT', 'Copper (Cu) - extractable', '%', NULL, NULL, 'Copper (Cu) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CUEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CUTOT', 'Copper (Cu) - total', '%', NULL, NULL, 'Copper (Cu) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CUTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ECX', 'Electrical conductivity', 'dS/m', 0.025647739, 1.366607, 'electricalConductivityProperty', 'quantitative', 10, '#CA0020', '#3F68E2', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ECX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.03" color="#ca0020" opacity="1" label="0.03 - 0.16"/>
             <sld:ColorMapEntry quantity="0.16" color="#bb0b35" opacity="1" label="0.16 - 0.29"/>
             <sld:ColorMapEntry quantity="0.29" color="#ac174b" opacity="1" label="0.29 - 0.43"/>
             <sld:ColorMapEntry quantity="0.43" color="#9c2260" opacity="1" label="0.43 - 0.56"/>
             <sld:ColorMapEntry quantity="0.56" color="#8d2e76" opacity="1" label="0.56 - 0.70"/>
             <sld:ColorMapEntry quantity="0.7" color="#7d398b" opacity="1" label="0.70 - 0.83"/>
             <sld:ColorMapEntry quantity="0.83" color="#6e45a1" opacity="1" label="0.83 - 0.96"/>
             <sld:ColorMapEntry quantity="0.96" color="#5e50b6" opacity="1" label="0.96 - 1.10"/>
             <sld:ColorMapEntry quantity="1.1" color="#4f5ccc" opacity="1" label="1.10 - 1.23"/>
             <sld:ColorMapEntry quantity="1.23" color="#3f68e2" opacity="1" label="1.23 - 1.37"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ECXSD', 'Electrical conductivity standard deviation', 'dS/m', 0, 14.041121, 'electricalConductivityProperty', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ECXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 1.40"/>
             <sld:ColorMapEntry quantity="1.4" color="#e4d5c2" opacity="1" label="1.40 - 2.81"/>
             <sld:ColorMapEntry quantity="2.81" color="#d3c2b0" opacity="1" label="2.81 - 4.21"/>
             <sld:ColorMapEntry quantity="4.21" color="#c2b09e" opacity="1" label="4.21 - 5.62"/>
             <sld:ColorMapEntry quantity="5.62" color="#b19d8c" opacity="1" label="5.62 - 7.02"/>
             <sld:ColorMapEntry quantity="7.02" color="#a08b7b" opacity="1" label="7.02 - 8.42"/>
             <sld:ColorMapEntry quantity="8.42" color="#8f7869" opacity="1" label="8.42 - 9.83"/>
             <sld:ColorMapEntry quantity="9.83" color="#7e6657" opacity="1" label="9.83 - 11.23"/>
             <sld:ColorMapEntry quantity="11.23" color="#6d5345" opacity="1" label="11.23 - 12.64"/>
             <sld:ColorMapEntry quantity="12.64" color="#5c4033" opacity="1" label="12.64 - 14.04"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('FEEXT', 'Iron (Fe) - extractable', '%', NULL, NULL, 'Iron (Fe) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>FEEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('FETOT', 'Iron (Fe) - total', '%', NULL, NULL, 'Iron (Fe) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>FETOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('HCO3SOL', 'Hydrocarbonate (HCO3-) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>HCO3SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('HEXC', 'Hydrogen (H+) - exchangeable', 'cmol/kg', NULL, NULL, 'Hydrogen (H+) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>HEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KEXC', 'Potassium (K+) - exchangeable', 'cmol/kg', 0.55516, 196.908, 'Potassium (K+) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.56" color="#f4e7d3" opacity="1" label="0.56 - 20.19"/>
             <sld:ColorMapEntry quantity="20.19" color="#e4d5c2" opacity="1" label="20.19 - 39.83"/>
             <sld:ColorMapEntry quantity="39.83" color="#d3c2b0" opacity="1" label="39.83 - 59.46"/>
             <sld:ColorMapEntry quantity="59.46" color="#c2b09e" opacity="1" label="59.46 - 79.10"/>
             <sld:ColorMapEntry quantity="79.1" color="#b19d8c" opacity="1" label="79.10 - 98.73"/>
             <sld:ColorMapEntry quantity="98.73" color="#a08b7b" opacity="1" label="98.73 - 118.37"/>
             <sld:ColorMapEntry quantity="118.37" color="#8f7869" opacity="1" label="118.37 - 138.00"/>
             <sld:ColorMapEntry quantity="138" color="#7e6657" opacity="1" label="138.00 - 157.64"/>
             <sld:ColorMapEntry quantity="157.64" color="#6d5345" opacity="1" label="157.64 - 177.27"/>
             <sld:ColorMapEntry quantity="177.27" color="#5c4033" opacity="1" label="177.27 - 196.91"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KEXCSD', 'Potassium (K+) - exchangeable standard deviation', 'cmol/kg', 0.5131245, 229.28043, 'Potassium (K+) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.51" color="#f4e7d3" opacity="1" label="0.51 - 23.39"/>
             <sld:ColorMapEntry quantity="23.39" color="#e4d5c2" opacity="1" label="23.39 - 46.27"/>
             <sld:ColorMapEntry quantity="46.27" color="#d3c2b0" opacity="1" label="46.27 - 69.14"/>
             <sld:ColorMapEntry quantity="69.14" color="#c2b09e" opacity="1" label="69.14 - 92.02"/>
             <sld:ColorMapEntry quantity="92.02" color="#b19d8c" opacity="1" label="92.02 - 114.90"/>
             <sld:ColorMapEntry quantity="114.9" color="#a08b7b" opacity="1" label="114.90 - 137.77"/>
             <sld:ColorMapEntry quantity="137.77" color="#8f7869" opacity="1" label="137.77 - 160.65"/>
             <sld:ColorMapEntry quantity="160.65" color="#7e6657" opacity="1" label="160.65 - 183.53"/>
             <sld:ColorMapEntry quantity="183.53" color="#6d5345" opacity="1" label="183.53 - 206.40"/>
             <sld:ColorMapEntry quantity="206.4" color="#5c4033" opacity="1" label="206.40 - 229.28"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KEXT', 'Potassium (K) - extractable', 'cmol/kg', NULL, NULL, 'Potassium (K) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KSOL', 'Potassium (K+) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KSOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KTOT', 'Potassium (K) - total', 'cmol/kg', NULL, NULL, 'Potassium (K) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KXX', 'Potassium (K)', 'mg/kg', 0.16248894, 392.0226, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KXX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.16" color="#f4e7d3" opacity="1" label="0.16 - 39.35"/>
             <sld:ColorMapEntry quantity="39.35" color="#e4d5c2" opacity="1" label="39.35 - 78.53"/>
             <sld:ColorMapEntry quantity="78.53" color="#d3c2b0" opacity="1" label="78.53 - 117.72"/>
             <sld:ColorMapEntry quantity="117.72" color="#c2b09e" opacity="1" label="117.72 - 156.91"/>
             <sld:ColorMapEntry quantity="156.91" color="#b19d8c" opacity="1" label="156.91 - 196.09"/>
             <sld:ColorMapEntry quantity="196.09" color="#a08b7b" opacity="1" label="196.09 - 235.28"/>
             <sld:ColorMapEntry quantity="235.28" color="#8f7869" opacity="1" label="235.28 - 274.46"/>
             <sld:ColorMapEntry quantity="274.46" color="#7e6657" opacity="1" label="274.46 - 313.65"/>
             <sld:ColorMapEntry quantity="313.65" color="#6d5345" opacity="1" label="313.65 - 352.84"/>
             <sld:ColorMapEntry quantity="352.84" color="#5c4033" opacity="1" label="352.84 - 392.02"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MGEXC', 'Magnesium (Mg++) - exchangeable', 'cmol/kg', 0.2067, 4.28254, 'Magnesium (Mg++) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MGEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.21" color="#f4e7d3" opacity="1" label="0.21 - 0.61"/>
             <sld:ColorMapEntry quantity="0.61" color="#e4d5c2" opacity="1" label="0.61 - 1.02"/>
             <sld:ColorMapEntry quantity="1.02" color="#d3c2b0" opacity="1" label="1.02 - 1.43"/>
             <sld:ColorMapEntry quantity="1.43" color="#c2b09e" opacity="1" label="1.43 - 1.84"/>
             <sld:ColorMapEntry quantity="1.84" color="#b19d8c" opacity="1" label="1.84 - 2.24"/>
             <sld:ColorMapEntry quantity="2.24" color="#a08b7b" opacity="1" label="2.24 - 2.65"/>
             <sld:ColorMapEntry quantity="2.65" color="#8f7869" opacity="1" label="2.65 - 3.06"/>
             <sld:ColorMapEntry quantity="3.06" color="#7e6657" opacity="1" label="3.06 - 3.47"/>
             <sld:ColorMapEntry quantity="3.47" color="#6d5345" opacity="1" label="3.47 - 3.87"/>
             <sld:ColorMapEntry quantity="3.87" color="#5c4033" opacity="1" label="3.87 - 4.28"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MGEXCSD', 'Magnesium (Mg++) - exchangeable standard deviation', 'cmol/kg', 0.2911276, 4.936183, 'Magnesium (Mg++) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MGEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.29" color="#f4e7d3" opacity="1" label="0.29 - 0.76"/>
             <sld:ColorMapEntry quantity="0.76" color="#e4d5c2" opacity="1" label="0.76 - 1.22"/>
             <sld:ColorMapEntry quantity="1.22" color="#d3c2b0" opacity="1" label="1.22 - 1.68"/>
             <sld:ColorMapEntry quantity="1.68" color="#c2b09e" opacity="1" label="1.68 - 2.15"/>
             <sld:ColorMapEntry quantity="2.15" color="#b19d8c" opacity="1" label="2.15 - 2.61"/>
             <sld:ColorMapEntry quantity="2.61" color="#a08b7b" opacity="1" label="2.61 - 3.08"/>
             <sld:ColorMapEntry quantity="3.08" color="#8f7869" opacity="1" label="3.08 - 3.54"/>
             <sld:ColorMapEntry quantity="3.54" color="#7e6657" opacity="1" label="3.54 - 4.01"/>
             <sld:ColorMapEntry quantity="4.01" color="#6d5345" opacity="1" label="4.01 - 4.47"/>
             <sld:ColorMapEntry quantity="4.47" color="#5c4033" opacity="1" label="4.47 - 4.94"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MGEXT', 'Magnesium (Mg) - extractable', 'cmol/kg', NULL, NULL, 'Magnesium (Mg) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MGEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MGSOL', 'Magnesium (Mg++) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MGSOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MGTOT', 'Magnesium (Mg) - total', 'cmol/kg', NULL, NULL, 'Magnesium (Mg) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MGTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MNEXT', 'Manganese (Mn) - extractable', 'cmol/kg', NULL, NULL, 'Manganese (Mn) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MNEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('MNTOT', 'Manganese (Mn) - total', 'cmol/kg', NULL, NULL, 'Manganese (Mn) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>MNTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NAEXT', 'Sodium (Na) - extractable', 'cmol/kg', NULL, NULL, 'Sodium (Na) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NASOL', 'Sodium (Na+) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NASOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NATOT', 'Sodium (Na) - total', 'cmol/kg', NULL, NULL, 'Sodium (Na) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NATOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NO2SOL', 'Nitrite (NO2-) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NO2SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NO3SOL', 'Nitrate (NO3-) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NO3SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NTOT', 'Nitrogen (N) - total', '%', 0.0713, 4.24148, 'Nitrogen (N) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.07" color="#f4e7d3" opacity="1" label="0.07 - 0.49"/>
             <sld:ColorMapEntry quantity="0.49" color="#e4d5c2" opacity="1" label="0.49 - 0.91"/>
             <sld:ColorMapEntry quantity="0.91" color="#d3c2b0" opacity="1" label="0.91 - 1.32"/>
             <sld:ColorMapEntry quantity="1.32" color="#c2b09e" opacity="1" label="1.32 - 1.74"/>
             <sld:ColorMapEntry quantity="1.74" color="#b19d8c" opacity="1" label="1.74 - 2.16"/>
             <sld:ColorMapEntry quantity="2.16" color="#a08b7b" opacity="1" label="2.16 - 2.57"/>
             <sld:ColorMapEntry quantity="2.57" color="#8f7869" opacity="1" label="2.57 - 2.99"/>
             <sld:ColorMapEntry quantity="2.99" color="#7e6657" opacity="1" label="2.99 - 3.41"/>
             <sld:ColorMapEntry quantity="3.41" color="#6d5345" opacity="1" label="3.41 - 3.82"/>
             <sld:ColorMapEntry quantity="3.82" color="#5c4033" opacity="1" label="3.82 - 4.24"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NTOTSD', 'Nitrogen (N) - total standard deviation', '%', 0.023296468, 6.4045763, 'Nitrogen (N) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NTOTSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.02" color="#f4e7d3" opacity="1" label="0.02 - 0.66"/>
             <sld:ColorMapEntry quantity="0.66" color="#e4d5c2" opacity="1" label="0.66 - 1.30"/>
             <sld:ColorMapEntry quantity="1.3" color="#d3c2b0" opacity="1" label="1.30 - 1.94"/>
             <sld:ColorMapEntry quantity="1.94" color="#c2b09e" opacity="1" label="1.94 - 2.58"/>
             <sld:ColorMapEntry quantity="2.58" color="#b19d8c" opacity="1" label="2.58 - 3.21"/>
             <sld:ColorMapEntry quantity="3.21" color="#a08b7b" opacity="1" label="3.21 - 3.85"/>
             <sld:ColorMapEntry quantity="3.85" color="#8f7869" opacity="1" label="3.85 - 4.49"/>
             <sld:ColorMapEntry quantity="4.49" color="#7e6657" opacity="1" label="4.49 - 5.13"/>
             <sld:ColorMapEntry quantity="5.13" color="#6d5345" opacity="1" label="5.13 - 5.77"/>
             <sld:ColorMapEntry quantity="5.77" color="#5c4033" opacity="1" label="5.77 - 6.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PEXT', 'Phosphorus (P) - extractable', '%', NULL, NULL, 'Phosphorus (P) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PHAQ', 'pH - Hydrogen potential in water', 'pH', 4.13604, 7.18042, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHAQ</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.14" color="#f4e7d3" opacity="1" label="4.14 - 4.44"/>
             <sld:ColorMapEntry quantity="4.44" color="#e4d5c2" opacity="1" label="4.44 - 4.74"/>
             <sld:ColorMapEntry quantity="4.74" color="#d3c2b0" opacity="1" label="4.74 - 5.05"/>
             <sld:ColorMapEntry quantity="5.05" color="#c2b09e" opacity="1" label="5.05 - 5.35"/>
             <sld:ColorMapEntry quantity="5.35" color="#b19d8c" opacity="1" label="5.35 - 5.66"/>
             <sld:ColorMapEntry quantity="5.66" color="#a08b7b" opacity="1" label="5.66 - 5.96"/>
             <sld:ColorMapEntry quantity="5.96" color="#8f7869" opacity="1" label="5.96 - 6.27"/>
             <sld:ColorMapEntry quantity="6.27" color="#7e6657" opacity="1" label="6.27 - 6.57"/>
             <sld:ColorMapEntry quantity="6.57" color="#6d5345" opacity="1" label="6.57 - 6.88"/>
             <sld:ColorMapEntry quantity="6.88" color="#5c4033" opacity="1" label="6.88 - 7.18"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PHAQSD', 'pH - Hydrogen potential in water standard deviation', 'pH', 0.31554648, 1.3453712, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHAQSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.32" color="#f4e7d3" opacity="1" label="0.32 - 0.42"/>
             <sld:ColorMapEntry quantity="0.42" color="#e4d5c2" opacity="1" label="0.42 - 0.52"/>
             <sld:ColorMapEntry quantity="0.52" color="#d3c2b0" opacity="1" label="0.52 - 0.62"/>
             <sld:ColorMapEntry quantity="0.62" color="#c2b09e" opacity="1" label="0.62 - 0.73"/>
             <sld:ColorMapEntry quantity="0.73" color="#b19d8c" opacity="1" label="0.73 - 0.83"/>
             <sld:ColorMapEntry quantity="0.83" color="#a08b7b" opacity="1" label="0.83 - 0.93"/>
             <sld:ColorMapEntry quantity="0.93" color="#8f7869" opacity="1" label="0.93 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#7e6657" opacity="1" label="1.04 - 1.14"/>
             <sld:ColorMapEntry quantity="1.14" color="#6d5345" opacity="1" label="1.14 - 1.24"/>
             <sld:ColorMapEntry quantity="1.24" color="#5c4033" opacity="1" label="1.24 - 1.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PHX', 'pH - Hydrogen potential', 'pH', 3.8297784, 7.971385, 'pH - Hydrogen potential', 'quantitative', 10, '#CA0020', '#3F68E2', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="3.83" color="#ca0020" opacity="1" label="3.83 - 4.24"/>
             <sld:ColorMapEntry quantity="4.24" color="#bb0b35" opacity="1" label="4.24 - 4.66"/>
             <sld:ColorMapEntry quantity="4.66" color="#ac174b" opacity="1" label="4.66 - 5.07"/>
             <sld:ColorMapEntry quantity="5.07" color="#9c2260" opacity="1" label="5.07 - 5.49"/>
             <sld:ColorMapEntry quantity="5.49" color="#8d2e76" opacity="1" label="5.49 - 5.90"/>
             <sld:ColorMapEntry quantity="5.9" color="#7d398b" opacity="1" label="5.90 - 6.31"/>
             <sld:ColorMapEntry quantity="6.31" color="#6e45a1" opacity="1" label="6.31 - 6.73"/>
             <sld:ColorMapEntry quantity="6.73" color="#5e50b6" opacity="1" label="6.73 - 7.14"/>
             <sld:ColorMapEntry quantity="7.14" color="#4f5ccc" opacity="1" label="7.14 - 7.56"/>
             <sld:ColorMapEntry quantity="7.56" color="#3f68e2" opacity="1" label="7.56 - 7.97"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PHXSD', 'pH - Hydrogen potential standard deviation', 'pH', 0, 0.028895816, 'pH - Hydrogen potential', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#e4d5c2" opacity="1" label="0.00 - 0.01"/>
             <sld:ColorMapEntry quantity="0.01" color="#a08b7b" opacity="1" label="0.01 - 0.02"/>
             <sld:ColorMapEntry quantity="0.02" color="#6d5345" opacity="1" label="0.02 - 0.03"/>
             <sld:ColorMapEntry quantity="0.03" color="#5c4033" opacity="1" label="0.03 - 0.03"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PO4SOL', 'Phosphate (PO4--) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PO4SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PRET', 'Phosphorus (P) - retention', 'g/hg', NULL, NULL, 'Phosphorus (P) - retention', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PRET</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PTOT', 'Phosphorus (P) - total', '%', NULL, NULL, 'Phosphorus (P) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PXX', 'Phosphorus (P)', 'mg/kg', 2.52944, 203.4695, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PXX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.53" color="#f4e7d3" opacity="1" label="2.53 - 22.62"/>
             <sld:ColorMapEntry quantity="22.62" color="#e4d5c2" opacity="1" label="22.62 - 42.72"/>
             <sld:ColorMapEntry quantity="42.72" color="#d3c2b0" opacity="1" label="42.72 - 62.81"/>
             <sld:ColorMapEntry quantity="62.81" color="#c2b09e" opacity="1" label="62.81 - 82.91"/>
             <sld:ColorMapEntry quantity="82.91" color="#b19d8c" opacity="1" label="82.91 - 103.00"/>
             <sld:ColorMapEntry quantity="103" color="#a08b7b" opacity="1" label="103.00 - 123.09"/>
             <sld:ColorMapEntry quantity="123.09" color="#8f7869" opacity="1" label="123.09 - 143.19"/>
             <sld:ColorMapEntry quantity="143.19" color="#7e6657" opacity="1" label="143.19 - 163.28"/>
             <sld:ColorMapEntry quantity="163.28" color="#6d5345" opacity="1" label="163.28 - 183.38"/>
             <sld:ColorMapEntry quantity="183.38" color="#5c4033" opacity="1" label="183.38 - 203.47"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('PXXSD', 'Phosphorus (P) standard deviation', 'mg/kg', 4.233701, 232.6194, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PXXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.23" color="#f4e7d3" opacity="1" label="4.23 - 27.07"/>
             <sld:ColorMapEntry quantity="27.07" color="#e4d5c2" opacity="1" label="27.07 - 49.91"/>
             <sld:ColorMapEntry quantity="49.91" color="#d3c2b0" opacity="1" label="49.91 - 72.75"/>
             <sld:ColorMapEntry quantity="72.75" color="#c2b09e" opacity="1" label="72.75 - 95.59"/>
             <sld:ColorMapEntry quantity="95.59" color="#b19d8c" opacity="1" label="95.59 - 118.43"/>
             <sld:ColorMapEntry quantity="118.43" color="#a08b7b" opacity="1" label="118.43 - 141.27"/>
             <sld:ColorMapEntry quantity="141.27" color="#8f7869" opacity="1" label="141.27 - 164.10"/>
             <sld:ColorMapEntry quantity="164.1" color="#7e6657" opacity="1" label="164.10 - 186.94"/>
             <sld:ColorMapEntry quantity="186.94" color="#6d5345" opacity="1" label="186.94 - 209.78"/>
             <sld:ColorMapEntry quantity="209.78" color="#5c4033" opacity="1" label="209.78 - 232.62"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SALT', 'Salinification', 'class', 1, 10, NULL, 'categorical', 4, '#CA0020', '#3F68E2', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SALT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="values">
             <sld:ColorMapEntry quantity="-1" color="#000000" opacity="0" label="No Data"/>
             <sld:ColorMapEntry quantity="1" color="#ff0000" opacity="1" label="1 - Extreme Salinity"/>
             <sld:ColorMapEntry quantity="2" color="#f5deb3" opacity="1" label="2 - Moderate Salinity"/>
             <sld:ColorMapEntry quantity="3" color="#ee82ee" opacity="1" label="3 - Moderate Sodicity"/>
             <sld:ColorMapEntry quantity="4" color="#ffffff" opacity="1" label="4 - None"/>
             <sld:ColorMapEntry quantity="5" color="#00ffff" opacity="1" label="5 - Saline Sodic"/>
             <sld:ColorMapEntry quantity="6" color="#90ee90" opacity="1" label="6 - Slight Salinity"/>
             <sld:ColorMapEntry quantity="7" color="#add8e6" opacity="1" label="7 - Slight Sodicity"/>
             <sld:ColorMapEntry quantity="8" color="#f08080" opacity="1" label="8 - Strong Salinity"/>
             <sld:ColorMapEntry quantity="9" color="#da70d6" opacity="1" label="9 - Strong Sodicity"/>
             <sld:ColorMapEntry quantity="10" color="#f84040" opacity="1" label="10 - Very Strong Salinity"/>
             <sld:ColorMapEntry quantity="11" color="#800080" opacity="1" label="11 - Very Strong Sodicity"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SALTU', 'Salinification uncertainty', 'class', 0, 0.098, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SALTU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.01"/>
             <sld:ColorMapEntry quantity="0.01" color="#e4d5c2" opacity="1" label="0.01 - 0.02"/>
             <sld:ColorMapEntry quantity="0.02" color="#d3c2b0" opacity="1" label="0.02 - 0.03"/>
             <sld:ColorMapEntry quantity="0.03" color="#c2b09e" opacity="1" label="0.03 - 0.04"/>
             <sld:ColorMapEntry quantity="0.04" color="#b19d8c" opacity="1" label="0.04 - 0.05"/>
             <sld:ColorMapEntry quantity="0.05" color="#a08b7b" opacity="1" label="0.05 - 0.06"/>
             <sld:ColorMapEntry quantity="0.06" color="#8f7869" opacity="1" label="0.06 - 0.07"/>
             <sld:ColorMapEntry quantity="0.07" color="#7e6657" opacity="1" label="0.07 - 0.08"/>
             <sld:ColorMapEntry quantity="0.08" color="#6d5345" opacity="1" label="0.08 - 0.09"/>
             <sld:ColorMapEntry quantity="0.09" color="#5c4033" opacity="1" label="0.09 - 0.10"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SAND', 'Sand texture fraction', '%', 9.00936, 68.16394, 'Sand texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SAND</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="9.01" color="#f4e7d3" opacity="1" label="9.01 - 14.92"/>
             <sld:ColorMapEntry quantity="14.92" color="#e4d5c2" opacity="1" label="14.92 - 20.84"/>
             <sld:ColorMapEntry quantity="20.84" color="#d3c2b0" opacity="1" label="20.84 - 26.76"/>
             <sld:ColorMapEntry quantity="26.76" color="#c2b09e" opacity="1" label="26.76 - 32.67"/>
             <sld:ColorMapEntry quantity="32.67" color="#b19d8c" opacity="1" label="32.67 - 38.59"/>
             <sld:ColorMapEntry quantity="38.59" color="#a08b7b" opacity="1" label="38.59 - 44.50"/>
             <sld:ColorMapEntry quantity="44.5" color="#8f7869" opacity="1" label="44.50 - 50.42"/>
             <sld:ColorMapEntry quantity="50.42" color="#7e6657" opacity="1" label="50.42 - 56.33"/>
             <sld:ColorMapEntry quantity="56.33" color="#6d5345" opacity="1" label="56.33 - 62.25"/>
             <sld:ColorMapEntry quantity="62.25" color="#5c4033" opacity="1" label="62.25 - 68.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SANDSD', 'Sand texture fraction standard deviation', '%', 8.00042, 26.035404, 'Sand texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SANDSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="8" color="#f4e7d3" opacity="1" label="8.00 - 9.80"/>
             <sld:ColorMapEntry quantity="9.8" color="#e4d5c2" opacity="1" label="9.80 - 11.61"/>
             <sld:ColorMapEntry quantity="11.61" color="#d3c2b0" opacity="1" label="11.61 - 13.41"/>
             <sld:ColorMapEntry quantity="13.41" color="#c2b09e" opacity="1" label="13.41 - 15.21"/>
             <sld:ColorMapEntry quantity="15.21" color="#b19d8c" opacity="1" label="15.21 - 17.02"/>
             <sld:ColorMapEntry quantity="17.02" color="#a08b7b" opacity="1" label="17.02 - 18.82"/>
             <sld:ColorMapEntry quantity="18.82" color="#8f7869" opacity="1" label="18.82 - 20.62"/>
             <sld:ColorMapEntry quantity="20.62" color="#7e6657" opacity="1" label="20.62 - 22.43"/>
             <sld:ColorMapEntry quantity="22.43" color="#6d5345" opacity="1" label="22.43 - 24.23"/>
             <sld:ColorMapEntry quantity="24.23" color="#5c4033" opacity="1" label="24.23 - 26.04"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SEEXT', 'Selenium (Se) - extractable', 'mg/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SEEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SETOT', 'Selenium (Se) - total', 'mg/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SETOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SEXT', 'Sulfur (S) - extractable', '%', NULL, NULL, 'Sulfur (S) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SIEXT', 'Silicon (Si) - oxalate extractable', 'mg/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SIEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SILT', 'Silt texture fraction', '%', 18.000025, 67.36794, 'Silt texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SILT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="18" color="#f4e7d3" opacity="1" label="18.00 - 22.94"/>
             <sld:ColorMapEntry quantity="22.94" color="#e4d5c2" opacity="1" label="22.94 - 27.87"/>
             <sld:ColorMapEntry quantity="27.87" color="#d3c2b0" opacity="1" label="27.87 - 32.81"/>
             <sld:ColorMapEntry quantity="32.81" color="#c2b09e" opacity="1" label="32.81 - 37.75"/>
             <sld:ColorMapEntry quantity="37.75" color="#b19d8c" opacity="1" label="37.75 - 42.68"/>
             <sld:ColorMapEntry quantity="42.68" color="#a08b7b" opacity="1" label="42.68 - 47.62"/>
             <sld:ColorMapEntry quantity="47.62" color="#8f7869" opacity="1" label="47.62 - 52.56"/>
             <sld:ColorMapEntry quantity="52.56" color="#7e6657" opacity="1" label="52.56 - 57.49"/>
             <sld:ColorMapEntry quantity="57.49" color="#6d5345" opacity="1" label="57.49 - 62.43"/>
             <sld:ColorMapEntry quantity="62.43" color="#5c4033" opacity="1" label="62.43 - 67.37"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SILTSD', 'Silt texture fraction standard deviation', '%', 5.1637464, 27.138943, 'Silt texture fraction', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SILTSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.16" color="#f4e7d3" opacity="1" label="5.16 - 7.36"/>
             <sld:ColorMapEntry quantity="7.36" color="#e4d5c2" opacity="1" label="7.36 - 9.56"/>
             <sld:ColorMapEntry quantity="9.56" color="#d3c2b0" opacity="1" label="9.56 - 11.76"/>
             <sld:ColorMapEntry quantity="11.76" color="#c2b09e" opacity="1" label="11.76 - 13.95"/>
             <sld:ColorMapEntry quantity="13.95" color="#b19d8c" opacity="1" label="13.95 - 16.15"/>
             <sld:ColorMapEntry quantity="16.15" color="#a08b7b" opacity="1" label="16.15 - 18.35"/>
             <sld:ColorMapEntry quantity="18.35" color="#8f7869" opacity="1" label="18.35 - 20.55"/>
             <sld:ColorMapEntry quantity="20.55" color="#7e6657" opacity="1" label="20.55 - 22.74"/>
             <sld:ColorMapEntry quantity="22.74" color="#6d5345" opacity="1" label="22.74 - 24.94"/>
             <sld:ColorMapEntry quantity="24.94" color="#5c4033" opacity="1" label="24.94 - 27.14"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('SO4SOL', 'Sulfate (SO4--) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SO4SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('STOT', 'Sulfur (S) - total', '%', NULL, NULL, 'Sulfur (S) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>STOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ZNEXT', 'Zinc (Zn) - extractable', '%', NULL, NULL, 'Zinc (Zn) - extractable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ZNEXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CFA', 'Carbon (C) - fulvic acid', 'g/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFA</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CFRAG', 'Coarse fragments', '%', NULL, NULL, 'coarseFragmentsProperty', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFRAG</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CLSOL', 'Chloride (Cl-) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLSOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CNRAT', 'Carbon/Nitrogen (C/N) ratio', 'dimensionless', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CNRAT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CO3SOL', 'Carbonate (CO3--) - soluble', 'cmol/L', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CO3SOL</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM1', 'Organic carbon sequestration potential - ASR SSM1', 't/(ha·a)', -49.95, 2.6588793, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.69"/>
             <sld:ColorMapEntry quantity="-44.69" color="#e4d5c2" opacity="1" label="-44.69 - -39.43"/>
             <sld:ColorMapEntry quantity="-39.43" color="#d3c2b0" opacity="1" label="-39.43 - -34.17"/>
             <sld:ColorMapEntry quantity="-34.17" color="#c2b09e" opacity="1" label="-34.17 - -28.91"/>
             <sld:ColorMapEntry quantity="-28.91" color="#b19d8c" opacity="1" label="-28.91 - -23.65"/>
             <sld:ColorMapEntry quantity="-23.65" color="#a08b7b" opacity="1" label="-23.65 - -18.38"/>
             <sld:ColorMapEntry quantity="-18.38" color="#8f7869" opacity="1" label="-18.38 - -13.12"/>
             <sld:ColorMapEntry quantity="-13.12" color="#7e6657" opacity="1" label="-13.12 - -7.86"/>
             <sld:ColorMapEntry quantity="-7.86" color="#6d5345" opacity="1" label="-7.86 - -2.60"/>
             <sld:ColorMapEntry quantity="-2.6" color="#5c4033" opacity="1" label="-2.60 - 2.66"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM1U', 'Organic carbon sequestration potential - ASR SSM1 uncertainty', 't/(ha·a)', 15.3517, 573.3476, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM1U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.35" color="#f4e7d3" opacity="1" label="15.35 - 71.15"/>
             <sld:ColorMapEntry quantity="71.15" color="#e4d5c2" opacity="1" label="71.15 - 126.95"/>
             <sld:ColorMapEntry quantity="126.95" color="#d3c2b0" opacity="1" label="126.95 - 182.75"/>
             <sld:ColorMapEntry quantity="182.75" color="#c2b09e" opacity="1" label="182.75 - 238.55"/>
             <sld:ColorMapEntry quantity="238.55" color="#b19d8c" opacity="1" label="238.55 - 294.35"/>
             <sld:ColorMapEntry quantity="294.35" color="#a08b7b" opacity="1" label="294.35 - 350.15"/>
             <sld:ColorMapEntry quantity="350.15" color="#8f7869" opacity="1" label="350.15 - 405.95"/>
             <sld:ColorMapEntry quantity="405.95" color="#7e6657" opacity="1" label="405.95 - 461.75"/>
             <sld:ColorMapEntry quantity="461.75" color="#6d5345" opacity="1" label="461.75 - 517.55"/>
             <sld:ColorMapEntry quantity="517.55" color="#5c4033" opacity="1" label="517.55 - 573.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM2', 'Organic carbon sequestration potential - ASR SSM2', 't/(ha·a)', -49.95, 2.86917, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.67"/>
             <sld:ColorMapEntry quantity="-44.67" color="#e4d5c2" opacity="1" label="-44.67 - -39.39"/>
             <sld:ColorMapEntry quantity="-39.39" color="#d3c2b0" opacity="1" label="-39.39 - -34.10"/>
             <sld:ColorMapEntry quantity="-34.1" color="#c2b09e" opacity="1" label="-34.10 - -28.82"/>
             <sld:ColorMapEntry quantity="-28.82" color="#b19d8c" opacity="1" label="-28.82 - -23.54"/>
             <sld:ColorMapEntry quantity="-23.54" color="#a08b7b" opacity="1" label="-23.54 - -18.26"/>
             <sld:ColorMapEntry quantity="-18.26" color="#8f7869" opacity="1" label="-18.26 - -12.98"/>
             <sld:ColorMapEntry quantity="-12.98" color="#7e6657" opacity="1" label="-12.98 - -7.69"/>
             <sld:ColorMapEntry quantity="-7.69" color="#6d5345" opacity="1" label="-7.69 - -2.41"/>
             <sld:ColorMapEntry quantity="-2.41" color="#5c4033" opacity="1" label="-2.41 - 2.87"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM2U', 'Organic carbon sequestration potential - ASR SSM2 uncertainty', 't/(ha·a)', 15.36283, 578.25543, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM2U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.36" color="#f4e7d3" opacity="1" label="15.36 - 71.65"/>
             <sld:ColorMapEntry quantity="71.65" color="#e4d5c2" opacity="1" label="71.65 - 127.94"/>
             <sld:ColorMapEntry quantity="127.94" color="#d3c2b0" opacity="1" label="127.94 - 184.23"/>
             <sld:ColorMapEntry quantity="184.23" color="#c2b09e" opacity="1" label="184.23 - 240.52"/>
             <sld:ColorMapEntry quantity="240.52" color="#b19d8c" opacity="1" label="240.52 - 296.81"/>
             <sld:ColorMapEntry quantity="296.81" color="#a08b7b" opacity="1" label="296.81 - 353.10"/>
             <sld:ColorMapEntry quantity="353.1" color="#8f7869" opacity="1" label="353.10 - 409.39"/>
             <sld:ColorMapEntry quantity="409.39" color="#7e6657" opacity="1" label="409.39 - 465.68"/>
             <sld:ColorMapEntry quantity="465.68" color="#6d5345" opacity="1" label="465.68 - 521.97"/>
             <sld:ColorMapEntry quantity="521.97" color="#5c4033" opacity="1" label="521.97 - 578.26"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM3', 'Organic carbon sequestration potential - ASR SSM3', 't/(ha·a)', -49.95, 3.289751, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.63"/>
             <sld:ColorMapEntry quantity="-44.63" color="#e4d5c2" opacity="1" label="-44.63 - -39.30"/>
             <sld:ColorMapEntry quantity="-39.3" color="#d3c2b0" opacity="1" label="-39.30 - -33.98"/>
             <sld:ColorMapEntry quantity="-33.98" color="#c2b09e" opacity="1" label="-33.98 - -28.65"/>
             <sld:ColorMapEntry quantity="-28.65" color="#b19d8c" opacity="1" label="-28.65 - -23.33"/>
             <sld:ColorMapEntry quantity="-23.33" color="#a08b7b" opacity="1" label="-23.33 - -18.01"/>
             <sld:ColorMapEntry quantity="-18.01" color="#8f7869" opacity="1" label="-18.01 - -12.68"/>
             <sld:ColorMapEntry quantity="-12.68" color="#7e6657" opacity="1" label="-12.68 - -7.36"/>
             <sld:ColorMapEntry quantity="-7.36" color="#6d5345" opacity="1" label="-7.36 - -2.03"/>
             <sld:ColorMapEntry quantity="-2.03" color="#5c4033" opacity="1" label="-2.03 - 3.29"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGASRSSM3U', 'Organic carbon sequestration potential - ASR SSM3 uncertainty', 't/(ha·a)', 15.385822, 587.7394, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM3U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.39" color="#f4e7d3" opacity="1" label="15.39 - 72.62"/>
             <sld:ColorMapEntry quantity="72.62" color="#e4d5c2" opacity="1" label="72.62 - 129.86"/>
             <sld:ColorMapEntry quantity="129.86" color="#d3c2b0" opacity="1" label="129.86 - 187.09"/>
             <sld:ColorMapEntry quantity="187.09" color="#c2b09e" opacity="1" label="187.09 - 244.33"/>
             <sld:ColorMapEntry quantity="244.33" color="#b19d8c" opacity="1" label="244.33 - 301.56"/>
             <sld:ColorMapEntry quantity="301.56" color="#a08b7b" opacity="1" label="301.56 - 358.80"/>
             <sld:ColorMapEntry quantity="358.8" color="#8f7869" opacity="1" label="358.80 - 416.03"/>
             <sld:ColorMapEntry quantity="416.03" color="#7e6657" opacity="1" label="416.03 - 473.27"/>
             <sld:ColorMapEntry quantity="473.27" color="#6d5345" opacity="1" label="473.27 - 530.50"/>
             <sld:ColorMapEntry quantity="530.5" color="#5c4033" opacity="1" label="530.50 - 587.74"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGBAUU', 'Organic carbon sequestration potential - business as usual uncertainty', 't/(ha·a)', 19.502748, 114.15707, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGBAUU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="19.5" color="#f4e7d3" opacity="1" label="19.50 - 28.97"/>
             <sld:ColorMapEntry quantity="28.97" color="#e4d5c2" opacity="1" label="28.97 - 38.43"/>
             <sld:ColorMapEntry quantity="38.43" color="#d3c2b0" opacity="1" label="38.43 - 47.90"/>
             <sld:ColorMapEntry quantity="47.9" color="#c2b09e" opacity="1" label="47.90 - 57.36"/>
             <sld:ColorMapEntry quantity="57.36" color="#b19d8c" opacity="1" label="57.36 - 66.83"/>
             <sld:ColorMapEntry quantity="66.83" color="#a08b7b" opacity="1" label="66.83 - 76.30"/>
             <sld:ColorMapEntry quantity="76.3" color="#8f7869" opacity="1" label="76.30 - 85.76"/>
             <sld:ColorMapEntry quantity="85.76" color="#7e6657" opacity="1" label="85.76 - 95.23"/>
             <sld:ColorMapEntry quantity="95.23" color="#6d5345" opacity="1" label="95.23 - 104.69"/>
             <sld:ColorMapEntry quantity="104.69" color="#5c4033" opacity="1" label="104.69 - 114.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGNTOTR', 'Organic carbon (C) nitrogen (N) ratio', 'dimensionless', 5.91756, 53.81236, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGNTOTR</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.92" color="#f4e7d3" opacity="1" label="5.92 - 10.71"/>
             <sld:ColorMapEntry quantity="10.71" color="#e4d5c2" opacity="1" label="10.71 - 15.50"/>
             <sld:ColorMapEntry quantity="15.5" color="#d3c2b0" opacity="1" label="15.50 - 20.29"/>
             <sld:ColorMapEntry quantity="20.29" color="#c2b09e" opacity="1" label="20.29 - 25.08"/>
             <sld:ColorMapEntry quantity="25.08" color="#b19d8c" opacity="1" label="25.08 - 29.86"/>
             <sld:ColorMapEntry quantity="29.86" color="#a08b7b" opacity="1" label="29.86 - 34.65"/>
             <sld:ColorMapEntry quantity="34.65" color="#8f7869" opacity="1" label="34.65 - 39.44"/>
             <sld:ColorMapEntry quantity="39.44" color="#7e6657" opacity="1" label="39.44 - 44.23"/>
             <sld:ColorMapEntry quantity="44.23" color="#6d5345" opacity="1" label="44.23 - 49.02"/>
             <sld:ColorMapEntry quantity="49.02" color="#5c4033" opacity="1" label="49.02 - 53.81"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGNTOTRSD', 'Organic carbon (C) nitrogen (N) ratio standard deviation', 'dimensionless', 2.0641875, 75.02881, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGNTOTRSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.06" color="#f4e7d3" opacity="1" label="2.06 - 9.36"/>
             <sld:ColorMapEntry quantity="9.36" color="#e4d5c2" opacity="1" label="9.36 - 16.66"/>
             <sld:ColorMapEntry quantity="16.66" color="#d3c2b0" opacity="1" label="16.66 - 23.95"/>
             <sld:ColorMapEntry quantity="23.95" color="#c2b09e" opacity="1" label="23.95 - 31.25"/>
             <sld:ColorMapEntry quantity="31.25" color="#b19d8c" opacity="1" label="31.25 - 38.55"/>
             <sld:ColorMapEntry quantity="38.55" color="#a08b7b" opacity="1" label="38.55 - 45.84"/>
             <sld:ColorMapEntry quantity="45.84" color="#8f7869" opacity="1" label="45.84 - 53.14"/>
             <sld:ColorMapEntry quantity="53.14" color="#7e6657" opacity="1" label="53.14 - 60.44"/>
             <sld:ColorMapEntry quantity="60.44" color="#6d5345" opacity="1" label="60.44 - 67.73"/>
             <sld:ColorMapEntry quantity="67.73" color="#5c4033" opacity="1" label="67.73 - 75.03"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRDSSM1', 'Organic carbon sequestration potential - relative difference SSM1', 't/(ha·a)', 0, 5.4669366, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.55"/>
             <sld:ColorMapEntry quantity="0.55" color="#e4d5c2" opacity="1" label="0.55 - 1.09"/>
             <sld:ColorMapEntry quantity="1.09" color="#d3c2b0" opacity="1" label="1.09 - 1.64"/>
             <sld:ColorMapEntry quantity="1.64" color="#c2b09e" opacity="1" label="1.64 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#b19d8c" opacity="1" label="2.19 - 2.73"/>
             <sld:ColorMapEntry quantity="2.73" color="#a08b7b" opacity="1" label="2.73 - 3.28"/>
             <sld:ColorMapEntry quantity="3.28" color="#8f7869" opacity="1" label="3.28 - 3.83"/>
             <sld:ColorMapEntry quantity="3.83" color="#7e6657" opacity="1" label="3.83 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#6d5345" opacity="1" label="4.37 - 4.92"/>
             <sld:ColorMapEntry quantity="4.92" color="#5c4033" opacity="1" label="4.92 - 5.47"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRDSSM2', 'Organic carbon sequestration potential - relative difference SSM2', 't/(ha·a)', 0, 10.933873, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 1.09"/>
             <sld:ColorMapEntry quantity="1.09" color="#e4d5c2" opacity="1" label="1.09 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#d3c2b0" opacity="1" label="2.19 - 3.28"/>
             <sld:ColorMapEntry quantity="3.28" color="#c2b09e" opacity="1" label="3.28 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#b19d8c" opacity="1" label="4.37 - 5.47"/>
             <sld:ColorMapEntry quantity="5.47" color="#a08b7b" opacity="1" label="5.47 - 6.56"/>
             <sld:ColorMapEntry quantity="6.56" color="#8f7869" opacity="1" label="6.56 - 7.65"/>
             <sld:ColorMapEntry quantity="7.65" color="#7e6657" opacity="1" label="7.65 - 8.75"/>
             <sld:ColorMapEntry quantity="8.75" color="#6d5345" opacity="1" label="8.75 - 9.84"/>
             <sld:ColorMapEntry quantity="9.84" color="#5c4033" opacity="1" label="9.84 - 10.93"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRDSSM3', 'Organic carbon sequestration potential - relative difference SSM3', 't/(ha·a)', 0, 21.867746, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#e4d5c2" opacity="1" label="2.19 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#d3c2b0" opacity="1" label="4.37 - 6.56"/>
             <sld:ColorMapEntry quantity="6.56" color="#c2b09e" opacity="1" label="6.56 - 8.75"/>
             <sld:ColorMapEntry quantity="8.75" color="#b19d8c" opacity="1" label="8.75 - 10.93"/>
             <sld:ColorMapEntry quantity="10.93" color="#a08b7b" opacity="1" label="10.93 - 13.12"/>
             <sld:ColorMapEntry quantity="13.12" color="#8f7869" opacity="1" label="13.12 - 15.31"/>
             <sld:ColorMapEntry quantity="15.31" color="#7e6657" opacity="1" label="15.31 - 17.49"/>
             <sld:ColorMapEntry quantity="17.49" color="#6d5345" opacity="1" label="17.49 - 19.68"/>
             <sld:ColorMapEntry quantity="19.68" color="#5c4033" opacity="1" label="19.68 - 21.87"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM1', 'Organic carbon sequestration potential - RSR SSM1', 't/(ha·a)', 0, 0.27334684, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.03"/>
             <sld:ColorMapEntry quantity="0.03" color="#e4d5c2" opacity="1" label="0.03 - 0.05"/>
             <sld:ColorMapEntry quantity="0.05" color="#d3c2b0" opacity="1" label="0.05 - 0.08"/>
             <sld:ColorMapEntry quantity="0.08" color="#c2b09e" opacity="1" label="0.08 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#b19d8c" opacity="1" label="0.11 - 0.14"/>
             <sld:ColorMapEntry quantity="0.14" color="#a08b7b" opacity="1" label="0.14 - 0.16"/>
             <sld:ColorMapEntry quantity="0.16" color="#8f7869" opacity="1" label="0.16 - 0.19"/>
             <sld:ColorMapEntry quantity="0.19" color="#7e6657" opacity="1" label="0.19 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#6d5345" opacity="1" label="0.22 - 0.25"/>
             <sld:ColorMapEntry quantity="0.25" color="#5c4033" opacity="1" label="0.25 - 0.27"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM1U', 'Organic carbon sequestration potential - RSR SSM1 uncertainty', 't/(ha·a)', 5.4367414, 706.39966, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM1U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.44" color="#f4e7d3" opacity="1" label="5.44 - 75.53"/>
             <sld:ColorMapEntry quantity="75.53" color="#e4d5c2" opacity="1" label="75.53 - 145.63"/>
             <sld:ColorMapEntry quantity="145.63" color="#d3c2b0" opacity="1" label="145.63 - 215.73"/>
             <sld:ColorMapEntry quantity="215.73" color="#c2b09e" opacity="1" label="215.73 - 285.82"/>
             <sld:ColorMapEntry quantity="285.82" color="#b19d8c" opacity="1" label="285.82 - 355.92"/>
             <sld:ColorMapEntry quantity="355.92" color="#a08b7b" opacity="1" label="355.92 - 426.01"/>
             <sld:ColorMapEntry quantity="426.01" color="#8f7869" opacity="1" label="426.01 - 496.11"/>
             <sld:ColorMapEntry quantity="496.11" color="#7e6657" opacity="1" label="496.11 - 566.21"/>
             <sld:ColorMapEntry quantity="566.21" color="#6d5345" opacity="1" label="566.21 - 636.30"/>
             <sld:ColorMapEntry quantity="636.3" color="#5c4033" opacity="1" label="636.30 - 706.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM2', 'Organic carbon sequestration potential - RSR SSM2', 't/(ha·a)', 0, 0.5466937, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.05"/>
             <sld:ColorMapEntry quantity="0.05" color="#e4d5c2" opacity="1" label="0.05 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#d3c2b0" opacity="1" label="0.11 - 0.16"/>
             <sld:ColorMapEntry quantity="0.16" color="#c2b09e" opacity="1" label="0.16 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#b19d8c" opacity="1" label="0.22 - 0.27"/>
             <sld:ColorMapEntry quantity="0.27" color="#a08b7b" opacity="1" label="0.27 - 0.33"/>
             <sld:ColorMapEntry quantity="0.33" color="#8f7869" opacity="1" label="0.33 - 0.38"/>
             <sld:ColorMapEntry quantity="0.38" color="#7e6657" opacity="1" label="0.38 - 0.44"/>
             <sld:ColorMapEntry quantity="0.44" color="#6d5345" opacity="1" label="0.44 - 0.49"/>
             <sld:ColorMapEntry quantity="0.49" color="#5c4033" opacity="1" label="0.49 - 0.55"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM2U', 'Organic carbon sequestration potential - RSR SSM1 uncertainty', 't/(ha·a)', 5.4618306, 706.39966, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM2U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.46" color="#f4e7d3" opacity="1" label="5.46 - 75.56"/>
             <sld:ColorMapEntry quantity="75.56" color="#e4d5c2" opacity="1" label="75.56 - 145.65"/>
             <sld:ColorMapEntry quantity="145.65" color="#d3c2b0" opacity="1" label="145.65 - 215.74"/>
             <sld:ColorMapEntry quantity="215.74" color="#c2b09e" opacity="1" label="215.74 - 285.84"/>
             <sld:ColorMapEntry quantity="285.84" color="#b19d8c" opacity="1" label="285.84 - 355.93"/>
             <sld:ColorMapEntry quantity="355.93" color="#a08b7b" opacity="1" label="355.93 - 426.02"/>
             <sld:ColorMapEntry quantity="426.02" color="#8f7869" opacity="1" label="426.02 - 496.12"/>
             <sld:ColorMapEntry quantity="496.12" color="#7e6657" opacity="1" label="496.12 - 566.21"/>
             <sld:ColorMapEntry quantity="566.21" color="#6d5345" opacity="1" label="566.21 - 636.31"/>
             <sld:ColorMapEntry quantity="636.31" color="#5c4033" opacity="1" label="636.31 - 706.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM3', 'Organic carbon sequestration potential - RSR SSM3', 't/(ha·a)', 0, 1.0933874, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#e4d5c2" opacity="1" label="0.11 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#d3c2b0" opacity="1" label="0.22 - 0.33"/>
             <sld:ColorMapEntry quantity="0.33" color="#c2b09e" opacity="1" label="0.33 - 0.44"/>
             <sld:ColorMapEntry quantity="0.44" color="#b19d8c" opacity="1" label="0.44 - 0.55"/>
             <sld:ColorMapEntry quantity="0.55" color="#a08b7b" opacity="1" label="0.55 - 0.66"/>
             <sld:ColorMapEntry quantity="0.66" color="#8f7869" opacity="1" label="0.66 - 0.77"/>
             <sld:ColorMapEntry quantity="0.77" color="#7e6657" opacity="1" label="0.77 - 0.87"/>
             <sld:ColorMapEntry quantity="0.87" color="#6d5345" opacity="1" label="0.87 - 0.98"/>
             <sld:ColorMapEntry quantity="0.98" color="#5c4033" opacity="1" label="0.98 - 1.09"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGRSRSSM3U', 'Organic carbon sequestration potential - RSR SSM3 uncertainty', 't/(ha·a)', 5.511483, 706.39966, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM3U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.51" color="#f4e7d3" opacity="1" label="5.51 - 75.60"/>
             <sld:ColorMapEntry quantity="75.6" color="#e4d5c2" opacity="1" label="75.60 - 145.69"/>
             <sld:ColorMapEntry quantity="145.69" color="#d3c2b0" opacity="1" label="145.69 - 215.78"/>
             <sld:ColorMapEntry quantity="215.78" color="#c2b09e" opacity="1" label="215.78 - 285.87"/>
             <sld:ColorMapEntry quantity="285.87" color="#b19d8c" opacity="1" label="285.87 - 355.96"/>
             <sld:ColorMapEntry quantity="355.96" color="#a08b7b" opacity="1" label="355.96 - 426.04"/>
             <sld:ColorMapEntry quantity="426.04" color="#8f7869" opacity="1" label="426.04 - 496.13"/>
             <sld:ColorMapEntry quantity="496.13" color="#7e6657" opacity="1" label="496.13 - 566.22"/>
             <sld:ColorMapEntry quantity="566.22" color="#6d5345" opacity="1" label="566.22 - 636.31"/>
             <sld:ColorMapEntry quantity="636.31" color="#5c4033" opacity="1" label="636.31 - 706.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CORGT0U', 'Organic carbon sequestration potential - time zero uncertainty', 't/(ha·a)', -105.512276, 567.0031, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGT0U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-105.51" color="#f4e7d3" opacity="1" label="-105.51 - -38.26"/>
             <sld:ColorMapEntry quantity="-38.26" color="#e4d5c2" opacity="1" label="-38.26 - 28.99"/>
             <sld:ColorMapEntry quantity="28.99" color="#d3c2b0" opacity="1" label="28.99 - 96.24"/>
             <sld:ColorMapEntry quantity="96.24" color="#c2b09e" opacity="1" label="96.24 - 163.49"/>
             <sld:ColorMapEntry quantity="163.49" color="#b19d8c" opacity="1" label="163.49 - 230.75"/>
             <sld:ColorMapEntry quantity="230.75" color="#a08b7b" opacity="1" label="230.75 - 298.00"/>
             <sld:ColorMapEntry quantity="298" color="#8f7869" opacity="1" label="298.00 - 365.25"/>
             <sld:ColorMapEntry quantity="365.25" color="#7e6657" opacity="1" label="365.25 - 432.50"/>
             <sld:ColorMapEntry quantity="432.5" color="#6d5345" opacity="1" label="432.50 - 499.75"/>
             <sld:ColorMapEntry quantity="499.75" color="#5c4033" opacity="1" label="499.75 - 567.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CTHUM', 'Carbon (C) - total humic', 'g/kg', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CTHUM</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('CTOT', 'Carbon (C) - total', 'g/kg', NULL, NULL, 'Carbon (C) - total', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('KXXSD', 'Potassium (K) standard deviation', 'mg/kg', 20.059908, 456.89383, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KXXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="20.06" color="#f4e7d3" opacity="1" label="20.06 - 63.74"/>
             <sld:ColorMapEntry quantity="63.74" color="#e4d5c2" opacity="1" label="63.74 - 107.43"/>
             <sld:ColorMapEntry quantity="107.43" color="#d3c2b0" opacity="1" label="107.43 - 151.11"/>
             <sld:ColorMapEntry quantity="151.11" color="#c2b09e" opacity="1" label="151.11 - 194.79"/>
             <sld:ColorMapEntry quantity="194.79" color="#b19d8c" opacity="1" label="194.79 - 238.48"/>
             <sld:ColorMapEntry quantity="238.48" color="#a08b7b" opacity="1" label="238.48 - 282.16"/>
             <sld:ColorMapEntry quantity="282.16" color="#8f7869" opacity="1" label="282.16 - 325.84"/>
             <sld:ColorMapEntry quantity="325.84" color="#7e6657" opacity="1" label="325.84 - 369.53"/>
             <sld:ColorMapEntry quantity="369.53" color="#6d5345" opacity="1" label="369.53 - 413.21"/>
             <sld:ColorMapEntry quantity="413.21" color="#5c4033" opacity="1" label="413.21 - 456.89"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NAEXC', 'Sodium (Na+) - exchangeable', '%', 0.001, 337.90482, 'Sodium (Na+) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 33.79"/>
             <sld:ColorMapEntry quantity="33.79" color="#e4d5c2" opacity="1" label="33.79 - 67.58"/>
             <sld:ColorMapEntry quantity="67.58" color="#d3c2b0" opacity="1" label="67.58 - 101.37"/>
             <sld:ColorMapEntry quantity="101.37" color="#c2b09e" opacity="1" label="101.37 - 135.16"/>
             <sld:ColorMapEntry quantity="135.16" color="#b19d8c" opacity="1" label="135.16 - 168.95"/>
             <sld:ColorMapEntry quantity="168.95" color="#a08b7b" opacity="1" label="168.95 - 202.74"/>
             <sld:ColorMapEntry quantity="202.74" color="#8f7869" opacity="1" label="202.74 - 236.53"/>
             <sld:ColorMapEntry quantity="236.53" color="#7e6657" opacity="1" label="236.53 - 270.32"/>
             <sld:ColorMapEntry quantity="270.32" color="#6d5345" opacity="1" label="270.32 - 304.11"/>
             <sld:ColorMapEntry quantity="304.11" color="#5c4033" opacity="1" label="304.11 - 337.90"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('NAEXCSD', 'Sodium (Na+) - exchangeable standard deviation', '%', 0, 3.2009795, 'Sodium (Na+) - exchangeable', 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.32"/>
             <sld:ColorMapEntry quantity="0.32" color="#e4d5c2" opacity="1" label="0.32 - 0.64"/>
             <sld:ColorMapEntry quantity="0.64" color="#d3c2b0" opacity="1" label="0.64 - 0.96"/>
             <sld:ColorMapEntry quantity="0.96" color="#c2b09e" opacity="1" label="0.96 - 1.28"/>
             <sld:ColorMapEntry quantity="1.28" color="#b19d8c" opacity="1" label="1.28 - 1.60"/>
             <sld:ColorMapEntry quantity="1.6" color="#a08b7b" opacity="1" label="1.60 - 1.92"/>
             <sld:ColorMapEntry quantity="1.92" color="#8f7869" opacity="1" label="1.92 - 2.24"/>
             <sld:ColorMapEntry quantity="2.24" color="#7e6657" opacity="1" label="2.24 - 2.56"/>
             <sld:ColorMapEntry quantity="2.56" color="#6d5345" opacity="1" label="2.56 - 2.88"/>
             <sld:ColorMapEntry quantity="2.88" color="#5c4033" opacity="1" label="2.88 - 3.20"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');
INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, min, max, property_phys_chem_id, property_type, num_intervals, start_color, end_color, sld) VALUES ('ZNTOT', 'Zinc (Zn) - total', '%', NULL, NULL, NULL, 'quantitative', 10, '#F4E7D3', '#5C4033', '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ZNTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>');


-- Completed on 2025-08-22 13:39:47 CEST

--
-- PostgreSQL database dump complete
--

