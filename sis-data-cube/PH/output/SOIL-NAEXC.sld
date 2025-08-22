<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NAEXC</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="0" color="#f4e7d3" opacity="1" label="0.00 - 33.79"/>
             <sld:ColorMapEntry quantity="33.79" color="#e4d5c2" opacity="1" label="33.79 - 67.58"/>
             <sld:ColorMapEntry quantity="67.58" color="#d3c2b0" opacity="1" label="67.58 - 101.37"/>
             <sld:ColorMapEntry quantity="101.37" color="#c2b09e" opacity="1" label="101.37 - 135.16"/>
             <sld:ColorMapEntry quantity="135.16" color="#b19d8c" opacity="1" label="135.16 - 168.95"/>
             <sld:ColorMapEntry quantity="168.95" color="#a08b7b" opacity="1" label="168.95 - 202.74"/>
             <sld:ColorMapEntry quantity="202.74" color="#8f7869" opacity="1" label="202.74 - 236.53"/>
             <sld:ColorMapEntry quantity="236.53" color="#7e6657" opacity="1" label="236.53 - 270.32"/>
             <sld:ColorMapEntry quantity="270.32" color="#6d5345" opacity="1" label="270.32 - 304.11"/>
             <sld:ColorMapEntry quantity="304.11" color="#5c4033" opacity="1" label="304.11 - 337.90"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>