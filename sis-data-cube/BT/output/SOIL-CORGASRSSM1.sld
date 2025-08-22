<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-49.95" color="#f4e7d3" opacity="1" label="-49.95 - -44.69"/>
             <sld:ColorMapEntry quantity="-44.69" color="#e4d5c2" opacity="1" label="-44.69 - -39.43"/>
             <sld:ColorMapEntry quantity="-39.43" color="#d3c2b0" opacity="1" label="-39.43 - -34.17"/>
             <sld:ColorMapEntry quantity="-34.17" color="#c2b09e" opacity="1" label="-34.17 - -28.91"/>
             <sld:ColorMapEntry quantity="-28.91" color="#b19d8c" opacity="1" label="-28.91 - -23.65"/>
             <sld:ColorMapEntry quantity="-23.65" color="#a08b7b" opacity="1" label="-23.65 - -18.38"/>
             <sld:ColorMapEntry quantity="-18.38" color="#8f7869" opacity="1" label="-18.38 - -13.12"/>
             <sld:ColorMapEntry quantity="-13.12" color="#7e6657" opacity="1" label="-13.12 - -7.86"/>
             <sld:ColorMapEntry quantity="-7.86" color="#6d5345" opacity="1" label="-7.86 - -2.60"/>
             <sld:ColorMapEntry quantity="-2.6" color="#5c4033" opacity="1" label="-2.60 - 2.66"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>