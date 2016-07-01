
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

IngredientModule = require './ingredients.coffee'


{
  loggedIn
  hasPermission
  ingredientBelongsToOrgan
} = require '../../mixins/mixins.coffee'


# Insert 
module.exports.insert = new ValidatedMethod
  name: 'ingredient.insert'
  validate: ({ingredient_doc}) ->
    IngredientModule.Ingredients.simpleSchema().clean(ingredient_doc)
    IngredientModule.Ingredients.simpleSchema().validate(ingredient_doc)

  run: ({ingredient_doc}) ->
    loggedIn @userId
    unless @isSimulation
      hasPermission(@userId, ingredient_doc.organization_id, "owner")

    if IngredientModule.Ingredients.findOne( $and: [ { organization_id: ingredient_doc.organization_id }, {name: ingredient_doc.name} ] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

    IngredientModule.Ingredients.insert ingredient_doc
