<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>SALT</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="values">
             <sld:ColorMapEntry quantity="-1" color="#000000" opacity="0" label="No Data"/>
             <sld:ColorMapEntry quantity="1" color="#ff0000" opacity="1" label="1 - Extreme Salinity"/>
             <sld:ColorMapEntry quantity="2" color="#f5deb3" opacity="1" label="2 - Moderate Salinity"/>
             <sld:ColorMapEntry quantity="3" color="#ee82ee" opacity="1" label="3 - Moderate Sodicity"/>
             <sld:ColorMapEntry quantity="4" color="#ffffff" opacity="1" label="4 - None"/>
             <sld:ColorMapEntry quantity="5" color="#00ffff" opacity="1" label="5 - Saline Sodic"/>
             <sld:ColorMapEntry quantity="6" color="#90ee90" opacity="1" label="6 - Slight Salinity"/>
             <sld:ColorMapEntry quantity="7" color="#add8e6" opacity="1" label="7 - Slight Sodicity"/>
             <sld:ColorMapEntry quantity="8" color="#f08080" opacity="1" label="8 - Strong Salinity"/>
             <sld:ColorMapEntry quantity="9" color="#da70d6" opacity="1" label="9 - Strong Sodicity"/>
             <sld:ColorMapEntry quantity="10" color="#f84040" opacity="1" label="10 - Very Strong Salinity"/>
             <sld:ColorMapEntry quantity="11" color="#800080" opacity="1" label="11 - Very Strong Sodicity"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>