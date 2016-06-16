{ Meteor } = require 'meteor/meteor'
{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'

EventModule = require '../events/events.coffee'
ExpenseModule = require '../expenses/expenses.coffee'
InventoryModule = require '../inventories/inventories.coffee'
ProductModule = require '../products/products.coffee'
ProviderModule = require '../providers/providers.coffee'
SellModule = require '../sells/sells.coffee'
UnitModule = require '../units/units.coffee'
YieldModule = require '../yields/yields.coffee'
IngredientModule = require '../ingredients/ingredients.coffee'
CustomerModule  = require '../customers/customers.coffee'



class OrganizationsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)


PermissionSchema = exports.PermissionSchema =
  new SimpleSchema(
    owner:
      type: Boolean
      defaultValue: false


    editor:
      type: Boolean
      defaultValue: false


    expenses_manager:
      type: Boolean
      defaultValue: false


    sells_manager:
      type: Boolean
      defaultValue: false


    units_manager:
      type: Boolean
      defaultValue: false


    inventories_manager:
      type: Boolean
      defaultValue: false


    users_manager:
      type: Boolean
      defaultValue: false

  )

UsersSchema =
  new SimpleSchema(
    user_id:
      type: String
      index: true

    permission:
      type: PermissionSchema
      optional: true
      label: 'permissons'
  )

OrganizationSchema =
  new SimpleSchema([
    name:
      type: String
      max: 128
      label: 'organization.name'

    ousers:
      type: [UsersSchema]
      optional: true
      label: 'users'
      maxCount: 5
      autoValue: ->
        if @isInsert
          @unset()
          sub_doc =
            user_id: @userId
            permission:
              owner: true
              editor: true
              users_manager: true
              inventories_manager: true
              units_manager: true
              sells_manager: true
              expenses_manager: true

          return [sub_doc]



  ,ContactSchema, TimestampSchema])

Organizations = exports.Organizations = new OrganizationsCollection('organizations')
Organizations.attachSchema OrganizationSchema

Organizations.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Organizations.helpers
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
    Meteor.users.find { _id: $in: id_array }
  yields: ->
    YieldModule.Yields.find { organization_id: @_id }

  hasUser: (user_id) ->
    for user in @ousers
      if user_id is user.user_id
        return user
    return
