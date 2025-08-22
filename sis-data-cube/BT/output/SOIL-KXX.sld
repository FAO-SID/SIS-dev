<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KXX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.16" color="#f4e7d3" opacity="1" label="0.16 - 39.35"/>
             <sld:ColorMapEntry quantity="39.35" color="#e4d5c2" opacity="1" label="39.35 - 78.53"/>
             <sld:ColorMapEntry quantity="78.53" color="#d3c2b0" opacity="1" label="78.53 - 117.72"/>
             <sld:ColorMapEntry quantity="117.72" color="#c2b09e" opacity="1" label="117.72 - 156.91"/>
             <sld:ColorMapEntry quantity="156.91" color="#b19d8c" opacity="1" label="156.91 - 196.09"/>
             <sld:ColorMapEntry quantity="196.09" color="#a08b7b" opacity="1" label="196.09 - 235.28"/>
             <sld:ColorMapEntry quantity="235.28" color="#8f7869" opacity="1" label="235.28 - 274.46"/>
             <sld:ColorMapEntry quantity="274.46" color="#7e6657" opacity="1" label="274.46 - 313.65"/>
             <sld:ColorMapEntry quantity="313.65" color="#6d5345" opacity="1" label="313.65 - 352.84"/>
             <sld:ColorMapEntry quantity="352.84" color="#5c4033" opacity="1" label="352.84 - 392.02"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>