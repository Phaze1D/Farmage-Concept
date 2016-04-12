{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization'

class ExpensesCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->

    super(selector, callback)


ExpenseSchema =
  new SimpleSchema([
    price:
      type: Number
      label: 'price'
      decimal: true
      min: 0

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3

    name:
      type: String
      label: 'name'
      max: 64

    description:
      type: String
      label: 'description'
      max: 256
      optional: true

    quantity:
      type: Number
      label: 'quantity'
      decimal: true
      min: 1

    receipts_id:
      type: String
      optional: true
      index: true
      sparse: true

    provider_id:
      type: String
      optional: true
      index: true
      sparse: true

    unit_id:
      type: String
      index: true

  , BelongsOrganizationSchema, CreateByUserSchema, TimestampSchema])

Expenses = exports.Expenses = new ExpensesCollection('expenses')
Expenses.attachSchema ExpenseSchema

Expenses.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

# Expense depends on receipts_id. If receipt is deleted then receipts_id will be null
# Expense depends on provider_id. If provider is deleted then provider_id will be null
# Expense depends on unit_id. On unit delete
                            # Option 1 expanses will pass to the parent unit.
                            # Option 2 expenses will be deleted
# Expense depends on organization_id. If organization is deleted then all expenses of that organization will be deleted
# Expense depends on user_id. If user is delete then user_id will change to the current user
