
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

CustomerModule  = require './customers.coffee'

{ loggedIn, ownsOrganization } = require '../../mixins/mixins.coffee'
{ hasSellsManagerPermission } = require '../../mixins/sells_manager_mixins.coffee'

###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###

# Insert Customer
module.exports.insert = new ValidatedMethod
  name: 'customers.insert'
  validate: ({organization_id, customer_doc}) ->
    CustomerModule.Customers.simpleSchema().validate(customer_doc)
  mixins: [hasSellsManagerPermission, loggedIn]
  run: ({organization_id, customer_doc}) ->
    customer_doc.organization_id = organization_id
    CustomerModule.Customers.insert customer_doc

# Update
