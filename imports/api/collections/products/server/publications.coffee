{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

ProductModule = require '../products.coffee'
SellModule = require '../../sells/sells.coffee'
IngredientModule = require '../../ingredients/ingredients.coffee'


collections = {}
collections.sell = SellModule.Sells
collections.ingredient = IngredientModule.Ingredients

# Missing permissions and pagenation
Meteor.publish "products", (organization_id, parent, parent_id) ->
  
  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'


  if @userId? && parentDoc? && (permissions.viewer || permissions.inventories_manager || permissions.owner)
    return parentDoc.products()
  else
    @ready();


# Missing permissions and pagenation
Meteor.publish 'product.ingredients', (organization_id, product_id) ->
  info = publicationInfo organization_id, 'product', product_id
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  product = ProductModule.Products.findOne(product_id)
  unless(product? && product.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.inventories_manager || permissions.owner)
    return product.ingredients()
  else
    @ready()
