React = require 'react'
{Link} = require 'react-router'
apiClient = require 'panoptes-client/lib/api-client'
MarkingMap = require '../components/marking-map'

module.exports = React.createClass
  displayName: 'MapPage'

  componentDidMount: ->
    document.documentElement.classList.add 'on-map-page'

    # Grab some subjects and add to map
    apiClient.type('set_member_subjects').get({
      subject_set_id: '3576'
      page_size: 200
    }).then (subjectSetMembers) =>
        subjectIds = (s.links.subject for i, s of subjectSetMembers)
        apiClient.type('subjects').get subjectIds
      .then (subjects) =>
        this.refs.map.setSubjects subjects

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-map-page'

  render: ->
    <div className="map-page" style={{display: 'flex', flex: 1}}>
      <MarkingMap ref="map" />
    </div>
