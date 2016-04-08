{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'


class CustomersCollection extends Mongo.Collection
  insert: (doc, callback) ->
    # Code for hooks
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    # Code for hooks
    super(selector, modifier, options, callback)

  remove: (selector, callback) -> # Careful with removing a client who has dependencias
    # Code for hooks
    super(selector, callback)

# Schema
CustomerSchema =
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

Customers = exports.Customers = new CustomersCollection "customers"
Customers.attachSchema CustomerSchema

Customers.deny
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

  Customers.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error
