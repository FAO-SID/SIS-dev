<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-194.49" color="#f4e7d3" opacity="1" label="-194.49 - -169.73"/>
             <sld:ColorMapEntry quantity="-169.73" color="#e4d5c2" opacity="1" label="-169.73 - -144.96"/>
             <sld:ColorMapEntry quantity="-144.96" color="#d3c2b0" opacity="1" label="-144.96 - -120.19"/>
             <sld:ColorMapEntry quantity="-120.19" color="#c2b09e" opacity="1" label="-120.19 - -95.43"/>
             <sld:ColorMapEntry quantity="-95.43" color="#b19d8c" opacity="1" label="-95.43 - -70.66"/>
             <sld:ColorMapEntry quantity="-70.66" color="#a08b7b" opacity="1" label="-70.66 - -45.89"/>
             <sld:ColorMapEntry quantity="-45.89" color="#8f7869" opacity="1" label="-45.89 - -21.12"/>
             <sld:ColorMapEntry quantity="-21.12" color="#7e6657" opacity="1" label="-21.12 - 3.64"/>
             <sld:ColorMapEntry quantity="3.64" color="#6d5345" opacity="1" label="3.64 - 28.41"/>
             <sld:ColorMapEntry quantity="28.41" color="#5c4033" opacity="1" label="28.41 - 53.18"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>