{createStore, combineReducers, applyMiddleware} = require 'redux'
thunk = require 'redux-thunk'
reducers = require './reducers'

createStoreWithMiddleware = applyMiddleware(thunk)(createStore)

store = createStoreWithMiddleware(combineReducers(reducers))

store.subscribe(=> console.log(store.getState()))

store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'INCREMENT'})
store.dispatch({type: 'DECREMENT'})

module?.exports = window.store = store
