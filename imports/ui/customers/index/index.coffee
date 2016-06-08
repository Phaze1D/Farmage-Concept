{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'

require './index.html'

Template.CustomersIndex.onCreated ->




Template.CustomersIndex.helpers
  customers: () ->
    CustomerModule.Customers.find()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
