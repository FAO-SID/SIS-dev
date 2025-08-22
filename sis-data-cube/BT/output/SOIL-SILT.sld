<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>