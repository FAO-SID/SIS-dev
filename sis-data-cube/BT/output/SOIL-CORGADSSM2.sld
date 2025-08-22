<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADSSM2</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-192.35" color="#f4e7d3" opacity="1" label="-192.35 - -167.37"/>
             <sld:ColorMapEntry quantity="-167.37" color="#e4d5c2" opacity="1" label="-167.37 - -142.40"/>
             <sld:ColorMapEntry quantity="-142.4" color="#d3c2b0" opacity="1" label="-142.40 - -117.43"/>
             <sld:ColorMapEntry quantity="-117.43" color="#c2b09e" opacity="1" label="-117.43 - -92.45"/>
             <sld:ColorMapEntry quantity="-92.45" color="#b19d8c" opacity="1" label="-92.45 - -67.48"/>
             <sld:ColorMapEntry quantity="-67.48" color="#a08b7b" opacity="1" label="-67.48 - -42.51"/>
             <sld:ColorMapEntry quantity="-42.51" color="#8f7869" opacity="1" label="-42.51 - -17.54"/>
             <sld:ColorMapEntry quantity="-17.54" color="#7e6657" opacity="1" label="-17.54 - 7.44"/>
             <sld:ColorMapEntry quantity="7.44" color="#6d5345" opacity="1" label="7.44 - 32.41"/>
             <sld:ColorMapEntry quantity="32.41" color="#5c4033" opacity="1" label="32.41 - 57.38"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>