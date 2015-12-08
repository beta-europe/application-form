'use strict'

angular.module 'applicationFormt'

.config ($urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode Meteor.settings.public.html5LocationMode
  $urlRouterProvider.otherwise '/'
