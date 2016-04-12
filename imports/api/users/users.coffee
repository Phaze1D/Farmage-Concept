{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'

# Missing permissons

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

  , TimestampSchema])

  Meteor.users.attachSchema UserSchema
