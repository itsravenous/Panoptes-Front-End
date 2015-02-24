stingyFirebase = require '../../../lib/stingy-firebase'
React = require 'react'
ChangeListener = require '../../../components/change-listener'
auth = require '../../../api/auth'
PromiseRenderer = require '../../../components/promise-renderer'
apiClient = require '../../../api/client'
Markdown = require '../../../components/markdown'

module.exports = React.createClass
  mixins: [stingyFirebase.Mixin]

  getDefaultProps: ->
    id: ''
    comment: null
    summary: false

  getInitialState: ->
    userID: ''

  componentDidMount: ->
    @bindAsObject stingyFirebase.child('users').child(@props.comment.user), 'userID'

  render: ->
    <div className="comment">
      <ChangeListener target={auth}>{=>
        <PromiseRenderer promise={auth.checkCurrent()}>{(user) =>
          if user?
            <button type="button" onClick={@handleFlag}>Flag</button>
        }</PromiseRenderer>
      }</ChangeListener>

      {if @state.userID
        <PromiseRenderer promise={apiClient.type('users').get(@state.userID)}>{(user) =>
          <div className="byline">
            <img src={user.avatar} style={borderRadius: '50%', height: '1.5em', verticalAlign: 'middle', width: '1.5em'} />&nbsp;
            <strong>{user.display_name}</strong> at {(new Date @props.comment.timestamp).toString()}
          </div>
        }</PromiseRenderer>}
      <Markdown>{@props.comment.content}</Markdown>
    </div>

  handleFlag: ->
    if confirm 'Really flag this comment?'
      @props.reference.child('flagged').set true
