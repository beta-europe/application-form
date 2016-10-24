'use strict'

angular.module 'applicationFormApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'guide',
    url: '/guide',
    templateUrl: 'app/guide/guide.html'
    controller: 'GuideCtrl'
    controllerAs: 'ctrl'
