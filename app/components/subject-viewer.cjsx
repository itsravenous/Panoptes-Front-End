React = require 'react'
LoadingIndicator = require '../components/loading-indicator'
FavoritesButton = require '../collections/favorites-button'
alert = require '../lib/alert'
{Markdown} = require 'markdownz'
getSubjectLocation = require '../lib/get-subject-location'
CollectionsManagerIcon = require '../collections/manager-icon'

NOOP = Function.prototype

subjectHasMixedLocationTypes = (subject) ->
  allTypes = []
  (subject?.locations ? []).forEach (location) ->
    Object.keys(location).forEach (typeAndFormat) ->
      type = typeAndFormat.split('/')[0]
      unless type in allTypes
        allTypes.push type
  allTypes.length > 1

ROOT_STYLE = display: 'block'
CONTAINER_STYLE = display: 'flex', flexWrap: 'wrap', position: 'relative'
SUBJECT_STYLE = display: 'block'

module.exports = React.createClass
  displayName: 'SubjectViewer'

  statics:
    overlayStyle:
      height: '100%'
      left: 0
      position: 'absolute'
      top: 0
      width: '100%'

  getDefaultProps: ->
    subject: null
    user: null
    playFrameDuration: 667
    playIterations: 3
    onFrameChange: NOOP
    onLoad: NOOP
    defaultStyle: true
    project: null
    linkToFullImage: false
    frameWrapper: null
    allowFlipbook: true
    allowSeparateFrames: true

  getInitialState: ->
    loading: true
    playing: false
    frame: @props.frame ? 0
    frameDimensions: {}
    inFlipbookMode: @props.allowFlipbook
    videoStates: []

  componentDidMount: ->
    for frame of @props.subject.locations
      @refs['videoScrubber'+frame]?.value = 0

  componentDidUpdate: ->
    for frame of @props.subject.locations
      @refs['videoPlayer'+frame]?.playbackRate = @state.videoStates[frame]?.playbackRate || 1

  willReceiveProps: (nextProps) ->
    # The default state for subjects is flipbook if allowed
    if typeof nextProps.allowFlipbook is 'boolean'
      this.setState
        inFlipbookMode: allowFlipbook

  render: ->
    rootClass = 'subject-viewer'
    if @props.workflow?.configuration?.multi_image_layout then rootClass += ' subject-viewer--layout-' + @props.workflow.configuration?.multi_image_layout
    if @state.inFlipbookMode then rootClass += ' subject-viewer--flipbook'
    mainDisplay = ''
    if @state.inFlipbookMode
      {type, format, src} = getSubjectLocation @props.subject, @state.frame
      mainDisplay = @renderFrame type, format, src, @state.frame
    else
      mainDisplay = for frame of @props.subject.locations
        {type, format, src} = getSubjectLocation @props.subject, frame
        @renderFrame type, format, src, frame

    tools = switch type
      when 'image'
        if not @state.inFlipbookMode or @props.subject?.locations.length < 2 or subjectHasMixedLocationTypes @props.subject
          if @props.allowFlipbook and @props.allowSeparateFrames
            <button className="flipbook-toggle" onClick={@toggleInFlipbookMode}>
              <i className={"fa fa-fw " + if @state.inFlipbookMode then "fa-th-large" else "fa-film"}></i>
            </button>
        else
          <span class="tools">
            {if @props.allowFlipbook and @props.allowSeparateFrames
              <button className="flipbook-toggle" onClick={@toggleInFlipbookMode}>
                <i className={"fa fa-fw " + if @state.inFlipbookMode then "fa-th-large" else "fa-film"}></i>
              </button>}

            {if not @state.inFlipbookMode or @props.subject?.locations.length < 2 or subjectHasMixedLocationTypes @props.subject
              null
            else
              <span className="subject-frame-play-controls">
                {if @state.playing
                  <button type="button" className="secret-button" onClick={@setPlaying.bind this, false}>
                    <i className="fa fa-pause fa-fw"></i>
                  </button>
                else
                  <button type="button" className="secret-button" onClick={@setPlaying.bind this, true}>
                    <i className="fa fa-play fa-fw"></i>
                  </button>}
              </span>}
          </span>

    <div className={rootClass} style={ROOT_STYLE if @props.defaultStyle}>
      {if type is 'image'
        @hiddenPreloadedImages()}
      <div className="subject-container" style={CONTAINER_STYLE}>
        {mainDisplay}
        {@props.children}
        {if @state.loading
          <div className="loading-cover" style={@constructor.overlayStyle}>
            <LoadingIndicator />
          </div>}
      </div>

      <div className="subject-tools">
        <span>{tools}</span>
        {if @props.subject?.locations.length >= 2 and @state.inFlipbookMode
          <span>
            <span className="subject-frame-pips">
              {for i in [0...@props.subject?.locations.length ? 0]
                <button type="button" key={i} className="subject-frame-pip #{if i is @state.frame then 'active' else ''}" value={i} onClick={@handleFrameChange.bind this, i}>{i + 1}</button>}
            </span>
        </span>}
        <span>
          {if @props.subject?.metadata?
            <button type="button" title="Metadata" className="metadata-toggle" onClick={@showMetadata}><i className="fa fa-info-circle fa-fw"></i></button>}
          {if @props.subject? and @props.user? and @props.project?
            <span>
              <FavoritesButton project={@props.project} subject={@props.subject} user={@props.user} />
              <CollectionsManagerIcon project={@props.project} subject={@props.subject} user={@props.user} />
            </span>}
          {if type is 'image' and @props.linkToFullImage
            <a href={src} title="Subject Image" target="_blank">
              <button type="button"><i className="fa fa-photo" /></button>
            </a>}
        </span>
      </div>
    </div>

  renderFrame: (type, format, src, frame) ->
    FrameWrapper = @props.frameWrapper
    frameDisplay = switch type
      when 'image'
        <img className="subject" src={src} style={SUBJECT_STYLE} onLoad={@handleLoad} />
      when 'video'
        <div className="subject-video-frame">
          <video ref={'videoPlayer'+frame} src={src} type={"#{type}/#{format}"} onCanPlayThrough={@handleLoad} onEnded={@endVideo.bind this, frame} onTimeUpdate={@updateScrubber.bind this, frame}>
            Your browser does not support the video format. Please upgrade your browser.
          </video>
          <span className="subject-video-controls">
            <span className="subject-frame-play-controls">
              {if @state.videoStates[frame]?.playing
                <button type="button" className="secret-button" aria-label="Pause" onClick={@playVideo.bind this, frame, false}>
                  <i className="fa fa-pause fa-fw"></i>
                </button>
              else
                <button type="button" className="secret-button" aria-label="Play" onClick={@playVideo.bind this, frame, true}>
                  <i className="fa fa-play fa-fw"></i>
                </button>}
            </span>
            <input type="range" className="video-scrubber" ref={'videoScrubber'+frame} min="0" step="any" onChange={@seekVideo.bind this, frame} />
            <span className="video-speed">
            Speed:
              {for rate, i in [0.25, 0.5, 1]
                checked = rate == @state.videoStates[frame]?.playbackRate or (not @state.videoStates[frame]?.playbackRate and rate is 1)
                <label key="rate-#{i}" className="secret-button">
                  <input type="radio" name={'playbackRate'+frame} value={rate} checked={checked} onChange={(e) => @setPlayRate e, frame } />
                  <span>
                    {rate}&times;
                  </span>
                </label>
              }
            </span>
          </span>
        </div>

    if FrameWrapper
      <FrameWrapper frame={frame} naturalWidth={@state.frameDimensions[src]?.width} naturalHeight={@state.frameDimensions[src]?.height} workflow={@props.workflow} subject={@props.subject} classification={@props.classification} annotation={@props.annotation}>
        {frameDisplay}
      </FrameWrapper>
    else
      frameDisplay

  hiddenPreloadedImages: ->
    # Render this to ensure that all a subject's location images are cached and ready to display.
    <div style={
      bottom: 0
      height: 1
      opacity: 0.1
      overflow: 'hidden'
      position: 'fixed'
      right: 0
      width: 1
    }>
      {for i in [0...@props.subject.locations.length]
        {src} = getSubjectLocation @props.subject, i
        <img key={i} src={src} />}
    </div>

  toggleInFlipbookMode: () ->
    @setInFlipbookMode not @state.inFlipbookMode

  setInFlipbookMode: (inFlipbookMode) ->
    @setState {inFlipbookMode}

  setPlaying: (frame, playing) ->
    if playing
      @nextFrame()
      @_playingInterval = setInterval @nextFrame, @props.playFrameDuration

      autoStopDelay = @props.subject.locations.length * @props.playFrameDuration * @props.playIterations
      @_autoStop = setTimeout @setPlaying.bind(this, false), autoStopDelay
    else
      clearInterval @_playingInterval
      clearTimeout @_autoStop

  nextFrame: ->
    @handleFrameChange (@state.frame + 1) %% @props.subject.locations.length

  handleFrameChange: (frame) ->
    @setState {frame}
    @props.onFrameChange frame

  showMetadata: ->
    # TODO: Sticky popup.
    alert <div className="content-container">
      <header className="form-label" style={textAlign: 'center'}>Subject metadata</header>
      <hr />
      <table className="standard-table">
        <tbody>
          {for key, value of @props.subject?.metadata when key.charAt(0) isnt '#' and key[...2] isnt '//'
            <tr key={key}>
              <th>{key}</th>
              <Markdown tag="td" content={value} inline />
            </tr>}
        </tbody>
      </table>
    </div>

  playVideo: (frame, playing) ->
    player = @refs['videoPlayer'+frame]
    return unless player?
    videoStates = @state.videoStates
    videoStates[frame] = videoStates[frame] || {}
    videoStates[frame].playing = playing
    @setState {videoStates}
    if playing
      player.play()
    else
      player.pause()

  setPlayRate: (e, frame) ->
    # Yeah, updating arrays in @state is hard... this method is potentially open to race-conditions but currently in practice it's not a problem
    videoStates = @state.videoStates
    videoStates[frame] = videoStates[frame] || {}
    videoStates[frame].playbackRate = parseFloat e.currentTarget.value
    @setState {videoStates}

  seekVideo: (frame) ->
    player = @refs['videoPlayer'+frame]
    scrubber = @refs['videoScrubber'+frame]
    time = scrubber.value
    player.currentTime = time

  endVideo: (frame) ->
    videoStates = @state.videoStates
    videoStates[frame] = videoStates[frame] || {}
    videoStates[frame].playing = false
    @setState {videoStates}

  updateScrubber: (frame) ->
    player = @refs['videoPlayer'+frame]
    scrubber = @refs['videoScrubber'+frame]
    scrubber.setAttribute 'max', player.duration unless scrubber.getAttribute 'max'
    scrubber.value = player.currentTime

  handleLoad: (e) ->
    frameDimensions = @state.frameDimensions
    frameDimensions[e.target.src] =
      width: e.target.naturalWidth
      height: e.target.naturalHeight

    @setState
      loading: false
      frameDimensions: frameDimensions

    @props.onLoad? arguments...
