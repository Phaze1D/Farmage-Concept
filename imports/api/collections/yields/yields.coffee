{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'



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

    notes:
      type: String
      label: 'notes'
      max: 512
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

    # Possible Add update yield date


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


# Yield depends on unit_id. On Unit delete
#             Option 1: move yield to parent Unit
#             Option 2: delete yields
