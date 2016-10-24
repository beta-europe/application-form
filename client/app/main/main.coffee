'use strict'

angular.module 'applicationFormApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'main',
    url: '/',
    templateUrl: 'app/main/main.html'
    controller: 'MainCtrl'
    controllerAs: 'ctrl'
