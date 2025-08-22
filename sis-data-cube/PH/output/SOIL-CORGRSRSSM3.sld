<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRSRSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.11"/>
             <sld:ColorMapEntry quantity="0.11" color="#e4d5c2" opacity="1" label="0.11 - 0.22"/>
             <sld:ColorMapEntry quantity="0.22" color="#d3c2b0" opacity="1" label="0.22 - 0.33"/>
             <sld:ColorMapEntry quantity="0.33" color="#c2b09e" opacity="1" label="0.33 - 0.44"/>
             <sld:ColorMapEntry quantity="0.44" color="#b19d8c" opacity="1" label="0.44 - 0.55"/>
             <sld:ColorMapEntry quantity="0.55" color="#a08b7b" opacity="1" label="0.55 - 0.66"/>
             <sld:ColorMapEntry quantity="0.66" color="#8f7869" opacity="1" label="0.66 - 0.77"/>
             <sld:ColorMapEntry quantity="0.77" color="#7e6657" opacity="1" label="0.77 - 0.87"/>
             <sld:ColorMapEntry quantity="0.87" color="#6d5345" opacity="1" label="0.87 - 0.98"/>
             <sld:ColorMapEntry quantity="0.98" color="#5c4033" opacity="1" label="0.98 - 1.09"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>