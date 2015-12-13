'use strict'

Meteor.methods
  'submit': (data) ->
    console.log 'in submit', data
    for file in data.files
      console.log file.name
      # file.save(path)
