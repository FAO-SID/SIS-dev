<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>