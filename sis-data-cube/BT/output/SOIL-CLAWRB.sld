<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>CLAWRB</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="values">
             <sld:ColorMapEntry quantity="-1" color="#000000" opacity="1" label="-1 - No Data"/>
             <sld:ColorMapEntry quantity="1" color="#800080" opacity="1" label="1 - Anthraquic Cambisols"/>
             <sld:ColorMapEntry quantity="2" color="#f84040" opacity="1" label="2 - Dystric Cambisols"/>
             <sld:ColorMapEntry quantity="3" color="#da70d6" opacity="1" label="3 - Eutric Cambisols"/>
             <sld:ColorMapEntry quantity="4" color="#f08080" opacity="1" label="4 - Haplic Acrisols"/>
             <sld:ColorMapEntry quantity="5" color="#00ffff" opacity="1" label="5 - Haplic Alisols"/>
             <sld:ColorMapEntry quantity="6" color="#f5deb3" opacity="1" label="6 - Haplic Lixisols"/>
             <sld:ColorMapEntry quantity="7" color="#ee82ee" opacity="1" label="7 - Skeletic Cambisols"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>