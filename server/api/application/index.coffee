'use strict'

express = require 'express'
controller = require './application.controller'

router = express.Router()

router.post '/', controller.create


module.exports = router
