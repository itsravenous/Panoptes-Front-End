module?.exports =
  count: (store = 0, action) ->
    switch (action.type)
      when 'INCREMENT'
        store + 1
      when 'DECREMENT'
        store - 1
      else
        store

  boards: (store = [], action) ->
    switch (action.type)
      when 'BOARDS'
        action.boards
      else
        store
