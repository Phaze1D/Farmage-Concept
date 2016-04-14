{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
ProductModule = require '../products/products.coffee'
YieldModule = require '../yields/yields.coffee'
EventModule = require '../events/events.coffee'
SellModule = require '../sells/sells.coffee'

class InventoriesCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      Inventories cannot be deleted but they can be hided
    ###
    super(selector, callback)


YieldAssociationSchema =
  new SimpleSchema(
    yield_id:
      type: String
      denyUpdate: true
      index: true

    amount_taken:  # Max number most be the yield max amount (total amount that is currently avaiable)
      type: Number
      decimal: true
      min: 0
  )


InventorySchema =
  new SimpleSchema([
    amount:
      type: Number
      label: 'amount'
      min: 0

    expiration_date:
      type: Date
      label: 'expiration_date'
      optional: true

    yield_objects:
      type: [YieldAssociationSchema]
      min: 1

    product_id:
      type: String
      index: true
      denyUpdate: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Inventories = exports.Inventories = new InventoriesCollection('inventories')
Inventories.attachSchema InventorySchema

Inventories.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Inventories.helpers

  sells: ->
    SellModule.Sells.find { sell_details: $elemMatch: inventories: $elemMatch: inventory_id: @_id }   # Careful could lead to error

  events: ->
    EventModule.Events.find { for_id: @_id }, sort: created_at: -1

  yields: ->
    id_array = ( yield_item.yield_id for yield_item in @yield_objects )
    YieldModule.Yields.find { _id: $in: id_array }

  product: ->
    ProductModule.Products.findOne { _id: @product_id }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}

# Inventory depends on yield_id. Yields can only be soft deleted
# Inventory depends on product_id. If Product gets soft deleted and Inventory amount > 0 ask user to set amount = 0
# Inventory amount can only be changes with events
# Inventory amount max must be equal to the converted amount of the sum of yield.amount_taken
# Deleting a yield object will create events to correct Inventory amount and put back yield
# * depends on organization_id. If organization is deleted then all * of that organization will be deleted
# * depends on user_id. If user is delete then user_id will change to the current user or owner
