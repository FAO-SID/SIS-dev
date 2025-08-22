<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAY</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.76" color="#f4e7d3" opacity="1" label="5.76 - 11.90"/>
             <sld:ColorMapEntry quantity="11.9" color="#e4d5c2" opacity="1" label="11.90 - 18.04"/>
             <sld:ColorMapEntry quantity="18.04" color="#d3c2b0" opacity="1" label="18.04 - 24.18"/>
             <sld:ColorMapEntry quantity="24.18" color="#c2b09e" opacity="1" label="24.18 - 30.32"/>
             <sld:ColorMapEntry quantity="30.32" color="#b19d8c" opacity="1" label="30.32 - 36.46"/>
             <sld:ColorMapEntry quantity="36.46" color="#a08b7b" opacity="1" label="36.46 - 42.60"/>
             <sld:ColorMapEntry quantity="42.6" color="#8f7869" opacity="1" label="42.60 - 48.74"/>
             <sld:ColorMapEntry quantity="48.74" color="#7e6657" opacity="1" label="48.74 - 54.88"/>
             <sld:ColorMapEntry quantity="54.88" color="#6d5345" opacity="1" label="54.88 - 61.02"/>
             <sld:ColorMapEntry quantity="61.02" color="#5c4033" opacity="1" label="61.02 - 67.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>