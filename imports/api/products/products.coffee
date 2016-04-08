{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../timestamps.coffee'


class ProductsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
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

    measurement_unit:
      type: String
      label: 'measurement_unit'
      max: 64

    quantity:
      type: Number
      label: 'product.quantity'
      decimal: true
      min: 0

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


  , TimestampSchema])

  # SKU must be unique to a single organization only
