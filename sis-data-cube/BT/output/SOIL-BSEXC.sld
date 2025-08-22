<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>BSEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1.55" color="#f4e7d3" opacity="1" label="1.55 - 3.80"/>
             <sld:ColorMapEntry quantity="3.8" color="#e4d5c2" opacity="1" label="3.80 - 6.04"/>
             <sld:ColorMapEntry quantity="6.04" color="#d3c2b0" opacity="1" label="6.04 - 8.29"/>
             <sld:ColorMapEntry quantity="8.29" color="#c2b09e" opacity="1" label="8.29 - 10.53"/>
             <sld:ColorMapEntry quantity="10.53" color="#b19d8c" opacity="1" label="10.53 - 12.77"/>
             <sld:ColorMapEntry quantity="12.77" color="#a08b7b" opacity="1" label="12.77 - 15.02"/>
             <sld:ColorMapEntry quantity="15.02" color="#8f7869" opacity="1" label="15.02 - 17.26"/>
             <sld:ColorMapEntry quantity="17.26" color="#7e6657" opacity="1" label="17.26 - 19.51"/>
             <sld:ColorMapEntry quantity="19.51" color="#6d5345" opacity="1" label="19.51 - 21.75"/>
             <sld:ColorMapEntry quantity="21.75" color="#5c4033" opacity="1" label="21.75 - 24.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>