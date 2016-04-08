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


InventorySchema =
  new SimpleSchema([
    amount:
      type: Number
      min: 0

    expiration_date:
      type: Date
      label: 'expiration_date'
      optional: true


    # Should probably add product sub document for deleted products
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
