{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'

require './main_menu.html'


Template.MainMenu.onCreated ->
  @title = new ReactiveVar('Home')

  @subCallback =
    onStop: (err) ->
      console.log "sub stop #{err}"
    onReady: () ->


  @logout = ->
    Meteor.logout( (err) ->
      console.log err
      FlowRouter.go 'root' unless err?
    )

  @autorun =>
    @subscribe("organizations", @subCallback)


Template.MainMenu.helpers
  user: ->
    Meteor.users.findOne()

  email: ->
    user = Meteor.users.findOne()
    user.emails[0].address if user?

  title: ->
    FlowRouter.watchPathChange()
    group = FlowRouter.current().route.group
    Template.instance().title.get()

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
    param = FlowRouter.getParam('organization_id')
    param = if param? then _id: param else {}
    Organizations.find(param).forEach (doc) ->
      ret.push
        name: doc.name
        link: "/organizations/#{doc._id}"
    ret

  linkOrganSub: ->
    param = FlowRouter.getParam('organization_id')
    organization = Organizations.findOne param
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

  "click .js-mask, click .js-link": (event, instance) ->
    container = instance.$('.sidebar')
    container.removeClass 'showSidebar'
    container.addClass 'hideSidebar'
    container.one "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd",() ->
      instance.$('.js-mask').removeClass('mask-on').addClass('mask-off')



  'click #js-appmenu-b': (event, instance) ->
    instance.$('.mask').removeClass('mask-off').addClass('mask-on')
    container = instance.$('.sidebar')
    container.one "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd",() ->

    container.removeClass 'hideSidebar'
    container.addClass 'showSidebar'
