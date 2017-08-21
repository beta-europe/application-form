###*
Main application routes
###

'use strict'

errors = require './components/errors'
path = require 'path'

config = require './config/environment'

passport = require 'passport'
passportDiscourse = require('passport-discourse').Strategy
session = require 'express-session'
MemoryStore = require('session-memory-store')(session)

flash = require('connect-flash')()

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)

module.exports = (app) ->
  app.use session
    name: 'JSESSION'
    secret: 'wasdunichtweisstmachtdichnichtheiss' # session secret
    resave: false
    saveUninitialized: true
    store: new MemoryStore({})
  app.use flash
  app.use passport.initialize()
  app.use passport.session()

  # Insert routes below
  app.use '/api/application', require './api/application'

  # Insert Authentication
  # http://passportjs.org/docs/configure
  if config.auth.discourse_sso.enabled
    app.get '/auth/discourse_sso', passport.authenticate 'discourse',
    app.get passportDiscourse.route_callback, passport.authenticate 'discourse',
      session: true
      successRedirect: config.domain + '/form',
      failureRedirect: config.domain + '/'

    auth_discourse = new passportDiscourse
      secret: config.discourse.sso_secret # my secret
      discourse_url: config.discourse.url # https://forum.beta-europe.org
      debug: config.auth.discourse_sso.debug
    , (accessToken, refreshToken, profile, done) ->
      done null, profile
      console.log profile
    passport.use auth_discourse

  ensureAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
      return next()
    else
      res.redirect '/auth/discourse_sso'

  app.get '/form', ensureAuthenticated, (req, res) ->
    res.sendFile path.resolve(app.get('appPath') + '/index.html')


  # All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*').get errors[404]

  # All other routes should redirect to the index.html
  app.route('/*').get (req, res) ->
    res.sendFile path.resolve(app.get('appPath') + '/index.html')
