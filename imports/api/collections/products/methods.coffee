{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

ProductModule  = require './products.coffee'

{
  loggedIn
  hasPermission
  productBelongsToOrgan
  ingredientBelongsToOrgan
} = require '../../mixins/mixins.coffee'


validateDuplicates = (ingredients, organization_id) ->
  ings = {}
  for ingredient in ingredients
    ingredientBelongsToOrgan(ingredient.ingredient_id, organization_id)
    if ings[ingredient.ingredient_id]?
      throw new Meteor.Error 'duplicateIngredients', "Can't have duplicate ingredients"
    else
      ings[ingredient.ingredient_id] = ingredient.ingredient_id

# insert
module.exports.insert = new ValidatedMethod
  name: 'products.insert'
  validate: ({product_doc}) ->
    ProductModule.Products.simpleSchema().clean(product_doc)
    ProductModule.Products.simpleSchema().validate(product_doc)

  run: ({product_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, product_doc.organization_id, "inventories_manager")
      validateDuplicates(product_doc.pingredients, product_doc.organization_id)

    if ProductModule.Products.findOne( $and: [ { organization_id: product_doc.organization_id }, {sku: product_doc.sku} ] )?
      throw new Meteor.Error 'skuNotUnique', 'sku must be unqiue'

    ProductModule.Products.insert product_doc


# update
module.exports.update = new ValidatedMethod
  name: 'products.update'
  validate: ({organization_id, product_id, product_doc}) ->
    ProductModule.Products.simpleSchema().clean({$set: product_doc}, {isModifier: true})
    ProductModule.Products.simpleSchema().validate({$set: product_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      product_id:
        type: String
    ).validate({organization_id, product_id})

  run: ({organization_id, product_id, product_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "inventories_manager")
      productBelongsToOrgan(product_id, organization_id)

    if ProductModule.Products.findOne( $and: [{_id: {$ne: product_id }}, { organization_id: organization_id }, {sku: product_doc.sku}] )?
      throw new Meteor.Error 'skuNotUnique', 'sku must be unqiue'

    delete product_doc.organization_id # Organization ID can't be update
    delete product_doc.pingredients

    ProductModule.Products.update product_id,
                            $set: product_doc
