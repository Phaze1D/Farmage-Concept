{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

ContactModule = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'



UserProfileSchema = exports.UserProfileSchema =
  new SimpleSchema([
    first_name:
      type: String
      label: 'first_name'
      max: 64
      optional: true

    last_name:
      type: String
      label: 'last_name'
      max: 64
      optional: true

    date_of_birth:
      type: Date
      label: 'date_of_birth'
      optional: true

    notes:
      type: String
      label: 'notes'
      optional: true

    user_avatar_url:
      type: String
      label: 'avatar'
      regEx: SimpleSchema.RegEx.Url
      optional: true

    addresses:
      type: [ContactModule.AddressSchema]
      optional: true
      defaultValue: []
      maxCount: 5

    telephones:
      type: [ContactModule.TelephoneSchema]
      optional: true
      defaultValue: []
      maxCount: 5
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
      optional: true

    services:
        type: Object
        optional: true
        blackbox: true

  , CreateByUserSchema, TimestampSchema])

Meteor.users.attachSchema UserSchema

Meteor.users.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes
