React = require 'react'
TitleMixin = require '../../lib/title-mixin'
PromiseRenderer = require '../../components/promise-renderer'
apiClient = require '../../api/client'
SubjectViewer = require '../../components/subject-viewer'
stingyFirebase = require '../../lib/stingy-firebase'
FirebaseList = require '../../components/firebase-list'
Comment = require './chat/comment'
ChangeListener = require '../../components/change-listener'
auth = require '../../api/auth'
PromiseRenderer = require '../../components/promise-renderer'

commentsRef = stingyFirebase.child 'comments'

module.exports = React.createClass
  mixins: [TitleMixin, stingyFirebase.Mixin]

  title: ->
    "Subject details"

  render: ->
    <div className="subject-details-page columns-container content-container">
      <PromiseRenderer promise={apiClient.type('subjects').get @props.params.subjectID}>{(subject) =>
        <div className="classifier">
          <SubjectViewer subject={subject} />
        </div>
      }</PromiseRenderer>

      <hr />

      <div>
        <FirebaseList ref="list" items={commentsRef.orderByChild('subject').equalTo @props.params.subjectID}>{(key, comment) =>
          unless comment.flagged
            <Comment key={key} id={key} comment={comment} reference={commentsRef.child key} />
        }</FirebaseList>

        <ChangeListener target={auth}>{=>
          <PromiseRenderer promise={auth.checkCurrent()}>{(user) =>
            if user?
              <form onSubmit={@handleSubmit.bind this, @props.project?.id ? @props.params.projectID, @props.params.subjectID}>
                <textarea name="comment-content" /><br />
                <button type="submit">Save comment</button>
              </form>
            else
              <p>Sign in leave a comment</p>
          }</PromiseRenderer>
        }</ChangeListener>
      </div>
    </div>

  handleSubmit: (projectID, subjectID, e) ->
    e.preventDefault()

    contentInput = @getDOMNode().querySelector '[name="comment-content"]'

    stingyFirebase.child('comments').push
      user: stingyFirebase.getAuth()?.uid
      project: projectID
      subject: subjectID
      content: contentInput.value
      =>
        @refs.list.displayAll()
        contentInput.value = ''

        stingyFirebase.child("subjects/#{subjectID}/count").transaction (count) ->
          (count ? 0) + 1
