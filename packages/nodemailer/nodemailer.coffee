NodemailerAsync = Npm.require 'nodemailer'

NodemailerStubTransport = Npm.require 'nodemailer-stub-transport'

Nodemailer = {}

Nodemailer.createTransport = (args...) ->
  transporter = NodemailerAsync.createTransport(args...)
  transporter.sendMail = Meteor.wrapAsync transporter.sendMail, transporter
  transporter
