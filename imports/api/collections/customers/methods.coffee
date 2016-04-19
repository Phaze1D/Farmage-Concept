
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

CustomerModule  = require './customers.coffee'

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
  validate: CustomerModule.Customers.simpleSchema().validator()
  run: (customer_doc) ->
    unless @userId?
      throw new Meteor.Error 'notLoggedIn', 'Must be logged in'

    CustomerModule.Customers.insert customer_doc




# Update Customer First Name


# Update Customer Last Name


# Update Customer Company


# Remove
