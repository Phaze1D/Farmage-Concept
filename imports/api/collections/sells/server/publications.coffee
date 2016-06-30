{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

CustomerModule = require '../../customers/customers.coffee'
InventoryModule = require '../../inventories/inventories.coffee'
ProductModule = require '../../products/products.coffee'
SellModule = require '../sells.coffee'

collections = {}
collections.product = ProductModule.Products
collections.customer = CustomerModule.Customers
collections.inventory = InventoryModule.Inventories

# Missing permissions and pagenation
Meteor.publish "sells", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  organization = info.organization
  parentDoc = info.parentDoc

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId?
    return parentDoc.sells()
  else
    @ready();


# Missing permissions and pagenation
Meteor.publish 'sell.parents', (organization_id, sell_id) ->
  info = publicationInfo organization_id, 'sell', sell_id
  sell = SellModule.Sells.findOne sell_id

  if @userId? && sell?
    return [
      sell.products(),
      sell.inventories(),
      sell.customer()
    ]
  else
    @ready()
