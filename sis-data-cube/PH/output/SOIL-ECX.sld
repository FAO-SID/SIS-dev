<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>