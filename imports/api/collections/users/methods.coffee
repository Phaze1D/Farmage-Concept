{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'
{ Accounts } = require 'meteor/accounts-base'

require './users.coffee'


###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input
    Check organization user limit

###


# Invite User to organization ( Can't trust client side organization_id )
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: Meteor.users.simpleSchema().validator()
  run: (user_doc) ->
