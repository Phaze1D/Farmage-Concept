
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
    SellModule.Sells.simpleSchema().clean(sell_doc)
    SellModule.Sells.simpleSchema().validate(sell_doc)
  run: ({sell_doc}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, sell_doc.organization_id, 'sells_manager'
      mixins.customerBelongsToOrgan sell_doc.customer_id, sell_doc.organization_id if sell_doc.customer_id?
      validateDuplicates sell_doc.details, 'product_id'
      setupSell sell_doc
      removeInventoriesFields sell_doc
      removeZeroDetail sell_doc
      removePaidFields sell_doc
    SellModule.Sells.insert sell_doc


module.exports.update = new ValidatedMethod
  name: 'sells.update'
  validate: ({organization_id, sell_id, sell_doc}) ->
    SellModule.Sells.simpleSchema().clean({$set: sell_doc}, {isModifier: true})
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
      setDiscount(sell, sell_doc)
      sell_doc.organization_id = organization_id

      if sell.paid
        modifyPaid sell_doc, organization_id
      else
        modifyUnPaid sell_doc, organization_id, sell

      removeUnauthUpdateFields sell_doc
      SellModule.Sells.update sell_id,
                              $set: sell_doc



module.exports.addItems = new ValidatedMethod
  name: 'sells.addItems'
  validate: ({organization_id, sell_id, inventories}) ->
    SellModule.SellDetailsSchema.validate({$set: inventories: inventories}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id, inventories}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, organization_id, 'sells_manager'
      sell = mixins.sellBelongsToOrgan sell_id, organization_id
      if sell.paid
        throw new Meteor.Error 'itemError', 'Cannot add items after sell has been paid'

      validateDuplicates(inventories, 'inventory_id')
      invsByProduct = checkAddInventories(inventories, organization_id)
      addToDetailInventories(sell, invsByProduct)
      setQuantities(sell)
      removeZeroDetail(sell)
      setupSell(sell, sell)
      updateInventories(inventories, -1, sell)
      removeUnauthUpdateFields(sell)
      SellModule.Sells.simpleSchema().clean(sell)
      SellModule.Sells.update sell_id,
                              $set: sell



module.exports.putBackItems = new ValidatedMethod
  name: 'sells.putBackItems'
  validate: ({organization_id, sell_id, inventories}) ->
    SellModule.SellDetailsSchema.validate({$set: inventories: inventories}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})

  run: ({organization_id, sell_id, inventories}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, organization_id, 'sells_manager'
      sell = mixins.sellBelongsToOrgan sell_id, organization_id
      if sell.paid
        throw new Meteor.Error 'itemError', 'Cannot remove items after sell has been paid'

      validateDuplicates(inventories, 'inventory_id')
      invsByProduct = checkPutBackInventories(inventories, organization_id)
      putBackInventories(sell, invsByProduct)
      setQuantities(sell)
      removeZeroDetail(sell)
      setupSell(sell, sell)
      updateInventories(inventories, 1, sell)
      removeUnauthUpdateFields(sell)
      SellModule.Sells.simpleSchema().clean(sell)
      SellModule.Sells.update sell_id,
                              $set: sell



module.exports.pay = new ValidatedMethod
  name: 'sells.pay'
  validate: ({organization_id, sell_id, payment_method}) ->
    SellModule.Sells.simpleSchema().validate({$set: payment_method: payment_method}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      sell_id:
        type: String
    ).validate({organization_id, sell_id})
  run: ({organization_id, sell_id, payment_method}) ->
    mixins.loggedIn @userId

    unless @isSimulation
      mixins.hasPermission @userId, organization_id, 'sells_manager'
      sell = mixins.sellBelongsToOrgan sell_id, organization_id

      if sell.paid
        throw new Meteor.Error 'payError', 'sell has already been paid'

      for detail in sell.details
        unless detail.inventories? & detail.inventories.length > 0
          throw new Meteor.Error 'payError', 'Cannot paid sell that has no physical items'

        sum = 0
        sum += inv.quantity_taken for inv in detail.inventories

        unless sum is detail.quantity
          throw new Meteor.Error 'detailMismatch', 'Detail quantity and inventories quantities dont match'

      setupSell(sell, sell)
      removeUnauthUpdateFields(sell)

      sell.paid = true
      sell.payment_method = payment_method

      SellModule.Sells.simpleSchema().clean(sell)
      SellModule.Sells.update sell_id,
                              $set: sell



remove = module.exports.remove = new ValidatedMethod
  name: 'sells.remove'
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





setDiscount = (sell, sell_doc) ->
  unless sell_doc.discount?
    sell_doc.discount = sell.discount
  unless sell_doc.discount_type?
    sell_doc.discount_type = sell.discount_type

removeUnauthUpdateFields = (sell_doc) ->
  delete sell_doc._id
  delete sell_doc.organization_id
  delete sell_doc.created_user_id
  delete sell_doc.createdAt

removePaidFields = (sell_doc) ->
  delete sell_doc.paid
  delete sell_doc.paid_date
  delete sell_doc.payment_method

convertToDict = (array, key) ->
  dic = {}
  for item in array
    if item[key]?
      dic[item[key]] = item
  dic

setupSell = (sell_doc, previousSell) ->
  resetSell sell_doc

  if previousSell?
    preSellDict = convertToDict previousSell.details, 'product_id'

  for detail in sell_doc.details
    product = mixins.productBelongsToOrgan detail.product_id, sell_doc.organization_id
    detail.unit_price = if previousSell? && preSellDict[detail.product_id]? then preSellDict[detail.product_id].unit_price else product.unit_price
    detail.tax_rate = if previousSell? && preSellDict[detail.product_id]? then preSellDict[detail.product_id].tax_rate else product.tax_rate
    sell_doc.sub_total += detail.unit_price * detail.quantity
    sell_doc.tax_total += (detail.unit_price * detail.quantity) * (detail.tax_rate/100)

  calculateTotal(sell_doc)

calculateTotal = (sell_doc) ->
  sell_doc.total_price = sell_doc.sub_total + sell_doc.tax_total
  sell_doc.discount = 0 unless sell_doc.discount?
  if sell_doc.discount_type
    sell_doc.total_price = sell_doc.total_price - (sell_doc.total_price * sell_doc.discount/100)
  else if sell_doc.total_price > sell_doc.discount
      sell_doc.total_price = sell_doc.total_price - sell_doc.discount
  else if sell_doc.total_price < sell_doc.discount
    sell_doc.total_price = 0

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
  detail.inventories = [] for detail in sell_doc.details

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

modifyUnPaid = (sell_doc, organization_id, sell) ->
  mixins.customerBelongsToOrgan sell_doc.customer_id, organization_id if sell_doc.customer_id?
  removePaidFields sell_doc
  if sell_doc.details?
    removeInventoriesFields sell_doc
    addSavedDetails sell_doc, sell
    setupSell sell_doc, sell
    removeZeroDetail sell_doc

addSavedDetails = (sell_doc, savedSell) ->
  sdD = validateDuplicates sell_doc.details, 'product_id'

  for detail in savedSell.details
    if sdD[detail.product_id]?
      sdD[detail.product_id].inventories = detail.inventories
    else
      sell_doc.details.push detail

removeZeroDetail = (sell_doc) ->
  sell_doc.details = (detail for detail in sell_doc.details when detail.quantity isnt 0 || detail.inventories.length > 0)

setQuantities = (sell) ->
  for detail in sell.details
    if detail.inventories? && detail.inventories.length > 0
      detail.quantity = 0
      detail.inventories = (dinv for dinv in detail.inventories when dinv.quantity_taken isnt 0)
      for inv in detail.inventories
        detail.quantity += inv.quantity_taken

addToDetailInventories = (sell, invsByProduct) ->
  for detail in sell.details
    dinvByIDs = validateDuplicates(detail.inventories, 'inventory_id')

    if invsByProduct[detail.product_id]?
      for inv in invsByProduct[detail.product_id]
        if dinvByIDs[inv.inventory_id]?
          dinvByIDs[inv.inventory_id].quantity_taken += inv.quantity_taken
        else
          detail.inventories.push inv

    delete invsByProduct[detail.product_id]

  addProductWithInventories(sell, invsByProduct)

addProductWithInventories = (sell, invsByProduct) ->
  for key, value of invsByProduct
    deta =
      product_id: key
      inventories: value
    sell.details.push deta

checkAddInventories = (inventories, organization_id) ->
  invsByProduct = {}
  for inv in inventories
    inventory = mixins.inventoryBelongsToOrgan inv.inventory_id, organization_id
    if inv.quantity_taken > inventory.amount
      throw new Meteor.Error 'quantityError', "inventory #{inventory._id} only has #{inventory.amount}"

    invsByProduct[inventory.product_id] = [] unless invsByProduct[inventory.product_id]?
    invsByProduct[inventory.product_id].push inv
  invsByProduct

checkPutBackInventories = (inventories, organization_id) ->
  invsByProduct = {}
  for inv in inventories
    inventory = mixins.inventoryBelongsToOrgan inv.inventory_id, organization_id
    invsByProduct[inventory.product_id] = [] unless invsByProduct[inventory.product_id]?
    invsByProduct[inventory.product_id].push inv
  invsByProduct

putBackInventories = (sell, invsByProduct) ->
  for detail in sell.details
    dinvByIDs = validateDuplicates(detail.inventories, 'inventory_id')

    if invsByProduct[detail.product_id]?
      for inv in invsByProduct[detail.product_id]
        unless dinvByIDs[inv.inventory_id]? # if inventory does not exist
          throw new Meteor.Error 'putBackError', 'Cannot remove item that has not been added'

        if dinvByIDs[inv.inventory_id].quantity_taken < inv.quantity_taken
          throw new Meteor.Error 'putBackError', "Cannot remove more then #{dinvByIDs[inv.inventory_id].quantity_taken}"

        dinvByIDs[inv.inventory_id].quantity_taken -= inv.quantity_taken

      delete invsByProduct[detail.product_id]

  unless Object.keys(invsByProduct).length is 0 # if product does not exist
    throw new Meteor.Error 'putBackError', 'Cannot remove item that has not been added'

updateInventories = (inventories, sign, sell) ->
  for inv in inventories
    ievent_doc =
      amount: inv.quantity_taken * sign
      description: "inventory #{inv.inventory_id} move sell #{sell._id} sign #{sign}"
      is_user_event: false
      for_type: "inventory"
      for_id: inv.inventory_id
      organization_id: sell.organization_id

    EventModule.Events.simpleSchema().validate(ievent_doc)
    InventoryModule.Inventories.update {_id: ievent_doc.for_id},
                                        $inc:
                                          amount: ievent_doc.amount
    EventModule.Events.insert ievent_doc
