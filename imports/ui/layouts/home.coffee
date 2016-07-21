
OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './home.jade'

class Home extends BlazeComponent
  @register 'Home'

  constructor: (args) ->

  onCreated: ->
    @enterAnimation = new ReactiveVar(true)
    @autorun =>
      @subscribe "organizations",
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  user: ->
    Meteor.users.findOne()

  email: ->
    user = Meteor.users.findOne()
    user.emails[0].address if user?


  organizationClasses: ->
    if OrganizationModule.Organizations.find().count() is 0
      return "drawer-item toggle-drawer"
    else
      return "drawer-item"

  onLogout: (event) ->
    @exitAnimation()

  exitAnimation: () ->
    $('#scrim').addClass('hide')
    $('#paper-drawer').velocity
      p:
        left: "-240px"
      o:
        duration: 250
        easing: "ease-in-out"

    $("#paper-drawer-main").velocity
      p:
        left: "0px"
      o:
        duration: 250
        easing: "ease-in-out"

    $('#paper-header').velocity
      p:
        top: "-212px"
      o:
        duration: 250
        complete: ->
          $('#paper-drawer').removeClass('move-foward').addClass('move-back')
          $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
          Meteor.logout( (err) ->
            FlowRouter.go 'login' unless err?
          )


  events: ->
    super.concat
      'click .js-logout': @onLogout
      'click .js-test-home': @testhome
