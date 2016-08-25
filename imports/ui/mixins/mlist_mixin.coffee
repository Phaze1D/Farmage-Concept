
CustomerModule = require '../../api/collections/customers/customers.coffee'
ExpenseModule = require '../../api/collections/expenses/expenses.coffee'
ProviderModule = require '../../api/collections/providers/providers.coffee'
YieldModule = require '../../api/collections/yields/yields.coffee'
UnitModule = require '../../api/collections/units/units.coffee'
ProductModule = require '../../api/collections/products/products.coffee'
InventoryModule = require '../../api/collections/inventories/inventories.coffee'
EventModule = require '../../api/collections/events/events.coffee'
SellModule = require '../../api/collections/sells/sells.coffee'
IngredientModule = require '../../api/collections/ingredients/ingredients.coffee'


mlists = {}
mlists.ingredients = IngredientModule.Ingredients
mlists.providers = ProviderModule.Providers
mlists.units = UnitModule.Units
mlists.products = ProductModule.Products
mlists.yields = YieldModule.Yields
mlists.inventories = InventoryModule.Inventories
mlists.customers = CustomerModule.Customers




module.exports.mlists = mlists
