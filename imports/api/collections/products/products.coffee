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

IngredientSchema =
  new SimpleSchema(
    ingredient_name: # Single do not use pural
      type: String
      label: 'ingredient'
      max: 128
      denyUpdate: true
      autoValue: () ->
        if @isSet
          return @value.toLowerCase().replace(/\s+/g,' ').trim();

    amount:
      type: Number
      label: 'product.package_amount'
      decimal: true
      min: 0
      denyUpdate: true
      autoValue: () ->
        if @isSet
          return Number(@value.toFixed(10))

    measurement_unit: # Trim and downcase
      type: String
      label: 'measurement_unit'
      max: 64
      denyUpdate: true
      autoValue: () ->
        if @isSet
          return @value.toLowerCase().replace(/\s+/g,' ').trim();
  )


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
      max: 512
      optional: true

    sku:
      type: String
      label: 'SKU'
      index: true
      max: 64
      custom: () ->
        if @isSet
          if /\s/g.test(@value)
            throw new Meteor.Error "regExError", "Cannot contain whitespaces"


    unit_price: # Excluding tax
      type: Number
      label: 'product.unit_price'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

    currency:
      type: String
      label: 'currency_ISO_4217'
      max: 3

    tax_rate:
      type: Number
      label: 'tax_rate'
      decimal: true
      max: 100
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(5)

    ingredients: # this array cannot contain items that have the same ingredient_name
      type: [IngredientSchema]
      label: 'ingredients'
      denyUpdate: true
      minCount: 1
      maxCount: 100

    product_image_url:
      type: String
      optional: true
      regEx: SimpleSchema.RegEx.Url

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
