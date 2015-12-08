'use strict'

angular.module 'applicationFormt'
.directive 'toolbar', ->
  restrict: 'AE'
  templateUrl: 'client/components/directives/toolbar.view.html'
  replace: true
