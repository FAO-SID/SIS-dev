<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM3</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-188.05" color="#f4e7d3" opacity="1" label="-188.05 - -162.67"/>
             <sld:ColorMapEntry quantity="-162.67" color="#e4d5c2" opacity="1" label="-162.67 - -137.28"/>
             <sld:ColorMapEntry quantity="-137.28" color="#d3c2b0" opacity="1" label="-137.28 - -111.90"/>
             <sld:ColorMapEntry quantity="-111.9" color="#c2b09e" opacity="1" label="-111.90 - -86.51"/>
             <sld:ColorMapEntry quantity="-86.51" color="#b19d8c" opacity="1" label="-86.51 - -61.13"/>
             <sld:ColorMapEntry quantity="-61.13" color="#a08b7b" opacity="1" label="-61.13 - -35.74"/>
             <sld:ColorMapEntry quantity="-35.74" color="#8f7869" opacity="1" label="-35.74 - -10.36"/>
             <sld:ColorMapEntry quantity="-10.36" color="#7e6657" opacity="1" label="-10.36 - 15.03"/>
             <sld:ColorMapEntry quantity="15.03" color="#6d5345" opacity="1" label="15.03 - 40.41"/>
             <sld:ColorMapEntry quantity="40.41" color="#5c4033" opacity="1" label="40.41 - 65.80"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>