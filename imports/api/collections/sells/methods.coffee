
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

EventModule = require '../events/events.coffee'
InventoryModule = require '../inventories/inventories.coffee'
SellModule = require './sells.coffee'

mixins = require '../../mixins/mixins.coffee'


###
  create a sell
  update items (if sell has not been paid)
  update sell
  delete a sell (if items have not been scanned and has not been paid)
###


###
What can be updated after sell has been paid

InventoryAssociationSchema =
    quantity_taken: no
    inventory_id: no

SellDetailsSchema =
    product_id: no
    quantity: no
    unit_price: no
    tax_price: no
    inventories: no (inventories cannot be update in updateSell)

SellSchema =
    sub_total: no
    tax_total: no
    discount: no
    discount_type: no
    total_price: no
    currency: no
    details: no
    status: yes
    paid: no
    paid_date: no
    payment_method: no
    receipt_id: yes
    note: yes
    customer_id: no
    shipping_address: yes
    telephone: yes
    organization_id: never
###


module.exports.insert = new ValidatedMethod
  name: 'sells.insert'
  validate: ({sell_doc}) ->
    SellModule.Sells.simpleSchema().validate(sell_doc)
  run: ({sell_doc}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, sell_doc.organization_id, 'sells_manager'
      mixins.customerBelongsToOrgan sell_doc.customer_id, sell_doc.organization_id
      validateDuplicates sell_doc.details, 'product_id'
      setupSell sell_doc
      removeZeroDetail sell_doc
      removePaidFields sell_doc
      removeInventoriesFields sell_doc

    SellModule.Sells.insert sell_doc


module.exports.updateSell = new ValidatedMethod
  name: 'sells.updateSell'
  validate: ({organization_id, sell_id, sell_doc}) ->
    SellModule.Sells.simpleSchema().validate({$set: sell_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id, sell_doc}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, organization_id, 'sells_manager'
      sell = mixins.sellBelongsToOrgan sell_id, organization_id
      delete sell_doc.organization_id

      if sell.paid
        modifyPaid sell_doc, organization_id
      else
        modifyUnPaid sell_doc, organization_id
        return deleteSell.call organization_id, sell_id if sell_doc.total_price is 0


      SellModule.Sells.update sell_id,
                              $set: sell_doc


module.exports.addItems = new ValidatedMethod
  name: 'sells.addItems'
  validate: ({organization_id, sell_id, inventories}) ->

  run: ({organization_id, sell_id, inventories}) ->


module.exports.putBackItems = new ValidatedMethod
  name: 'sells.putBackItems'
  validate: ({organization_id, sell_id, inventories}) ->

  run: ({organization_id, sell_id, inventories}) ->


module.exports.pay = new ValidatedMethod
  name: 'sells.pay'
  validate: () ->

  run: () ->


deleteSell = module.exports.deleteSell = new ValidatedMethod
  name: 'sells.deleteSell'
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
      mixins.hasPermission @userId, organization_id, 'sells_manager'
      sell = mixins.sellBelongsToOrgan sell_id, organization_id

      if sell.paid
        throw new Meteor.Error 'deleteError', 'Cannot delete a sell that is already paid'

      for detail in sell.details
        if detail.inventories? && detail.inventories.length > 0
          throw new Meteor.Error 'deleteError', 'Please put back all items first before deleting'

    SellModule.Sells.remove sell_id





removePaidFields = (sell_doc) ->
  delete sell_doc.paid
  delete sell_doc.paid_date
  delete sell_doc.payment_method

setupSell = (sell_doc) ->
  resetSell sell_doc

  for detail in sell_doc.details
    product = mixins.productBelongsToOrgan detail.product_id, sell_doc.organization_id
    detail.unit_price = product.unit_price
    detail.tax_rate = product.tax_rate
    sell_doc.sub_total += detail.unit_price * detail.quantity
    sell_doc.tax_total += (detail.unit_price * detail.quantity) * (detail.tax_rate/100)

  calculateTotal(sell_doc)

calculateTotal = (sell_doc) ->
  sell_doc.total_price = sell_doc.sub_total + sell_doc.tax_total

  if sell_doc.discount_type
    sell_doc.total_price = sell_doc.total_price - (sell_doc.total_price * sell_doc.discount)
  else
    sell_doc.total_price = sell_doc.total_price - sell_doc.discount if sell_doc.total_price > 0

resetSell = (sell_doc) ->
  sell_doc.sub_total = 0
  sell_doc.tax_total = 0
  sell_doc.total_price = 0

validateDuplicates = (array, key) ->
  dic = {}
  for object in array
    unless object[key]?
      throw new Meteor.Error 'keyNull', 'key not found'
    if dic[object[key]]?
      throw new Meteor.Error 'duplicateError', "key #{object[key]} already exist"
    dic[object[key]] = object
  dic

removeInventoriesFields = (sell_doc) ->
  delete detail.inventories for detail in sell_doc.details

modifyPaid = (sell_doc, organization_id) ->
  delete sell_doc.sub_total
  delete sell_doc.tax_total
  delete sell_doc.discount
  delete sell_doc.discount_type
  delete sell_doc.total_price
  delete sell_doc.currency
  delete sell_doc.details
  delete sell_doc.paid
  delete sell_doc.paid_date
  delete sell_doc.payment_method
  delete sell_doc.customer_id

modifyUnPaid = (sell_doc, organization_id) ->
  mixins.customerBelongsToOrgan sell_doc.customer_id, organization_id if sell_doc.customer_id?
  removePaidFields sell_doc
  if sell_doc.details?
    validateDuplicates sell_doc.details, 'product_id'
    setupSell sell_doc
    removeZeroDetail sell_doc
    removeInventoriesFields sell_doc

removeZeroDetail = (sell_doc) ->
  sell_doc.details = (detail for detail in sell_doc.details when detail.quantity isnt 0)
