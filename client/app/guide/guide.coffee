'use strict'

angular.module 'applicationFormApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/guide',
    templateUrl: 'app/guide/guide.html'
    controller: 'GuideCtrl'
    controllerAs: 'ctrl'
