React = require 'react'
{Link} = require 'react-router'
apiClient = require '../api/client'
MarkingMap = require '../components/marking-map'

module.exports = React.createClass
  displayName: 'MapPage'

  componentDidMount: ->
    document.documentElement.classList.add 'on-map-page'

    # Grab some subjects and add to map
    apiClient.type('subjects').get().then (subjects) =>
      this.refs.map.setSubjects(subjects)

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-map-page'

  render: ->
    <div className="home-page" style={{display: 'flex', flex: 1}}>
      <MarkingMap ref="map" />
    </div>
