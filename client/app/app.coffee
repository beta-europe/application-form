'use strict'

angular.module 'applicationFormApp', [
  'ngRoute'
  'ngMaterial'
  'ngMessages'
  'ngMdIcons'
  'ngStorage'
  'ngFileUpload'
  'settings'
]
.config ($routeProvider, $locationProvider) ->
  $routeProvider
  .otherwise
    redirectTo: '/'

  $locationProvider.html5Mode true
