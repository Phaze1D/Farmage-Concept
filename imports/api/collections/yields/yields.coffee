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

    initial:
      type: Number
      label: 'initial_amount'
      decimal: true
      denyUpdate: true
      min: 0

    discarded: # (Add a discard action that discards a certain amount)
      type: Number
      label: 'discared_amount'
      decimal: true
      min: 0

    current:
      type: Number
      label: 'yield.total'
      decimal: true
      min: 0

    measurement_unit: # Trim and downcase
      type: String
      label: 'measurement_unit'
      denyUpdate: true
      max: 64

    ingredient_name: # Trim and downcase
      type: String
      label: 'ingredient'
      denyUpdate: true
      max: 128

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
    InventoryModule.Inventories.find {'yield_objects.yield_id': @_id}

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
