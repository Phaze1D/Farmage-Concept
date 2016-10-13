{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

ProductModule = require '../../products/products.coffee'

collections = {}
collections.product = ProductModule.Products



Meteor.publish "ingredients", (organization_id, parent, parent_id, limit) ->

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


  if @userId? && parentDoc? && (permissions.viewer || permissions.owner)
    return parentDoc.ingredients(limit)
  else
    @ready();
