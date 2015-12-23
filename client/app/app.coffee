'use strict'

angular.module 'applicationFormApp', [
  'ngRoute'
  'ngMaterial'
  'ngMessages'
  'ngMdIcons'
  'ngStorage'
  'ngFileUpload'
]
.config ($routeProvider, $locationProvider) ->
  $routeProvider
  .otherwise
    redirectTo: '/'

  $locationProvider.html5Mode true
