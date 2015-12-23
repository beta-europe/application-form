'use strict'

express = require 'express'
controller = require './application.controller'

router = express.Router()

router.get '/', controller.index


module.exports = router
