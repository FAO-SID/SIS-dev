<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PXXSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="4.23" color="#f4e7d3" opacity="1" label="4.23 - 27.07"/>
             <sld:ColorMapEntry quantity="27.07" color="#e4d5c2" opacity="1" label="27.07 - 49.91"/>
             <sld:ColorMapEntry quantity="49.91" color="#d3c2b0" opacity="1" label="49.91 - 72.75"/>
             <sld:ColorMapEntry quantity="72.75" color="#c2b09e" opacity="1" label="72.75 - 95.59"/>
             <sld:ColorMapEntry quantity="95.59" color="#b19d8c" opacity="1" label="95.59 - 118.43"/>
             <sld:ColorMapEntry quantity="118.43" color="#a08b7b" opacity="1" label="118.43 - 141.27"/>
             <sld:ColorMapEntry quantity="141.27" color="#8f7869" opacity="1" label="141.27 - 164.10"/>
             <sld:ColorMapEntry quantity="164.1" color="#7e6657" opacity="1" label="164.10 - 186.94"/>
             <sld:ColorMapEntry quantity="186.94" color="#6d5345" opacity="1" label="186.94 - 209.78"/>
             <sld:ColorMapEntry quantity="209.78" color="#5c4033" opacity="1" label="209.78 - 232.62"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>