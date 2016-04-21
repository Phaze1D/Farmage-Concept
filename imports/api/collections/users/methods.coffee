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

isLoggedIn = (userId) ->
  unless userId?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


userOwnsOrganization = (user, organization_id) ->
  for user_organ in user.organizations
    if user_organ.organization_id is organization_id and user_organ.permission.owner
      return true

  throw new Meteor.Error 'notAuthorized', 'User does not belong to this organization'


sendInvitationEmail = (user) ->




# Invite User to organization ( Can't trust client side organization_id )
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: new SimpleSchema(
              email:
                type: String
                regEx: SimpleSchema.RegEx.Email
                max: 45
            ).validator()
  run: (email, organization_id) ->
    isLoggedIn(@userId)
    userOwnsOrganization(Meteor.users.find(_id: @userId), organization_id)

    if Meteor.isServer
      @unblock()
      sendInvitationEmail(email) # Handle whether the user exist or not after they click the link
