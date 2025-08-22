<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHAQ</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.14" color="#f4e7d3" opacity="1" label="4.14 - 4.44"/>
             <sld:ColorMapEntry quantity="4.44" color="#e4d5c2" opacity="1" label="4.44 - 4.74"/>
             <sld:ColorMapEntry quantity="4.74" color="#d3c2b0" opacity="1" label="4.74 - 5.05"/>
             <sld:ColorMapEntry quantity="5.05" color="#c2b09e" opacity="1" label="5.05 - 5.35"/>
             <sld:ColorMapEntry quantity="5.35" color="#b19d8c" opacity="1" label="5.35 - 5.66"/>
             <sld:ColorMapEntry quantity="5.66" color="#a08b7b" opacity="1" label="5.66 - 5.96"/>
             <sld:ColorMapEntry quantity="5.96" color="#8f7869" opacity="1" label="5.96 - 6.27"/>
             <sld:ColorMapEntry quantity="6.27" color="#7e6657" opacity="1" label="6.27 - 6.57"/>
             <sld:ColorMapEntry quantity="6.57" color="#6d5345" opacity="1" label="6.57 - 6.88"/>
             <sld:ColorMapEntry quantity="6.88" color="#5c4033" opacity="1" label="6.88 - 7.18"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>