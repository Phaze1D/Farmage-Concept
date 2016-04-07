
{ TAPi18n } = require 'meteor/tap:i18n'
{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'



class CustomersCollection extends Mongo.Collection
  insert: (doc, callback) ->
    # Code for hooks
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    # Code for hooks
    super(selector, modifier, options, callback)

  remove: (selector, callback) -> # Careful with removing a client who has dependencias
    # Code for hooks
    super(selector, callback)

# Associations
  # organization: () ->
  #   Organizations.find {id: this.organization_id}
  #
  # sells: () ->
  #   Sells.find {client_id: this._id}

# Schema
CustomersSchema =
  new SimpleSchema([
    first_name:
      type: String
      label: TAPi18n.__ "first_name"
      max: 45

    last_name:
      type: String
      label: TAPi18n.__ "last_name"
      optional: true
      max: 45

    company:
      type: String
      label: TAPi18n.__ "company"
      optional: true
      max: 45

    organization_id: # Think about adding autoValue for this field
      type: String
      index: true

  , share.ContactSchema, share.TimestampSchema])

Customers = exports.Customers = new CustomersCollection "customers"
Customers.attachSchema CustomersSchema

Customers.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

if Meteor.isServer
  multikeys =
    email: 1
    organization_id: 1

  Customers.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error



# Methods
