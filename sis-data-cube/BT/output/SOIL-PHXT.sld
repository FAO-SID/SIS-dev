<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PHXT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.76" color="#f4e7d3" opacity="1" label="0.76 - 1.02"/>
             <sld:ColorMapEntry quantity="1.02" color="#e4d5c2" opacity="1" label="1.02 - 1.28"/>
             <sld:ColorMapEntry quantity="1.28" color="#d3c2b0" opacity="1" label="1.28 - 1.54"/>
             <sld:ColorMapEntry quantity="1.54" color="#c2b09e" opacity="1" label="1.54 - 1.79"/>
             <sld:ColorMapEntry quantity="1.79" color="#b19d8c" opacity="1" label="1.79 - 2.05"/>
             <sld:ColorMapEntry quantity="2.05" color="#a08b7b" opacity="1" label="2.05 - 2.31"/>
             <sld:ColorMapEntry quantity="2.31" color="#8f7869" opacity="1" label="2.31 - 2.56"/>
             <sld:ColorMapEntry quantity="2.56" color="#7e6657" opacity="1" label="2.56 - 2.82"/>
             <sld:ColorMapEntry quantity="2.82" color="#6d5345" opacity="1" label="2.82 - 3.08"/>
             <sld:ColorMapEntry quantity="3.08" color="#5c4033" opacity="1" label="3.08 - 3.33"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>