<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.65" color="#f4e7d3" opacity="1" label="5.65 - 30.53"/>
             <sld:ColorMapEntry quantity="30.53" color="#e4d5c2" opacity="1" label="30.53 - 55.40"/>
             <sld:ColorMapEntry quantity="55.4" color="#d3c2b0" opacity="1" label="55.40 - 80.28"/>
             <sld:ColorMapEntry quantity="80.28" color="#c2b09e" opacity="1" label="80.28 - 105.16"/>
             <sld:ColorMapEntry quantity="105.16" color="#b19d8c" opacity="1" label="105.16 - 130.03"/>
             <sld:ColorMapEntry quantity="130.03" color="#a08b7b" opacity="1" label="130.03 - 154.91"/>
             <sld:ColorMapEntry quantity="154.91" color="#8f7869" opacity="1" label="154.91 - 179.79"/>
             <sld:ColorMapEntry quantity="179.79" color="#7e6657" opacity="1" label="179.79 - 204.66"/>
             <sld:ColorMapEntry quantity="204.66" color="#6d5345" opacity="1" label="204.66 - 229.54"/>
             <sld:ColorMapEntry quantity="229.54" color="#5c4033" opacity="1" label="229.54 - 254.41"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>