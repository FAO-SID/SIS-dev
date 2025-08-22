<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1.72" color="#f4e7d3" opacity="1" label="1.72 - 3.68"/>
             <sld:ColorMapEntry quantity="3.68" color="#e4d5c2" opacity="1" label="3.68 - 5.64"/>
             <sld:ColorMapEntry quantity="5.64" color="#d3c2b0" opacity="1" label="5.64 - 7.61"/>
             <sld:ColorMapEntry quantity="7.61" color="#c2b09e" opacity="1" label="7.61 - 9.57"/>
             <sld:ColorMapEntry quantity="9.57" color="#b19d8c" opacity="1" label="9.57 - 11.53"/>
             <sld:ColorMapEntry quantity="11.53" color="#a08b7b" opacity="1" label="11.53 - 13.50"/>
             <sld:ColorMapEntry quantity="13.5" color="#8f7869" opacity="1" label="13.50 - 15.46"/>
             <sld:ColorMapEntry quantity="15.46" color="#7e6657" opacity="1" label="15.46 - 17.42"/>
             <sld:ColorMapEntry quantity="17.42" color="#6d5345" opacity="1" label="17.42 - 19.39"/>
             <sld:ColorMapEntry quantity="19.39" color="#5c4033" opacity="1" label="19.39 - 21.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>