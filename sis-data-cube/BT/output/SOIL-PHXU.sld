<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHXU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1" color="#f4e7d3" opacity="1" label="1.00 - 1.01"/>
             <sld:ColorMapEntry quantity="1.01" color="#d3c2b0" opacity="1" label="1.01 - 1.02"/>
             <sld:ColorMapEntry quantity="1.02" color="#b19d8c" opacity="1" label="1.02 - 1.03"/>
             <sld:ColorMapEntry quantity="1.03" color="#8f7869" opacity="1" label="1.03 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#7e6657" opacity="1" label="1.04 - 1.05"/>
             <sld:ColorMapEntry quantity="1.05" color="#5c4033" opacity="1" label="1.05 - 1.06"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>