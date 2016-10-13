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

Meteor.publish "sells", (organization_id, parent, parent_id, limit) ->

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

  if @userId? && (permissions.viewer || permissions.sells_manager || permissions.owner)
    return parentDoc.sells(limit)
  else
    @ready();


Meteor.publish 'sell.parents', (organization_id, sell_id) ->
  info = publicationInfo organization_id, 'sell', sell_id
  organization = info.organization

  if organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless(organization? && permissions?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  sell = SellModule.Sells.findOne sell_id

  unless(sell? && sell.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.sells_manager || permissions.owner)
    return [
      sell.products(),
      sell.inventories(),
      sell.customer()
    ]
  else
    @ready()
