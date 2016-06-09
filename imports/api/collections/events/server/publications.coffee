{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'
YieldModule = require '../../yields/yields.coffee'
InventoryModule = require '../../inventories/inventories.coffee'

collections = {}
collections.yield = YieldModule.Yields
collections.unit = UnitModule.Units
collections.inventory = InventoryModule.Inventories

Meteor.publish "events", (organization_id, parent, parent_id) ->

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
    return parentDoc.events()
  else
    @ready();
