###*
Main application routes
###

'use strict'

errors = require './components/errors'
path = require 'path'

passport = require 'passport'
passportDiscourse = require('passport-discourse').Strategy
session = require 'express-session'
config = require './config/environment'


module.exports = (app) ->

  # Insert routes below
  app.use '/api/application', require './api/application'

  # Insert Authentication
  # app.use '/auth', require './auth'

  app.use session
    secret: 'wasdunichtweisstmachtdichnichtheiss' # session secret
    saveUninitialized: true
    resave: false
  app.use passport.initialize()
  app.use passport.session()

  app.get '/auth/discourse_sso', passport.authenticate 'discourse'
  app.get passportDiscourse.route_callback, passport.authenticate 'discourse',
    successRedirect: '/assets/images/logo.png',
    failureRedirect: '/assets/images/beta-logo-small.png'

  if config.auth.discourse_sso.enabled
    auth_discourse = new passportDiscourse
      secret: config.auth.discourse_sso.discourse_secret # my secret
      discourse_url: config.auth.discourse_sso.discourse_url # https://forum.beta-europe.org
      debug: config.auth.discourse_sso.debug
    , (accessToken, refreshToken, profile, done) ->
      usedAuthentication 'discourse'
      done null, profile
    passport.use auth_discourse


  # All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*').get errors[404]

  # All other routes should redirect to the index.html
  app.route('/*').get (req, res) ->
    res.sendFile path.resolve(app.get('appPath') + '/index.html')
