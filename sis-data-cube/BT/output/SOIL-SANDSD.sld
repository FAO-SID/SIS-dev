<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SANDSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="8" color="#f4e7d3" opacity="1" label="8.00 - 9.80"/>
             <sld:ColorMapEntry quantity="9.8" color="#e4d5c2" opacity="1" label="9.80 - 11.61"/>
             <sld:ColorMapEntry quantity="11.61" color="#d3c2b0" opacity="1" label="11.61 - 13.41"/>
             <sld:ColorMapEntry quantity="13.41" color="#c2b09e" opacity="1" label="13.41 - 15.21"/>
             <sld:ColorMapEntry quantity="15.21" color="#b19d8c" opacity="1" label="15.21 - 17.02"/>
             <sld:ColorMapEntry quantity="17.02" color="#a08b7b" opacity="1" label="17.02 - 18.82"/>
             <sld:ColorMapEntry quantity="18.82" color="#8f7869" opacity="1" label="18.82 - 20.62"/>
             <sld:ColorMapEntry quantity="20.62" color="#7e6657" opacity="1" label="20.62 - 22.43"/>
             <sld:ColorMapEntry quantity="22.43" color="#6d5345" opacity="1" label="22.43 - 24.23"/>
             <sld:ColorMapEntry quantity="24.23" color="#5c4033" opacity="1" label="24.23 - 26.04"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>