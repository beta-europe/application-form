'use strict'

angular.module 'applicationFormt'
.controller 'ResetCtrl', ($meteor, $state) ->
  vm = this
  vm.credentials = email: ''
  vm.error = ''

  vm.reset = ->
    $meteor.forgotPassword(vm.credentials).then ->
      $state.go 'index'
      return
    , (err) ->
      vm.error = 'Error sending forgot password email - ' + err
      return
    return

  return
