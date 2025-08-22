<?xml version="1.0" encoding="UTF-8"?>
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
</StyledLayerDescriptor>