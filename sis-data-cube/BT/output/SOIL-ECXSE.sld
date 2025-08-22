<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ECXSE</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#e4d5c2" opacity="1" label="1.04 - 2.07"/>
             <sld:ColorMapEntry quantity="2.07" color="#d3c2b0" opacity="1" label="2.07 - 3.10"/>
             <sld:ColorMapEntry quantity="3.1" color="#c2b09e" opacity="1" label="3.10 - 4.14"/>
             <sld:ColorMapEntry quantity="4.14" color="#b19d8c" opacity="1" label="4.14 - 5.17"/>
             <sld:ColorMapEntry quantity="5.17" color="#a08b7b" opacity="1" label="5.17 - 6.21"/>
             <sld:ColorMapEntry quantity="6.21" color="#8f7869" opacity="1" label="6.21 - 7.24"/>
             <sld:ColorMapEntry quantity="7.24" color="#7e6657" opacity="1" label="7.24 - 8.27"/>
             <sld:ColorMapEntry quantity="8.27" color="#6d5345" opacity="1" label="8.27 - 9.31"/>
             <sld:ColorMapEntry quantity="9.31" color="#5c4033" opacity="1" label="9.31 - 10.34"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>