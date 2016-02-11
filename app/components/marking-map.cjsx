React = require 'react'
ReactDOM = require 'react-dom'
getSubjectLocation = require '../lib/get-subject-location'
L = if window.navigator then require 'leaflet' else null

if (L)
  BASE_LAYER = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors')
  MARKER_ICON = L.divIcon
    html: '<div style="border-radius: 50% 50%; width: 5px; height: 5px; background:rgba(255, 255, 255, 0.5); border: 5px solid rgba(0, 0, 0, 0.5); background-clip: content-box"></div>'
    iconSize: [10, 10]
  MARKER_OPTIONS =
    icon: MARKER_ICON

module.exports = React.createClass
  displayName: 'MarkingMap'

  # React lifecycle
  getInitialState: ->
    subjects: []

  # API methods
  setSubjects: (subjects) ->
    layers = []
    for subject in subjects
      @addSubjectMarker subject
      for image, idx in @getSubjectImages subject
        layers[idx] = [] if not layers[idx]
        layers[idx].push @addSubjectTile subject, idx

    layerGroupsKeyed = {}
    for i, layer of layers
      layerGroupsKeyed['layer'+i] = L.layerGroup layer

    L.control.layers({base: BASE_LAYER}, layerGroupsKeyed)
      .addTo @map

    bounds = @getSubjectSetBounds subjects
    @map.fitBounds bounds
    @setState {subjects}

  addSubjectTile: (subject, imageIdx) ->
    images = @getSubjectImages subject
    bounds = @getSubjectBounds subject
    L.imageOverlay images[imageIdx].src, bounds

  addSubjectMarker: (subject) ->
    image = subject.locations[0][Object.keys(subject.locations[0])[0]]
    center = @getSubjectCenter subject
    L.marker(center, MARKER_OPTIONS)
      .addTo @map
      .bindPopup '<a href="'+image+'">Image</a>'
      .openPopup();

  # Private methods
  getSubjectSetBounds: (subjects) ->
    latlngs = []
    for subject in subjects
      latlngs.push [subject.metadata.upper_left_lat, subject.metadata.upper_left_lon]
      latlngs.push [subject.metadata.bottom_right_lat, subject.metadata.bottom_right_lon]

    return latlngs

  getSubjectBounds: (subject) ->
    [
      [subject.metadata.upper_left_lat, subject.metadata.upper_left_lon]
      [subject.metadata.bottom_right_lat, subject.metadata.bottom_right_lon]
    ]

  getSubjectCenter: (subject) ->
    [subject.metadata.center_lat, subject.metadata.center_lon]

  getSubjectImages: (subject) ->
    images = []
    images = for frame, location of subject.locations
      getSubjectLocation subject, frame

  # Lifecycle methods
  componentDidMount: ->
    if L
      @map = map = L.map(ReactDOM.findDOMNode this)
      BASE_LAYER.addTo map


  render: ->
    <div className="marking-map" style={{display: 'flex'; flex: 1}}>
      {@mapDiv}
    </div>
