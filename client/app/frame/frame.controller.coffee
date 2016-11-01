'use strict'

angular.module 'applicationFormApp'

.run ($rootScope, $state, $stateParams) ->
  $rootScope.$state = $state;
  $rootScope.$stateParams = $stateParams;

.controller 'FrameCtrl', ($scope, $location, $state) ->
  return
