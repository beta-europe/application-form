'use strict'

angular.module 'applicationFormt'
.filter 'keyboardShortcut', ($window) ->
    return (str) ->
      return unless str
      keys = str.split('-')
      isOSX = /Mac OS X/.test($window.navigator.userAgent)
      seperator = (!isOSX || keys.length > 2) ? '+' : ''
      abbreviations = {
        M: isOSX ? '⌘' : 'Ctrl'
        A: isOSX ? 'Option' : 'Alt'
        S: 'Shift'
      }
      return keys.map( (key, index) ->
        last = index == keys.length - 1;
        return last ? key : abbreviations[key]
      ).join(seperator)


.config ($mdThemingProvider) ->
    # Configure a dark theme with primary foreground yellow
    $mdThemingProvider.theme('docs-dark', 'default')
      .primaryPalette('orange')
      .dark()

.controller 'IndexCtrl', ($meteor, $mdDialog, $scope) ->

  @settings =
    printLayout: true
    showRuler: true
    showSpellingSuggestions: true
    presentationMode: 'edit'

  @model =
    title: 'Developer'
    email: 'ipsum@lorem.com'
    firstName: ''
    lastName: ''
    phone: ''
    affiliation: 'Google',
    address: '1600 Amphitheatre Pkwy'
    city: 'Mountain View'
    biography: 'da geht was'
    postalCode: '94043'

  @sampleAction = (name, ev) ->
    $mdDialog.show($mdDialog.alert()
      .title(name)
      .textContent('You triggered the "' + name + '" action')
      .ok('Great')
      .targetEvent(ev)
    )

  return
