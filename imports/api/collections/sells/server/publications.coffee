{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

CustomerModule = require '../../customers/customers.coffee'
InventoryModule = require '../../inventories/inventories.coffee'
ProductModule = require '../../products/products.coffee'

collections = {}
collections.product = ProductModule.Products
collections.customer = CustomerModule.Customers
collections.inventory = InventoryModule.Inventories

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

  # Missing permissions and pagenation
  if @userId?
    return parentDoc.sells()
  else
    @ready();
