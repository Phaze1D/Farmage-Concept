{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'

class ProvidersCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

ProviderSchema =
  new SimpleSchema([
      first_name:
        type: String
        label: "first_name"
        max: 45

      last_name:
        type: String
        label: "last_name"
        optional: true
        max: 45

      company:
        type: String
        label: "company"
        optional: true
        max: 45

      organization_id: # Think about adding autoValue for this field
        type: String
        index: true

  , ContactSchema, TimestampSchema])

Providers = exports.Providers = new CustomersCollection "providers"
Providers.attachSchema ProviderSchema

Providers.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

if Meteor.isServer
  multikeys =
    email: 1
    organization_id: 1

  Providers.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error
