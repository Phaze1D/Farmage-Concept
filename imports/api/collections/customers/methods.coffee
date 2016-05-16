
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

CustomerModule  = require './customers.coffee'


{
  loggedIn
  hasPermission
  customerBelongsToOrgan
} = require '../../mixins/mixins.coffee'

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
  validate: ({customer_doc}) ->
    CustomerModule.Customers.simpleSchema().validate(customer_doc)

  run: ({customer_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, customer_doc.organization_id, "sells_manager")
      
    CustomerModule.Customers.insert customer_doc


# Update
module.exports.update = new ValidatedMethod
  name: 'customers.update'
  validate: ({organization_id, customer_id, customer_doc}) ->
    CustomerModule.Customers.simpleSchema().validate({$set: customer_doc}, modifier: true)

    new SimpleSchema(
      customer_id:
        type: String

      organization_id:
        type: String
    ).validate({customer_id, organization_id})

  run: ({organization_id, customer_id, customer_doc}) ->

    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, "sells_manager")
      customerBelongsToOrgan(customer_id, organization_id)

    delete customer_doc.organization_id
    CustomerModule.Customers.update customer_id,
                                    $set: customer_doc
