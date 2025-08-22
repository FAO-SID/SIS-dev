<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGT0U</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-105.51" color="#f4e7d3" opacity="1" label="-105.51 - -38.26"/>
             <sld:ColorMapEntry quantity="-38.26" color="#e4d5c2" opacity="1" label="-38.26 - 28.99"/>
             <sld:ColorMapEntry quantity="28.99" color="#d3c2b0" opacity="1" label="28.99 - 96.24"/>
             <sld:ColorMapEntry quantity="96.24" color="#c2b09e" opacity="1" label="96.24 - 163.49"/>
             <sld:ColorMapEntry quantity="163.49" color="#b19d8c" opacity="1" label="163.49 - 230.75"/>
             <sld:ColorMapEntry quantity="230.75" color="#a08b7b" opacity="1" label="230.75 - 298.00"/>
             <sld:ColorMapEntry quantity="298" color="#8f7869" opacity="1" label="298.00 - 365.25"/>
             <sld:ColorMapEntry quantity="365.25" color="#7e6657" opacity="1" label="365.25 - 432.50"/>
             <sld:ColorMapEntry quantity="432.5" color="#6d5345" opacity="1" label="432.50 - 499.75"/>
             <sld:ColorMapEntry quantity="499.75" color="#5c4033" opacity="1" label="499.75 - 567.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>