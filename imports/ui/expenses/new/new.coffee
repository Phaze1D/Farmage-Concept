{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
EMethods = require '../../../api/collections/expenses/methods.coffee'


require './new.html'

Template.ExpensesNew.onCreated ->

  @insert = (expense_doc) =>
    expense_doc.organization_id = FlowRouter.getParam('organization_id')
    EMethods.insert.call {expense_doc}, (err, res) ->
      console.log err
      params =
        organization_id: expense_doc.organization_id
      FlowRouter.go('expenses.index', params ) unless err?

Template.ExpensesNew.helpers



Template.ExpensesNew.events
  'submit .js-expenses-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-expenses-form-new')
    expense_doc =
      price: $form.find('[name=price]').val()
      currency: $form.find('[name=currency]').val()
      description: $form.find('[name=description]').val()
      quantity: $form.find('[name=quantity]').val()
      receipt_id: $form.find('[name=receipt_id]').val()
      provider_id: $form.find('[name=provider_id]').val()
      unit_id: $form.find('[name=unit_id]').val()
    instance.insert expense_doc
