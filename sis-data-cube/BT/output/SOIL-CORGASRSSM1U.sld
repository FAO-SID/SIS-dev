<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM1U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.35" color="#f4e7d3" opacity="1" label="15.35 - 71.15"/>
             <sld:ColorMapEntry quantity="71.15" color="#e4d5c2" opacity="1" label="71.15 - 126.95"/>
             <sld:ColorMapEntry quantity="126.95" color="#d3c2b0" opacity="1" label="126.95 - 182.75"/>
             <sld:ColorMapEntry quantity="182.75" color="#c2b09e" opacity="1" label="182.75 - 238.55"/>
             <sld:ColorMapEntry quantity="238.55" color="#b19d8c" opacity="1" label="238.55 - 294.35"/>
             <sld:ColorMapEntry quantity="294.35" color="#a08b7b" opacity="1" label="294.35 - 350.15"/>
             <sld:ColorMapEntry quantity="350.15" color="#8f7869" opacity="1" label="350.15 - 405.95"/>
             <sld:ColorMapEntry quantity="405.95" color="#7e6657" opacity="1" label="405.95 - 461.75"/>
             <sld:ColorMapEntry quantity="461.75" color="#6d5345" opacity="1" label="461.75 - 517.55"/>
             <sld:ColorMapEntry quantity="517.55" color="#5c4033" opacity="1" label="517.55 - 573.35"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>