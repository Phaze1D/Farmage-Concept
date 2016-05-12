OrganizationModule = require '../collections/organizations/organizations.coffee'
ProviderModule = require '../collections/providers/providers.coffee'
ProductModule = require '../collections/products/products.coffee'
CustomerModule = require '../collections/customers/customers.coffee'
UnitModule = require '../collections/units/units.coffee'
YieldModule = require '../collections/yields/yields.coffee'
ReceiptModule = require '../collections/receipts/receipts.coffee'
ExpenseModule = require '../collections/expenses/expenses.coffee'
InventoryModule = require '../collections/inventories/inventories.coffee'

module.exports.loggedIn = (user_id) ->
  unless user_id?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


module.exports.hasPermission = (user_id, organization_id, type) ->
  organization = OrganizationModule.Organizations.findOne(_id: organization_id)
  unless organization?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  user = organization.hasUser(user_id)
  unless( user? && (user.permission[type] || user.permission["owner"]) )
    throw new Meteor.Error 'permissionDenied', 'permission denied'

  return organization


module.exports.userBelongsToOrgan = (user_id, organization_id) ->
  organization = OrganizationModule.Organizations.findOne(_id: organization_id)

  unless( organization? && organization.hasUser(user_id)? )
    throw new Meteor.Error 'notAuthorized', 'user does not belong'


module.exports.unitBelongsToOrgan = (unit_id, organization_id) ->
  unit = UnitModule.Units.findOne(_id: unit_id)

  unless(unit? && unit.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'unit does not belong'

  return unit


module.exports.customerBelongsToOrgan = (customer_id, organization_id) ->
  customer = CustomerModule.Customers.findOne(_id: customer_id)

  unless (customer? && customer.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'customer does not belong'

  return customer


module.exports.productBelongsToOrgan = (product_id, organization_id) ->
  product = ProductModule.Products.findOne(_id: product_id)

  unless (product? && product.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'product does not belong'

  return product


module.exports.providerBelongsToOrgan = (provider_id, organization_id) ->
  provider = ProviderModule.Providers.findOne(_id: provider_id)

  unless (provider? && provider.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'provider does not belong'

  return provider


module.exports.yieldBelongsToOrgan = (yield_id, organization_id) ->
  yield_ = YieldModule.Yields.findOne(_id: yield_id)

  unless (yield_? && yield_.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'yield does not belong'

  return yield_


module.exports.receiptBelongsToOrgan = (receipt_id, organization_id) ->
  receipt = ReceiptModule.Receipts.findOne(_id: receipt_id)

  unless (receipt? && receipt.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'receipt does not belong'

  return receipt

module.exports.expenseBelongsToOrgan = (expense_id, organization_id) ->
  expense = ExpenseModule.Expenses.findOne(_id: expense_id)

  unless (expense? && expense.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'expense does not belong'

  return expense


module.exports.inventoryBelongsToOrgan = (inventory_id, organization_id) ->
  inventory = InventoryModule.Inventories.findOne(_id: inventory_id)

  unless (inventory? && inventory.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'inventory does not belong'

  return inventory
