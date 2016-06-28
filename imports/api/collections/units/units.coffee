{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'


class UnitsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)
    ###
    Unit can only be soft deleted
     * depends on unit_id. On unit soft delete
         Option 1 * will pass to the parent unit.
         If parent unit = null
         Option 2 unit will be soft deleted
    ###


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
      max: 512

    amount:
      type: Number
      label: 'amount'
      min: 0
      optional: true
      defaultValue: 0

    unit_id: # Parent Id
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
