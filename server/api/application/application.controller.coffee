###*
Using Rails-like standard naming convention for endpoints.
GET     /things              ->  index
POST    /things              ->  create
GET     /things/:id          ->  show
PUT     /things/:id          ->  update
DELETE  /things/:id          ->  destroy
###

'use strict'

_ = require 'lodash'
config = require '../../config/environment'

Charlatan = require 'Charlatan'
fs = require 'fs'
path = require 'path'
nodemailer = require 'nodemailer'
stubTransport = require 'nodemailer-stub-transport'

# setup mail
transporter = if process.env.SMTP_HOST?
  nodemailer.createTransport
    # service: 'Mailjet'
    host: process.env.SMTP_HOST
    port: process.env.SMTP_PORT
    auth:
      user: process.env.SMTP_USER
      pass: process.env.SMTP_PASS
  ,
    from: 'MEUS Application 2016 <noreply@meu-strasbourg.org>'
else
  nodemailer.createTransport stubTransport()


applicationDirectory = process.env.APPLICATION_DIR || "/tmp/applications/"

maximumTotalAttachmentSize = config.public.application.maximumTotalAttachmentSizeMB*1024*1024

hideFields = [
  'phone'
  'email'
  'firstname'
  'lastname'
  'role'
]


# http://jsfiddle.net/deepumohanp/jZeKu/
regex = /\s+/gi
wordCount = (value) ->
  trimmed = value.trim()
  return 0 if trimmed.length is 0
  return trimmed.replace(regex, ' ').split(' ').length

# Get list of things
exports.create = (req, res) ->
  req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
    #
  req.busboy.on 'field', (key, value, keyTruncated, valueTruncated) ->
    #

  req.pipe req.busboy
