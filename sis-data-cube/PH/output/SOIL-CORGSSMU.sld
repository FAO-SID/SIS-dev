<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSSMU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="9.56" color="#f4e7d3" opacity="1" label="9.56 - 14.81"/>
             <sld:ColorMapEntry quantity="14.81" color="#e4d5c2" opacity="1" label="14.81 - 20.05"/>
             <sld:ColorMapEntry quantity="20.05" color="#d3c2b0" opacity="1" label="20.05 - 25.29"/>
             <sld:ColorMapEntry quantity="25.29" color="#c2b09e" opacity="1" label="25.29 - 30.54"/>
             <sld:ColorMapEntry quantity="30.54" color="#b19d8c" opacity="1" label="30.54 - 35.78"/>
             <sld:ColorMapEntry quantity="35.78" color="#a08b7b" opacity="1" label="35.78 - 41.03"/>
             <sld:ColorMapEntry quantity="41.03" color="#8f7869" opacity="1" label="41.03 - 46.27"/>
             <sld:ColorMapEntry quantity="46.27" color="#7e6657" opacity="1" label="46.27 - 51.51"/>
             <sld:ColorMapEntry quantity="51.51" color="#6d5345" opacity="1" label="51.51 - 56.76"/>
             <sld:ColorMapEntry quantity="56.76" color="#5c4033" opacity="1" label="56.76 - 62.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>