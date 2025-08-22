<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NTOT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.07" color="#f4e7d3" opacity="1" label="0.07 - 0.49"/>
             <sld:ColorMapEntry quantity="0.49" color="#e4d5c2" opacity="1" label="0.49 - 0.91"/>
             <sld:ColorMapEntry quantity="0.91" color="#d3c2b0" opacity="1" label="0.91 - 1.32"/>
             <sld:ColorMapEntry quantity="1.32" color="#c2b09e" opacity="1" label="1.32 - 1.74"/>
             <sld:ColorMapEntry quantity="1.74" color="#b19d8c" opacity="1" label="1.74 - 2.16"/>
             <sld:ColorMapEntry quantity="2.16" color="#a08b7b" opacity="1" label="2.16 - 2.57"/>
             <sld:ColorMapEntry quantity="2.57" color="#8f7869" opacity="1" label="2.57 - 2.99"/>
             <sld:ColorMapEntry quantity="2.99" color="#7e6657" opacity="1" label="2.99 - 3.41"/>
             <sld:ColorMapEntry quantity="3.41" color="#6d5345" opacity="1" label="3.41 - 3.82"/>
             <sld:ColorMapEntry quantity="3.82" color="#5c4033" opacity="1" label="3.82 - 4.24"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>