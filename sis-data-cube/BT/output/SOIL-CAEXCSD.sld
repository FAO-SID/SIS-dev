<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CAEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.91" color="#f4e7d3" opacity="1" label="0.91 - 2.59"/>
             <sld:ColorMapEntry quantity="2.59" color="#e4d5c2" opacity="1" label="2.59 - 4.26"/>
             <sld:ColorMapEntry quantity="4.26" color="#d3c2b0" opacity="1" label="4.26 - 5.94"/>
             <sld:ColorMapEntry quantity="5.94" color="#c2b09e" opacity="1" label="5.94 - 7.61"/>
             <sld:ColorMapEntry quantity="7.61" color="#b19d8c" opacity="1" label="7.61 - 9.29"/>
             <sld:ColorMapEntry quantity="9.29" color="#a08b7b" opacity="1" label="9.29 - 10.96"/>
             <sld:ColorMapEntry quantity="10.96" color="#8f7869" opacity="1" label="10.96 - 12.64"/>
             <sld:ColorMapEntry quantity="12.64" color="#7e6657" opacity="1" label="12.64 - 14.31"/>
             <sld:ColorMapEntry quantity="14.31" color="#6d5345" opacity="1" label="14.31 - 15.99"/>
             <sld:ColorMapEntry quantity="15.99" color="#5c4033" opacity="1" label="15.99 - 17.66"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>