{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'
ProviderModule = require '../../providers/providers.coffee'
ReceiptModule = require '../../receipts/receipts.coffee'


collections = {}
collections.unit = UnitModule.Units
collections.provider = ProviderModule.Providers
collections.receipt = ReceiptModule.Receipts


Meteor.publish "expenses", (organization_id, parent, parent_id) ->

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
    return parentDoc.expenses()
  else
    @ready();
