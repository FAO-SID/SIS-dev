<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGBAUU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="19.5" color="#f4e7d3" opacity="1" label="19.50 - 28.97"/>
             <sld:ColorMapEntry quantity="28.97" color="#e4d5c2" opacity="1" label="28.97 - 38.43"/>
             <sld:ColorMapEntry quantity="38.43" color="#d3c2b0" opacity="1" label="38.43 - 47.90"/>
             <sld:ColorMapEntry quantity="47.9" color="#c2b09e" opacity="1" label="47.90 - 57.36"/>
             <sld:ColorMapEntry quantity="57.36" color="#b19d8c" opacity="1" label="57.36 - 66.83"/>
             <sld:ColorMapEntry quantity="66.83" color="#a08b7b" opacity="1" label="66.83 - 76.30"/>
             <sld:ColorMapEntry quantity="76.3" color="#8f7869" opacity="1" label="76.30 - 85.76"/>
             <sld:ColorMapEntry quantity="85.76" color="#7e6657" opacity="1" label="85.76 - 95.23"/>
             <sld:ColorMapEntry quantity="95.23" color="#6d5345" opacity="1" label="95.23 - 104.69"/>
             <sld:ColorMapEntry quantity="104.69" color="#5c4033" opacity="1" label="104.69 - 114.16"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>