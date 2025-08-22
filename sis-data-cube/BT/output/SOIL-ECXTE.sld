<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ECXTE</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-42.49" color="#f4e7d3" opacity="1" label="-42.49 - -38.09"/>
             <sld:ColorMapEntry quantity="-38.09" color="#e4d5c2" opacity="1" label="-38.09 - -33.69"/>
             <sld:ColorMapEntry quantity="-33.69" color="#d3c2b0" opacity="1" label="-33.69 - -29.29"/>
             <sld:ColorMapEntry quantity="-29.29" color="#c2b09e" opacity="1" label="-29.29 - -24.89"/>
             <sld:ColorMapEntry quantity="-24.89" color="#b19d8c" opacity="1" label="-24.89 - -20.49"/>
             <sld:ColorMapEntry quantity="-20.49" color="#a08b7b" opacity="1" label="-20.49 - -16.09"/>
             <sld:ColorMapEntry quantity="-16.09" color="#8f7869" opacity="1" label="-16.09 - -11.69"/>
             <sld:ColorMapEntry quantity="-11.69" color="#7e6657" opacity="1" label="-11.69 - -7.29"/>
             <sld:ColorMapEntry quantity="-7.29" color="#6d5345" opacity="1" label="-7.29 - -2.89"/>
             <sld:ColorMapEntry quantity="-2.89" color="#5c4033" opacity="1" label="-2.89 - 1.51"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>