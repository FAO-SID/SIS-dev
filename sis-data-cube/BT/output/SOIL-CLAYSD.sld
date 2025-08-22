<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAYSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.14" color="#f4e7d3" opacity="1" label="4.14 - 6.01"/>
             <sld:ColorMapEntry quantity="6.01" color="#e4d5c2" opacity="1" label="6.01 - 7.88"/>
             <sld:ColorMapEntry quantity="7.88" color="#d3c2b0" opacity="1" label="7.88 - 9.76"/>
             <sld:ColorMapEntry quantity="9.76" color="#c2b09e" opacity="1" label="9.76 - 11.63"/>
             <sld:ColorMapEntry quantity="11.63" color="#b19d8c" opacity="1" label="11.63 - 13.51"/>
             <sld:ColorMapEntry quantity="13.51" color="#a08b7b" opacity="1" label="13.51 - 15.38"/>
             <sld:ColorMapEntry quantity="15.38" color="#8f7869" opacity="1" label="15.38 - 17.26"/>
             <sld:ColorMapEntry quantity="17.26" color="#7e6657" opacity="1" label="17.26 - 19.13"/>
             <sld:ColorMapEntry quantity="19.13" color="#6d5345" opacity="1" label="19.13 - 21.00"/>
             <sld:ColorMapEntry quantity="21" color="#5c4033" opacity="1" label="21.00 - 22.88"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>