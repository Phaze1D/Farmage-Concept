{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OC = require '../../../api/collections/organizations/organizations.coffee'

require './organization_menu.html'

require '../../organizations/organization.coffee'
require '../../customers/customers.coffee'
require '../../events/events.coffee'
require '../../expenses/expenses.coffee'
require '../../ingredients/ingredients.coffee'
require '../../inventories/inventories.coffee'
require '../../products/products.coffee'
require '../../providers/providers.coffee'
require '../../sells/sells.coffee'
require '../../units/units.coffee'
require '../../ousers/ousers.coffee'
require '../../yields/yields.coffee'


Template.OrganizationMenu.onCreated ->

Template.OrganizationMenu.onRendered ->

Template.OrganizationMenu.onDestroyed ->


Template.OrganizationMenu.helpers
  organization: ->
    OC.Organizations.findOne _id: FlowRouter.getParam 'organization_id'

  permission: (type)->
    organ = OC.Organizations.findOne _id: FlowRouter.getParam 'organization_id'
    if organ?
      ouser = organ.hasUser(Meteor.userId())
      return ouser.permission[type] ||
             ouser.permission.owner ||
             ouser.permission.viewer

  subView: ->
    routeName = FlowRouter.getRouteName()

    return 'OrganizationT'  if /organization/i.test(routeName)
    return 'CustomersT'     if /customers/i.test(routeName)
    return 'EventsT'        if /events/i.test(routeName)
    return 'ExpensesT'      if /expenses/i.test(routeName)
    return 'IngredientsT'   if /ingredients/i.test(routeName)
    return 'InventoriesT'   if /inventories/i.test(routeName)
    return 'ProductsT'      if /products/i.test(routeName)
    return 'ProvidersT'     if /providers/i.test(routeName)
    return 'ReceiptsT'      if /receipts/i.test(routeName)
    return 'SellsT'         if /sells/i.test(routeName)
    return 'UnitsT'         if /units/i.test(routeName)
    return 'OUsersT'        if /ousers/i.test(routeName)
    return 'YieldsT'        if /yields/i.test(routeName)


  subViewData: ->
    routeName = FlowRouter.getRouteName()
    return index: true  if /index/i.test(routeName)
    return new: true    if /new/i.test(routeName)
    return update: true if /update/i.test(routeName)
    return show: true   if /show/i.test(routeName)
    {}



Template.OrganizationMenu.events

  'click .list-item': (event, instance) ->
    listItem = $(event.target)
    pos = listItem.position()
    wi = listItem.outerWidth()
    he = listItem.outerHeight()

    listItem.css left: pos.left, top: pos.top, 'width': wi, 'min-height': he

    set = () ->
      listItem.css left: '', top: '', 'width': '', 'min-height': ''
      listItem.addClass('list-expand')

    Meteor.setTimeout( ->
      set()
    , 100)
