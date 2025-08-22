<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGT0</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 28.31"/>
             <sld:ColorMapEntry quantity="28.31" color="#e4d5c2" opacity="1" label="28.31 - 56.62"/>
             <sld:ColorMapEntry quantity="56.62" color="#d3c2b0" opacity="1" label="56.62 - 84.93"/>
             <sld:ColorMapEntry quantity="84.93" color="#c2b09e" opacity="1" label="84.93 - 113.25"/>
             <sld:ColorMapEntry quantity="113.25" color="#b19d8c" opacity="1" label="113.25 - 141.56"/>
             <sld:ColorMapEntry quantity="141.56" color="#a08b7b" opacity="1" label="141.56 - 169.87"/>
             <sld:ColorMapEntry quantity="169.87" color="#8f7869" opacity="1" label="169.87 - 198.18"/>
             <sld:ColorMapEntry quantity="198.18" color="#7e6657" opacity="1" label="198.18 - 226.49"/>
             <sld:ColorMapEntry quantity="226.49" color="#6d5345" opacity="1" label="226.49 - 254.80"/>
             <sld:ColorMapEntry quantity="254.8" color="#5c4033" opacity="1" label="254.80 - 283.11"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>