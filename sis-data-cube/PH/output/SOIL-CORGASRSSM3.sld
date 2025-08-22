<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.63"/>
             <sld:ColorMapEntry quantity="-44.63" color="#e4d5c2" opacity="1" label="-44.63 - -39.30"/>
             <sld:ColorMapEntry quantity="-39.3" color="#d3c2b0" opacity="1" label="-39.30 - -33.98"/>
             <sld:ColorMapEntry quantity="-33.98" color="#c2b09e" opacity="1" label="-33.98 - -28.65"/>
             <sld:ColorMapEntry quantity="-28.65" color="#b19d8c" opacity="1" label="-28.65 - -23.33"/>
             <sld:ColorMapEntry quantity="-23.33" color="#a08b7b" opacity="1" label="-23.33 - -18.01"/>
             <sld:ColorMapEntry quantity="-18.01" color="#8f7869" opacity="1" label="-18.01 - -12.68"/>
             <sld:ColorMapEntry quantity="-12.68" color="#7e6657" opacity="1" label="-12.68 - -7.36"/>
             <sld:ColorMapEntry quantity="-7.36" color="#6d5345" opacity="1" label="-7.36 - -2.03"/>
             <sld:ColorMapEntry quantity="-2.03" color="#5c4033" opacity="1" label="-2.03 - 3.29"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>