<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>