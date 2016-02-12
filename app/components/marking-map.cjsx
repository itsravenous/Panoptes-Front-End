React = require 'react'
ReactDOM = require 'react-dom'
apiClient = require 'panoptes-client/lib/api-client'
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

  getDefaultProps: ->
    subjectSet: null
    numSubjects: 50

  componentDidMount: ->
    if L
      @map = map = L.map(ReactDOM.findDOMNode this)
      BASE_LAYER.addTo map

  componentWillReceiveProps: (newProps, oldProps) ->
    if newProps.subjectSet isnt oldProps.subjectSet or newProps.numSubjects isnt oldProps.numSubjects
      @fetchSubjects()

  render: ->
    <div className="marking-map" style={{display: 'flex'; flex: 1}}>
      {@mapDiv}
    </div>

  # Private methods

  # Grab some subjects and add to map
  fetchSubjects: () ->
    apiClient.type('set_member_subjects').get({
      subject_set_id: @props.subjectSet
      page_size: @props.numSubjects
    }).then (subjectSetMembers) =>
        subjectIds = (s.links.subject for i, s of subjectSetMembers)
        apiClient.type('subjects').get subjectIds
      .then (subjects) =>
        @setSubjects subjects

  # Set which subjects to display
  setSubjects: (subjects) ->
    # Create layers grouped by frame number (e.g. for before/after subjects)
    layers = []
    for subject in subjects
      @addSubjectMarker subject
      for image, idx in @getSubjectImages subject
        layers[idx] = [] if not layers[idx]
        layers[idx].push @addSubjectTile subject, idx

    layerGroupsKeyed = {}
    for i, layer of layers
      layerGroupsKeyed['layer'+i] = L.layerGroup layer # @todo grab column header of row for layer name - is that useful?

    # Add layer switcher control
    L.control.layers({base: BASE_LAYER}, layerGroupsKeyed)
      .addTo @map

    # Zoom out far enough to see all subjects
    @map.fitBounds @getSubjectSetBounds(subjects)

  # Add an image from a subject as a tile on the map, covering the area defined by the subject's metadata
  addSubjectTile: (subject, imageIdx) ->
    images = @getSubjectImages subject
    bounds = @getSubjectBounds subject
    L.imageOverlay images[imageIdx].src, bounds

  # Add a marker at the center point of a subject's area, with a popup containing links to its images
  addSubjectMarker: (subject) ->
    images = @getSubjectImages subject
    center = @getSubjectCenter subject
    popupHtml = for i, image of images
      "<a href='#{image.src}'>Image #{(parseInt(i) + 1)}</a>"

    L.marker(center, MARKER_OPTIONS)
      .addTo @map
      .bindPopup popupHtml.join '<p>'
      .openPopup()

  # Determine the outer bounding box which contains all subjects in a set
  getSubjectSetBounds: (subjects) ->
    latlngs = []
    for subject in subjects
      latlngs.push [subject.metadata.upper_left_lat, subject.metadata.upper_left_lon]
      latlngs.push [subject.metadata.bottom_right_lat, subject.metadata.bottom_right_lon]

    return latlngs

  # Retrieve the bounding box of a subject from its metadata
  getSubjectBounds: (subject) ->
    [
      [subject.metadata.upper_left_lat, subject.metadata.upper_left_lon]
      [subject.metadata.bottom_right_lat, subject.metadata.bottom_right_lon]
    ]

  # Retrieve the center coordinates of a subject from its metadata
  getSubjectCenter: (subject) ->
    [subject.metadata.center_lat, subject.metadata.center_lon]

  # Retrieve all images from a subject
  getSubjectImages: (subject) ->
    images = for frame, location of subject.locations
      getSubjectLocation subject, frame
