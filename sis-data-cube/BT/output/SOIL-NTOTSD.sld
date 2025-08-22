<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NTOTSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.02" color="#f4e7d3" opacity="1" label="0.02 - 0.66"/>
             <sld:ColorMapEntry quantity="0.66" color="#e4d5c2" opacity="1" label="0.66 - 1.30"/>
             <sld:ColorMapEntry quantity="1.3" color="#d3c2b0" opacity="1" label="1.30 - 1.94"/>
             <sld:ColorMapEntry quantity="1.94" color="#c2b09e" opacity="1" label="1.94 - 2.58"/>
             <sld:ColorMapEntry quantity="2.58" color="#b19d8c" opacity="1" label="2.58 - 3.21"/>
             <sld:ColorMapEntry quantity="3.21" color="#a08b7b" opacity="1" label="3.21 - 3.85"/>
             <sld:ColorMapEntry quantity="3.85" color="#8f7869" opacity="1" label="3.85 - 4.49"/>
             <sld:ColorMapEntry quantity="4.49" color="#7e6657" opacity="1" label="4.49 - 5.13"/>
             <sld:ColorMapEntry quantity="5.13" color="#6d5345" opacity="1" label="5.13 - 5.77"/>
             <sld:ColorMapEntry quantity="5.77" color="#5c4033" opacity="1" label="5.77 - 6.40"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>