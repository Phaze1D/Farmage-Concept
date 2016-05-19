{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
YieldModule = require '../yields/yields.coffee'
ProductModule = require '../products/products.coffee'



class IngredientsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)


IngredientSchema =
  new SimpleSchema([
    name:
      type: String
      label: 'ingredient'
      max: 128
      denyUpdate: true

    measurement_unit:
      type: String
      label: 'measurement_unit'
      max: 64
      denyUpdate: true

    cost:
      type: Number
      label: 'price of single'
      decimal: true
      min: 0
      autoValue: () ->
        if @isSet
          return parseFloat @value.toFixed(2)

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])


Ingredients = exports.Ingredients = new IngredientsCollection "ingredients"
Ingredients.attachSchema IngredientSchema

Ingredients.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Ingredients.helpers
  products: ->
    ProductModule.Products.find {'ingredients.ingredient_id': @_id} # possible error

  yields: ->
    YieldModule.Yields.find {ingredient_id: @_id}

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Name must be unique to a single organization only
if Meteor.isServer
  multikeys =
    name: 1
    organization_id: 1

  Ingredients.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error
