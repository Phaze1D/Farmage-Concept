{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../timestamps.coffee'


class ProductsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    # If a product gets remove check to see if there exists an
    # inventory that is not at 0 and ask the user what to do with the left over product
    super(selector, callback)


ProductSchema =
  new SimpleSchema([
    name:
      type: String
      label: 'product.name'
      index: true
      max: 64

    description:
      type: String
      label: 'description'
      max: 256
      optional: true

    sku:
      type: String
      label: 'SKU'
      index: true
      unique: true
      max: 64

    price:
      type: Number
      label: 'product.price_without_tax'
      decimal: true

    package_amount:
      type: Number
      label: 'product.quantity'
      decimal: true
      min: 0
      denyUpdate: true

    measurement_unit:
      type: String
      label: 'measurement_unit'
      max: 64
      denyUpdate: true

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3

    tax_rate:
      type: Number
      label: 'tax_rate'
      decimal: true
      max: 100

    product_image_url:
      type: String
      optional: true

    organization_id: # Think about adding autoValue for this field
      type: String
      index: true

  , TimestampSchema])

Products= exports.Products = new CustomersCollection "products"
Products.attachSchema ProductSchema

Products.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

  # SKU must be unique to a single organization only
if Meteor.isServer
  multikeys =
    sku: 1
    organization_id: 1

  Products.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error
