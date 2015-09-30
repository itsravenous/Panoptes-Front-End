{createStore, combineReducers} = require 'redux'

reducers = require './reducers'

store = createStore(combineReducers(reducers))

store.subscribe(=> console.log(store.getState()))

store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'DECREMENT'})

module?.exports = window.store = store
