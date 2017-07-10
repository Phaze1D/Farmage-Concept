
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

  isOpened: (routeName, params) ->
    routeName is FlowRouter.getRouteName() and params is FlowRouter.getParam('organization_id')

  scrollCallbacks: ->
    ret =
      scrollBottom: =>
        child = @childComponents()[0].childComponents()[1].childComponentsWith('canLoadMore')[0]
        if child? && child.page.ready() && child.canLoadMore
          child.page.loadNextPage()


  onLogout: (event) ->
    @onExitAnimation()

  onEnterAnimation: () ->

    if @enterAnimation
      @enterAnimation = false
      $('#root-paper-header').velocity(
        p:
          top: "0px"
        o:
          duration: 250
          queue: false
      )

      $("#root-paper-header-main").velocity(
        p:
          opacity: '1'
        o:
          duration: 200
          easing: "linear"
          queue: false
      )

  onExitAnimation: () ->
    unless @enterAnimation
      @enterAnimation = true
      $('#scrim').addClass('hide')
      $('.js-hide-right').trigger('click')
      $('#paper-drawer').velocity(
        p:
          left: "-240px"
        o:
          duration: 250
          easing: "ease-in-out"
          queue: false
      )

      $("#paper-drawer-main").velocity(
        p:
          left: "0px"
        o:
          duration: 250
          easing: "ease-in-out"
          queue: false
      )

      $("#root-paper-header-main").velocity(
        p:
          opacity: '0'
        o:
          duration: 250
          easing: "linear"
          queue: false
      )

      $('#root-paper-header').velocity(
        p:
          top: "-212px"
        o:
          duration: 250
          queue: false
          complete: ->
            $('#paper-drawer').removeClass('move-foward').addClass('move-back')
            $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
            Meteor.logout( (err) ->
              FlowRouter.go 'login' unless err?
            )
      )

  onChangeRoute: (event) ->
    event.preventDefault()
    unless FlowRouter.getRouteName() is $(event.target).attr 'href'
      # Animate page change
      $("#paper-drawer-main").css 'padding-right': ''
      $("#root-paper-header-panel").css overflow: ''
      a = $(event.target)
      params = {}

      params.organization_id = a.attr('data-organ') if a.attr('data-organ')?
      params.child_id = a.attr('data-child') if a.attr('data-child')?

      FlowRouter.go a.attr('href'), params


  onShowSearch: (event) ->
    tar = $(event.currentTarget).closest('.search-header').find('.search-hidden')

    if tar.attr('show') is 'true'
      @onSearch(event)
    else
      tar.attr('show', 'true')
      tar.velocity
        p:
          width: 320
        o:
          duration: 200

    tar.closest('.search-header').find('.pinput').focus()

  onHideSearch: (event) ->
    child = @childComponents()[0].childComponents()[1].childComponentsWith('search')[0]
    child.clearSearch()
    tar = $(event.currentTarget).closest('.search-header').find('.search-hidden')
    tar.attr('show', 'false')
    tar.closest('.search-header').find('.pinput').val('')
    tar.velocity
      p:
        width: 0
      o:
        duration: 200

  onSearch: (event) ->
    event.preventDefault()
    child = @childComponents()[0].childComponents()[1].childComponentsWith('search')[0]
    child.search($(event.currentTarget).find('.pinput').val())

  onShowFilter: (event) ->
    tar = $('.filter-area')
    tar.removeClass 'hide-f'
    tar.addClass 'show-f'

  onCloseFilter: (event) ->
    tar = $('.filter-area')
    tar.addClass 'hide-f'
    tar.removeClass 'show-f'



  events: ->
    super.concat
      'click .js-logout': @onLogout
      'click a': @onChangeRoute
      'click .js-search': @onShowSearch
      'click .js-cross': @onHideSearch
      'submit .search-form': @onSearch
      'click .js-filter': @onShowFilter
      'click .js-close-filter': @onCloseFilter
