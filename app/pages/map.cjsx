React = require 'react'
{Link} = require 'react-router'
apiClient = require '../api/client'
MarkingMap = require '../components/marking-map'

module.exports = React.createClass
  displayName: 'MapPage'

  componentDidMount: ->
    document.documentElement.classList.add 'on-map-page'

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-map-page'

  render: ->
    <div className="home-page" style={{display: 'flex', flex: 1}}>
      <MarkingMap />
    </div>
