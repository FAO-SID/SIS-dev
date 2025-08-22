<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGNTOTR</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.92" color="#f4e7d3" opacity="1" label="5.92 - 10.71"/>
             <sld:ColorMapEntry quantity="10.71" color="#e4d5c2" opacity="1" label="10.71 - 15.50"/>
             <sld:ColorMapEntry quantity="15.5" color="#d3c2b0" opacity="1" label="15.50 - 20.29"/>
             <sld:ColorMapEntry quantity="20.29" color="#c2b09e" opacity="1" label="20.29 - 25.08"/>
             <sld:ColorMapEntry quantity="25.08" color="#b19d8c" opacity="1" label="25.08 - 29.86"/>
             <sld:ColorMapEntry quantity="29.86" color="#a08b7b" opacity="1" label="29.86 - 34.65"/>
             <sld:ColorMapEntry quantity="34.65" color="#8f7869" opacity="1" label="34.65 - 39.44"/>
             <sld:ColorMapEntry quantity="39.44" color="#7e6657" opacity="1" label="39.44 - 44.23"/>
             <sld:ColorMapEntry quantity="44.23" color="#6d5345" opacity="1" label="44.23 - 49.02"/>
             <sld:ColorMapEntry quantity="49.02" color="#5c4033" opacity="1" label="49.02 - 53.81"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>