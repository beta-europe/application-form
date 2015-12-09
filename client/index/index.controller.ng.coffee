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

.config (ipnConfig) ->
    # ipnConfig.defaultCountry = 'fr'
    # ipnConfig.preferredCountries = ['de', 'fr', 'uk', 'es']
    ipnConfig.defaultCountry = ''
    ipnConfig.preferredCountries = []

.config ($mdThemingProvider) ->
    # Configure a dark theme with primary foreground yellow
    $mdThemingProvider.theme('docs-dark', 'default')
      .primaryPalette('orange')
      .dark()

.controller 'IndexCtrl', ($meteor, $mdDialog, $scope, $localStorage) ->

  @showAlert = (event) ->
    $mdDialog.show(
      $mdDialog.alert()
        .parent angular.element(document.body)
        .clickOutsideToClose(true)
        .title('Attention! Beta-Software.')
        .textContent('By accident, you have found the work-in-progress formular. Do not use it for a real application.')
        .ariaLabel('Alert Dialog Do not use this forumlar. It is work-in-progress.')
        .ok("I promise I won't use it. Let me see.")
        .targetEvent(event)
  )

  @showAlert() unless Meteor.absoluteUrl().match /localhost/


  # validation
  @conferenceStart = new Date(Meteor.settings.public.conference.dates.start)
  # @conferenceEnd = new Date(Meteor.settings.conference.dates.end)
  @birthMin = new Date(@conferenceStart)
  @birthMin.setYear(@birthMin.getYear()-Meteor.settings.public.application.criteria.age.min)
  console.log "birthMin", @birthMin
  @birthMax = new Date(@conferenceStart)
  @birthMax.setYear(@birthMax.getYear()-Meteor.settings.public.application.criteria.age.max-1)
  console.log "birthMax", @birthMax

  @genders = [
    'female'
    'male'
    'other / prefer not to say'
  ]
  @idtypes = [
    'National ID'
    'Passport'
  ]
  @degrees = [
    'high school'
    'undergraduate'
    'masters graduate'
    'Ph.D.'
    'other / prefer not to say'
  ]
  @studyyears = ("#{i} year(s)" for i in [0...8])

  @languagelevels = [
    'Fluent'
    'Advanced'
    'Intermediate'
    'Beginner'
  ]

  @roles = [
    'Member of the Parliament (MEP)'
    'Minister'
    'Print Journalist'
    'Photo/Video Journalist'
    'Lobbyist'
    'Interpreter'
  ]

  @model = $localStorage.model ||= {}

  return
