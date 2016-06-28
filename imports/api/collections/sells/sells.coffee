{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
ContactExports = require '../../shared/contact_info.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'


class SellsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      Warn the user if he/she really wants to delete this sell.
      Show the user that they can cancel a sell and return the inventory with an event
    ###
    super(selector, callback)

InventoryAssociationSchema =
  new SimpleSchema(
    quantity_taken:
      type: Number
      min: 1

    inventory_id:
      type: String
      index: true
  )

SellDetailsSchema = exports.SellDetailsSchema =
  new SimpleSchema([
    product_id:
      type: String
      index: true

    quantity:
      type: Number
      label: 'quantity'
      min: 0

    unit_price:
      type: Number
      label: 'unit_price'
      decimal: true
      optional: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    tax_rate:
      type: Number
      label: 'tax_rate'
      decimal: true
      optional: true
      min: 0
      max: 100

    inventories:
      type: [InventoryAssociationSchema]
      optional: true
      defaultValue: []
      minCount: 0
      maxCount: 15

  ])

SellSchema =
  new SimpleSchema([

    sub_total:
      type: Number
      label: 'sub_total'
      decimal: true
      optional: true
      min: 0
      autoValue: () ->
        if @isSet
          return Number @value.toFixed(2)

    tax_total:
      type: Number
      label: 'total_tax'
      decimal: true
      optional: true
      min: 0
      autoValue: () ->
        if @isSet
          return Number @value.toFixed(2)

    discount:
      type: Number
      label: 'discount'
      decimal: true
      min: 0
      optional: true
      autoValue: () ->
        if @isSet
          return Number @value.toFixed(2)
        else if @isInsert
          return 0


    discount_type:
      type: Boolean
      optional: true
      defaultValue: true


    total_price:
      type: Number
      label: 'total_price'
      decimal: true
      min: 0
      optional: true
      autoValue: () ->
        if @isSet
          return Number @value.toFixed(2)

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3
      optional: true

    details:
      type: [SellDetailsSchema]
      label: 'sell_details'
      minCount: 0
      maxCount: 100

    status:
      type: String
      label: 'status'
      max: 24
      index: true
      autoValue: () ->
        if @isSet
          return @value.toLowerCase().replace(/\s+/g,' ').trim();

    paid:
      type: Boolean
      defaultValue: false
      optional: true

    paid_date:
      type: Date
      optional: true
      autoValue: () ->
        @unset()
        paid = @field('paid')
        if paid.isSet && paid.value
          return new Date()

    payment_method:
      type: String
      optional: true

    receipt_url:
      type: String
      optional: true

    note:
      type: String
      label: 'note'
      max: 256
      optional: true

    customer_id:
      type: String
      index: true
      sparse: true
      optional: true


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



# Sells depends on inventory id. Inventory can only be soft delete
# Sells depends on unit_id. On unit delete
                            # Option 1 sells will pass to the parent unit.
                            # Option 2 unit_id will be null
# Sells depends on customer_id. Customers can only be soft deleted
# Sells depends on product_id. Product can only be soft delete
