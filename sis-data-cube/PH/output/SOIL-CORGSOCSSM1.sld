<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGSOCSSM1</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="5.76" color="#f4e7d3" opacity="1" label="5.76 - 31.17"/>
             <sld:ColorMapEntry quantity="31.17" color="#e4d5c2" opacity="1" label="31.17 - 56.59"/>
             <sld:ColorMapEntry quantity="56.59" color="#d3c2b0" opacity="1" label="56.59 - 82.00"/>
             <sld:ColorMapEntry quantity="82" color="#c2b09e" opacity="1" label="82.00 - 107.41"/>
             <sld:ColorMapEntry quantity="107.41" color="#b19d8c" opacity="1" label="107.41 - 132.82"/>
             <sld:ColorMapEntry quantity="132.82" color="#a08b7b" opacity="1" label="132.82 - 158.23"/>
             <sld:ColorMapEntry quantity="158.23" color="#8f7869" opacity="1" label="158.23 - 183.65"/>
             <sld:ColorMapEntry quantity="183.65" color="#7e6657" opacity="1" label="183.65 - 209.06"/>
             <sld:ColorMapEntry quantity="209.06" color="#6d5345" opacity="1" label="209.06 - 234.47"/>
             <sld:ColorMapEntry quantity="234.47" color="#5c4033" opacity="1" label="234.47 - 259.88"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>