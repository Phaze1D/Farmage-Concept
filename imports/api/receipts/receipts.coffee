{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization'

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
