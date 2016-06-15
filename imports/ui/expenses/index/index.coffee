{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ExpenseModule = require '../../../api/collections/expenses/expenses.coffee'

require './index.html'

Template.ExpensesIndex.onCreated ->




Template.ExpensesIndex.helpers
  expenses: () ->
    ExpenseModule.Expenses.find()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')