<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 1.09"/>
             <sld:ColorMapEntry quantity="1.09" color="#e4d5c2" opacity="1" label="1.09 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#d3c2b0" opacity="1" label="2.19 - 3.28"/>
             <sld:ColorMapEntry quantity="3.28" color="#c2b09e" opacity="1" label="3.28 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#b19d8c" opacity="1" label="4.37 - 5.47"/>
             <sld:ColorMapEntry quantity="5.47" color="#a08b7b" opacity="1" label="5.47 - 6.56"/>
             <sld:ColorMapEntry quantity="6.56" color="#8f7869" opacity="1" label="6.56 - 7.65"/>
             <sld:ColorMapEntry quantity="7.65" color="#7e6657" opacity="1" label="7.65 - 8.75"/>
             <sld:ColorMapEntry quantity="8.75" color="#6d5345" opacity="1" label="8.75 - 9.84"/>
             <sld:ColorMapEntry quantity="9.84" color="#5c4033" opacity="1" label="9.84 - 10.93"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>