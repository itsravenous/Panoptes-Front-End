module?.exports =
  count: (store = 0, action) ->
    switch (action.type)
      when 'INCREMENT'
        store + 1
      when 'DECREMENT'
        store - 1
      else
        store

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

