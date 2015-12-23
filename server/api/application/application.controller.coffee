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

Charlatan = require 'charlatan'
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


dataToFileSync = (file, data) ->
  fd = fs.openSync file, 'w'
  fs.writeSync fd, data
  fs.closeSync fd

bufferToFileSync = (file, buffer) ->
  fd = fs.openSync file, 'w'
  fs.writeSync fd, buffer, 0, buffer.length
  fs.closeSync fd

# http://jsfiddle.net/deepumohanp/jZeKu/
regex = /\s+/gi
wordCount = (value) ->
  trimmed = value.trim()
  return 0 if trimmed.length is 0
  return trimmed.replace(regex, ' ').split(' ').length

# Get list of things
exports.create = (req, res) ->
  unless req.files instanceof Array and req.files.length > 0
    throw new Error("Please attach files to your application.")

  data = req.body.data

  # find pseudo
  pseudo = ""
  directory = ""
  loop
    pseudo = _.times(2,Charlatan.Name.lastName).join(' ').replace(/\s/g, "-")
    directory   = path.join applicationDirectory, ".#{pseudo}"
    try
      fs.statSync directory # supposed to throw if there is no directory
    catch error
      if error.code is 'ENOENT'
        break

  console.log "pseudo", pseudo
  data.pseudo = pseudo
  data.files = _.map req.files, (file) ->
    file.originalname
  data.fileNames = _.map req.files, (file) ->
    console.log file
    "http://apply.meu-strasbourg.org#{path.join('/files/applications/', ".#{pseudo}", file.originalname)}"

  # convert role IDs to names
  data.roleNames = _.map data.role, (role) ->
    config.public.application.roles[role]
  data.submitted = new Date()
  data.motivation0WordCount = wordCount(data.motivation0)
  data.motivation1WordCount = wordCount(data.motivation1)
  data.essayWordCount = wordCount(data.essay)

  # save files
  fs.mkdirSync directory
  dataToFileSync path.join(directory, 'data.json.private'), JSON.stringify(data, null, 2)
  dataToFileSync path.join(directory, 'mail.private'), "#{data.firstname} #{data.lastname} <#{data.email}>"
  dataToFileSync path.join(directory, 'data.json'), JSON.stringify(_.omit(data,hideFields), null, 2)
  for file in req.files
    saveTo = path.join directory, file.originalname
    bufferToFileSync saveTo, file.buffer

  strippedData = _.omit(data,hideFields,['motivation0', 'motivation1', 'essay','essayQuestion','roleNames','fileNames','files'])

  mail =
    from: "MEUS Application 2016 <#{config.mail.fromForumUser}>"
    subject: "MEUS Application 2016: #{pseudo}"
    to: config.mail.toForumCategory
    text: """
          Pseudo: **#{data.pseudo}** [reveil mail](http://apply.meu-strasbourg.org#{path.join('/files/applications/', ".#{pseudo}", "mail.private")})

          Roles: #{data.roleNames.join(', ')}

          ### Form Data

          ```json
          #{JSON.stringify(strippedData, null, 2)}
          ```

          ### Attachments

          - #{data['fileNames'].join('\n- ')}

          Application Data Folder: http://apply.meu-strasbourg.org#{path.join('/files/applications/', ".#{pseudo}")}

          ### Motivation 1 (#{data['motivation0WordCount']} words)

          #{data['motivation0']}


          ### Motivation 2 (#{data['motivation1WordCount']} words)

          #{data['motivation1']}


          ### Essay (#{data['essayWordCount']} words)

          Essay Question:
          > #{data['essayQuestion']}

          #{data['essay']}
          """
    # attachments: _.map files, (file) ->
    #   filename: file.originalname
    #   content: new Buffer(file.data)
    #   type: file.contentType

  transporter.sendMail mail, (err, info) ->
    throw new Error(err) if err?
    console.log "Mail status: id #{info.messageId} to #{info.envelope.to.join(' ')}"


    dataToFileSync path.join(directory, 'mail.eml'), info.response.toString()

    confirmationMail =
      from: "MEUS Application 2016 <#{config.mail.fromNoreply}>"
      subject: "MEUS Application 2016 Confirmation"
      to: "#{data.firstname} #{data.lastname} <#{data.email}>"
      text: """
            Dear #{data.firstname}!

            This message is just to let you know that we received your application.

            / The MEUS IT Dept.
            """
      attachments: [
        filename: "application-data.txt",
        content: JSON.stringify(_.omit(data,['fileNames']), null, 2)
        type: "text/plain"
      ]

    transporter.sendMail confirmationMail, (err, info) ->
      throw new Error(err) if err?
      console.log "Mail Confirmation status: id #{info.messageId} to #{info.envelope.to.join(' ')}"

      res.json _.pick data, 'pseudo'
