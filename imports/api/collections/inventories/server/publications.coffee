{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

ProductModule = require '../../products/products.coffee'
YieldModule = require '../../yields/yields.coffee'
SellModule = require '../../sells/sells.coffee'
InventoryModule = require '../inventories.coffee'

collections = {}
collections.product = ProductModule.Products
collections.yield = YieldModule.Yields
collections.sell = SellModule.Sells

# Missing permissions and pagenation
Meteor.publish "inventories", (organization_id, parent, parent_id, search, limit) ->

  new SimpleSchema(
    search:
      type: String
      optional: true
  ).validate({search: search})

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
    # Meteor._sleepForMs(3000);
    return parentDoc.inventories(limit, search)
  else
    @ready();

# Missing permissions and pagenation
Meteor.publish 'inventory.parents', (organization_id, inventory_id, yield_objects_count) ->
  info = publicationInfo organization_id, 'inventory', inventory_id
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  inventory = InventoryModule.Inventories.findOne inventory_id
  unless(inventory? && inventory.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'


  if @userId? && (permissions.viewer || permissions.inventories_manager || permissions.owner)
    return [
      inventory.product(),
      inventory.yields()
    ]
  else
    @ready()
