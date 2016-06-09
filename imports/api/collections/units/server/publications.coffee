{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'


collections = {}
collections.unit = UnitModule.Units


Meteor.publish "units", (organization_id, parent, parent_id) ->

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
    return parentDoc.units()
  else
    @ready();
