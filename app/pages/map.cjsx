React = require 'react'
{Link} = require 'react-router'
apiClient = require '../api/client'
MarkingMap = require '../components/marking-map'

module.exports = React.createClass
  displayName: 'MapPage'

  componentDidMount: ->
    console.log 'mappagemount'
    apiClient.type('subjects').get().then (subjects) =>
      console.log subjects
      @setState {subjects}
    document.documentElement.classList.add 'on-map-page'

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-map-page'

  render: ->
    console.log 'maprender'
    <div className="home-page" style={{display: 'flex', flex: 1}}>
      <MarkingMap />
    </div>
