<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM2U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.36" color="#f4e7d3" opacity="1" label="15.36 - 71.65"/>
             <sld:ColorMapEntry quantity="71.65" color="#e4d5c2" opacity="1" label="71.65 - 127.94"/>
             <sld:ColorMapEntry quantity="127.94" color="#d3c2b0" opacity="1" label="127.94 - 184.23"/>
             <sld:ColorMapEntry quantity="184.23" color="#c2b09e" opacity="1" label="184.23 - 240.52"/>
             <sld:ColorMapEntry quantity="240.52" color="#b19d8c" opacity="1" label="240.52 - 296.81"/>
             <sld:ColorMapEntry quantity="296.81" color="#a08b7b" opacity="1" label="296.81 - 353.10"/>
             <sld:ColorMapEntry quantity="353.1" color="#8f7869" opacity="1" label="353.10 - 409.39"/>
             <sld:ColorMapEntry quantity="409.39" color="#7e6657" opacity="1" label="409.39 - 465.68"/>
             <sld:ColorMapEntry quantity="465.68" color="#6d5345" opacity="1" label="465.68 - 521.97"/>
             <sld:ColorMapEntry quantity="521.97" color="#5c4033" opacity="1" label="521.97 - 578.26"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>