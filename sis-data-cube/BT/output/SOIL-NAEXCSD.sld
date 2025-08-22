<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXCSD</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 0.32"/>
             <sld:ColorMapEntry quantity="0.32" color="#e4d5c2" opacity="1" label="0.32 - 0.64"/>
             <sld:ColorMapEntry quantity="0.64" color="#d3c2b0" opacity="1" label="0.64 - 0.96"/>
             <sld:ColorMapEntry quantity="0.96" color="#c2b09e" opacity="1" label="0.96 - 1.28"/>
             <sld:ColorMapEntry quantity="1.28" color="#b19d8c" opacity="1" label="1.28 - 1.60"/>
             <sld:ColorMapEntry quantity="1.6" color="#a08b7b" opacity="1" label="1.60 - 1.92"/>
             <sld:ColorMapEntry quantity="1.92" color="#8f7869" opacity="1" label="1.92 - 2.24"/>
             <sld:ColorMapEntry quantity="2.24" color="#7e6657" opacity="1" label="2.24 - 2.56"/>
             <sld:ColorMapEntry quantity="2.56" color="#6d5345" opacity="1" label="2.56 - 2.88"/>
             <sld:ColorMapEntry quantity="2.88" color="#5c4033" opacity="1" label="2.88 - 3.20"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>