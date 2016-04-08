{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'

class EventsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

# Schema
EventSchema =
  new SimpleSchema([
    amount:
      type: Number
      label: 'event.amount'
      denyUpdate: true
      min: 1

    sign:
      type: Boolean
      label: 'event.sign'
      denyUpdate: true

    description:
      type: String
      label: 'description'
      max: 256
      optional: true

    auto_generated: # Careful the user may try and set this filter params from the client side
      type: Boolean
      denyUpdate: true

    because_type:
      type: String
      label: 'event.because_type'
      optional: true
      index: true
      sparse: true
      denyUpdate: true

    because_id:
      type: String
      optional: true
      index: true
      sparse: true
      denyUpdate: true

    for_type:
      type: String
      label: 'event.for_type'
      index: true
      denyUpdate: true

    for_id:
      type: String
      index: true
      denyUpdate: true

  , CreateByUserSchema, TimestampSchema])

Events = exports.Events = new EventsCollection('events')
Events.attachSchema EventSchema

Events.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

if Meteor.isServer
  multikeys =
    because_id: 1
    for_id: 1

  Events.rawCollection().createIndex multikeys, unique: true, (error) ->
