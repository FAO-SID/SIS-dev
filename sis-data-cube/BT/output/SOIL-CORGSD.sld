<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.17" color="#f4e7d3" opacity="1" label="0.17 - 0.61"/>
             <sld:ColorMapEntry quantity="0.61" color="#e4d5c2" opacity="1" label="0.61 - 1.05"/>
             <sld:ColorMapEntry quantity="1.05" color="#d3c2b0" opacity="1" label="1.05 - 1.48"/>
             <sld:ColorMapEntry quantity="1.48" color="#c2b09e" opacity="1" label="1.48 - 1.92"/>
             <sld:ColorMapEntry quantity="1.92" color="#b19d8c" opacity="1" label="1.92 - 2.36"/>
             <sld:ColorMapEntry quantity="2.36" color="#a08b7b" opacity="1" label="2.36 - 2.79"/>
             <sld:ColorMapEntry quantity="2.79" color="#8f7869" opacity="1" label="2.79 - 3.23"/>
             <sld:ColorMapEntry quantity="3.23" color="#7e6657" opacity="1" label="3.23 - 3.67"/>
             <sld:ColorMapEntry quantity="3.67" color="#6d5345" opacity="1" label="3.67 - 4.11"/>
             <sld:ColorMapEntry quantity="4.11" color="#5c4033" opacity="1" label="4.11 - 4.54"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>