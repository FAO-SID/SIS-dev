<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ECXU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="1" color="#f4e7d3" opacity="1" label="1.00 - 7810695988.20"/>
             <sld:ColorMapEntry quantity="7.810696e+09" color="#e4d5c2" opacity="1" label="7810695988.20 - 15621391975.40"/>
             <sld:ColorMapEntry quantity="1.5621392e+10" color="#d3c2b0" opacity="1" label="15621391975.40 - 23432087962.60"/>
             <sld:ColorMapEntry quantity="2.3432088e+10" color="#c2b09e" opacity="1" label="23432087962.60 - 31242783949.80"/>
             <sld:ColorMapEntry quantity="3.1242785e+10" color="#b19d8c" opacity="1" label="31242783949.80 - 39053479937.00"/>
             <sld:ColorMapEntry quantity="3.905348e+10" color="#a08b7b" opacity="1" label="39053479937.00 - 46864175924.20"/>
             <sld:ColorMapEntry quantity="4.6864175e+10" color="#8f7869" opacity="1" label="46864175924.20 - 54674871911.40"/>
             <sld:ColorMapEntry quantity="5.467487e+10" color="#7e6657" opacity="1" label="54674871911.40 - 62485567898.60"/>
             <sld:ColorMapEntry quantity="6.248557e+10" color="#6d5345" opacity="1" label="62485567898.60 - 70296263885.80"/>
             <sld:ColorMapEntry quantity="7.0296265e+10" color="#5c4033" opacity="1" label="70296263885.80 - 78106959873.00"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>