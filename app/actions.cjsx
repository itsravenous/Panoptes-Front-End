{dispatch} = require './store'
talk = require './api/talk'
api = require './api/client'

client = (clientName) ->
  switch clientName
    when 'api' then api
    when 'talk' then talk
    else
      throw new Error("Client must be one of: ['talk', 'api']")

module?.exports =
  get: (action) ->
    (dispatch) ->
      [clientName, resource] = action.type.split('/')

      client(clientName).type(resource).get(action.params)
        .then (response) ->

          resourcesObj = response.reduce((resourcesObj, resource) =>
            resourcesObj[resource.id] = resource
            resourcesObj['meta'] = resource.getMeta()
            resourcesObj['current'] = resourcesObj['current'].concat(resource.id)
            resourcesObj
          , {current: []})

          # console.log "resourcesObj", resourcesObj

          dispatch({type: resource, "#{resource}": resourcesObj})

  post: (action) ->

  patch: (action) ->

  delete: (action) ->
