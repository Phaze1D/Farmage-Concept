{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'



class EventsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    # Events cannot be deleted if user needs to change
    # an error then made from and event they must create a new one
    super(selector, callback)

# Schema
EventSchema =
  new SimpleSchema([
    amount:
      type: Number
      label: 'event.amount'
      decimal: true
      denyUpdate: true
      autoValue: () ->
        if @isSet
          return Number(@value.toFixed(10))

    description:
      type: String
      label: 'description'
      max: 512
      optional: true

    is_user_event:
      type: Boolean
      denyUpdate: true
      optional: true

    for_type:
      type: String
      label: 'event.for_type'
      index: true
      denyUpdate: true
      allowedValues: ['unit', 'yield', 'inventory']

    for_id:
      type: String
      index: true
      denyUpdate: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Events = exports.Events = new EventsCollection('events')
Events.attachSchema EventSchema

Events.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes


# Events depends on for_id ( The object that the event affected ). If for_id is deleted then delete all its events
# Events depends on organization_id. If organization is deleted then all events of that organization will be deleted
# Events depends on user_id. If user is delete then user_id will change to the current user
# A User cannot delete events
# A User cannot update events (expect there description)
