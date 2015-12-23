'use strict'

angular.module 'applicationFormApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/',
    templateUrl: 'app/main/main.html'
    controller: 'MainCtrl'
    controllerAs: 'ctrl'
