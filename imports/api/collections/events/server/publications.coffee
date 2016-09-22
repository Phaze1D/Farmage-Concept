{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'
YieldModule = require '../../yields/yields.coffee'
InventoryModule = require '../../inventories/inventories.coffee'
EventModule = require '../events.coffee'


collections = {}
collections.yield = YieldModule.Yields
collections.unit = UnitModule.Units
collections.inventory = InventoryModule.Inventories

Meteor.publish "events", (organization_id, parent, parent_id) ->

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
    return parentDoc.events()
  else
    @ready();


Meteor.publish 'event.parents', (organization_id, event_id) ->

  info = publicationInfo organization_id, 'event', event_id
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  event = EventModule.Events.findOne(event_id)

  unless(event? && event.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.events_manager || permissions.owner)
    return [
      event.for_doc(),
      event.created_by()
    ]

  else
    @ready()
