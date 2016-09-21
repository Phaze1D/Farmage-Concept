
require './users/users.coffee'
OrganizationModule = require './organizations/organizations.coffee'
CustomerModule = require './customers/customers.coffee'
ExpenseModule = require './expenses/expenses.coffee'
ProviderModule = require './providers/providers.coffee'
YieldModule = require './yields/yields.coffee'
UnitModule = require './units/units.coffee'
ProductModule = require './products/products.coffee'
InventoryModule = require './inventories/inventories.coffee'
EventModule = require './events/events.coffee'
SellModule = require './sells/sells.coffee'
IngredientModule = require './ingredients/ingredients.coffee'

# User Helpers
Meteor.users.helpers
  customers: ->
    CustomerModule.Customers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  events: ->
    EventModule.Events.find { $or:  [ created_user_id: @_id, updated_user_id: @_id]}, sort: created_at: -1
  expenses: ->
    ExpenseModule.Expenses.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  inventories: ->
    InventoryModule.Inventories.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  ingredients: ->
    IngredientModule.Ingredients.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  products: ->
    ProductModule.Products.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  providers: ->
    ProviderModule.Providers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  sells: ->
    SellModule.Sells.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  units: ->
    UnitModule.Units.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  users: ->
    Meteor.users.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  yields: ->
    YieldModule.Yields.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  organizations: ->
    OrganizationModule.Organizations.find { ousers: $elemMatch: user_id: @_id } # careful


# Sell Helpers
SellModule.Sells.helpers
  customer: ->
    CustomerModule.Customers.find _id: @customer_id

  products: ->
    id_array = (detail.product_id for detail in @details)
    ProductModule.Products.find { _id: $in: id_array}

  inventories: ->
    id_array = []
    for detail in @details
      for inventory in detail.inventories
        id_array.push inventory.inventory_id
    InventoryModule.Inventories.find { _id: $in: id_array }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id }

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id }


# Provider Helpers
ProviderModule.Providers.helpers
    expenses: ->
      ExpenseModule.Expenses.find { provider_id: @_id}

    organization: ->
      OrganizationModule.Organizations.findOne { _id: @organization_id }

    created_by: ->
      Meteor.users.findOne { _id: @created_user_id}

    updated_by: ->
      Meteor.users.findOne { _id: @updated_user_id}


# Product Helpers
ProductModule.Products.helpers
  ingredients: ->
    id_array = ( pingredient.ingredient_id for pingredient in @pingredients )
    IngredientModule.Ingredients.find { _id: $in: id_array }

  sells: ->
    SellModule.Sells.find 'details.product_id': @_id

  inventories: ->
    InventoryModule.Inventories.find product_id: @_id

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}

# Inventories Helpers
InventoryModule.Inventories.helpers

  sells: ->
    SellModule.Sells.find { sell_details: $elemMatch: inventories: $elemMatch: inventory_id: @_id }   # Careful could lead to error

  events: ->
    EventModule.Events.find { for_id: @_id }, sort: created_at: -1

  yields: ->
    id_array = ( yield_item.yield_id for yield_item in @yield_objects )
    YieldModule.Yields.find { _id: $in: id_array }

  product: ->
    ProductModule.Products.find @product_id

  yield_amount_taken: (yield_id) ->
    return yieldO.amount_taken for yieldO in @yield_objects when yield_id is yieldO.yield_id

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Ingredient Helpers
IngredientModule.Ingredients.helpers
  products: ->
    ProductModule.Products.find {'ingredients.ingredient_id': @_id} # possible error

  yields: ->
    YieldModule.Yields.find {ingredient_id: @_id}

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Expense Helpers
ExpenseModule.Expenses.helpers
  provider: ->
    ProviderModule.Providers.find _id: @provider_id

  unit: ->
    UnitModule.Units.find @unit_id

  organization: ->
    OrganizationModule.Organizations.findOne @organization_id

  created_by: ->
    Meteor.users.findOne @created_user_id

  updated_by: ->
    Meteor.users.findOne @updated_user_id


# Event Helpers
EventModule.Events.helpers
  for_doc: ->
    switch @for_type
      when 'unit' then  UnitModule.Units.find { _id: @for_id}
      when 'yield' then YieldModule.Yields.find { _id: @for_id }
      when 'inventory' then InventoryModule.Inventories.find { _id: @for_id}
      else
        return

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Customer Helpers
CustomerModule.Customers.helpers
  sells: ->
    SellModule.Sells.find {customer_id: @_id},  sort: created_at: -1

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Organization Helpers
OrganizationModule.Organizations.helpers
  events: ->
    EventModule.Events.find { organization_id: @_id }
  customers: ->
    CustomerModule.Customers.find { organization_id: @_id }
  expenses: ->
    ExpenseModule.Expenses.find { organization_id: @_id }
  inventories: ->
    InventoryModule.Inventories.find { organization_id: @_id }
  ingredients: ->
    IngredientModule.Ingredients.find { organization_id: @_id }
  products: ->
    ProductModule.Products.find { organization_id: @_id }
  providers: ->
    ProviderModule.Providers.find { organization_id: @_id }
  sells: ->
    SellModule.Sells.find { organization_id: @_id }
  units: ->
    UnitModule.Units.find { organization_id: @_id } # make sure only parents
  o_users: ->
    id_array = ( user.user_id for user in @ousers )
    Meteor.users.find { _id: $in: id_array }, {fields: services: 0 }
  yields: ->
    YieldModule.Yields.find { organization_id: @_id }

  hasUser: (user_id) ->
    for user in @ousers
      if user_id is user.user_id
        return user
    return

  founder: ->
    for ouser in @ousers
      if ouser.permission.founder
        return ouser
    return


# Unit Helpers
UnitModule.Units.helpers
  unit: ->
    UnitModule.Units.find @unit_id

  units: ->
    UnitModule.Units.find { unit_id: @_id }

  yields: ->
    YieldModule.Yields.find { unit_id: @_id }

  events: ->
    EventModule.Events.find { for_id: @_id }

  expenses: ->
    ExpenseModule.Expenses.find { unit_id: @_id }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}


# Yield Helpers
YieldModule.Yields.helpers
  unit: ->
    UnitModule.Units.find @unit_id

  inventories: ->
    InventoryModule.Inventories.find 'yield_objects.yield_id': @_id # possible error

  ingredient: ->
    IngredientModule.Ingredients.find @ingredient_id

  events: ->
    EventModule.Events.find for_id: @_id

  organization: ->
    OrganizationModule.Organizations.findOne _id: @organization_id

  created_by: ->
    Meteor.users.findOne _id: @created_user_id

  updated_by: ->
    Meteor.users.findOne _id: @updated_user_id
