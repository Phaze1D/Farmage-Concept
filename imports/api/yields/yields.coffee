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

    total:
      type: Number
      label: 'yield.total'
      decimal: true
      min: 0

    usable:
      type: Number
      label: 'yield.usable'
      decimal: true
      min: 0

    measurement_unit:
      type: String
      label: 'measurement_unit'
      max: 64

    unit_id:
      type: String
      index: true

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
