{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'


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
  new SimpleSchema
    yield_id:
      type: String
      index: true

    amount_taken:
      type: Number
      decimal: true
      min: 0
      exclusiveMin: true
      autoValue: () ->
        if @isSet
          return Number(@value.toFixed(10))


InventorySchema =
  new SimpleSchema([
    name:
      type: String
      label: 'name'
      max: 64
      optional: true

    amount:
      type: Number
      label: 'amount'
      optional: true
      defaultValue: 0
      min: 0

    expiration_date:
      type: Date
      label: 'expiration_date'
      optional: true

    notes:
      type: String
      label: 'notes'
      max: 512
      optional: true

    yield_objects: # Should be able to update if adding
      type: [YieldAssociationSchema]
      optional: true
      defaultValue: []
      minCount: 0
      maxCount: 100

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


# Inventory depends on yield_id. Yields can only be soft deleted
# Inventory depends on product_id. If Product gets soft deleted and Inventory amount > 0 ask user to set amount = 0
# Inventory amount can only be changes with events
# Inventory amount max must be equal to the converted amount of the sum of yield.amount_taken
# Deleting a yield object will create events to correct Inventory amount and put back yield
# * depends on organization_id. If organization is deleted then all * of that organization will be deleted
# * depends on user_id. If user is delete then user_id will change to the current user or owner
