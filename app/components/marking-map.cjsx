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

  # API methods
  setSubjects: (subjects) ->
    for subject in subjects
      subject = @generateSubjectLatLng subject
      @addSubjectMarker subject
      @addSubjectTile subject

    bounds = @getBoundsForSubjects subjects
    @map.fitBounds bounds

  addSubjectTile: (subject) ->
    image = subject.locations[0][Object.keys(subject.locations[0])[0]]
    L.imageOverlay image, [subject.metadata.latlngNW, subject.metadata.latlngSE]
      .addTo @map;

  addSubjectMarker: (subject) ->
    image = subject.locations[0][Object.keys(subject.locations[0])[0]]
    L.marker(subject.metadata.latlngCenter, MARKER_OPTIONS).addTo(@map).bindPopup('<a href="'+image+'">Image</a>').openPopup();

  # Private methods
  getBoundsForSubjects: (subjects) ->
    latlngs = []

    for subject in subjects
      latlngs.push new L.LatLng(subject.metadata.latlngNW[0], subject.metadata.latlngNW[1])
      latlngs.push new L.LatLng(subject.metadata.latlngSE[0], subject.metadata.latlngSE[1])

    return latlngs

  generateSubjectLatLng: (subject) ->
    subject.metadata = subject.metadata || {}
    subject.metadata.latlngNW = [
      Math.random() * 90 / 5
      Math.random() * 180 / 5
    ]
    subject.metadata.latlngSE = [
      subject.metadata.latlngNW[0] + 1
      subject.metadata.latlngNW[1] + 3
    ]
    subject.metadata.latlngCenter = [
      subject.metadata.latlngNW[0] + 0.5
      subject.metadata.latlngNW[1] + 1.5
    ]
    return subject

  # Lifecycle methods
  componentDidMount: ->
    if L
      @map = map = L.map(ReactDOM.findDOMNode this)
      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors').addTo map


  render: ->
    <div className="marking-map" style={{display: 'flex'; flex: 1}}>
      {@mapDiv}
    </div>
