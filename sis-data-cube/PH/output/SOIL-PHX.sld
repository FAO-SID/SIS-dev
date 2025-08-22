<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>