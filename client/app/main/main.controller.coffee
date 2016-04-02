'use strict'

angular.module 'applicationFormApp'

.config ($mdThemingProvider) ->
    # Configure a dark theme with primary foreground yellow
    $mdThemingProvider.theme('docs-dark', 'default')
      .primaryPalette('orange')
      .dark()

.controller 'DialogCtrl', ($scope, $mdDialog, upload) ->
  @upload = upload.promise
  @progress = 0

  @upload.then (resp) =>
    $mdDialog.hide(resp)
    # @reset()
  , (err) =>
    $mdDialog.cancel(err)
  , (event) =>
    @progress = parseInt(100.0 * event.loaded / event.total)

  @abort = ($event) ->
    $event.preventDefault()
    @upload.abort()

  return

.controller 'MainCtrl', ($mdDialog, $scope, $localStorage, $location, settings, Upload) ->
  # @showAlert = (event) ->
  #   $mdDialog.show(
  #     $mdDialog.alert()
  #       .parent angular.element(document.body)
  #       .clickOutsideToClose(true)
  #       .title('Attention!')
  #       .textContent('By accident, you have found the work-in-progress formular. Do not use it for a real application.')
  #       .ariaLabel('Alert Dialog Do not use this forumlar. It is work-in-progress.')
  #       .ok("I promise I won't use it. Let me see.")
  #       .targetEvent(event)
  # )
  #
  # @showAlert() unless $location.absUrl().match /localhost/


  # validation
  @conferenceStart = new Date(settings.conference.dates.start)
  # @conferenceEnd = new Date(Meteor.settings.conference.dates.end)
  @birthMin = new Date(@conferenceStart)
  @birthMin.setYear(@birthMin.getYear()-settings.application.criteria.age.min)
  console.log "birthMin", @birthMin
  @birthMax = new Date(@conferenceStart)
  @birthMax.setYear(@birthMax.getYear()-settings.application.criteria.age.max-1)
  console.log "birthMax", @birthMax

  @partners = [
    'AECPOL (Associación de estudiantes de ciencas politicas) (Spain)'
    'AEGEE Heraklion (Greece)'
    'AEGEE Mainz/Wiesbaden, Department of Political Science @ University of Mainz (Germany)'
    'AEGEE Yerevan (Armenia)'
    'Ain Shams University (Egypt)'
    'A.D.E.L. - Association for Development, Education and Labour (Slovakia)'
    'BETA (Germany)'
    'BETA España (Spain)'
    'BETA Hungary (Hungary)'
    'BETA Polska (Poland)'
    'BEUM Student Association (Serbia)'
    'Brussels MEU Student Association (Belgium)'
    'Europe House (MTÜ Euroopa Maja) (Estonia)'
    'IRTEA - Institute of Research and Training on European Affairs (Greece)'
    'Istanbul Global Youth Association (Turkey)'
    'HERMES (Croatia)'
    'MEU_TN (Italy)'
    'MEU Pisa (Italy)'
    'ProYouth Albania (Albania)'
  ]

  @workshops =
    from_scratch: 'Starting from scratch: how to start organising your own MEU'
    project_management: 'Project management and volunteer leadership'
    writing_applications: 'Writing a successful Erasmus+ application'
    fundraising: 'How to raise funds beyond the E+ scheme, how to attract sponsors and donors'
    public_relations: 'Public Relations: successful techniques for advertising your MEU'
    scheduling: 'Timetabling for MEU and simulating the interplay between EP and Council'
    content: 'Content: topics and legislative procedures, what makes a good topic'
    chairing: 'Chairing: How to select and train good chairs'
    interpreting: 'Interpreting and the value of multilingual MEUs'
    lobbyists: 'How to better integrate Lobbyists into the simulation'
    journalists: 'Journalists: how to run an exciting newsroom, which media possibilities do MEU journalists have today?'

  @genders = [
    'female'
    'male'
    'other / prefer not to say'
  ]
  @idtypes = [
    'National ID'
    'Passport'
  ]

  @studyyears = ("#{i} year(s)" for i in [0..10])

  @Roles =
    OrganiserTrainee: "0"
    ExpertOrganiser: "1"

  # titles for the Roles object
  @roles = settings.application.roles

  @motivationMaxWords = settings.application.textsize.motivationletter
  @essayMaxWords = settings.application.textsize.essay
  @maxFileMB = settings.application.maximumTotalAttachmentSizeMB
  @maxFileB = @maxFileMB*1024*1024

  @needMotivation = true
  @needEssay = true

  @model = $localStorage.model ||= {}
  @model.role ||= []
  @model.birthdate = if @model.birthdate? then new Date(@model.birthdate) else undefined


  # size: @maxFileMB*1024*1024

  @files = []

  @removeFile = (event, index) ->
    event.preventDefault()
    @files.splice index, 1

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


    console.log "about to send", angular.copy(@model), @files

    @progress = 0
    upload = Upload.upload
      url: '/api/application'
      data:
        data: angular.copy(@model)
        file: @files
      disableProgress: false

    upload.catch (err) ->
      console.log 'upload err', err

    # progress window
    dialog = $mdDialog.show
      parent: angular.element(document.body)
      templateUrl: 'app/main/loading-dialog.html'
      locals:
        # workaround to get the unresolved promise
        upload: promise: upload
      controller: 'DialogCtrl'
      controllerAs: 'ctrl'
      escapeToClose: false

    dialog.then (resp) =>
      data = resp.data
      $mdDialog.show(
        $mdDialog.alert()
        # .parent(angular.element(document.querySelector('#popupContainer')))
        .clickOutsideToClose(true)
        .title('Application Successfully submitted')
        .textContent("Your application was successfully submitted. You will receive as well an email with a confirmation. Your dossier is called #{data.pseudo}.")
        .ariaLabel('Application successfully submitted Dialog')
        .ok('Close')
        # .targetEvent(ev)
      )
    , (err) =>
      console.log "error from dialog:", err
      $mdDialog.show(
        $mdDialog.alert()
        # .parent(angular.element(document.querySelector('#popupContainer')))
        .clickOutsideToClose(true)
        .title('Aborted')
        .textContent(err.message)
        .ariaLabel('Error Dialog')
        .ok('Close')
        # .targetEvent(ev)
      )

  return
