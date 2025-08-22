<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.51" color="#f4e7d3" opacity="1" label="0.51 - 23.39"/>
             <sld:ColorMapEntry quantity="23.39" color="#e4d5c2" opacity="1" label="23.39 - 46.27"/>
             <sld:ColorMapEntry quantity="46.27" color="#d3c2b0" opacity="1" label="46.27 - 69.14"/>
             <sld:ColorMapEntry quantity="69.14" color="#c2b09e" opacity="1" label="69.14 - 92.02"/>
             <sld:ColorMapEntry quantity="92.02" color="#b19d8c" opacity="1" label="92.02 - 114.90"/>
             <sld:ColorMapEntry quantity="114.9" color="#a08b7b" opacity="1" label="114.90 - 137.77"/>
             <sld:ColorMapEntry quantity="137.77" color="#8f7869" opacity="1" label="137.77 - 160.65"/>
             <sld:ColorMapEntry quantity="160.65" color="#7e6657" opacity="1" label="160.65 - 183.53"/>
             <sld:ColorMapEntry quantity="183.53" color="#6d5345" opacity="1" label="183.53 - 206.40"/>
             <sld:ColorMapEntry quantity="206.4" color="#5c4033" opacity="1" label="206.40 - 229.28"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>