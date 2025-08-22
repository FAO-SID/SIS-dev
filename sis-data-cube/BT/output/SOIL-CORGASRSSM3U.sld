<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGASRSSM3U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="15.39" color="#f4e7d3" opacity="1" label="15.39 - 72.62"/>
             <sld:ColorMapEntry quantity="72.62" color="#e4d5c2" opacity="1" label="72.62 - 129.86"/>
             <sld:ColorMapEntry quantity="129.86" color="#d3c2b0" opacity="1" label="129.86 - 187.09"/>
             <sld:ColorMapEntry quantity="187.09" color="#c2b09e" opacity="1" label="187.09 - 244.33"/>
             <sld:ColorMapEntry quantity="244.33" color="#b19d8c" opacity="1" label="244.33 - 301.56"/>
             <sld:ColorMapEntry quantity="301.56" color="#a08b7b" opacity="1" label="301.56 - 358.80"/>
             <sld:ColorMapEntry quantity="358.8" color="#8f7869" opacity="1" label="358.80 - 416.03"/>
             <sld:ColorMapEntry quantity="416.03" color="#7e6657" opacity="1" label="416.03 - 473.27"/>
             <sld:ColorMapEntry quantity="473.27" color="#6d5345" opacity="1" label="473.27 - 530.50"/>
             <sld:ColorMapEntry quantity="530.5" color="#5c4033" opacity="1" label="530.50 - 587.74"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>