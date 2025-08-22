<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>