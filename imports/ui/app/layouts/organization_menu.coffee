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


Template.OrganizationMenu.onCreated ->

Template.OrganizationMenu.onRendered ->

Template.OrganizationMenu.onDestroyed ->


Template.OrganizationMenu.helpers
  organization: ->
    OC.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  permission: ->
    organ = OC.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organ.hasUser(Meteor.userId()).permission if organ?

  subView: ->
    routeName = FlowRouter.getRouteName()

    if /organization/i.test(routeName)
      'OrganizationT'

    else if /customers/i.test(routeName)
      'CustomersT'

  subViewData: ->
    routeName = FlowRouter.getRouteName()
    if /index/i.test(routeName)
      index: true
    else if /new/i.test(routeName)
      new: true
    else if /update/i.test(routeName)
      ret =
        update:
          id: FlowRouter.getParam 'child_id'
    else if /show/i.test(routeName)
      ret =
        show:
          id: FlowRouter.getParam 'child_id'
    else
      {}


Template.OrganizationMenu.events
