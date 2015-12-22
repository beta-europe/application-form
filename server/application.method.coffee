'use strict'

fs = Npm.require 'fs'
path = Npm.require 'path'

# setup mail
transporter = if process.env.SMTP_HOST?
  Nodemailer.createTransport
    # service: 'Mailjet'
    host: process.env.SMTP_HOST
    port: process.env.SMTP_PORT
    auth:
      user: process.env.SMTP_USER
      pass: process.env.SMTP_PASS
  ,
    from: 'MEUS Application 2016 <noreply@meu-strasbourg.org>'
else
  Nodemailer.createTransport NodemailerStubTransport()

# setup application directory
applicationDirectory = process.env.APPLICATION_DIR || "/tmp/applications/"

maximumTotalAttachmentSize = Meteor.settings.maximumTotalAttachmentSizeMB*1024*1024

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



# http://jsfiddle.net/deepumohanp/jZeKu/
regex = /\s+/gi
wordCount = (value) ->
  trimmed = value.trim()
  return 0 if trimmed.length is 0
  return trimmed.replace(regex, ' ').split(' ').length

Meteor.methods
  'submit': (data, files) ->

    unless files instanceof Array and files.length > 0
      throw new Meteor.Error(400, "Please attach files to your application.")

    totalAttachmentSize = _.reduce files, (sum, file) ->
      sum += file.size # in byte
    , 0

    if totalAttachmentSize > maximumTotalAttachmentSize
      throw new Meteor.Error(400, "Please reduce the filesize to fit the limit of #{Meteor.settings.maximumTotalAttachmentSizeMB}MiB.")

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
    data.files = _.map files, (file) ->
      file.name
    data.fileNames = _.map files, (file) ->
      "http://apply.meu-strasbourg.org#{path.join('/files/applications/', ".#{pseudo}", file.name)}"
    # convert role IDs to names
    data.roleNames = _.map data.role, (role) ->
      Meteor.settings.public.application.roles[role]
    data.submitted = new Date()
    data.motivation0WordCount = wordCount(data.motivation0)
    data.motivation1WordCount = wordCount(data.motivation1)
    data.essayWordCount = wordCount(data.essay)

    # save files
    fs.mkdirSync directory
    dataToFileSync path.join(directory, 'data.json.private'), JSON.stringify(data, null, 2)
    dataToFileSync path.join(directory, 'mail.private'), "#{data.firstname} #{data.lastname} <#{data.email}>"
    dataToFileSync path.join(directory, 'data.json'), JSON.stringify(_.omit(data,hideFields), null, 2)
    for file in files
      file.save directory

    strippedData = _.omit(data,hideFields,['motivation0', 'motivation1', 'essay','essayQuestion','roleNames','fileNames','files'])

    mail =
      from: "MEUS Application 2016 <#{Meteor.settings.mail.fromForumUser}>"
      subject: "MEUS Application 2016: #{pseudo}"
      to: Meteor.settings.mail.toForumCategory
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
      #   filename: file.name
      #   content: new Buffer(file.data)
      #   type: file.contentType

    info = transporter.sendMail mail
    console.log "Mail status: id #{info.messageId} to #{info.envelope.to.join(' ')}"
    dataToFileSync path.join(directory, 'mail.eml'), info.response.toString()

    confirmationMail =
      from: "MEUS Application 2016 <#{Meteor.settings.mail.fromNoreply}>"
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

    info = transporter.sendMail confirmationMail
    console.log "Mail Confirmation status: id #{info.messageId} to #{info.envelope.to.join(' ')}"

    return _.pick data, 'pseudo'
