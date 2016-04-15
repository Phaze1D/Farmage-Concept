{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

InventoryModule = require '../products/products.coffee'
OrganizationModule = require '../organizations/organizations.coffee'


class ProductsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      If a product gets remove check to see if there exists an
      inventory that is not at 0 and ask the user what to do with the left over product
      and then soft delete
    ###
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
      max: 64

    price_excluding_tax:
      type: Number
      label: 'product.price_excluding_tax'
      decimal: true
      min: 0

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

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Products = exports.Products = new ProductsCollection "products"
Products.attachSchema ProductSchema

Products.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Products.helpers
  inventories: ->
    InventoryModule.Inventories.find { product_id: @_id}

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}

  # SKU must be unique to a single organization only
if Meteor.isServer
  multikeys =
    sku: 1
    organization_id: 1

  Products.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error

# Products can only be soft deleted
# * depends on organization_id. If organization is deleted then all * of that organization will be deleted
# * depends on user_id. If user is delete then user_id will change to the current user or owner
