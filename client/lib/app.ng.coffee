angular.module 'applicationFormt', [
  'angular-meteor'
  'ui.router'
  'ngMaterial'
  'ngMessages'
  'ngMdIcons'
  'ngStorage'
  'ngFileUpload'
]

onReady = () ->
  angular.bootstrap document, ['applicationFormt']

if Meteor.isCordova
  angular.element(document).on 'deviceready', onReady
else
  angular.element(document).ready onReady
