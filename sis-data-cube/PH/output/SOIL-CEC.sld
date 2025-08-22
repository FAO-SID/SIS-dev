<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CEC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="7.76" color="#f4e7d3" opacity="1" label="7.76 - 13.92"/>
             <sld:ColorMapEntry quantity="13.92" color="#e4d5c2" opacity="1" label="13.92 - 20.08"/>
             <sld:ColorMapEntry quantity="20.08" color="#d3c2b0" opacity="1" label="20.08 - 26.24"/>
             <sld:ColorMapEntry quantity="26.24" color="#c2b09e" opacity="1" label="26.24 - 32.40"/>
             <sld:ColorMapEntry quantity="32.4" color="#b19d8c" opacity="1" label="32.40 - 38.56"/>
             <sld:ColorMapEntry quantity="38.56" color="#a08b7b" opacity="1" label="38.56 - 44.72"/>
             <sld:ColorMapEntry quantity="44.72" color="#8f7869" opacity="1" label="44.72 - 50.88"/>
             <sld:ColorMapEntry quantity="50.88" color="#7e6657" opacity="1" label="50.88 - 57.04"/>
             <sld:ColorMapEntry quantity="57.04" color="#6d5345" opacity="1" label="57.04 - 63.20"/>
             <sld:ColorMapEntry quantity="63.2" color="#5c4033" opacity="1" label="63.20 - 69.36"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>