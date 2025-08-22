<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>