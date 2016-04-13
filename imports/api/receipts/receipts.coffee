{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
ExpenseModule = require '../expenses/expenses.coffee'

class ReceiptsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

ReceiptSchema =
  new SimpleSchema([
    receipt_image_url:
      type: String

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Receipts = exports.Receipts = new ReceiptsCollection('receipts')
Receipts.attachSchema ReceiptSchema

Receipts.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Receipts.helpers
  expanses: ->
    ExpenseModule.Expenses.find { receipt_id: @_id}

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @user_id}
