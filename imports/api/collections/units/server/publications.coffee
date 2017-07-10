{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'


collections = {}
collections.unit = UnitModule.Units

# Missing permissions and pagenation
Meteor.publish "units", (organization_id, parent, parent_id, search, limit) ->

  new SimpleSchema(
    search:
      type: String
      optional: true
  ).validate({search: search})

  info = publicationInfo organization_id, parent, parent_id
  organization = info.organization
  parentDoc = info.parentDoc

  if organization? &&  organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id) if collections[parent]?
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.units_manager || permissions.owner)
    return parentDoc.units(limit, search)
  else
    @ready();

# Missing permissions and pagenation
Meteor.publish 'unit.parent', (organization_id, unit_id) ->
  info = publicationInfo organization_id, 'unit', unit_id
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unit = UnitModule.Units.findOne unit_id
  unless(unit? && unit.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.units_manager || permissions.owner)
    return unit.unit()
  else
    @ready()
