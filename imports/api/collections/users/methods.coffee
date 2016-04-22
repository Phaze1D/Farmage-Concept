{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'
{ Accounts } = require 'meteor/accounts-base'
{ SSR } = require 'meteor/meteorhacks:ssr'
{ Email } = require 'meteor/email'

{ Organizations } = require '../organizations/organizations.coffee'


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


createNewUser = (user_doc) ->
  new_user_id = Accounts.createUser(email: user_doc.emails[0].address, profile: user_doc.profile)
  new_user = Meteor.users.findOne(_id: new_user_id)
  new_user.organizations = user_doc.organizations
  Meteor.users.update new_user_id, $set: organizations: new_user.organizations
  new_user


# Simple invitational email linking to the organization site
sendInvitationEmail = (user) ->
  organ = Organizations.findOne(user.organizations[0].organization_id)
  options =
    from: 'SA Units <steadypathapp@gmail.com>'
    to: user.emails[0].address
    subject: 'Invited to new SA Unit Organization'
    html: SSR.render('invite', {user: user, organization: organ, url: 'www.sa-units.com/login' })
  Email.send options

# Enrollment email that links to the new users create password page with invitational info
sendInvitationEmailWithPasswordLink = (user) ->
  Accounts.sendEnrollmentEmail(user._id)


# Invite User to organization ( Can't trust client side organization_id )
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: Meteor.users.simpleSchema().validator()
  run: (invited_user_doc) ->
    isLoggedIn(@userId)
    userOwnsOrganization(Meteor.users.findOne(_id: @userId), invited_user_doc.organizations[0].organization_id)

    if Meteor.isServer
      @unblock()
      user = Accounts.findUserByEmail invited_user_doc.emails[0].address

      if user?
        user.organizations.push invited_user_doc.organizations[0]
        Meteor.users.update user._id, $set: organizations: user.organizations
        sendInvitationEmail(user)
      else
        new_user = createNewUser(invited_user_doc)
        sendInvitationEmailWithPasswordLink(new_user)
