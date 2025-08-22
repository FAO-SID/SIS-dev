<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>KXXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="20.06" color="#f4e7d3" opacity="1" label="20.06 - 63.74"/>
             <sld:ColorMapEntry quantity="63.74" color="#e4d5c2" opacity="1" label="63.74 - 107.43"/>
             <sld:ColorMapEntry quantity="107.43" color="#d3c2b0" opacity="1" label="107.43 - 151.11"/>
             <sld:ColorMapEntry quantity="151.11" color="#c2b09e" opacity="1" label="151.11 - 194.79"/>
             <sld:ColorMapEntry quantity="194.79" color="#b19d8c" opacity="1" label="194.79 - 238.48"/>
             <sld:ColorMapEntry quantity="238.48" color="#a08b7b" opacity="1" label="238.48 - 282.16"/>
             <sld:ColorMapEntry quantity="282.16" color="#8f7869" opacity="1" label="282.16 - 325.84"/>
             <sld:ColorMapEntry quantity="325.84" color="#7e6657" opacity="1" label="325.84 - 369.53"/>
             <sld:ColorMapEntry quantity="369.53" color="#6d5345" opacity="1" label="369.53 - 413.21"/>
             <sld:ColorMapEntry quantity="413.21" color="#5c4033" opacity="1" label="413.21 - 456.89"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>