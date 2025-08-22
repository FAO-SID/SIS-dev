<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXCPT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-7.49" color="#f4e7d3" opacity="1" label="-7.49 - -6.19"/>
             <sld:ColorMapEntry quantity="-6.19" color="#e4d5c2" opacity="1" label="-6.19 - -4.90"/>
             <sld:ColorMapEntry quantity="-4.9" color="#d3c2b0" opacity="1" label="-4.90 - -3.61"/>
             <sld:ColorMapEntry quantity="-3.61" color="#c2b09e" opacity="1" label="-3.61 - -2.31"/>
             <sld:ColorMapEntry quantity="-2.31" color="#b19d8c" opacity="1" label="-2.31 - -1.02"/>
             <sld:ColorMapEntry quantity="-1.02" color="#a08b7b" opacity="1" label="-1.02 - 0.27"/>
             <sld:ColorMapEntry quantity="0.27" color="#8f7869" opacity="1" label="0.27 - 1.57"/>
             <sld:ColorMapEntry quantity="1.57" color="#7e6657" opacity="1" label="1.57 - 2.86"/>
             <sld:ColorMapEntry quantity="2.86" color="#6d5345" opacity="1" label="2.86 - 4.16"/>
             <sld:ColorMapEntry quantity="4.16" color="#5c4033" opacity="1" label="4.16 - 5.45"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>