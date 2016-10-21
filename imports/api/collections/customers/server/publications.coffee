{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

Meteor.publish "customers", (organization_id, parent, parent_id, search, limit) ->

  new SimpleSchema(
    search:
      type: String
      optional: true
  ).validate({search: search})

  info = publicationInfo organization_id, parent, parent_id
  organization = info.organization
  parentDoc = info.parentDoc

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.sells_manager || permissions.viewer || permissions.owner)
    # Meteor._sleepForMs(10000);
    return parentDoc.customers(limit, search)
  else
    @ready();
