'use strict'

describe 'Directive: wordCount', ->

  # load the directive's module
  beforeEach module 'applicationFormApp'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<word-count></word-count>'
    element = $compile(element) scope
