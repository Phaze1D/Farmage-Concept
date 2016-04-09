{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'

class InventoriesCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
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
      min: 0

    expiration_date:
      type: Date
      label: 'expiration_date'
      optional: true


    yield_object:
      type: [YieldAssociateSchema]
      min: 1

    # If Product gets delete warn user about leftover inventory
    product_id:
      type: String
      index: true
      denyUpdate: true

  , CreateByUserSchema, TimestampSchema])

Inventories = exports.Inventories = new InventoriesCollection('inventories')
Inventories.attachSchema InventorySchema

Inventories.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes
