<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>