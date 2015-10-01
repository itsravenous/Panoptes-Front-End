{dispatch} = require './store'

module?.exports = 
  get: (action) ->
    (dispatch) ->
      talkClient.type(action.type).get(action.params)
        .then (resources) =>
          dispatch({type: action.type, "#{action.type}": resources})

  post: (action) ->

  patch: (action) ->

  delete: (action) ->
