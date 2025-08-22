<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.87" color="#f4e7d3" opacity="1" label="5.87 - 31.82"/>
             <sld:ColorMapEntry quantity="31.82" color="#e4d5c2" opacity="1" label="31.82 - 57.77"/>
             <sld:ColorMapEntry quantity="57.77" color="#d3c2b0" opacity="1" label="57.77 - 83.72"/>
             <sld:ColorMapEntry quantity="83.72" color="#c2b09e" opacity="1" label="83.72 - 109.66"/>
             <sld:ColorMapEntry quantity="109.66" color="#b19d8c" opacity="1" label="109.66 - 135.61"/>
             <sld:ColorMapEntry quantity="135.61" color="#a08b7b" opacity="1" label="135.61 - 161.56"/>
             <sld:ColorMapEntry quantity="161.56" color="#8f7869" opacity="1" label="161.56 - 187.51"/>
             <sld:ColorMapEntry quantity="187.51" color="#7e6657" opacity="1" label="187.51 - 213.45"/>
             <sld:ColorMapEntry quantity="213.45" color="#6d5345" opacity="1" label="213.45 - 239.40"/>
             <sld:ColorMapEntry quantity="239.4" color="#5c4033" opacity="1" label="239.40 - 265.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>