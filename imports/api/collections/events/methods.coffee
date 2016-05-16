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



# +++++++++++++++++++ User Event

module.exports.userEvent = new ValidatedMethod
  name: "events.userEvent"
  validate: ({event_doc}) ->
    EventModule.Events.simpleSchema().clean(event_doc)
    EventModule.Events.simpleSchema().validate(event_doc)

  run: ({event_doc}) ->
    mixins.loggedIn(@userId)
    unless @isSimulation
      switch event_doc.for_type
        when 'unit'
          transcation event_doc, @userId, "unitBelongsToOrgan", "Units", "units_manager"
        when 'yield'
          transcation event_doc, @userId, "yieldBelongsToOrgan", "Yields", "units_manager"
        when 'inventory'
          transcation event_doc, @userId, "inventoryBelongsToOrgan", "Inventories", "inventories_manager"


transcation = (event_doc, userId, belongsToM, collection, permission) ->
  mixins.hasPermission(userId, event_doc.organization_id, permission)
  mixins[belongsToM](event_doc.for_id, event_doc.organization_id)

  event_doc.is_user_event = true

  type = collections[collection].findOne event_doc.for_id
  if type.amount + event_doc.amount < 0
    throw new Meteor.Error "amountError", "amount cannot be less then 0"

  # Trans
  collections[collection].update _id: event_doc.for_id,
                                $inc:
                                  amount: event_doc.amount
  EventModule.Events.insert event_doc
  # Trans



# ++++++++++++++++++++++++ App Events
# moving yield to inventory (packaging event)
###
  p.amount == sum(yo.amount_taken/yo.conversation_rate) / p.ingredient.amount when yo.ingredient is p.ingredient for all p.ingredients

  Description
    yield amount taken divide by the yield conversation_rate
    sum with all other yields that share the same ingredient
    divide by the product's ingredient amount
    should equal the amount of increase that the inventory will have.
    This should be true for all the product's ingredients
###

module.exports.packageEvent = new ValidatedMethod
  name: "events.packageEvent"
  validate: ({organization_id, inventory_id, yield_objects, amount}) ->
    unless InventoryModule.Inventories.simpleSchema().newContext().validateOne(yield_objects, 'yield_objects')
      throw new Meteor.Error "validation-error", "yield objects not valid"

    new SimpleSchema(
      organization_id:
        type: String
      inventory_id:
        type: String
      amount:
        type: Number
        min: 0
    ).validate({organization_id, inventory_id, amount})

  run: ({organization_id, inventory_id, yield_objects, amount}) ->
    mixins.loggedIn(@userId)

    unless @isSimulation
      mixins.hasPermission(@userId, organization_id, "inventories_manager")
      inventory = mixins.inventoryBelongsToOrgan(inventory_id, organization_id)
      product = mixins.productBelongsToOrgan(inventory.product_id, organization_id)

      pDictionary = convertToDictionary(product.ingredients, "ingredient_name")
      sums = getSums(yield_objects, pDictionary, organization_id)
      checkAmounts(sums, product, amount)
      updateYields(yield_objects)
      updateInventory(inventory_id, amount)




# moving inventory to sell iteam
# putting back sell item when sell has not been sold




convertToDictionary = (array, key) ->
  dic = {}
  for object in array
    unless object[key]?
      throw new Meteor.Error "keyNull", "object key not found"
    dic[object[key]] = object


getSums = (yield_objects, pDictionary, organization_id) ->
  sums = {}
  for yield_obj in yield_objects
    _yield = mixins.yieldBelongsToOrgan(yield_obj.yield_id, organization_id)

    if yield_obj.amount_taken > _yield.amount
      throw new Meteor.Error "amountTakenError", "amount taken from yield cannot be greater then current amount"

    unless pDictionary[_yield.ingredient_name]?
      throw new Meteor.Error "ingredientError", "this ingredient was not found in product.ingredients"

    if sums[_yield.ingredient_name]?
      sums[_yield.ingredient_name] += (yield_obj.amount_taken / yield_obj.conversation_rate)
    else
      sums[_yield.ingredient_name] = (yield_obj.amount_taken / yield_obj.conversation_rate)

  return sums


checkAmounts = (sums, product, amount) ->
  for ing in product.ingredients
    unless sums[ing.ingredient_name]?
      throw new Meteor.Error "ingredientError", "this ingredient is missing"

    if sums[ing.ingredient_name] / ing.amount isnt amount
      throw new Meteor.Error "ingredientError", "ingredient amount mismatch"


updateYields = (yield_objects) ->
  for yield_obj in yield_objects
    yevent_doc =
      amount: -(yield_obj.amount_taken)
      description: "moved from yield #{yield_obj.yield_id} to inventory #{inventory_id}"
      is_user_event: false
      for_type: "yield"
      for_id: yield_obj.yield_id

    EventModule.Events.simpleSchema().validate(yevent_doc)
    YieldModule.Yields.update {_id: yevent_doc.for_id}, {$inc: amount: yevent_doc.amount}
    EventModule.Events.insert yevent_doc


updateInventory = (inventory_id, amount) ->
  ievent_doc =
    amount: amount
    description: "added to inventory #{inventory_id}"
    is_user_event: false
    for_type: "inventory"
    for_id: inventory_id

  EventModule.Events.simpleSchema().validate(ievent_doc)
  InventoryModule.Inventories.update {_id: ievent_doc.for_id}, {$inc: amount: ievent_doc.amount}
  EventModule.Events.insert ievent_doc
