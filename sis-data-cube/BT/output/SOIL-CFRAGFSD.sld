<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFRAGFSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.15" color="#f4e7d3" opacity="1" label="2.15 - 5.09"/>
             <sld:ColorMapEntry quantity="5.09" color="#e4d5c2" opacity="1" label="5.09 - 8.04"/>
             <sld:ColorMapEntry quantity="8.04" color="#d3c2b0" opacity="1" label="8.04 - 10.99"/>
             <sld:ColorMapEntry quantity="10.99" color="#c2b09e" opacity="1" label="10.99 - 13.94"/>
             <sld:ColorMapEntry quantity="13.94" color="#b19d8c" opacity="1" label="13.94 - 16.89"/>
             <sld:ColorMapEntry quantity="16.89" color="#a08b7b" opacity="1" label="16.89 - 19.84"/>
             <sld:ColorMapEntry quantity="19.84" color="#8f7869" opacity="1" label="19.84 - 22.79"/>
             <sld:ColorMapEntry quantity="22.79" color="#7e6657" opacity="1" label="22.79 - 25.74"/>
             <sld:ColorMapEntry quantity="25.74" color="#6d5345" opacity="1" label="25.74 - 28.68"/>
             <sld:ColorMapEntry quantity="28.68" color="#5c4033" opacity="1" label="28.68 - 31.63"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>