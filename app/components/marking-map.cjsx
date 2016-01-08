React = require 'react'
ReactDOM = require 'react-dom'
L = if window.navigator then require 'leaflet' else null
console.log ReactDOM
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
      ]).addTo(map).bindPopup('A pretty CSS3 popup.<br> Easily customizable.').openPopup()

      setTimeout resize 3000

  resize: ->
    console.log 'resize'
    @map.invalidateSize()

  render: ->
    <div className="marking-map" style={{display: 'flex'; flex: 1}} />
