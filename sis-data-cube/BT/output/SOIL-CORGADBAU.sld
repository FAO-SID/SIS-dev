<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CORGADBAU</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="intervals">
             <sld:ColorMapEntry quantity="-196.64" color="#f4e7d3" opacity="1" label="-196.64 - -172.08"/>
             <sld:ColorMapEntry quantity="-172.08" color="#e4d5c2" opacity="1" label="-172.08 - -147.52"/>
             <sld:ColorMapEntry quantity="-147.52" color="#d3c2b0" opacity="1" label="-147.52 - -122.96"/>
             <sld:ColorMapEntry quantity="-122.96" color="#c2b09e" opacity="1" label="-122.96 - -98.40"/>
             <sld:ColorMapEntry quantity="-98.4" color="#b19d8c" opacity="1" label="-98.40 - -73.84"/>
             <sld:ColorMapEntry quantity="-73.84" color="#a08b7b" opacity="1" label="-73.84 - -49.27"/>
             <sld:ColorMapEntry quantity="-49.27" color="#8f7869" opacity="1" label="-49.27 - -24.71"/>
             <sld:ColorMapEntry quantity="-24.71" color="#7e6657" opacity="1" label="-24.71 - -0.15"/>
             <sld:ColorMapEntry quantity="-0.15" color="#6d5345" opacity="1" label="-0.15 - 24.41"/>
             <sld:ColorMapEntry quantity="24.41" color="#5c4033" opacity="1" label="24.41 - 48.97"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>