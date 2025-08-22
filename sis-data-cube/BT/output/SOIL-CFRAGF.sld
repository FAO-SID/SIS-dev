<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CFRAGF</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.91" color="#f4e7d3" opacity="1" label="0.91 - 5.15"/>
             <sld:ColorMapEntry quantity="5.15" color="#e4d5c2" opacity="1" label="5.15 - 9.39"/>
             <sld:ColorMapEntry quantity="9.39" color="#d3c2b0" opacity="1" label="9.39 - 13.64"/>
             <sld:ColorMapEntry quantity="13.64" color="#c2b09e" opacity="1" label="13.64 - 17.88"/>
             <sld:ColorMapEntry quantity="17.88" color="#b19d8c" opacity="1" label="17.88 - 22.12"/>
             <sld:ColorMapEntry quantity="22.12" color="#a08b7b" opacity="1" label="22.12 - 26.36"/>
             <sld:ColorMapEntry quantity="26.36" color="#8f7869" opacity="1" label="26.36 - 30.60"/>
             <sld:ColorMapEntry quantity="30.6" color="#7e6657" opacity="1" label="30.60 - 34.85"/>
             <sld:ColorMapEntry quantity="34.85" color="#6d5345" opacity="1" label="34.85 - 39.09"/>
             <sld:ColorMapEntry quantity="39.09" color="#5c4033" opacity="1" label="39.09 - 43.33"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>