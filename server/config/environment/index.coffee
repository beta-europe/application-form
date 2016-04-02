'use strict'

path = require 'path'
_ = require 'lodash'

requiredProcessEnv = (name) ->
  throw new Error('You must set the ' + name + ' environment variable')  unless process.env[name]
  process.env[name]

# All configurations will extend these options
# ============================================
all =
  env: process.env.NODE_ENV

  # Root path of server
  root: path.normalize(__dirname + '/../../..')

  # Server port
  port: process.env.PORT or 9000

  public:
    conference:
      dates:
        start: '2016-05-12T00:00:00.000Z'
        end: '2016-05-15T00:00:00.000Z'
    application:
      maximumTotalAttachmentSizeMB: 8
      criteria:
        age:
          min: 14
          max: 99
      textsize:
        essay: 100
        motivationletter: 200
      roles: [
        'Organiser Trainee'
        'Expert Organiser'
      ]
  mail:
    fromNoreply: 'no-reply@forum.beta-europe.org'
    applicationSender: 'applications@beta-europe.org'
    applicationReceiver: 'beta-applications@forum.beta-europe.org'



# Export the config object based on the NODE_ENV
# ==============================================
module.exports = _.merge(all, require('./' + process.env.NODE_ENV) or {})
