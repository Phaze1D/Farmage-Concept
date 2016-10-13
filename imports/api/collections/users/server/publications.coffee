{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'


Meteor.publish "ousers", (organization_id, parent, parent_id, limit) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  if organization? &&  organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && parentDoc? && (permissions.users_manager || permissions.viewer || permissions.owner)
    return parentDoc.o_users(limit)
  else
    @ready();


Meteor.publish 'timestamp', (organization_id, created_by, updated_by) ->
  new SimpleSchema(
    organization_id:
      type: String
    created_by:
      type: String
      optional: true
    updated_by:
      type: String
      optional: true

  ).validate({organization_id, created_by, updated_by})

  if @userId?
    return Meteor.users.find($or: [_id: created_by, _id: updated_by])
  else
    @ready()
