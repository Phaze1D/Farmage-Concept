{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

InventoryModule = require './inventories.coffee'

{
  loggedIn
  hasPermission
  inventoryBelongsToOrgan
  productBelongsToOrgan
  yieldBelongsToOrgan
} = require '../../mixins/mixins.coffee'



# insert
# delete amount and yields[]

module.exports.insert = new ValidatedMethod
  name: 'inventory.insert'
  validate: ({organization_id, inventory_doc}) ->
    InventoryModule.Inventories.simpleSchema().clean(inventory_doc)
    InventoryModule.Inventories.simpleSchema().validate(inventory_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  run: ({organization_id, inventory_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, "inventories_manager")
      productBelongsToOrgan(inventory_doc.product_id, organization_id)

    delete inventory_doc.amount
    delete inventory_doc.yield_objects

    inventory_doc.organization_id = organization_id
    InventoryModule.Inventories.insert inventory_doc

# update
# delete amount yields[] organization_id product_id

module.exports.update = new ValidatedMethod
  name: 'inventory.update'
  validate: ({organization_id, inventory_id, inventory_doc}) ->
    InventoryModule.Inventories.simpleSchema().clean(inventory_doc)
    InventoryModule.Inventories.simpleSchema().validate({$set: inventory_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      inventory_id:
        type: String
    ).validate({organization_id, inventory_id})

  run: ({organization_id, inventory_id, inventory_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, "inventories_manager")
      inventoryBelongsToOrgan(inventory_id, organization_id)

    delete inventory_doc.amount
    delete inventory_doc.yield_objects
    delete inventory_doc.product_id
    delete inventory_doc.organization_id

    InventoryModule.Inventories.update inventory_id, {$set: inventory_doc}
