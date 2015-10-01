{dispatch} = require './store'

module?.exports = 
  get: (action) ->
    (dispatch) ->
      talkClient.type('boards').get(section: 'zooniverse')
        .then (boards) =>
          dispatch({type: 'BOARDS', boards})

  post: (action) ->

  patch: (action) ->

  delete: (action) ->
