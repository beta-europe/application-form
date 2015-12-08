'use strict'

angular.module 'applicationFormt'
.controller 'LoginCtrl', ($meteor, $state) ->
  vm = this
  vm.credentials =
    email: ''
    password: ''
  vm.error = ''

  vm.login = ->
    $meteor.loginWithPassword(vm.credentials.email, vm.credentials.password).then ->
      $state.go 'index'
      return
    , (err) ->
      vm.error = 'Login error - ' + err
      return
    return

  return
