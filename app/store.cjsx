{createStore} = require 'redux'

counter = (store = 0, action) ->
  switch (action.type) 
    when 'INCREMENT'
      store + 1
    when 'DECREMENT'
      store - 1
    else
      store

store = createStore(counter)

store.subscribe(=> console.log(store.getState()))

store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'DECREMENT'})

module?.exports = store
