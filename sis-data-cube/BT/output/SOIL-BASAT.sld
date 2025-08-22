<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BASAT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="6.14" color="#f4e7d3" opacity="1" label="6.14 - 28.06"/>
             <sld:ColorMapEntry quantity="28.06" color="#e4d5c2" opacity="1" label="28.06 - 49.98"/>
             <sld:ColorMapEntry quantity="49.98" color="#d3c2b0" opacity="1" label="49.98 - 71.91"/>
             <sld:ColorMapEntry quantity="71.91" color="#c2b09e" opacity="1" label="71.91 - 93.83"/>
             <sld:ColorMapEntry quantity="93.83" color="#b19d8c" opacity="1" label="93.83 - 115.75"/>
             <sld:ColorMapEntry quantity="115.75" color="#a08b7b" opacity="1" label="115.75 - 137.68"/>
             <sld:ColorMapEntry quantity="137.68" color="#8f7869" opacity="1" label="137.68 - 159.60"/>
             <sld:ColorMapEntry quantity="159.6" color="#7e6657" opacity="1" label="159.60 - 181.52"/>
             <sld:ColorMapEntry quantity="181.52" color="#6d5345" opacity="1" label="181.52 - 203.44"/>
             <sld:ColorMapEntry quantity="203.44" color="#5c4033" opacity="1" label="203.44 - 225.37"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>