'use strict'

Meteor.methods
  'submit': (files) ->
    ff = for file in files
      buffer = new Buffer(file)
    console.log ff
