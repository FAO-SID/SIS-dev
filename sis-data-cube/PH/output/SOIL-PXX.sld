<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>PXX</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="2.53" color="#f4e7d3" opacity="1" label="2.53 - 22.62"/>
             <sld:ColorMapEntry quantity="22.62" color="#e4d5c2" opacity="1" label="22.62 - 42.72"/>
             <sld:ColorMapEntry quantity="42.72" color="#d3c2b0" opacity="1" label="42.72 - 62.81"/>
             <sld:ColorMapEntry quantity="62.81" color="#c2b09e" opacity="1" label="62.81 - 82.91"/>
             <sld:ColorMapEntry quantity="82.91" color="#b19d8c" opacity="1" label="82.91 - 103.00"/>
             <sld:ColorMapEntry quantity="103" color="#a08b7b" opacity="1" label="103.00 - 123.09"/>
             <sld:ColorMapEntry quantity="123.09" color="#8f7869" opacity="1" label="123.09 - 143.19"/>
             <sld:ColorMapEntry quantity="143.19" color="#7e6657" opacity="1" label="143.19 - 163.28"/>
             <sld:ColorMapEntry quantity="163.28" color="#6d5345" opacity="1" label="163.28 - 183.38"/>
             <sld:ColorMapEntry quantity="183.38" color="#5c4033" opacity="1" label="183.38 - 203.47"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>