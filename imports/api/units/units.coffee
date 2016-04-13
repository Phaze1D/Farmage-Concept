{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization.coffee'


class UnitsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)


UnitSchema =
  new SimpleSchema([

    name:
      type: String
      label: 'unit_name'
      index: true
      max: 64

    description:
      type: String
      label: 'description'
      optional: true
      max: 256

    amount:
      type: Number
      label: 'amount'
      min: 0
      defaultValue: 0

    unit_id:
      type: String
      index: true
      sparse: true
      optional: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Units = exports.Units = new UnitsCollection('units')
Units.attachSchema UnitSchema

Units.deny
    insert: ->
      yes
    update: ->
      yes
    remove: ->
      yes

if Meteor.isServer
  multikeys =
    name: 1
    organization_id: 1

  Units.rawCollection().createIndex multikeys, unique: true, (error) ->

# Unit depends on unit id. If parent unit is delete
#                         Option 1: Set unit_id to parents parent
#                         Option 2: Make unit_id null
