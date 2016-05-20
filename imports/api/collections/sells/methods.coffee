
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

EventModule = require '../events/events.coffee'
SellModule = require './sells.coffee'

mixins = require '../../mixins/mixins.coffee'



validateDuplicates = (array, key) ->
  dic = {}
  for object in array
    throw new Meteor.Error "keyNull", "object key not found" unless object[key]?
    throw new Meteor.Error "duplicate", "there is already one #{key}" if dic[object[key]]?
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
  for detail in sell_doc.details
    product = mixins.productBelongsToOrgan(detail.product_id, sell_doc.organization_id)
    detail.unit_price = product.unit_price
    detail.tax_price = product.unit_price * product.tax_rate
    sell_doc.tax_total += detail.tax_price
    sell_doc.sub_total += detail.unit_price

  sell_doc.total_price = sell_doc.tax_total + sell_doc.sub_total

  if sell_doc.discount_type
    sell_doc.total_price -= sell_doc.total_price * sell_doc.discount
  else
    sell_doc.total_price -= sell_doc.discount

  sell_doc.status = "preorder"





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
      sDeD = validateDuplicates(sell.details, "product_id")
      invByP = {}

      for sinv in inventories
        inventory = inventoryBelongsToOrgan(sinv.inventory_id, organization_id)
        throw new Meteor.Error "productMismatch", "This sell does not include this product" if sDeD[inventory.product_id]
        invByP[inventory.product_id] = [] unless invByP[inventory.product_id]?
        invByP[inventory.product_id].push sinv


      for detail in sell.details
        throw new Meteor.Error "inventoryMissing", "You must mention from which inventory to take from" unless invByP[detail.product_id]?
        validateDuplicates(invByP[detail.product_id], "inventory_id")
        detail.inventories = invByP[detail.product_id]

      SellModule.Sells.update {_id: sell_id}, {$set: details: sell.details}



###
Canceled - Cannot take from inventories
         - Cannot remove sell_details
         - Ask user if they would like to return items to inventories
         - Cannot delete
  Params
    sell_id (of order)
    putBack (boolean to determine putBack inventories)

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
