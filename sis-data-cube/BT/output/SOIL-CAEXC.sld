<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CAEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.75" color="#f4e7d3" opacity="1" label="0.75 - 2.23"/>
             <sld:ColorMapEntry quantity="2.23" color="#e4d5c2" opacity="1" label="2.23 - 3.71"/>
             <sld:ColorMapEntry quantity="3.71" color="#d3c2b0" opacity="1" label="3.71 - 5.19"/>
             <sld:ColorMapEntry quantity="5.19" color="#c2b09e" opacity="1" label="5.19 - 6.67"/>
             <sld:ColorMapEntry quantity="6.67" color="#b19d8c" opacity="1" label="6.67 - 8.15"/>
             <sld:ColorMapEntry quantity="8.15" color="#a08b7b" opacity="1" label="8.15 - 9.63"/>
             <sld:ColorMapEntry quantity="9.63" color="#8f7869" opacity="1" label="9.63 - 11.11"/>
             <sld:ColorMapEntry quantity="11.11" color="#7e6657" opacity="1" label="11.11 - 12.59"/>
             <sld:ColorMapEntry quantity="12.59" color="#6d5345" opacity="1" label="12.59 - 14.07"/>
             <sld:ColorMapEntry quantity="14.07" color="#5c4033" opacity="1" label="14.07 - 15.55"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>