{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'
{ Accounts } = require 'meteor/accounts-base'

OrganizationModule = require '../organizations/organizations.coffee'
{ loggedIn, ownsOrganization } = require '../../mixins/mixins.coffee'


if Meteor.isServer
  { SMC } = require './server/secret_methods.coffee'


###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input
    Check organization user limit

###


# Invite User to organization
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: ({invited_user_doc, organization_id, permission}) ->
    Meteor.users.simpleSchema().validate(invited_user_doc)

  mixins: [ownsOrganization, loggedIn]

  run: ({invited_user_doc, organization_id, permission}) ->
    @unblock()
    unless @isSimulation
      organization = arguments[0].organization
      invited_user = Accounts.findUserByEmail invited_user_doc.emails[0].address
      if invited_user?
        OrganizationModule.Organizations.update(_id: organization._id, {$addToSet: user_ids: {user_id: invited_user._id, permission: permission}})
        SMC.sendInvitationEmail(invited_user, organization)
      else
        new_user = SMC.createInvitedUser(invited_user_doc, organization_id, permission)
        SMC.sendInvitationEmailWithPasswordLink(new_user, new_user.emails[0].address, organization)


# Update Profile

# Update User Organization Permissons

# Remove User from Organization
