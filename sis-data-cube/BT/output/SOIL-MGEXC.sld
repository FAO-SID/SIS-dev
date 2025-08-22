<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>