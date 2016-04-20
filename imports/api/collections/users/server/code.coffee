{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'

require '../users.coffee'


Accounts.validateNewUser (user) ->
  Meteor.users.simpleSchema().validate(user)
  return true


Accounts.onCreateUser (options, user) ->
  user.organizations = []
  user.profile = options.profile
  return user
