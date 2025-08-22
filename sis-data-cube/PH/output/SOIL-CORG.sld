<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORG</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.67" color="#f4e7d3" opacity="1" label="0.67 - 8.24"/>
             <sld:ColorMapEntry quantity="8.24" color="#e4d5c2" opacity="1" label="8.24 - 15.81"/>
             <sld:ColorMapEntry quantity="15.81" color="#d3c2b0" opacity="1" label="15.81 - 23.38"/>
             <sld:ColorMapEntry quantity="23.38" color="#c2b09e" opacity="1" label="23.38 - 30.96"/>
             <sld:ColorMapEntry quantity="30.96" color="#b19d8c" opacity="1" label="30.96 - 38.53"/>
             <sld:ColorMapEntry quantity="38.53" color="#a08b7b" opacity="1" label="38.53 - 46.10"/>
             <sld:ColorMapEntry quantity="46.1" color="#8f7869" opacity="1" label="46.10 - 53.67"/>
             <sld:ColorMapEntry quantity="53.67" color="#7e6657" opacity="1" label="53.67 - 61.25"/>
             <sld:ColorMapEntry quantity="61.25" color="#6d5345" opacity="1" label="61.25 - 68.82"/>
             <sld:ColorMapEntry quantity="68.82" color="#5c4033" opacity="1" label="68.82 - 76.39"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>