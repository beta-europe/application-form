NodemailerAsync = Npm.require 'nodemailer'

Nodemailer = {}

Nodemailer.createTransport = (args...) ->
  transporter = NodemailerAsync.createTransport(args...)
  transporter.sendMail = Meteor.wrapAsync transporter.sendMail, transporter
  transporter
