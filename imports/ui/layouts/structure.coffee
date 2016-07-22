
OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './structure.jade'

class Structure extends BlazeComponent
  @register 'structure'

  constructor: (args) ->

  onCreated: ->
    @enterAnimation = new ReactiveVar(true)
    @autorun =>
      @subscribe "organizations",
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->



  headermain: ->
    FlowRouter.getRouteName()

  user: ->
    Meteor.user()

  email: ->
    user = Meteor.user()
    user.emails[0].address if user?

  organizationClasses: ->
    if OrganizationModule.Organizations.find().count() is 0
      return "drawer-item toggle-drawer"
    else
      return "drawer-item"

  organizations: ->
    OrganizationModule.Organizations.find()

  permission: (type, organization_id) ->
    ouser = OrganizationModule.Organizations.findOne(organization_id).hasUser(Meteor.userId())
    ouser.permission[type] || ouser.permission['owner'] || ouser.permission['viewer']

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
