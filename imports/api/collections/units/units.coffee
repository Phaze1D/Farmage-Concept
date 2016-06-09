{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
YieldModule = require '../yields/yields.coffee'
EventModule = require '../events/events.coffee'
SellModule = require '../sells/sells.coffee'
ExpenseModule = require '../expenses/expenses.coffee'


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


Units.helpers

  unit: ->
    Units.findOne { _id: @unit_id }

  units: ->
    Units.find { unit_id: @_id }

  yields: ->
    YieldModule.Yields.find { unit_id: @_id }

  events: ->
    EventModule.Events.find { for_id: @_id }

  expenses: ->
    ExpenseModule.Expenses.find { unit_id: @_id }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}

if Meteor.isServer
  multikeys =
    name: 1
    organization_id: 1

  Units.rawCollection().createIndex multikeys, unique: true, (error) ->

# Unit depends on unit id. If parent unit is delete
#                         Option 1: Set unit_id to parents parent
#                         Option 2: Make unit_id null
