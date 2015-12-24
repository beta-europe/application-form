'use strict'

express = require 'express'
controller = require './application.controller'

router = express.Router()

config = require '../../config/environment'
multer = require 'multer'
upload = multer
  # dest: '/home/europe/tmp'
  limits:
    fileSize: 1024 * 1024 * config.public.application.maximumTotalAttachmentSizeMB

router.post '/', upload.any(), controller.create


module.exports = router
