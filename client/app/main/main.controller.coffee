'use strict'

angular.module 'applicationFormApp'

.config ($mdThemingProvider) ->
    # Configure a dark theme with primary foreground yellow
    $mdThemingProvider.theme('docs-dark', 'default')
      .primaryPalette('orange')
      .dark()

.controller 'MainCtrl', ($mdDialog, $scope, $localStorage, $location, settings, Upload) ->

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

  @showAlert() unless $location.absUrl().match /localhost/


  # validation
  @conferenceStart = new Date(settings.conference.dates.start)
  # @conferenceEnd = new Date(Meteor.settings.conference.dates.end)
  @birthMin = new Date(@conferenceStart)
  @birthMin.setYear(@birthMin.getYear()-settings.application.criteria.age.min)
  console.log "birthMin", @birthMin
  @birthMax = new Date(@conferenceStart)
  @birthMax.setYear(@birthMax.getYear()-settings.application.criteria.age.max-1)
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
  @roles = settings.application.roles

  @motivationMaxWords = settings.application.textsize.motivationletter
  @essayMaxWords = settings.application.textsize.essay
  @maxFileMB = settings.application.maximumTotalAttachmentSizeMB

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


  # size: @maxFileMB*1024*1024

  @files = []

  @removeFile = (event, index) ->
    event.preventDefault()
    @files.splice index, 1

  @isSaving = false

  @print = ->
    window.print()

  @aboutForm = (event) ->
    $mdDialog.show(
      $mdDialog.alert()
        .parent angular.element(document.body)
        .clickOutsideToClose(true)
        .title('About this Form')
        .textContent('This application formulas has been developed by Robert Riemann <robert@riemann.cc>.')
        .ariaLabel('Alert Dialog about form')
        .ok("OK")
        .targetEvent(event)
    )

  @autoFill = (event) ->
    $mdDialog.show(
      $mdDialog.alert()
        .parent angular.element(document.body)
        .clickOutsideToClose(true)
        .title('Auto Fill')
        .textContent('This feature is scheduled for 2100. Until then, you have to fill your application on your own.')
        .ariaLabel('Alert Dialog auto fill easter-egg')
        .ok("OK")
        .targetEvent(event)
    )

  @clear = (event) ->
    $mdDialog.show(
      $mdDialog.confirm()
        .parent angular.element(document.body)
        .clickOutsideToClose(false)
        .title('Clear Formular')
        .textContent('Do you really want to clear the formular?')
        .ariaLabel('Alert Dialog clear forumlar')
        .ok("Yes, clear")
        .cancel("Cancel")
        .targetEvent(event)
    ).then =>
      @reset()

  @reset = ->
    @files = []
    $localStorage.$reset()
    @model = $localStorage.model ||= {}
    @model.role ||= []

  @submit = () ->
    # return false if $scope.userForm.$invalid
    # cleanup input data
    unless @needMotivation0
      @model.motivation0 = ''
    unless @needMotivation1
      @model.motivation1 = ''
    unless @needEssay
      @model.essay = ''

    @isSaving = true

    console.log "about to send", angular.copy(@model), @files

    upload = Upload.upload
      url: '/api/application'
      data:
        data: angular.copy(@model)
        file: @files
      disableProgress: false
      # resumeChunkSize: '10KB'

    upload.then (resp) =>
      console.log "resp", resp
      data = resp.data
      $mdDialog.show(
        $mdDialog.confirm()
        # .parent(angular.element(document.querySelector('#popupContainer')))
        .clickOutsideToClose(true)
        .title('Application Successfully submitted')
        .textContent("Your application was successfully submitted. You will receive as well an email with a confirmation. Your dossier is called #{data.pseudo}.")
        .ariaLabel('Application successfully submitted Dialog')
        .ok('Close')
        # .targetEvent(ev)
      )
      # @reset()
      @isSaving = false
    , (err) =>
      console.log 'catch error', err
      $mdDialog.show(
        $mdDialog.alert()
        # .parent(angular.element(document.querySelector('#popupContainer')))
        .clickOutsideToClose(true)
        .title('Error')
        .textContent(err.message)
        .ariaLabel('Error Dialog')
        .ok('Close')
        # .targetEvent(ev)
      )
    , (event) ->
      console.log event
      console.log('progress: ' + parseInt(100.0 * event.loaded / event.total) + '% file :'+ event.config.data.file.name);

  return
