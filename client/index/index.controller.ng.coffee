'use strict'

angular.module 'applicationFormt'
# .filter 'keyboardShortcut', ($window) ->
#     return (str) ->
#       return unless str
#       keys = str.split('-')
#       isOSX = /Mac OS X/.test($window.navigator.userAgent)
#       seperator = (!isOSX || keys.length > 2) ? '+' : ''
#       abbreviations = {
#         M: isOSX ? '⌘' : 'Ctrl'
#         A: isOSX ? 'Option' : 'Alt'
#         S: 'Shift'
#       }
#       return keys.map( (key, index) ->
#         last = index == keys.length - 1;
#         return last ? key : abbreviations[key]
#       ).join(seperator)

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

  @essayQuestions = [
    'Does the current refugee crisis demonstrate the failure or the success of dealing with the right to asylum at a European level?'
    'Is it feasible and desirable for the European Union to rely exclusively on the use of renewable energy?'
    'Is the process of European Integration driven by ideology or practical considerations? Discuss.'
  ]

  @Roles =
    None: "-1"
    MEP: "0"
    Minister: "1"
    Journalist: "2"
    JournalistMedia: "3"
    Lobbyist: "4"
    Interpreter: "5"

  # titles for the Roles object
  @roles = [
    'Member of the Parliament (MEP)'
    'Minister'
    'Print Journalist'
    'Photo/Video Journalist'
    'Lobbyist'
    'Interpreter'
  ]
  @motivationMaxWords = Meteor.settings.public.application.textsize.motivationletter
  @essayMaxWords = Meteor.settings.public.application.textsize.essay

  @needMotivation0 = true
  @needMotivation1 = false
  @needEssay = true
  $scope.$watch =>
    @model.role
  , (role) =>
    @needMotivation0 = _.contains [@Roles.MEP, @Roles.Minister, @Roles.Lobbyist], @model.role[0]
    @needMotivation1 = _.contains [@Roles.MEP, @Roles.Minister, @Roles.Lobbyist], @model.role[1]
    @needEssay = @needMotivation0 or @needMotivation1

    if role[0] is @Roles.Interpreter
      @motivationUpload = true
      @model.role[1] = @Roles.None
    else
      @motivationMaxWords = 250
      @motivationUpload = false
  , true # objectEquality

  @model = $localStorage.model ||= {}
  @model.role ||= []
  @model.birthdate = if @model.birthdate? then new Date(@model.birthdate) else undefined

  @mFiles = []

  @addFiles = (files) ->
    for file in files
      mFile = new MeteorFile file
      mFile.read file, (error, res) =>
        throw error if error
        @mFiles.push mFile

  @isSaving = false

  @reset = ->
    @mFiles = []
    $localStorage.$reset()
    @model = $localStorage.model ||= {}
    @model.role ||= []

  @submit = () ->
    # cleanup input data
    unless @needMotivation0
      @model.motivation0 = ''
    unless @needMotivation1
      @model.motivation1 = ''
    unless @needEssay
      @model.essay = ''

    @isSaving = true

    $meteor.call 'submit', _.extend {files: @mFiles}, angular.copy(@model)
    .then =>
      @reset()
    , (err) =>
      console.log "couldn't submit: ", err
      $mdDialog.show(
        $mdDialog.alert()
        # .parent(angular.element(document.querySelector('#popupContainer')))
        .clickOutsideToClose(true)
        .title('Error')
        .textContent(err.message)
        .ariaLabel('Error Dialog')
        .ok('Close')
        # .targetEvent(ev)
      ).then =>
        @isSaving = false


  return
