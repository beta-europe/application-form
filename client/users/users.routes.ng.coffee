'use strict'

angular.module 'applicationFormt'
.config ($stateProvider) ->
  $stateProvider
  .state 'login',
    url: '/login'
    templateUrl: 'client/users/login.view.html'
    controller: 'LoginCtrl'
    controllerAs: 'lc'
  .state 'register',
    url: '/register'
    templateUrl: 'client/users/register.view.html'
    controller: 'RegisterCtrl'
    controllerAs: 'rc'
  .state 'resetpw',
    url: '/resetpw'
    templateUrl: 'client/users/reset-password.view.html'
    controller: 'ResetCtrl'
    controllerAs: 'rpc'
  .state 'logout',
      url: '/logout'
      resolve:
        "logout": ($meteor, $state) ->
          $meteor.logout().then ->
            $state.go 'index'
          , (err) ->
            console.log 'logout error - ', err

.run ($rootScope, $state) ->
  $rootScope.$on "$stateChangeError", (event, toState, toParams, fromState, fromParams, error) ->
    # We can catch the error thrown when the $meteor.requireUser() promise is rejected
    # and redirect the user back to the login page
    if error is "AUTH_REQUIRED"
      # It is better to use $state instead of $location. See Issue #283.
      $state.go 'login'
