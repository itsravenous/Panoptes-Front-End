React = require 'react'
{Link} = require '@edpaget/react-router'
DiscussionPreview = require './discussion-preview'
CommentBox = require './comment-box'
commentValidations = require './lib/comment-validations'
discussionValidations = require './lib/discussion-validations'
{getErrors} = require './lib/validations'
Router = require '@edpaget/react-router'
NewDiscussionForm = require './discussion-new-form'
Paginator = require './lib/paginator'
Moderation = require './lib/moderation'
StickyDiscussionList = require './sticky-discussion-list'
ROLES = require './lib/roles'
Loading = require '../components/loading-indicator'
merge = require 'lodash.merge'
talkConfig = require './config'
SignInPrompt = require '../partials/sign-in-prompt'
alert = require '../lib/alert'
store = require '../store'
{get, update, destroy} = require '../actions'
{connect} = require 'react-redux'

promptToSignIn = -> alert (resolve) -> <SignInPrompt onChoose={resolve} />

PAGE_SIZE = talkConfig.boardPageSize

mapStateToProps = (state) ->
  discussions: state.discussions
  boards: state.boards

module?.exports = connect(mapStateToProps) React.createClass
  displayName: 'TalkBoard'
  mixins: [Router.Navigation]

  getInitialState: ->
    discussions: []
    board: {}
    discussionsMeta: {}
    newDiscussionOpen: false
    loading: false
    moderationOpen: false

  getDefaultProps: ->
    query: page: 1

  componentWillReceiveProps: (nextProps) ->
    unless nextProps.query.page is @props.query.page
      @dispatchDiscussions(nextProps.query.page ? 1)

  componentWillMount: ->
    @dispatchDiscussions(@props.query.page ? 1)
    @dispatchBoards()

  dispatchDiscussions: (page) ->
    store.dispatch(get({
      type: 'talk/discussions',
      params: {
        board_id: @props.params.board,
        page_size: PAGE_SIZE,
        page: page
      }
    }))

  dispatchBoards: ->
    store.dispatch(get({
      type: 'talk/boards',
      params: {
        id: @props.params.board
      }
    }))
    
  onCreateDiscussion: ->
    @setState newDiscussionOpen: false
    @dispatchDiscussions()

  discussionPreview: (discussion, i) ->
    <DiscussionPreview {...@props} key={i} discussion={discussion} />

  onClickDeleteBoard: ->
    if window.confirm("Are you sure that you want to delete this board? All of the comments and discussions will be lost forever.")
      {owner, name} = @props.params
      if @board().section is 'zooniverse'
        store.dispatch(destroy({type: 'talk/boards', id: @props.params.board}))
          .then =>
            @transitionTo('talk')
      else
        store.dispatch(destroy({type: 'talk/boards', id: @props.params.board}))
          .then =>
            @transitionTo('project-talk', {owner: owner, name: name})

  onEditBoard: (e) ->
    e.preventDefault()
    form = React.findDOMNode(@).querySelector('.talk-edit-board-form')

    input = form.querySelector('input')
    title = input.value

    description = form.querySelector('textarea').value

    # permissions
    read = form.querySelector(".roles-read input[name='role-read']:checked").value
    write = form.querySelector(".roles-write input[name='role-write']:checked").value
    permissions = {read, write}
    board = {title, permissions, description}

    store.dispatch(update({
      type: 'talk/boards',
      id: @props.params.board
      params: board
    }))

  onClickNewDiscussion: ->
    @setState newDiscussionOpen: !@state.newDiscussionOpen

  roleReadLabel: (data, i) ->
    <label key={i}>
      <input
        type="radio"
        name="role-read"
        onChange={=>
          @setState board: merge {}, @board(), {permissions: read: data}
        }
        value={data}
        checked={@board().permissions.read is data}/>
      {data}
    </label>

  roleWriteLabel: (data, i) ->
    <label key={i}>
      <input
        type="radio"
        name="role-write"
        onChange={=>
          @setState board: merge {}, @board(), {permissions: write: data}
        }
        checked={@board().permissions.write is data}
        value={data}/>
      {data}
    </label>

  board: ->
    @props.boards[@props.params.board]

  render: ->
    board = @props.boards[@props.params.board]
    discussions = @props.discussions.current?.map (id) => @props.discussions[id]

    <div className="talk-board">
      <h1 className="talk-page-header">{board?.title}</h1>
      {if board && @props.user?
        <div className="talk-moderation">
          <Moderation user={@props.user} section={@props.section}>
            <button onClick={=> @setState moderationOpen: !@state.moderationOpen}>
              <i className="fa fa-#{if @state.moderationOpen then 'close' else 'warning'}" /> Moderator Controls
            </button>
          </Moderation>

          {if @state.moderationOpen
            <div className="talk-moderation-children talk-module">
              <h2>Moderator Zone:</h2>

              <Link
                to="#{if @props.section isnt 'zooniverse' then 'project-' else ''}talk-moderations"
                params={
                  if (@props.params?.owner and @props.params?.name)
                    {owner: @props.params.owner, name: @props.params.name}
                  else
                    {}
                }>
                View Reported Comments
              </Link>

              {if board?.title
                <form className="talk-edit-board-form" onSubmit={@onEditBoard}>
                  <h3>Edit Title:</h3>
                  <input defaultValue={board?.title}/>

                  <h3>Edit Description</h3>
                  <textarea defaultValue={board?.description}></textarea>

                  <h4>Can Read:</h4>
                  <div className="roles-read">{ROLES.map(@roleReadLabel)}</div>

                  <h4>Can Write:</h4>
                  <div className="roles-write">{ROLES.map(@roleWriteLabel)}</div>

                  <button type="submit">Update</button>
                </form>}

              <button onClick={@onClickDeleteBoard}>
                Delete this board <i className="fa fa-close" />
              </button>

              <StickyDiscussionList board={board} />
            </div>
          }
        </div>
        }

      {if @props.user?
        <section>
          <button onClick={@onClickNewDiscussion}>
            <i className="fa fa-#{if @state.newDiscussionOpen then 'close' else 'plus'}" />&nbsp;
            New Discussion
          </button>

          {if @state.newDiscussionOpen
            <NewDiscussionForm
              boardId={+@props.params.board}
              onCreateDiscussion={@onCreateDiscussion}
              user={@props.user} />}
         </section>
       else
         <p>Please <button className="link-style" type="button" onClick={promptToSignIn}>sign in</button> to create discussions</p>}

      <div className="talk-list-content">
        <section>
          {if @state.loading
            <Loading />
           else if discussions?.length
            discussions.map(@discussionPreview)
           else
            <p>There are currently no discussions in this board.</p>}
        </section>

        <div className="talk-sidebar">
          <h2>Talk Sidebar</h2>
          <section>
            <h3>Description:</h3>
            <p>{board?.description}</p>
            <h3>Join the Discussion</h3>
            <p>Check out the existing posts or start a new discussion of your own</p>
          </section>

          <section>
            <h3>
              {if @props.section is 'zooniverse'
                <Link className="sidebar-link" to="talk-board-recents" {...@props}>Recent Comments</Link>
              else
                <Link className="sidebar-link" to="project-talk-board-recents" {...@props}>Recent Comments</Link>
              }
            </h3>
          </section>
        </div>
      </div>

      <Paginator page={+@props.discussions.meta?.page} pageCount={@props.discussions.meta?.page_count} />
    </div>
