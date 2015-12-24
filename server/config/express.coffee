###*
Express configuration
###

'use strict'

express = require 'express'
favicon = require 'serve-favicon'
morgan = require 'morgan'
compression = require 'compression'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
cookieParser = require 'cookie-parser'
errorHandler = require 'errorhandler'
path = require 'path'
mime = require 'mime-types'
config = require './environment'

module.exports = (app) ->
  env = app.get('env')

  app.set 'views', config.root + '/server/views'
  app.engine 'html', require('ejs').renderFile
  app.set 'view engine', 'html'
  app.set 'view engine', 'jade'
  app.use compression()
  app.use bodyParser.urlencoded(extended: false)
  app.use bodyParser.json()
  app.use methodOverride()
  app.use cookieParser()


  if 'production' is env
    app.use favicon(path.join(config.root, 'public', 'favicon.ico'))
    app.use express.static path.join(config.root, 'public'),
      etag: false
      maxAge: '7d'
      setHeaders: (res, path) ->
        if mime.lookup(path) is 'text/html'
          res.set 'Cache-Control', 'public, max-age=0'

    app.set 'appPath', config.root + '/public'
    app.use morgan('dev')

  if 'development' is env or 'test' is env
    app.use require('connect-livereload')()
    app.use express.static(path.join(config.root, '.tmp'))
    app.use express.static(path.join(config.root, 'client'))
    app.set 'appPath', 'client'
    app.use morgan('dev')
    app.use errorHandler() # Error handler - has to be last
