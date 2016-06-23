{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ExpenseModule = require '../../../api/collections/expenses/expenses.coffee'

require './show.html'

Template.ExpensesShow.onCreated ->




Template.ExpensesShow.helpers
  expense: () ->
    ExpenseModule.Expenses.findOne(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(FlowRouter.getParam 'organization_id')
