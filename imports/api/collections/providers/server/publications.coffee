{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

Meteor.publish "providers", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  organization = info.organization
  parentDoc = info.parentDoc

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  # Missing permissions and pagenation
  if @userId?
    return parentDoc.providers()
  else
    @ready();
