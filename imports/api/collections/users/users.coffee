{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

ContactModule = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'


CustomerModule = require '../customers/customers.coffee'
EventModule = require '../events/events.coffee'
ExpenseModule = require '../expenses/expenses.coffee'
InventoryModule = require '../inventories/inventories.coffee'
ProductModule = require '../products/products.coffee'
ProviderModule = require '../providers/providers.coffee'
ReceiptModule = require '../receipts/receipts.coffee'
SellModule = require '../sells/sells.coffee'
UnitModule = require '../units/units.coffee'
YieldModule = require '../yields/yields.coffee'
OrganizationModule = require '../organizations/organizations.coffee'


UserProfileSchema =
  new SimpleSchema([

    first_name:
      type: String
      label: 'first_name'
      max: 64

    last_name:
      type: String
      label: 'last_name'
      max: 64
      optional: true

    user_avatar_url:
      type: String
      label: 'avatar'
      regEx: SimpleSchema.RegEx.Url
      optional: true

    addresses:
      type: [ContactModule.AddressSchema]
      optional: true
      maxCount: 5

    telephones:
      type: [ContactModule.TelephoneSchema]
      optional: true
      maxCount: 5
   ])

PermissionSchema =
  new SimpleSchema(
    owner:
      type: Boolean
      optional: true
      defaultValue: false


    editor:
      type: Boolean
      optional: true
      defaultValue: false


    expanses_manager:
      type: Boolean
      optional: true
      defaultValue: false


    sells_manager:
      type: Boolean
      optional: true
      defaultValue: false


    units_manager:
      type: Boolean
      optional: true
      defaultValue: false


    inventories_manager:
      type: Boolean
      optional: true
      defaultValue: false


    users_manager:
      type: Boolean
      optional: true
      defaultValue: false

  )

OrganizationsSchema =
  new SimpleSchema([

    organization_id:
      type: String
      index: true

    permission:
      type: PermissionSchema
      optional: true
      label: 'permissons'

    selected:
      type: Boolean
      defaultValue: false
      optional: true

  ])

UserSchema =
  new SimpleSchema([

    _id:
      type: String
      optional: true

    username:
      type: String
      label: 'username'
      optional: true

    emails:
        type: Array
        min: 1

    "emails.$":
        type: Object

    "emails.$.address":
        type: String,
        regEx: SimpleSchema.RegEx.Email

    "emails.$.verified":
        type: Boolean
        optional: true
        defaultValue: false

    profile:
      type: UserProfileSchema


    services:
        type: Object
        optional: true
        blackbox: true

    organizations:
      type: [OrganizationsSchema]
      optional: true
      defaultValue: []
      minCount: 0
      maxCount: 10

  , CreateByUserSchema, TimestampSchema])

Meteor.users.attachSchema UserSchema

Meteor.users.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Meteor.users.helpers
  customers: ->
    CustomerModule.Customers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  events: ->
    EventModule.Events.find { $or:  [ created_user_id: @_id, updated_user_id: @_id]}, sort: created_at: -1
  expenses: ->
    ExpenseModule.Expenses.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  inventories: ->
    InventoryModule.Inventories.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  products: ->
    ProductModule.Products.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  providers:->
    ProviderModule.Providers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  receipts: ->
    ReceiptModule.Receipts.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  sells: ->
    SellModule.Sells.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  units: ->
    UnitModule.Units.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  users: ->
    Meteor.users.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  yields: ->
    YieldModule.Yields.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  organizations_as: ->
    id_array = ( organization_item.organization_id for organization_item in @organizations )
    OrganizationModule.Organizations.find { _id: $in: id_array }
