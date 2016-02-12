React = require 'react'
{Link} = require 'react-router'
MarkingMap = require '../components/marking-map'

module.exports = React.createClass
  displayName: 'MapPage'

  componentDidMount: ->
    document.documentElement.classList.add 'on-map-page'

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-map-page'

  render: ->
    <div className="map-page" style={{display: 'flex', height: '60vh'}}>
      <MarkingMap ref="map" subjectSet="3576" numSubjects="5" />
    </div>
