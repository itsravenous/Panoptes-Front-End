module?.exports =
  boards: (store = {}, action) ->
    switch (action.type)
      when 'boards'
        Object.assign {}, store, action.boards
      else
        store

  subjects: (store = {}, action) ->
    switch (action.type)
      when 'subjects'
        Object.assign {}, store, action.subjects
      else
        store

  comments: (store = {}, action) ->
    switch (action.type)
      when 'comments'
        Object.assign {}, store, action.comments
      else
        store

  discussions: (store = {}, action) ->
    switch (action.type)
      when 'discussions'
        Object.assign {}, store, action.discussions
      else
        store

