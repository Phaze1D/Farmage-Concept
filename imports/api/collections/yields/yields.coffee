{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
UnitModule = require '../units/units.coffee'
InventoryModule = require '../inventories/inventories.coffee'
EventModule = require '../events/events.coffee'



class YieldsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      Yields cannot be deleted but they can be hided
    ###
    super(selector, callback)


YieldSchema =
  new SimpleSchema([
    name:
      type: String
      label: 'name'
      max: 64
      optional: true

    amount:
      type: Number
      label: 'yield.total'
      decimal: true
      optional: true
      min: 0
      autoValue: () ->
        if @isSet
          return Number(@value.toFixed(10))
        else if @isInsert
          return 0

    ingredient_id:
      type: String
      index: true
      denyUpdate: true

    unit_id:
      type: String
      index: true
      denyUpdate: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Yields = exports.Yields = new YieldsCollection('yields')
Yields.attachSchema YieldSchema

Yields.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Yields.helpers

  unit: ->
    UnitModule.Units.findOne { _id: @unit_id }

  inventories: ->
    InventoryModule.Inventories.find {'yield_objects.yield_id': @_id} # possible error

  events: ->
    EventModule.Events.find { for_id: @_id}

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}

# Yield depends on unit_id. On Unit delete
#             Option 1: move yield to parent Unit
#             Option 2: delete yields
