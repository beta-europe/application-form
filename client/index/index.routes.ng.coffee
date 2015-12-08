'use strict'

angular.module 'applicationFormt'
.config ($stateProvider) ->
  $stateProvider
  .state 'index',
    url: '/'
    templateUrl: 'client/index/index.view.html'
    controller: 'IndexCtrl'
    controllerAs: 'ctrl'
