'use strict'

angular.module 'applicationFormApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'frame.welcome',
    url: '/welcome',
    templateUrl: 'app/welcome/welcome.html'
    controller: 'WelcomeCtrl'
    controllerAs: 'ctrl'
