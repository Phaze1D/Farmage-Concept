
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

EventModule = require '../events/events.coffee'
InventoryModule = require '../inventories/inventories.coffee'
SellModule = require './sells.coffee'

mixins = require '../../mixins/mixins.coffee'



validateDuplicates = (array, key) ->
  dic = {}
  for object in array
    unless object[key]?
      throw new Meteor.Error "keyNull", "object key not found"

    if dic[object[key]]?
      throw new Meteor.Error "duplicateError", "key #{key} with value #{object[key]} already exists"

    dic[object[key]] = object

  return dic


###
Preorder - Does not take from inventories
         - Auto delete if sell_details is 0
         - Can delete
  Params
    sell_doc (without inventories)

###
preorder = module.exports.preorder = new ValidatedMethod
  name: 'sells.preorder'
  validate: ({sell_doc, isOrder}) ->
    SellModule.Sells.simpleSchema().validate(sell_doc)
    new SimpleSchema(
      isOrder:
        type: Boolean
    ).validate({isOrder})

  run: ({sell_doc, isOrder}) ->
    mixins.loggedIn(@userId)

    unless @isSimulation
      mixins.hasPermission(@userId, sell_doc.organization_id, "sells_manager")
      mixins.customerBelongsToOrgan(sell_doc.customer_id, sell_doc.organization_id) if sell_doc.customer_id?
      validateDuplicates(sell_doc.details, "product_id")
      setupSell(sell_doc)
      sell_doc.status = "preorder"
      delete sell_doc.paid
      delete sell_doc.paid_date
      delete sell_doc.payment_method

    inventories = []
    for detail in sell_doc.details
      inventories.push(inv) for inv in detail.inventories
      delete detail.inventories

    sell_id = SellModule.Sells.insert sell_doc
    organization_id = sell_doc.organization_id

    if isOrder
      order.call({organization_id, sell_id, inventories})

    sell_id


setupSell = (sell_doc) ->
  sell_doc.tax_total = 0
  sell_doc.sub_total = 0
  for detail in sell_doc.details
    product = mixins.productBelongsToOrgan(detail.product_id, sell_doc.organization_id)
    detail.unit_price = product.unit_price
    detail.tax_price = (product.unit_price * detail.quantity) * (product.tax_rate/100)
    sell_doc.tax_total += detail.tax_price
    sell_doc.sub_total += detail.unit_price * detail.quantity

  sell_doc.total_price = sell_doc.tax_total + sell_doc.sub_total

  if sell_doc.discount_type
    sell_doc.total_price -= sell_doc.total_price * sell_doc.discount
  else
    sell_doc.total_price -= sell_doc.discount





###
Order - Takes from inventories when saved
      - Puts back inventories when removed
      - Auto deletes if sell_details is 0
      - Can delete
  Params
    sell_id (of a preorder, optional)
    inventories_array
###
order = module.exports.order = new ValidatedMethod
  name: 'sells.order'
  validate: ({organization_id, sell_id, inventories}) ->
    SellModule.SellDetailsSchema.validate({$set: inventories: inventories}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id, inventories}) ->
    mixins.loggedIn(@userId)

    unless @isSimulation
      mixins.hasPermission(@userId, organization_id, "sells_manager")
      sell = mixins.sellBelongsToOrgan(sell_id, organization_id)
      sellByProduct = validateDuplicates(sell.details, "product_id")
      invByProduct = inventoryCheck(inventories, organization_id, sellByProduct)
      detailsCheck(sell, invByProduct)
      removeFromInventories(sell)

      SellModule.Sells.update {_id: sell_id}, $set:
                                                details: sell.details
                                                status: 'ordered'


#
module.exports.putBack = new ValidatedMethod
  name: 'sells.putBack'
  validate: ({organization_id, sell_id, inventories}) ->

  run: ({organization_id, sell_id, inventories}) ->
    # if it hasnt been paided yet user can put a product back to its inventory
    # Remember to put back and update the sell doc eg total_price, sell_detail.quantity ...


module.exports.paid = new ValidatedMethod
  name: 'sells.paid'
  validate: ({organization_id, sell_id, payment_method}) ->
    SellModule.Sells.simpleSchema().validate({$set: payment_method: payment_method}, modifier: true)

    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id}) ->


module.exports.statusUpdate = new ValidatedMethod
  name: 'sells.statusUpdate'
  validate: ({organization_id, sell_id, status}) ->
    SellModule.Sells.simpleSchema().validate({$set: status: status}, modifier: true)

    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id, status})

  run: ({organization_id, sell_id, status}) ->


module.exports.preorderDelete = new ValidatedMethod
  name: 'sells.preorderDelete'
  validate: ({organization_id, sell_id}) ->
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission(@userId, organization_id, "sells_manager")
      sell = mixins.sellBelongsToOrgan(sell_id, organization_id)

      unless(sell.status is 'preorder' && !sell.paid)
        throw new Meteor.Error "preorderDelete", "only unpaid preorders can be deleted"

      SellModule.Sells.remove sell_id















removeFromInventories = (sell) ->
  for detail in sell.details
    for inv in detail.inventories
      ievent_doc =
        amount: -inv.quantity_taken
        description: "auto remove from inventory #{inv.inventory_id} cause sell #{sell._id}"
        is_user_event: false
        for_type: "inventory"
        for_id: inv.inventory_id
        organization_id: sell.organization_id

      InventoryModule.Inventories.update {_id: ievent_doc.for_id},
                                          $inc:
                                            amount: ievent_doc.amount
      EventModule.Events.insert ievent_doc


inventoryCheck = (inventories, organization_id, sellByProduct) ->
  invByP = {}
  for sinv in inventories
    inventory = mixins.inventoryBelongsToOrgan(sinv.inventory_id, organization_id)

    unless sellByProduct[inventory.product_id]?
      throw new Meteor.Error "productMismatch", "This sell does not include this product"

    if sinv.quantity_taken > inventory.amount
      throw new Meteor.Error "stockError", "Inventory #{inventory._id} does not have enough"

    unless invByP[inventory.product_id]?
      invByP[inventory.product_id] = []

    invByP[inventory.product_id].push sinv

  return invByP

detailsCheck = (sell, invByP) ->
  for detail in sell.details
    unless invByP[detail.product_id]?
      throw new Meteor.Error "inventoryMissing", "You must mention from which inventory to take from"

    validateDuplicates(invByP[detail.product_id], "inventory_id")

    quantitySum = 0
    for inv in invByP[detail.product_id]
      quantitySum += inv.quantity_taken

    unless quantitySum == detail.quantity
      throw new Meteor.Error "quantityMismatch", "detail quantity does not match inventory taken quantity"

    detail.inventories = invByP[detail.product_id]






###
Canceled - Cannot take from inventories
         - Cannot remove sell_details
         - Ask user if they would like to return items to inventories
         - Cannot delete
  Params
    sell_id (of order)
    putBack (boolean to determine putBack inventories)

###





###
Delivered & Paid - Just status updates
            - Cannot take from inventories
            - Cannot delete
            - Cannot remove sell_details
  Params
    sell_id (of order)
    status (Delivered or Paid)

Returned - Cannot take from inventories
         - Cannot remove sell_details
         - Ask user if they would like to return items to inventories
         - Cannot delete
  Params
    sell_id (of order)
    putBack (boolean to determine putBack inventories)
###

###
  PutBack Method
###
