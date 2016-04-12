{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'

class YieldsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
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
      min: 0

    discarded:
      type: Number
      label: 'discared_amount'
      decimal: true
      min: 0

    current:
      type: Number
      label: 'yield.total'
      decimal: true
      min: 0

    measurement_unit:
      type: String
      label: 'measurement_unit'
      denyUpdate: true
      max: 64

    # May need to add unit sub document for deleted units
    unit_id:
      type: String
      index: true
      denyUpdate: true


  , CreateByUserSchema, TimestampSchema])

Yields = exports.Yields = new YieldsCollection('yields')
Yields.attachSchema YieldSchema

Yields.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes
