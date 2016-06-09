{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

ProductModule = require '../../products/products.coffee'

collections = {}
collections.product = ProductModule.Products



Meteor.publish "ingredients", (organization_id, parent, parent_id) ->

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
    return parentDoc.ingredients()
  else
    @ready();
