React = require 'react'
window.React = React
React.initializeTouchEvents true
{Provider} = require 'react-redux'

Router = require '@edpaget/react-router'

routes = require './router'
mainContainer = document.createElement 'div'
mainContainer.id = 'panoptes-main-container'
document.body.appendChild mainContainer

store = require './store'

if process.env.NON_ROOT isnt 'true' and location.hash isnt ""
  location.pathname = location.hash.slice(1)

Router.run routes, Router.HistoryLocation, (Handler, routerState) =>
  window.dispatchEvent new CustomEvent 'locationchange'
  React.render(
    <Provider store={store}>
      {=> <Handler {...routerState} />}
    </Provider>,
  mainContainer)

logDeployedCommit = require './lib/log-deployed-commit'
logDeployedCommit()
