{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ ContactSchema } = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
SellModule = require '../sells/sells.coffee'


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


Customers.helpers
  sells: ->  # This may not be necessary could use the route for this
    SellModule.Sells.find {customer_id: @_id},  sort: created_at: -1

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @created_user_id}

  updated_by: ->
    Meteor.users.findOne { _id: @updated_user_id}



# Customers depends on organization. If an Organization is deleted then delete all its customers
# Customers depends on user. If a User is deleted then reasign user_id to the person who deleted the previous user
