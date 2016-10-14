{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

ProductModule = require '../products.coffee'
SellModule = require '../../sells/sells.coffee'
IngredientModule = require '../../ingredients/ingredients.coffee'


collections = {}
collections.sell = SellModule.Sells
collections.ingredient = IngredientModule.Ingredients

# Missing permissions and pagenation
Meteor.publish "products", (organization_id, parent, parent_id, limit) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'


  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id) if collections[parent]?
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'


  if @userId? && parentDoc? && (permissions.viewer || permissions.inventories_manager || permissions.owner)
    return parentDoc.products(limit)
  else
    @ready();
