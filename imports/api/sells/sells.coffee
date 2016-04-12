{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'
ContactExports = require '../contact_info.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization'


class SellsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)

InventoryAssociationSchema =
  new SimpleSchema(
    quantity_taken:
      type: Number
      min: 0

    inventory_id:
      type: String
      index: true
  )

SellDetailsSchema =
  new SimpleSchema([

    quantity:
      type: Number
      label: 'quantity'
      min: 0

    unit_price:
      type: Number
      label: 'unit_price'
      decimal: true
      min: 0

    tax_price:
      type: Number
      label: 'tax_price'
      decimal: true
      min: 0

    inventories: 
      type: [InventoryAssociationSchema]

    unit_id:
      type: String
      index: true
      sparse: true
      optional: true
  ])



SellSchema =
  new SimpleSchema([

    sub_total:
      type: Number
      label: 'sub_total'
      decimal: true
      min: 0

    total_tax:
      type: Number
      label: 'total_tax'
      decimal: true
      min: 0

    discount:
      type: Number
      label: 'discount'
      decimal: true
      defaultValue: 0
      min: 0

    total_price:
      type: Number
      label: 'total_price'
      decimal: true
      min: 0

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3

    sell_details:
      type: [SellDetailsSchema]
      label: 'sell_details'
      min: 1

    status:
      type: String
      label: 'status'
      max: 45

    note:
      type: String
      label: 'note'
      max: 128
      optional: true

    customer_id:
      type: String
      index: true

    shipping_address:
      type: ContactExports.AddressSchema
      optional: true

    telephone:
      type: ContactExports.TelephoneSchema
      optional: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Sells = exports.Sells = new SellsCollection('sells')
Sells.attachSchema SellSchema

Sells.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes
