<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.71"/>
             <sld:ColorMapEntry quantity="-44.71" color="#e4d5c2" opacity="1" label="-44.71 - -39.47"/>
             <sld:ColorMapEntry quantity="-39.47" color="#d3c2b0" opacity="1" label="-39.47 - -34.23"/>
             <sld:ColorMapEntry quantity="-34.23" color="#c2b09e" opacity="1" label="-34.23 - -28.99"/>
             <sld:ColorMapEntry quantity="-28.99" color="#b19d8c" opacity="1" label="-28.99 - -23.75"/>
             <sld:ColorMapEntry quantity="-23.75" color="#a08b7b" opacity="1" label="-23.75 - -18.51"/>
             <sld:ColorMapEntry quantity="-18.51" color="#8f7869" opacity="1" label="-18.51 - -13.27"/>
             <sld:ColorMapEntry quantity="-13.27" color="#7e6657" opacity="1" label="-13.27 - -8.03"/>
             <sld:ColorMapEntry quantity="-8.03" color="#6d5345" opacity="1" label="-8.03 - -2.79"/>
             <sld:ColorMapEntry quantity="-2.79" color="#5c4033" opacity="1" label="-2.79 - 2.45"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>