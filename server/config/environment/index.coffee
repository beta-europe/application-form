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
        start: '2016-04-02T00:00:00.000Z'
        end: '2016-04-09T00:00:00.000Z'
    application:
      maximumTotalAttachmentSizeMB: 8
      criteria:
        age:
          min: 18
          max: 26
      textsize:
        essay: 500
        motivationletter: 250
      roles: [
        'Member of the Parliament (MEP)'
        'Minister'
        'Print Journalist'
        'Photo/Video Journalist'
        'Lobbyist'
        'Interpreter'
      ]
  mail:
    fromNoreply: 'noreply@meu-strasbourg.org'
    applicationSender: 'meus@beta-europe.org'
    applicationReceiver: 'forum-meus-apply-2016@beta-europe.org'



# Export the config object based on the NODE_ENV
# ==============================================
module.exports = _.merge(all, require('./' + process.env.NODE_ENV) or {})
