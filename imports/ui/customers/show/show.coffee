{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'

require './show.html'

Template.CustomersShow.onCreated ->




Template.CustomersShow.helpers
  customer: () ->
    CustomerModule.Customers.findOne(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(FlowRouter.getParam 'organization_id')
