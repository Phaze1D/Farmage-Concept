{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

SellModule = require '../../sells/sells.coffee'
IngredientModule = require '../../ingredients/ingredients.coffee'

collections = {}
collections.sell = SellModule.Sells
collections.ingredient = IngredientModule.Ingredients

Meteor.publish "products", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'


  # Missing permissions and pagenation
  if @userId? && parentDoc?
    return parentDoc.products()
  else
    @ready();
