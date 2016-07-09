{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'

require './main_menu.html'


Template.MainMenu.onCreated ->

  @subCallback =
    onStop: (err) ->
      console.log "sub stop #{err}"
    onReady: () ->

  @autorun =>
    @subscribe("organizations", @subCallback)


  @logout = ->
    Meteor.logout( (err) ->
      console.log err
      FlowRouter.go 'root' unless err?
    )

  @subTitles = ( title, organ, routesB) ->

    child_id = FlowRouter.getParam 'child_id'
    parent = FlowRouter.getQueryParam('parent')
    parent_id = FlowRouter.getQueryParam('parent_id')
    group = FlowRouter.current().route.group.name

    title.push
      name: organ.name
      link: "/organizations/#{organ._id}"

    if parent_id? && parent
      title.push
        name: @capitalize parent
        link: "/organizations/#{organ._id}/#{parent}s/#{parent_id}/show"

    if routesB.showR || routesB.updateR
      title.push
        name: @capitalize @singular group
        link: "/organizations/#{organ._id}/#{group}/#{child_id}/show"

    if routesB.updateR
      title.push
        name: 'Update'
        link: "/organizations/#{organ._id}/#{group}/#{child_id}/update"

    if routesB.indexR
      title.push
        name: @capitalize group
        link: "/organizations/#{organ._id}/#{group}"

    if routesB.newR
      title.push
        name: 'New'
        link: "/organizations/#{organ._id}/#{group}/new"


  @organizationTitles = (title, organ, routesB) =>
    if routesB.showR || routesB.updateR
      title.push
        name: organ.name
        link: "/organizations/#{organ._id}"

    if routesB.updateR
      title.push
        name: 'Update'
        link: "/organizations/#{organ._id}/update"

    if routesB.indexR
      title.push
        name: 'Organizations'
        link: "/organizations"

    if routesB.newR
      title.push
        name: 'New'
        link: "/organizations/new"

  @capitalize = (string) =>
    if string is 'ousers' or string is 'Ousers'
      return string.charAt(1).toUpperCase() + string.slice(2)
    string.charAt(0).toUpperCase() + string.slice(1)

  @singular = (plural) =>
    if plural is 'inventories' or plural is 'Inventories'
      return plural.slice(0, -3) + 'y'
    plural.slice(0,-1)


Template.MainMenu.helpers
  user: ->
    Meteor.users.findOne()

  email: ->
    user = Meteor.users.findOne()
    user.emails[0].address if user?

  titles: ->
    FlowRouter.watchPathChange()
    routeName = FlowRouter.getRouteName()

    routesB = {}
    routesB.newR = if /new/i.test(routeName) then true else false
    routesB.updateR = if /update/i.test(routeName) then true else false
    routesB.showR = if /show/i.test(routeName) then true else false
    routesB.indexR = !(routesB.showR || routesB.updateR)

    organ = Organizations.findOne FlowRouter.getParam 'organization_id'
    group = FlowRouter.current().route.group
    title = []
    if organ? && group.name isnt 'organizations'
      Template.instance().subTitles title, organ, routesB
    else if group? && group.name is 'organizations'
      Template.instance().organizationTitles title, organ, routesB
    else
      title.push
        name: 'Home'
        link: '/home'

    title[title.length - 1].last = true
    title

  links: ->
    ret = [
      {
        name: 'Home'
        link: '/home'
        class: 'js-link'
      },
      {
        name: 'Organizations'
        link: '/organizations'
      }
    ]

  linkOrganizations: ->
    ret = []
    Organizations.find().forEach (doc) ->
      ret.push
        organization: doc
        link: "/organizations/#{doc._id}"
    ret

  linkOrganSub: (organization) ->
    if organization?
      permission = organization.hasUser(Meteor.userId()).permission
      ret = []
      if permission.sells_manager || permission.owner || permission.viewer
        ret.push
          name: 'Customers'
          link: "/organizations/#{organization._id}/customers"
        ret.push
          name: 'Sells'
          link: "/organizations/#{organization._id}/sells"

      if permission.owner || permission.viewer
        ret.push
          name: 'Events'
          link: "/organizations/#{organization._id}/events"

      if permission.expenses_manager || permission.owner || permission.viewer
        ret.push
          name: 'Expenses'
          link: "/organizations/#{organization._id}/expenses"
        ret.push
          name: 'Providers'
          link: "/organizations/#{organization._id}/providers"

      if permission.owner || permission.viewer
        ret.push
          name: 'Ingredients'
          link: "/organizations/#{organization._id}/ingredients"

      if permission.inventories_manager || permission.owner || permission.viewer
        ret.push
          name: 'Inventories'
          link: "/organizations/#{organization._id}/inventories"

        ret.push
          name: 'Products'
          link: "/organizations/#{organization._id}/products"

      if permission.units_manager || permission.owner || permission.viewer
        ret.push
          name: 'Units'
          link: "/organizations/#{organization._id}/units"

        ret.push
          name: 'Yields'
          link: "/organizations/#{organization._id}/yields"

      if permission.users_manager || permission.owner || permission.viewer
        ret.push
          name: 'Users'
          link: "/organizations/#{organization._id}/ousers"

      return ret


Template.MainMenu.events
  'click .js-logout': (event, instance) ->
    instance.logout()

  "click .js-mask-app-b, click .js-link": (event, instance) ->
    sideBar = instance.$('.sidebar')
    sideBar.removeClass('showSidebar')
    sideBar.addClass('hideSidebar')
    instance.$('.js-mask-app-b').addClass('mask-off')

    sideBar.on "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd",() ->
      sideBar.off "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd"
      instance.$('.js-mask-app-b').removeClass('mask-on')
      $('body').removeClass 'disable-scroll'

  'click .js-organ-link': (event, instance) ->
    $('.suborgan-ul').each( ()->
      $this = $(@)
      if $this.hasClass('suborgan-show')
        $this.removeClass('suborgan-show')
        $this.parent().find('.menu-link').removeClass('js-link')
    )
    $target = $(event.target)
    $target.parent().find('.suborgan-ul').addClass('suborgan-show')
    $target.addClass('js-link')

  'click .js-menu-link': (event, instance) ->
    $('.suborgan-ul').each( ()->
      $this = $(@)
      if $this.hasClass('suborgan-show')
        $this.removeClass('suborgan-show')
        $this.parent().find('.menu-link').removeClass('js-link')
    )


  'click #js-appmenu-b': (event, instance) ->
    instance.$('.js-mask-app-b').removeClass('mask-off').addClass('mask-on')
    sideBar = instance.$('.sidebar')
    sideBar.removeClass 'hideSidebar'
    sideBar.addClass 'showSidebar'
    $('body').addClass 'disable-scroll'
