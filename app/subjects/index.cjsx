React = require 'react'
apiClient = require '../api/client'
talkClient = require '../api/talk'
getSubjectLocation = require '../lib/get-subject-location'
FavoritesButton = require '../collections/favorites-button'
PromiseRenderer = require '../components/promise-renderer'
SubjectViewer = require '../components/subject-viewer'
NewDiscussionForm = require '../talk/discussion-new-form'
CommentLink = require '../talk/comment-link'
projectSection = require '../talk/lib/project-section'
parseSection = require '../talk/lib/parse-section'
QuickSubjectCommentForm= require '../talk/quick-subject-comment-form'
{Navigation, Link} = require '@edpaget/react-router'
{Markdown} = require 'markdownz'
alert = require '../lib/alert'
SignInPrompt = require '../partials/sign-in-prompt'

store = require '../store'
{get} = require '../actions'
{connect} = require 'react-redux'

indexOf = (elem) ->
  (elem while elem = elem.previousSibling).length

promptToSignIn = ->
  alert (resolve) -> <SignInPrompt onChoose={resolve} />

mapStateToProps = (state) ->
  subjects: state.subjects
  comments: state.comments

module?.exports = connect(mapStateToProps) React.createClass
  displayName: 'Subject'
  mixins: [Navigation]

  getInitialState: ->
    tab: 0

  componentWillMount: ->
    @dispatchSubjects()
    .then ({subjects}) => @dispatchComments(subjects[0])

  componentWillReceiveProps: (nextProps) ->
    if nextProps.params?.id isnt @props.params?.id
      @dispatchSubjects()

  dispatchSubjects: ->
    id = @props.params?.id.toString()
    store.dispatch(get({type: 'api/subjects', params: {id}}))

  dispatchComments: (subject) ->
    store.dispatch(get({
      type: 'talk/comments',
      params: {focus_id: subject.id, focus_type: 'Subject'}
    }))

  comment: (data, i) ->
    <CommentLink key={data.id} comment={data}>
      <div className="talk-module">
        <strong>{data.user_display_name}</strong>
        <br />
        <Markdown project={@props.project}>{data.body}</Markdown>
      </div>
    </CommentLink>

  onCreateDiscussion: (discussion) ->
    projectId = parseSection(discussion.section)
    apiClient.type('projects').get(projectId).then (project) =>
      [owner, name] = project.slug.split('/')
      @transitionTo('project-talk-discussion', {owner: owner, name: name, board: discussion.board_id, discussion: discussion.id})

  linkToClassifier: (text) ->
    [owner, name] = @props.project.slug.split('/')
    <Link to="project-classify" params={{owner, name}}>{text}</Link>

  render: ->
    subject = @props.subjects[0]
    {comments} = @props

    <div className="subject-page talk">
      {if subject
        <section>
          <h1>Subject {subject.id}</h1>

          <SubjectViewer subject={subject} user={@props.user} project={@props.project}/>

          {if comments.length
            <div>
              <h2>Comments mentioning this subject:</h2>
              <div>{comments.map(@comment)}</div>
            </div>
          else
            <p>There are no comments focused on this subject</p>}

          {if @props.user
            {# TODO remove subject.get('project'), replace with params but browser freezes on get to projects with slug}
            project = subject.get('project')
            boards = project.then (project) -> talkClient.type('boards').get(section: projectSection(project), subject_default: false)
            subjectDefaultBoard = project.then (project) -> talkClient.type('boards').get(section: projectSection(project), subject_default: true)

            <PromiseRenderer promise={Promise.all([boards, subjectDefaultBoard])}>{([boards, subjectDefaultBoard]) =>
              defaultExists = subjectDefaultBoard.length
              if boards.length or defaultExists
                <div>
                  <div className="tabbed-content">
                    <div className="tabbed-content-tabs">
                      <div className="subject-page-tabs">
                        <div className="tabbed-content-tab #{if @state.tab is 0 then 'active' else ''}" onClick={=> @setState({tab: 0})}>
                          <span>Add a note about this subject</span>
                        </div>

                        <div className="tabbed-content-tab #{if @state.tab is 1 then 'active' else ''}" onClick={=> @setState({tab: 1})}>
                          <span>Start a new discussion</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div>
                    {if @state.tab is 0
                      if defaultExists
                        <QuickSubjectCommentForm subject={subject} user={@props.user} />
                      else
                        <p>
                          There is no default board for subject comments setup yet, Please{' '}
                          <button className="link-style" onClick={=> @setState(tab: 1)}>start a new discussion</button>{' '}
                          or {@linkToClassifier('return to classifying')}
                        </p>
                     else if @state.tab is 1
                      <NewDiscussionForm
                        user={@props.user}
                        subject={subject}
                        onCreateDiscussion={@onCreateDiscussion} />
                        }
                  </div>
                </div>
              else
                <p>There are no discussion boards setup for this project yet. Check back soon!</p>
            }</PromiseRenderer>
          else
            <p>Please <button className="link-style" type="button" onClick={promptToSignIn}>sign in</button> to contribute to subject discussions</p>}
        </section>
        }
    </div>
