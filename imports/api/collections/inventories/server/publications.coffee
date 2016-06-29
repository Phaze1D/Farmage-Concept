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
Meteor.publish "inventories", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'


  if @userId? && parentDoc?
    return parentDoc.inventories()
  else
    @ready();

# Missing permissions and pagenation
Meteor.publish 'inventory.parents', (organization_id, inventory_id, yield_objects_count) ->
  info = publicationInfo organization_id, 'inventory', inventory_id
  inventory = InventoryModule.Inventories.findOne inventory_id

  if @userId? && inventory?
    return [
      inventory.product(),
      inventory.yields()
    ]
  else
    @ready()
