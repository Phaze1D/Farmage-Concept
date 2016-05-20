{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
ContactExports = require '../../shared/contact_info.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
CustomerModule = require '../customers/customers.coffee'
UnitModule = require '../units/units.coffee'
ProductModule = require '../products/products.coffee'
InventoryModule = require '../inventories/inventories.coffee'


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

InventoryAssociationSchema =   # When removing inventory after it has been saved then insure the user that the inventory will be put back
  new SimpleSchema(            # Cannot removing or update after status is 'sent', 'paid'
    quantity_taken:
      type: Number
      min: 0

    inventory_id:
      type: String
      index: true
  )

SellDetailsSchema = exports.SellDetailsSchema =    # When removing SellDetails after a sell has been saved then insure the user that the inventory will be put back
  new SimpleSchema([                                # Cannot removing or update after status is 'sent', 'paid'
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
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    tax_price:
      type: Number
      label: 'tax_price'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    inventories:
      type: [InventoryAssociationSchema]
      optional: true
      minCount: 1
      maxCount: 25

  ])

SellSchema =
  new SimpleSchema([

    sub_total:
      type: Number
      label: 'sub_total'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    tax_total:
      type: Number
      label: 'total_tax'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    discount:
      type: Number
      label: 'discount'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)
        else
          return 0

    discount_type:
      type: Boolean


    total_price:
      type: Number
      label: 'total_price'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3
      optional: true

    details:
      type: [SellDetailsSchema]
      label: 'sell_details'
      minCount: 1
      maxCount: 100

    status:
      type: String
      label: 'status'
      allowedValues: ['preorder', 'ordered', 'canceled', 'delivered', 'paid', 'returned']

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

Sells.helpers

  customer: ->
    CustomerModule.Customers.findOne { _id: @customer_id }

  sell_detail_unit: (sell_detail) ->
    unless sell_detail.unit_id?
      UnitModule.Units.findOne { _id: sell_detail.unit_id }

  sell_detail_product: (sell_detail) ->
    ProductModule.Products.findOne { _id: sell_detail.product_id }

  sell_detail_inventories: (sell_detail) ->
    id_array = ( inventory_item.inventory_id for inventory_item in sell_detail.inventories )
    InventoryModule.Inventories.find { _id: $in: id_array }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id }

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id }


# Sells depends on inventory id. Inventory can only be soft delete
# Sells depends on unit_id. On unit delete
                            # Option 1 sells will pass to the parent unit.
                            # Option 2 unit_id will be null
# Sells depends on customer_id. Customers can only be soft deleted
# Sells depends on product_id. Product can only be soft delete
