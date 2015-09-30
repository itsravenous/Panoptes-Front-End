module?.exports =
  count: (store = 0, action) ->
    switch (action.type)
      when 'INCREMENT'
        store + 1
      when 'DECREMENT'
        store - 1
      else
        store

  boardz: (store = [], action) ->
    switch (action.type)
      when 'BOARDZ'
        [{id: 1, name: 'test boardz'}]
      else
        store
