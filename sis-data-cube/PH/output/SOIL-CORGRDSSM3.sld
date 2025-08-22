<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#e4d5c2" opacity="1" label="2.19 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#d3c2b0" opacity="1" label="4.37 - 6.56"/>
             <sld:ColorMapEntry quantity="6.56" color="#c2b09e" opacity="1" label="6.56 - 8.75"/>
             <sld:ColorMapEntry quantity="8.75" color="#b19d8c" opacity="1" label="8.75 - 10.93"/>
             <sld:ColorMapEntry quantity="10.93" color="#a08b7b" opacity="1" label="10.93 - 13.12"/>
             <sld:ColorMapEntry quantity="13.12" color="#8f7869" opacity="1" label="13.12 - 15.31"/>
             <sld:ColorMapEntry quantity="15.31" color="#7e6657" opacity="1" label="15.31 - 17.49"/>
             <sld:ColorMapEntry quantity="17.49" color="#6d5345" opacity="1" label="17.49 - 19.68"/>
             <sld:ColorMapEntry quantity="19.68" color="#5c4033" opacity="1" label="19.68 - 21.87"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>