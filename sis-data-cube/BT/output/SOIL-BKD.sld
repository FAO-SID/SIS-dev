<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BKD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0.61" color="#f4e7d3" opacity="1" label="0.61 - 0.72"/>
             <sld:ColorMapEntry quantity="0.72" color="#e4d5c2" opacity="1" label="0.72 - 0.82"/>
             <sld:ColorMapEntry quantity="0.82" color="#d3c2b0" opacity="1" label="0.82 - 0.93"/>
             <sld:ColorMapEntry quantity="0.93" color="#c2b09e" opacity="1" label="0.93 - 1.04"/>
             <sld:ColorMapEntry quantity="1.04" color="#b19d8c" opacity="1" label="1.04 - 1.14"/>
             <sld:ColorMapEntry quantity="1.14" color="#a08b7b" opacity="1" label="1.14 - 1.25"/>
             <sld:ColorMapEntry quantity="1.25" color="#8f7869" opacity="1" label="1.25 - 1.36"/>
             <sld:ColorMapEntry quantity="1.36" color="#7e6657" opacity="1" label="1.36 - 1.46"/>
             <sld:ColorMapEntry quantity="1.46" color="#6d5345" opacity="1" label="1.46 - 1.57"/>
             <sld:ColorMapEntry quantity="1.57" color="#5c4033" opacity="1" label="1.57 - 1.68"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>