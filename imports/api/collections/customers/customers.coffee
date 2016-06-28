{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'


class CustomersCollection extends Mongo.Collection
  insert: (doc, callback) ->
    # Code for hooks
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    # Code for hooks
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      Sells depends on customers if customers is delete then delete all sells
      User can also hide this client
    ###
    super(selector, callback)

# Schema
CustomerSchema =
  new SimpleSchema([
    first_name:
      type: String
      label: "first_name"
      max: 64

    last_name:
      type: String
      label: "last_name"
      optional: true
      max: 64

    date_of_birth:
      type: String
      label: 'date_of_birth'
      optional: true

    notes:
      type: String
      label: 'notes'
      optional: true

    company:
      type: String
      label: "company"
      optional: true
      max: 64

    # Think about RFC

  ,ContactSchema, CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])


Customers = exports.Customers = new CustomersCollection "customers"
Customers.attachSchema CustomerSchema

Customers.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes





# Customers depends on organization. If an Organization is deleted then delete all its customers
# Customers depends on user. If a User is deleted then reasign user_id to the person who deleted the previous user
