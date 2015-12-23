'use strict'

express = require 'express'
controller = require './thing.controller'

router = express.Router()

router.get '/', controller.index


module.exports = router