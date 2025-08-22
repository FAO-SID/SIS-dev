<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CECSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.39" color="#f4e7d3" opacity="1" label="2.39 - 4.30"/>
             <sld:ColorMapEntry quantity="4.3" color="#e4d5c2" opacity="1" label="4.30 - 6.20"/>
             <sld:ColorMapEntry quantity="6.2" color="#d3c2b0" opacity="1" label="6.20 - 8.11"/>
             <sld:ColorMapEntry quantity="8.11" color="#c2b09e" opacity="1" label="8.11 - 10.02"/>
             <sld:ColorMapEntry quantity="10.02" color="#b19d8c" opacity="1" label="10.02 - 11.92"/>
             <sld:ColorMapEntry quantity="11.92" color="#a08b7b" opacity="1" label="11.92 - 13.83"/>
             <sld:ColorMapEntry quantity="13.83" color="#8f7869" opacity="1" label="13.83 - 15.74"/>
             <sld:ColorMapEntry quantity="15.74" color="#7e6657" opacity="1" label="15.74 - 17.64"/>
             <sld:ColorMapEntry quantity="17.64" color="#6d5345" opacity="1" label="17.64 - 19.55"/>
             <sld:ColorMapEntry quantity="19.55" color="#5c4033" opacity="1" label="19.55 - 21.46"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>