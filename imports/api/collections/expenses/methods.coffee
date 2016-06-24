{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

ExpensesModule = require './expenses.coffee'

{
  loggedIn
  hasPermission
  providerBelongsToOrgan
  unitBelongsToOrgan
  receiptBelongsToOrgan
  expenseBelongsToOrgan
} = require '../../mixins/mixins.coffee'


# insert
module.exports.insert = new ValidatedMethod
  name: 'expenses.insert'
  validate: ({expense_doc}) ->
    ExpensesModule.Expenses.simpleSchema().clean(expense_doc)
    ExpensesModule.Expenses.simpleSchema().validate(expense_doc)

  run: ({expense_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, expense_doc.organization_id, "expenses_manager")
      unitBelongsToOrgan(expense_doc.unit_id, expense_doc.organization_id)
      providerBelongsToOrgan(expense_doc.provider_id, expense_doc.organization_id) if expense_doc.provider_id?

    ExpensesModule.Expenses.insert expense_doc


# update
module.exports.update = new ValidatedMethod
  name: 'expenses.update'
  validate: ({organization_id, expense_id, expense_doc}) ->
    ExpensesModule.Expenses.simpleSchema().clean({$set: expense_doc}, {isModifier: true})
    ExpensesModule.Expenses.simpleSchema().validate({$set: expense_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      expense_id:
        type: String
    ).validate({organization_id, expense_id})

  run: ({organization_id, expense_id, expense_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, "expenses_manager")
      expenseBelongsToOrgan(expense_id, organization_id)
      unitBelongsToOrgan(expense_doc.unit_id, organization_id) if expense_doc.unit_id?
      providerBelongsToOrgan(expense_doc.provider_id, organization_id) if expense_doc.provider_id?

    # Check if u need to delete unit id if unit id is set to null
    delete expense_doc.organization_id
    ExpensesModule.Expenses.update expense_id,
                                  $set: expense_doc
