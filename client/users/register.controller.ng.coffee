'use strict'

angular.module 'applicationFormt'
.controller 'RegisterCtrl',  ($meteor, $state) ->
  vm = this
  vm.credentials =
    email: ''
    password: ''
  vm.error = ''

  vm.register = ->
    $meteor.createUser(vm.credentials).then ->
      $state.go 'index'
      return
    , (err) ->
      vm.error = 'Registration error - ' + err
      return
    return

  return
