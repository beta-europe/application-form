'use strict'

angular.module 'applicationFormApp', [
  'ui.router'
  'ngMaterial'
  'ngMessages'
  'ngMdIcons'
  'ngStorage'
  'ngFileUpload'
  'settings'
]
.config ($urlRouterProvider, $locationProvider) ->
  $urlRouterProvider
  .otherwise '/'

  $locationProvider.html5Mode true
