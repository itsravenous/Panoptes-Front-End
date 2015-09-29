counterpart = require 'counterpart'
React = require 'react'
{Link} = require '@edpaget/react-router'
ZooniverseLogo = require './zooniverse-logo'
Translate = require 'react-translate-component'
LoadingIndicator = require '../components/loading-indicator'
AccountBar = require './account-bar'
LoginBar = require './login-bar'
PromiseToSetState = require '../lib/promise-to-set-state'
auth = require '../api/auth'
isAdmin = require '../lib/is-admin'

counterpart.registerTranslations 'en',
  mainNav:
    home: 'Home'
    projects: 'Projects'
    about: 'About'
    collect: 'Collect'
    talk: 'Talk'
    daily: 'Daily Zooniverse'
    blog: 'Blog'
    lab: 'Build a project'
    admin: 'Admin'

module.exports = React.createClass
  displayName: 'MainHeader'

  getDefaultProps: ->
    user: null

  render: ->
    <header className="main-header">
      <div className="main-title" ref="mainTitle">
        <Link to="home" className="main-logo">
          <ZooniverseLogo />
        </Link>
      </div>

      <nav className="main-nav">
        <Link to="projects" className="main-nav-item">
          <Translate content="mainNav.projects" />
        </Link>
        <Link to="about" className="main-nav-item">
          <Translate content="mainNav.about" />
        </Link>
        <Link to="talk" className="main-nav-item">
          <Translate content="mainNav.talk" />
        </Link>
        <Link to="collections" className="main-nav-item">
          <Translate content="mainNav.collect" />
        </Link>
        <a href="http://daily.zooniverse.org/" className="main-nav-item" target="_blank">
          <Translate content="mainNav.daily" />
        </a>
        <a href="http://blog.zooniverse.org/"  className="main-nav-item" target="_blank">
          <Translate content="mainNav.blog" />
        </a>
        <Link to="lab" className="main-nav-item nav-build">
          <Translate className="minor" content="mainNav.lab" />
        </Link>
        {if isAdmin()
          <Link to="admin" className="main-nav-item nav-build">
            <Translate className="minor" content="mainNav.admin" />
          </Link>}
      </nav>

      <div className="user-info">
        {if @props.user?
          <AccountBar user={@props.user} />
        else
          <LoginBar />}
      </div>
    </header>
