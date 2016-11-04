'use strict'

# Use local.env.js for environment variables that grunt will set when the server starts locally.
# Use for your api keys, secrets, etc. This file should not be tracked by git.
#
# You will need to set these on the server you deploy to.

module.exports =
  DOMAIN: 'http://127.0.0.1:9000'
  DISCOURSE_API_KEY: "b7bfc37dd0a4240478975fb4511658708e0363e97e6c5be746ec5c6531b95a33"
  DISCOURSE_API_USER: "system"
  DISCOURSE_GROUP: "66" # group id where to put applicants in
  DISCOURSE_SECRET: "HMAC-SHA256signaturefrom"
  DISCOURSE_CATEGORY: "6" # category id for meus/applications-2017
  DISCOURSE_PMGROUP: "MEUS-Marker-Admins" # group to send PM with full data

  # Control debug level for modules using visionmedia/debug
  DEBUG: ''
