<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGRDSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.55"/>
             <sld:ColorMapEntry quantity="0.55" color="#e4d5c2" opacity="1" label="0.55 - 1.09"/>
             <sld:ColorMapEntry quantity="1.09" color="#d3c2b0" opacity="1" label="1.09 - 1.64"/>
             <sld:ColorMapEntry quantity="1.64" color="#c2b09e" opacity="1" label="1.64 - 2.19"/>
             <sld:ColorMapEntry quantity="2.19" color="#b19d8c" opacity="1" label="2.19 - 2.73"/>
             <sld:ColorMapEntry quantity="2.73" color="#a08b7b" opacity="1" label="2.73 - 3.28"/>
             <sld:ColorMapEntry quantity="3.28" color="#8f7869" opacity="1" label="3.28 - 3.83"/>
             <sld:ColorMapEntry quantity="3.83" color="#7e6657" opacity="1" label="3.83 - 4.37"/>
             <sld:ColorMapEntry quantity="4.37" color="#6d5345" opacity="1" label="4.37 - 4.92"/>
             <sld:ColorMapEntry quantity="4.92" color="#5c4033" opacity="1" label="4.92 - 5.47"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>