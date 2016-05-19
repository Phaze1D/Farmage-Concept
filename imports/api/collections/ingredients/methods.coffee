
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


# Insert Customer
module.exports.insert = new ValidatedMethod
  name: 'ingredient.insert'
  validate: ({ingredient_doc}) ->
    IngredientModule.Ingredients.simpleSchema().clean(ingredient_doc)
    IngredientModule.Ingredients.simpleSchema().validate(ingredient_doc)

  run: ({ingredient_doc}) ->
    loggedIn @userId
    unless @isSimulation
      hasPermission(@userId, ingredient_doc.organization_id, "units_manager")

    if IngredientModule.Ingredients.findOne( $and: [ { organization_id: ingredient_doc.organization_id }, {name: ingredient_doc.name} ] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

    IngredientModule.Ingredients.insert ingredient_doc

# Update
module.exports.update = new ValidatedMethod
  name: 'ingredient.update'
  validate: ({organization_id, ingredient_id, ingredient_doc}) ->
    IngredientModule.Ingredients.simpleSchema().clean(ingredient_doc)
    IngredientModule.Ingredients.simpleSchema().validate({$set: ingredient_doc}, modifier: true)

    new SimpleSchema(
      ingredient_id:
        type: String

      organization_id:
        type: String
    ).validate({ingredient_id, organization_id})

  run: ({organization_id, ingredient_id, ingredient_doc}) ->
    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "units_manager")
      ingredientBelongsToOrgan(ingredient_id, organization_id)

    delete ingredient_doc.organization_id # Organization ID can't be update
    delete ingredient_doc.name
    delete ingredient_doc.measurement_unit

    if IngredientModule.Ingredients.findOne( $and: [{_id: {$ne: ingredient_id }}, { organization_id: organization_id }, {name: ingredient_doc.name}] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'


    IngredientModule.Ingredients.update ingredient_id,
                                        $set: ingredient_doc
