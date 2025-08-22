<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BASATSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="7.75" color="#f4e7d3" opacity="1" label="7.75 - 24.91"/>
             <sld:ColorMapEntry quantity="24.91" color="#e4d5c2" opacity="1" label="24.91 - 42.07"/>
             <sld:ColorMapEntry quantity="42.07" color="#d3c2b0" opacity="1" label="42.07 - 59.22"/>
             <sld:ColorMapEntry quantity="59.22" color="#c2b09e" opacity="1" label="59.22 - 76.38"/>
             <sld:ColorMapEntry quantity="76.38" color="#b19d8c" opacity="1" label="76.38 - 93.53"/>
             <sld:ColorMapEntry quantity="93.53" color="#a08b7b" opacity="1" label="93.53 - 110.69"/>
             <sld:ColorMapEntry quantity="110.69" color="#8f7869" opacity="1" label="110.69 - 127.85"/>
             <sld:ColorMapEntry quantity="127.85" color="#7e6657" opacity="1" label="127.85 - 145.00"/>
             <sld:ColorMapEntry quantity="145" color="#6d5345" opacity="1" label="145.00 - 162.16"/>
             <sld:ColorMapEntry quantity="162.16" color="#5c4033" opacity="1" label="162.16 - 179.31"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>