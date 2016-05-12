{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

EventModule = require './events.coffee'
UnitModule = require '../units/units.coffee'
InventoryModule = require '../inventories/inventories.coffee'
YieldModule = require '../yields/yields.coffee'

mixins = require '../../mixins/mixins.coffee'

collections = {}

collections.Units = UnitModule.Units
collections.Inventories = InventoryModule.Inventories
collections.Yields = YieldModule.Yields

###
  Unlike app events, that are created by the app automaticly,
  user events are created by the user. This ensure that logs that
  keep track of every change that a user made

  Unit amounts can only be affected by user events
  Inventory amounts can be affected by both user events and app events
  Yield amounts can be affected by both user events and app events
###

module.exports.userEvent = new ValidatedMethod
  name: "events.userEvent"
  validate: ({organization_id, event_doc}) ->
    EventModule.Events.simpleSchema().clean(event_doc)
    EventModule.Events.simpleSchema().validate(event_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  run: ({organization_id, event_doc}) ->
    mixins.loggedIn(@userId)
    unless @isSimulation
      switch event_doc.for_type
        when 'unit'
          transcation organization_id, event_doc, @userId, "unitBelongsToOrgan", "Units", "units_manager"
        when 'yield'
          transcation organization_id, event_doc, @userId, "yieldBelongsToOrgan", "Yields", "units_manager"
        when 'inventory'
          transcation organization_id, event_doc, @userId, "inventoryBelongsToOrgan", "Inventories", "inventories_manager"


transcation = (organization_id, event_doc, userId, belongsToM, collection, permission) ->
  hasPermission(userId, organization_id, permission)
  mixins[belongsToM](event_doc.for_id, organization_id)

  event_doc.is_user_event = true
  event_doc.organization_id = organization_id

  type = collections[collection].findOne event_doc.for_id
  if type.amount + event_doc.amount < 0
    throw new Meteor.Error "amountError", "amount cannot be less then 0"

  # Trans
  collections[collection].update _id: event_doc.for_id,
                                $inc:
                                  amount: event_doc.amount
  EventModule.Events.insert event_doc
  # Trans
