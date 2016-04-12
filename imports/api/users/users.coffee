{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization'


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

  , ContactSchema.pick(['addresses', 'telephones']) ])

PermissonSchema =
  new SimpleSchema(
    owner:
      type: Boolean
      defaultValue: false

    editor:
      type: Boolean
      defaultValue: false

    expanses_manager:
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

UserSchema =
  new SimpleSchema([

    username:
      type: String
      label: 'username'

    emails:
        type: Array
        optional: true

    "emails.$":
        type: Object

    "emails.$.address":
        type: String,
        regEx: SimpleSchema.RegEx.Email

    "emails.$.verified":
        type: Boolean

    profile:
      type: UserProfileSchema

    services:
        type: Object
        optional: true
        blackbox: true

    permissons:
      type: PermissonSchema
      label: 'permissons'

  , BelongsOrganizationSchema, TimestampSchema])

  Meteor.users.attachSchema UserSchema

  Meteor.users.deny
    insert: ->
      yes
    update: ->
      yes
    remove: ->
      yes
