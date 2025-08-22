<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHAQSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.32" color="#f4e7d3" opacity="1" label="0.32 - 0.42"/>
             <sld:ColorMapEntry quantity="0.42" color="#e4d5c2" opacity="1" label="0.42 - 0.52"/>
             <sld:ColorMapEntry quantity="0.52" color="#d3c2b0" opacity="1" label="0.52 - 0.62"/>
             <sld:ColorMapEntry quantity="0.62" color="#c2b09e" opacity="1" label="0.62 - 0.73"/>
             <sld:ColorMapEntry quantity="0.73" color="#b19d8c" opacity="1" label="0.73 - 0.83"/>
             <sld:ColorMapEntry quantity="0.83" color="#a08b7b" opacity="1" label="0.83 - 0.93"/>
             <sld:ColorMapEntry quantity="0.93" color="#8f7869" opacity="1" label="0.93 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#7e6657" opacity="1" label="1.04 - 1.14"/>
             <sld:ColorMapEntry quantity="1.14" color="#6d5345" opacity="1" label="1.14 - 1.24"/>
             <sld:ColorMapEntry quantity="1.24" color="#5c4033" opacity="1" label="1.24 - 1.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>