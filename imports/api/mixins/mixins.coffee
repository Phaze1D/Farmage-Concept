OrganizationModule = require '../collections/organizations/organizations.coffee'
ProviderModule = require '../collections/providers/providers.coffee'
ProductModule = require '../collections/products/products.coffee'
CustomerModule = require '../collections/customers/customers.coffee'
UnitModule = require '../collections/units/units.coffee'
YieldModule = require '../collections/yields/yields.coffee'
ExpenseModule = require '../collections/expenses/expenses.coffee'
EventModule = require '../collections/events/events.coffee'
InventoryModule = require '../collections/inventories/inventories.coffee'
IngredientModule = require '../collections/ingredients/ingredients.coffee'
SellModule = require '../collections/sells/sells.coffee'

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
  _yield = YieldModule.Yields.findOne(_id: yield_id)

  unless (_yield? && _yield.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'yield does not belong'

  return _yield


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

module.exports.ingredientBelongsToOrgan = (ingredient_id, organization_id) ->
  ingredient = IngredientModule.Ingredients.findOne(_id: ingredient_id)

  unless (ingredient? && ingredient.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'ingredient does not belong'

  return ingredient


module.exports.sellBelongsToOrgan = (sell_id, organization_id) ->
  sell = SellModule.Sells.findOne(_id: sell_id)

  unless (sell? && sell.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'sell does not belong'

  return sell


module.exports.eventBelongsToOrgan = (event_id, organization_id) ->
  event = EventModule.Events.findOne(_id: event_id)

  unless (event? && event.organization_id is organization_id)
    throw new Meteor.Error 'notAuthorized', 'event does not belong'

  return event
