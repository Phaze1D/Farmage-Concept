{ Meteor } = require 'meteor/meteor'
{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'


class OrganizationsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)


PermissionSchema = exports.PermissionSchema =
  new SimpleSchema(
    founder:
      type: Boolean
      defaultValue: false
      optional: true

    owner:
      type: Boolean
      defaultValue: false

    viewer:
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
              founder: true
              owner: true
              viewer: true
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
