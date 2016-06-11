{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'


Meteor.publish "ousers", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  # Missing permissions and pagenation
  if @userId? && parentDoc?
    return parentDoc.o_users() # does not return update
    # Meteor.users.find() does
  else
    @ready();
