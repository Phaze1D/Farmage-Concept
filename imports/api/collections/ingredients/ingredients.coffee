{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'

# NOT Finished add Unqiue ignore case


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
      max: 128
      denyUpdate: true

    measurement_unit:
      type: String
      max: 64
      denyUpdate: true

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



# Name must be unique to a single organization only
if Meteor.isServer
  multikeys =
    name: 1
    organization_id: 1

  Ingredients.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error
