<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM2U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.46" color="#f4e7d3" opacity="1" label="5.46 - 75.56"/>
             <sld:ColorMapEntry quantity="75.56" color="#e4d5c2" opacity="1" label="75.56 - 145.65"/>
             <sld:ColorMapEntry quantity="145.65" color="#d3c2b0" opacity="1" label="145.65 - 215.74"/>
             <sld:ColorMapEntry quantity="215.74" color="#c2b09e" opacity="1" label="215.74 - 285.84"/>
             <sld:ColorMapEntry quantity="285.84" color="#b19d8c" opacity="1" label="285.84 - 355.93"/>
             <sld:ColorMapEntry quantity="355.93" color="#a08b7b" opacity="1" label="355.93 - 426.02"/>
             <sld:ColorMapEntry quantity="426.02" color="#8f7869" opacity="1" label="426.02 - 496.12"/>
             <sld:ColorMapEntry quantity="496.12" color="#7e6657" opacity="1" label="496.12 - 566.21"/>
             <sld:ColorMapEntry quantity="566.21" color="#6d5345" opacity="1" label="566.21 - 636.31"/>
             <sld:ColorMapEntry quantity="636.31" color="#5c4033" opacity="1" label="636.31 - 706.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>