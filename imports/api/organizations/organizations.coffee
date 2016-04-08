{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'


class OrganizationsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

OrganizationSchema =
  new SimpleSchema([
    name:
      type: String
      max: 128
      label: 'organization.name'
      index: true
      unique: true

  ,ContactSchema, TimestampSchema])

Organizations = exports.Organizations = new OrganizationsCollection('organizations')
Organizations.attachSchema OrganizationSchema

Organizations.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes
