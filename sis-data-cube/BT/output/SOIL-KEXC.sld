<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.56" color="#f4e7d3" opacity="1" label="0.56 - 20.19"/>
             <sld:ColorMapEntry quantity="20.19" color="#e4d5c2" opacity="1" label="20.19 - 39.83"/>
             <sld:ColorMapEntry quantity="39.83" color="#d3c2b0" opacity="1" label="39.83 - 59.46"/>
             <sld:ColorMapEntry quantity="59.46" color="#c2b09e" opacity="1" label="59.46 - 79.10"/>
             <sld:ColorMapEntry quantity="79.1" color="#b19d8c" opacity="1" label="79.10 - 98.73"/>
             <sld:ColorMapEntry quantity="98.73" color="#a08b7b" opacity="1" label="98.73 - 118.37"/>
             <sld:ColorMapEntry quantity="118.37" color="#8f7869" opacity="1" label="118.37 - 138.00"/>
             <sld:ColorMapEntry quantity="138" color="#7e6657" opacity="1" label="138.00 - 157.64"/>
             <sld:ColorMapEntry quantity="157.64" color="#6d5345" opacity="1" label="157.64 - 177.27"/>
             <sld:ColorMapEntry quantity="177.27" color="#5c4033" opacity="1" label="177.27 - 196.91"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>