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

CSVWriter = require('csv-write-stream')
csvWriter = CSVWriter
  sendHeaders: false
  headers: [
    'birthdate'
    'firstname'
    'lastname'
    'residency'
    'needvisa'
    'email'
    'phone'
    'gender'
    'idtype'
    'idnumber'
    'confirmTerms'
    'nationality'
    'pseudo'
    'submitted'
    'motivationWordCount'
    'essayWordCount'
    'role'
    'workshopsEntered'
    'directory'
  ]

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
    from: 'BETA Symposium Application 2016 <no-reply@forum.beta-europe.org>'
else
  nodemailer.createTransport stubTransport()


applicationDirectory = process.env.APPLICATION_DIR || "/tmp/applications/"

maximumTotalAttachmentSize = config.public.application.maximumTotalAttachmentSizeMB*1024*1024

hideFields = [
  'role' # we already have roleNames
  'workshopsEntered'
  # 'firstname'
  # 'lastname'
  # 'nationality'
  # 'residency'
  # 'birthdate'
  # 'idtype'
  # 'idnumber'
  # 'phone'
  # 'email'
  # 'gender'
]

hideFieldsCSV = [
  'role'
  'roleNames'
  'motivation'
  'essay'
  'fileNames'
  'workshops'
  'workshop_proposal'
]


dataToFileSync = (file, data) ->
  fd = fs.openSync file, 'w'
  fs.writeSync fd, data
  fs.closeSync fd

bufferToFileSync = (file, buffer) ->
  fd = fs.openSync file, 'w'
  fs.writeSync fd, buffer, 0, buffer.length
  fs.closeSync fd

dataToCSV = (file, data) ->
  stream = fs.createWriteStream file,
    flags: 'a' # append
  # csvWriter = CSVWriter()
  csvWriter.pipe stream
  csvWriter.write data
  csvWriter.unpipe stream
  stream.end()
  # csvWriter.end()

# http://jsfiddle.net/deepumohanp/jZeKu/
regex = /\s+/gi
wordCount = (value) ->
  trimmed = value.trim()
  return 0 if trimmed.length is 0
  return trimmed.replace(regex, ' ').split(' ').length

# Get list of things
exports.create = (req, res) ->
  # unless req.files instanceof Array and req.files.length > 0
  #   return res.status(400).send 'Please attach files to your application.'

  data = req.body.data
  unless data?
    return res.status(400).send 'Please provide application data.'

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

  for file in req.files
    file.originalname = file.originalname.replace /\s/g, '_'

  data.files = _.map req.files, (file) ->
    file.originalname
  data.fileNames = _.map req.files, (file) ->
    console.log file
    "http://meukyiv.apply.beta-europe.org#{path.join('/files/applications/', ".#{pseudo}", file.originalname)}"

  # convert role IDs to names
  data.roleName = config.public.application.roles[data.role]
  data.submitted = new Date()
  data.motivationWordCount = wordCount(data.motivation)
  data.essayWordCount = wordCount(data.essay)

  data.workshopsEntered = []
  if data.workshops
    _.merge data.workshopsEntered, _.keys(data.workshops)
  if data.workshop_proposal
    data.workshopsEntered.push "own: #{data.workshop_proposal}"
  data.workshopsEntered = data.workshopsEntered.join(' ')

  # save files
  fs.mkdirSync directory
  dataToFileSync path.join(directory, 'data.json'), JSON.stringify(data, null, 2)
  # dataToFileSync path.join(directory, 'data.json'), JSON.stringify(_.omit(data,hideFields), null, 2)
  dataToCSV path.join(applicationDirectory, 'applications.csv.private'), _.merge(_.omit(data, hideFieldsCSV), {role: data.roleName, directory: "http://meukyiv.apply.beta-europe.org/files/applications/.#{pseudo}"})
  for file in req.files
    saveTo = path.join directory, file.originalname
    bufferToFileSync saveTo, file.buffer

  strippedData = _.omit(data,hideFields,['motivation', 'essay', 'roleNames', 'fileNames', 'files'])

  mail =
    from: "BETA Symposium Application 2016 <#{config.mail.applicationSender}>"
    subject: "BETA Symposium Application 2016: #{data.firstname} #{data.lastname}"
    to: config.mail.applicationReceiver
    text: """
          Application From: #{data.firstname} #{data.lastname} (<#{data.email}>)

          Application-Identifier (Pseudo): #{data.pseudo}

          Role: #{data.roleName}

          ### Form Data

          ```json
          #{JSON.stringify(strippedData, null, 2)}
          ```

          Application Data Folder: http://symposium.apply.beta-europe.org#{path.join('/files/applications/', ".#{pseudo}")}

          ### Motivation (#{data['motivationWordCount']} words)

          #{data['motivation']}

          ### Experiences (#{data['essayWordCount']} words)

          #{data['essay']}
          """
    # attachments: _.map files, (file) ->
    #   filename: file.originalname
    #   content: new Buffer(file.data)
    #   type: file.contentType

  transporter.sendMail mail, (err, info) ->
    throw new Error(err) if err?
    console.log "Mail status: id #{info.messageId} to #{info.envelope.to.join(' ')}: #{info.response.toString()}"

    unless config.env is 'production'
      dataToFileSync path.join(directory, 'mail.eml'), info.response.toString()

    confirmationMail =
      from: "BETA Symposium Application 2016 <#{config.mail.fromNoreply}>"
      subject: "BETA Symposium Application 2016 Confirmation"
      to: "\"#{data.firstname} #{data.lastname}\" <#{data.email}>"
      text: """
            Dear #{data.firstname}!

            This message is just to let you know that we received your application.

            / The BETA Symposium Team
            """
      attachments: [
        filename: "application-data.txt",
        content: JSON.stringify(_.omit(data,['fileNames']), null, 2)
        type: "text/plain"
      ]

    transporter.sendMail confirmationMail, (err, info) ->
      throw new Error(err) if err?
      console.log "Mail Confirmation status: id #{info.messageId} to #{info.envelope.to.join(' ')}: #{info.response.toString()}"

      res.json _.pick data, 'pseudo'
