<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SAND</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="9.01" color="#f4e7d3" opacity="1" label="9.01 - 14.92"/>
             <sld:ColorMapEntry quantity="14.92" color="#e4d5c2" opacity="1" label="14.92 - 20.84"/>
             <sld:ColorMapEntry quantity="20.84" color="#d3c2b0" opacity="1" label="20.84 - 26.76"/>
             <sld:ColorMapEntry quantity="26.76" color="#c2b09e" opacity="1" label="26.76 - 32.67"/>
             <sld:ColorMapEntry quantity="32.67" color="#b19d8c" opacity="1" label="32.67 - 38.59"/>
             <sld:ColorMapEntry quantity="38.59" color="#a08b7b" opacity="1" label="38.59 - 44.50"/>
             <sld:ColorMapEntry quantity="44.5" color="#8f7869" opacity="1" label="44.50 - 50.42"/>
             <sld:ColorMapEntry quantity="50.42" color="#7e6657" opacity="1" label="50.42 - 56.33"/>
             <sld:ColorMapEntry quantity="56.33" color="#6d5345" opacity="1" label="56.33 - 62.25"/>
             <sld:ColorMapEntry quantity="62.25" color="#5c4033" opacity="1" label="62.25 - 68.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>