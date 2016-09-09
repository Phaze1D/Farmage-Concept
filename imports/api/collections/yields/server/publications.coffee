{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

YieldModule = require '../yields.coffee'
UnitModule = require '../../units/units.coffee'
IngredientModule = require '../../ingredients/ingredients.coffee'
InventoryModule = require '../../inventories/inventories.coffee'


collections = {}
collections.unit = UnitModule.Units
collections.ingredient = IngredientModule.Ingredients
collections.inventory = InventoryModule.Inventories

# Missing permissions and pagenation
Meteor.publish "yields", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  organization = info.organization
  parentDoc = info.parentDoc

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.units_manager || permissions.owner)
    return parentDoc.yields()
  else
    @ready();

# Missing permissions and pagenation
Meteor.publish 'yield.parents', (organization_id, yield_id) ->
  info = publicationInfo organization_id, 'yield', yield_id
  organization = info.organization

  if organization? &&  organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  _yield = YieldModule.Yields.findOne yield_id
  unless(_yield? && _yield.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.units_manager || permissions.owner)
    return [
      _yield.ingredient(),
      _yield.unit()
    ]
  else
    @ready()
