
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
  customers: (limit, search) ->
    options =
      sort:
        first_name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {first_name: regex},
          {last_name: regex},
          {company: regex},
          {email: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]
    CustomerModule.Customers.find query, options

  events: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    EventModule.Events.find { $or:  [ created_user_id: @_id, updated_user_id: @_id]}, options


  expenses: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    ExpenseModule.Expenses.find query, options

  inventories: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    InventoryModule.Inventories.find query, options

  ingredients: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {measurement_unit: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    IngredientModule.Ingredients.find query, options

  products: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {size: regex},
          {description: regex},
          {sku: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    ProductModule.Products.find query, options

  providers: (limit, search) ->
    options =
      sort:
        first_name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {first_name: regex},
          {last_name: regex},
          {company: regex},
          {email: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    ProviderModule.Providers.find query, options

  sells: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {status: regex},
          {notes: regex},
          {payment_method: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    SellModule.Sells.find query, option

  units: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex},
          {_id: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    UnitModule.Units.find query, options

  users: ->
    Meteor.users.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: createdAt: -1

  yields: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex},
          created_user_id: @_id,
          updated_user_id: @_id
        ]

    YieldModule.Yields.find query, options

  organizations: ->
    OrganizationModule.Organizations.find { ousers: $elemMatch: user_id: @_id } # careful


# Sell Helpers
SellModule.Sells.helpers
  customer: ->
    CustomerModule.Customers.find _id: @customer_id

  products: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    id_array = (detail.product_id for detail in @details)

    regex = new RegExp( "^#{search}", 'i' );
    query = { _id: $in: id_array}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {size: regex},
          {description: regex},
          {sku: regex}
        ]

    ProductModule.Products.find query, options

  inventories: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    id_array = []
    for detail in @details
      for inventory in detail.inventories
        id_array.push inventory.inventory_id

    regex = new RegExp( "^#{search}", 'i' );
    query = { _id: $in: id_array }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    InventoryModule.Inventories.find query, options

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id }

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id }


# Provider Helpers
ProviderModule.Providers.helpers
    expenses: (limit, search) ->
      options =
        sort:
          createdAt: -1
      options.limit = limit if limit?

      regex = new RegExp( "^#{search}", 'i' );
      query = {provider_id: @_id}

      if search? && search.length > 0
        query.$or = [
            {name: regex},
            {description: regex}
          ]

      ExpenseModule.Expenses.find query, options

    organization: ->
      OrganizationModule.Organizations.find { _id: @organization_id }

    created_by: ->
      Meteor.users.find { _id: @created_user_id}

    updated_by: ->
      Meteor.users.find { _id: @updated_user_id}


# Product Helpers
ProductModule.Products.helpers
  ingredients: (limit, search) ->
    options =
      sort:
        createdAt: 1
    options.limit = limit if limit?

    id_array = ( pingredient.ingredient_id for pingredient in @pingredients )

    regex = new RegExp( "^#{search}", 'i' );
    query = { _id: $in: id_array }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {measurement_unit: regex}
        ]

    IngredientModule.Ingredients.find query, options

  sells: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {'details.product_id': @_id}

    if search? && search.length > 0
      query.$or = [
          {status: regex},
          {notes: regex},
          {payment_method: regex}
        ]

    SellModule.Sells.find query, options

  inventories: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {product_id: @_id}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    InventoryModule.Inventories.find query, options

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}

# Inventories Helpers
InventoryModule.Inventories.helpers

  sells: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { details: $elemMatch: inventories: $elemMatch: inventory_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {status: regex},
          {notes: regex},
          {payment_method: regex}
        ]

    SellModule.Sells.find query, options   # Careful could lead to error

  events: (limit)->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    EventModule.Events.find { for_id: @_id }, options


  yields: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    id_array = ( yield_item.yield_id for yield_item in @yield_objects )

    regex = new RegExp( "^#{search}", 'i' );
    query = { _id: $in: id_array }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    YieldModule.Yields.find query, options

  product: ->
    ProductModule.Products.find @product_id

  yield_amount_taken: (yield_id) ->
    return yieldO.amount_taken for yieldO in @yield_objects when yield_id is yieldO.yield_id

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}


# Ingredient Helpers
IngredientModule.Ingredients.helpers
  products: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {'pingredients.ingredient_id': @_id}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {size: regex},
          {description: regex},
          {sku: regex}
        ]

    ProductModule.Products.find query, options# possible error

  yields: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {ingredient_id: @_id}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    YieldModule.Yields.find query, options

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}


# Expense Helpers
ExpenseModule.Expenses.helpers
  provider: ->
    ProviderModule.Providers.find _id: @provider_id

  unit: ->
    UnitModule.Units.find @unit_id

  organization: ->
    OrganizationModule.Organizations.find @organization_id

  created_by: ->
    Meteor.users.find @created_user_id

  updated_by: ->
    Meteor.users.find @updated_user_id


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
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}


# Customer Helpers
CustomerModule.Customers.helpers
  sells: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {customer_id: @_id}

    if search? && search.length > 0
      query.$or = [
          {status: regex},
          {notes: regex},
          {payment_method: regex}
        ]

    SellModule.Sells.find query, options

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}


# Organization Helpers
OrganizationModule.Organizations.helpers
  events: (limit)->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    EventModule.Events.find { organization_id: @_id }, options

  customers: (limit, search) ->
    options =
      sort:
        first_name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query =
      organization_id: @_id
    if search? && search.length > 0
      query.$or = [
          {first_name: regex},
          {last_name: regex},
          {company: regex},
          {email: regex}
        ]

    CustomerModule.Customers.find query, options

  expenses: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex}
        ]

    ExpenseModule.Expenses.find query, options

  inventories: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    InventoryModule.Inventories.find query, options

  ingredients: (limit, search) ->
    options =
      sort:
        createdAt: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {measurement_unit: regex}
        ]

    IngredientModule.Ingredients.find query, options

  products: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {size: regex},
          {description: regex},
          {sku: regex}
        ]

    ProductModule.Products.find query, options

  providers: (limit, search) ->
    options =
      sort:
        first_name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {first_name: regex},
          {last_name: regex},
          {company: regex},
          {email: regex}
        ]

    ProviderModule.Providers.find query, options

  sells: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {status: regex},
          {notes: regex},
          {payment_method: regex}
        ]

    SellModule.Sells.find query, options

  units: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex},
          {_id: regex}
        ]

    UnitModule.Units.find query, options

  o_users: (limit) ->
    options =
      fields:
        services: 0
      sort:
        'profile.first_name': 1
    options.limit = limit if limit?

    id_array = ( user.user_id for user in @ousers )
    Meteor.users.find { _id: $in: id_array }, options

  yields: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { organization_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    YieldModule.Yields.find query, options

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

  units: (limit, search) ->
    options =
      sort:
        name: 1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { unit_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex},
          {_id: regex}
        ]


    UnitModule.Units.find query, options

  yields: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { unit_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    YieldModule.Yields.find query, options

  events: (limit)->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    EventModule.Events.find { for_id: @_id }, options

  expenses: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = { unit_id: @_id }

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {description: regex}
        ]

    ExpenseModule.Expenses.find query, options

  organization: ->
    OrganizationModule.Organizations.find { _id: @organization_id }

  created_by: ->
    Meteor.users.find { _id: @created_user_id}

  updated_by: ->
    Meteor.users.find { _id: @updated_user_id}


# Yield Helpers
YieldModule.Yields.helpers
  unit: ->
    UnitModule.Units.find @unit_id

  inventories: (limit, search) ->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?

    regex = new RegExp( "^#{search}", 'i' );
    query = {'yield_objects.yield_id': @_id}

    if search? && search.length > 0
      query.$or = [
          {name: regex},
          {notes: regex},
          {_id: regex}
        ]

    InventoryModule.Inventories.find query, options # possible error

  ingredient: ->
    IngredientModule.Ingredients.find @ingredient_id

  events: (limit)->
    options =
      sort:
        createdAt: -1
    options.limit = limit if limit?
    EventModule.Events.find { for_id: @_id }, options

  organization: ->
    OrganizationModule.Organizations.find _id: @organization_id

  created_by: ->
    Meteor.users.find _id: @created_user_id

  updated_by: ->
    Meteor.users.find _id: @updated_user_id
