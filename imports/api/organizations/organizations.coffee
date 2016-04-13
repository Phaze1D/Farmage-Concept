{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'

CustomerModule = require '../customers/customers.coffee'
EventModule = require '../events/events.coffee'
ExpenseModule = require '../expenses/expenses.coffee'
InventoryModule = require '../inventories/inventories.coffee'
ProductModule = require '../products/products.coffee'
ProviderModule = require '../providers/providers.coffee'
ReceiptModule = require '../receipts/receipts.coffee'
SellModule = require '../sells/sells.coffee'
UnitModule = require '../units/units.coffee'
YieldModule = require '../yields/yields.coffee'


class OrganizationsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

OrganizationSchema =
  new SimpleSchema([
    name:
      type: String
      max: 128
      label: 'organization.name'
      index: true
      unique: true

  ,ContactSchema, TimestampSchema])

Organizations = exports.Organizations = new OrganizationsCollection('organizations')
Organizations.attachSchema OrganizationSchema

Organizations.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Organizations.helpers
  customers: ->
    CustomerModule.Customers.find { organization_id: @_id }
  events: ->
    EventModule.Events.find { organization_id: @_id }
  expenses: ->
    ExpenseModule.Expenses.find { organization_id: @_id }
  inventories: ->
    InventoryModule.Inventories.find { organization_id: @_id }
  products: ->
    ProductModule.Products.find { organization_id: @_id }
  providers:->
    ProviderModule.Providers.find { organization_id: @_id }
  receipts: ->
    ReceiptModule.Receipts.find { organization_id: @_id }
  sells: ->
    SellModule.Sells.find { organization_id: @_id }
  units: ->
    UnitModule.Units.find { organization_id: @_id }
  users: ->
    Meteor.users.find { organization_id: @_id }
  yields: ->
    YieldModule.Yields.find { organization_id: @_id }
