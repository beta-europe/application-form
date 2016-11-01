'use strict'

angular.module 'applicationFormApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'frame.guide',
    url: '/',
    templateUrl: 'app/guide/guide.html'
    controller: 'GuideCtrl'
    controllerAs: 'ctrl'
