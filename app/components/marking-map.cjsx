React = require 'react'
ReactDOM = require 'react-dom'
L = if window.navigator then require 'leaflet' else null
if (L)
  MARKER_ICON = L.divIcon
    html: '<svg viewBox="0 0 100 100" width="1em" height="1em" class="zooniverse-logo" data-reactid=".0.1.0.0.0"><use xlink:href="#zooniverse-logo-source" x="0" y="0" width="100" height="100"></use></svg>'
  MARKER_OPTIONS =
    icon: MARKER_ICON

module.exports = React.createClass
  displayName: 'MarkingMap'

  componentDidMount: ->
    if L
      @map = map = L.map(ReactDOM.findDOMNode this).setView([
        51.505
        -0.09
      ], 13)
      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors').addTo map
      L.marker([
        51.5
        -0.09
      ], MARKER_OPTIONS).addTo(map).bindPopup('A pretty CSS3 popup.<br> Easily customizable.').openPopup()

  render: ->
    <div className="marking-map" style={{display: 'flex'; flex: 1}}>
      {@mapDiv}
    </div>
