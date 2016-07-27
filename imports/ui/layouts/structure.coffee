
OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './structure.jade'

class Structure extends BlazeComponent
  @register 'structure'

  constructor: (args) ->

  onCreated: ->
    @enterAnimation = true
    @autorun =>
      @subscribe "organizations",
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    @onEnterAnimation()

  headermain: ->
    FlowRouter.getRouteName()

  user: ->
    user = Meteor.user()
    if user?
      return user
    else
      @onExitAnimation()

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
    @onExitAnimation()

  onEnterAnimation: () ->
    if @enterAnimation
      @enterAnimation = false
      $('#paper-header').animate(
        {
          top: "0px"
        },
        {
          duration: 250
          queue: false
        }
      )

      $("#paper-header-main").animate(
        {
          opacity: '1'
        },
        {
          duration: 200
          easing: "linear"
          queue: false
        }
      )

  onExitAnimation: () ->
    unless @enterAnimation
      @enterAnimation = true
      $('#scrim').addClass('hide')
      $('#paper-drawer').animate(
        {
          left: "-240px"
        },
        {
          duration: 250
          easing: "ease-in-out"
          queue: false
        }
      )

      $("#paper-drawer-main").animate(
        {
          left: "0px"
        },
        {
          duration: 250
          easing: "ease-in-out"
          queue: false
        }
      )

      $("#paper-header-main").animate(
        {
          opacity: '0'
        },
        {
          duration: 250
          easing: "linear"
          queue: false
        }
      )

      $('#paper-header').animate(
        {
          top: "-212px"
        },
        {
          duration: 250
          queue: false
          complete: ->
            $('#paper-drawer').removeClass('move-foward').addClass('move-back')
            $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
            Meteor.logout( (err) ->
              FlowRouter.go 'login' unless err?
            )
        }
      )


  events: ->
    super.concat
      'click .js-logout': @onLogout
      'click .js-test-home': @testhome