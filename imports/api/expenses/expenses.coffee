{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'

class ExpensesCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    # Check to see if there is an event assiated with this expense and
    # if so create a new event to counter act the previous one
    super(selector, callback)


ExpenseSchema =
  new SimpleSchema([
    price:
      type: Number
      label: 'price'
      decimal: true

    name:
      type: String
      label: 'name'
      max: 45

    description:
      type: String
      label: 'description'
      max: 256
      optional: true

    quantity:
      type: Number
      label: 'quantity'
      decimal: true
      min: 0
      denyUpdate: true

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
      denyUpdate: true

  , CreateByUserSchema , TimestampSchema])

  Expenses = exports.Expenses = new ExpensesCollection('expenses')
  Expenses.attachSchema ExpenseSchema

  Expenses.deny
    insert: ->
      yes
    update: ->
      yes
    remove: ->
      yes
