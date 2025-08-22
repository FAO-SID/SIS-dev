<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.03"/>
             <sld:ColorMapEntry quantity="0.03" color="#e4d5c2" opacity="1" label="0.03 - 0.05"/>
             <sld:ColorMapEntry quantity="0.05" color="#d3c2b0" opacity="1" label="0.05 - 0.08"/>
             <sld:ColorMapEntry quantity="0.08" color="#c2b09e" opacity="1" label="0.08 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#b19d8c" opacity="1" label="0.11 - 0.14"/>
             <sld:ColorMapEntry quantity="0.14" color="#a08b7b" opacity="1" label="0.14 - 0.16"/>
             <sld:ColorMapEntry quantity="0.16" color="#8f7869" opacity="1" label="0.16 - 0.19"/>
             <sld:ColorMapEntry quantity="0.19" color="#7e6657" opacity="1" label="0.19 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#6d5345" opacity="1" label="0.22 - 0.25"/>
             <sld:ColorMapEntry quantity="0.25" color="#5c4033" opacity="1" label="0.25 - 0.27"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>