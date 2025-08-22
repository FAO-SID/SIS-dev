<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.67"/>
             <sld:ColorMapEntry quantity="-44.67" color="#e4d5c2" opacity="1" label="-44.67 - -39.39"/>
             <sld:ColorMapEntry quantity="-39.39" color="#d3c2b0" opacity="1" label="-39.39 - -34.10"/>
             <sld:ColorMapEntry quantity="-34.1" color="#c2b09e" opacity="1" label="-34.10 - -28.82"/>
             <sld:ColorMapEntry quantity="-28.82" color="#b19d8c" opacity="1" label="-28.82 - -23.54"/>
             <sld:ColorMapEntry quantity="-23.54" color="#a08b7b" opacity="1" label="-23.54 - -18.26"/>
             <sld:ColorMapEntry quantity="-18.26" color="#8f7869" opacity="1" label="-18.26 - -12.98"/>
             <sld:ColorMapEntry quantity="-12.98" color="#7e6657" opacity="1" label="-12.98 - -7.69"/>
             <sld:ColorMapEntry quantity="-7.69" color="#6d5345" opacity="1" label="-7.69 - -2.41"/>
             <sld:ColorMapEntry quantity="-2.41" color="#5c4033" opacity="1" label="-2.41 - 2.87"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>