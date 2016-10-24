'use strict'

angular.module 'applicationFormApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'frame',
    url: '',
    abstract: true,
    templateUrl: 'app/frame/frame.html'
    controller: 'FrameCtrl'
    controllerAs: 'ctrl'
