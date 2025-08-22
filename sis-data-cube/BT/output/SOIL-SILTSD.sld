<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SILTSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.16" color="#f4e7d3" opacity="1" label="5.16 - 7.36"/>
             <sld:ColorMapEntry quantity="7.36" color="#e4d5c2" opacity="1" label="7.36 - 9.56"/>
             <sld:ColorMapEntry quantity="9.56" color="#d3c2b0" opacity="1" label="9.56 - 11.76"/>
             <sld:ColorMapEntry quantity="11.76" color="#c2b09e" opacity="1" label="11.76 - 13.95"/>
             <sld:ColorMapEntry quantity="13.95" color="#b19d8c" opacity="1" label="13.95 - 16.15"/>
             <sld:ColorMapEntry quantity="16.15" color="#a08b7b" opacity="1" label="16.15 - 18.35"/>
             <sld:ColorMapEntry quantity="18.35" color="#8f7869" opacity="1" label="18.35 - 20.55"/>
             <sld:ColorMapEntry quantity="20.55" color="#7e6657" opacity="1" label="20.55 - 22.74"/>
             <sld:ColorMapEntry quantity="22.74" color="#6d5345" opacity="1" label="22.74 - 24.94"/>
             <sld:ColorMapEntry quantity="24.94" color="#5c4033" opacity="1" label="24.94 - 27.14"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>