{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'
{ Accounts } = require 'meteor/accounts-base'
{ SSR } = require 'meteor/meteorhacks:ssr'
{ Random } = require 'meteor/random'
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

isLoggedIn = (currentUserId) ->
  unless currentUserId?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


userOwnsOrganization = (user, organization_id) ->
  organization = Organizations.findOne(_id: organization_id, user_ids: $elemMatch: user_id: user._id)
  if organization?
    return organization
  else
    throw new Meteor.Error 'notAuthorized', 'Only owners can invite'


createInvitedUser = (user_doc, organization_id, permission) ->
  new_user_id = Accounts.createUser(email: user_doc.emails[0].address, profile: user_doc.profile)
  Organizations.update(_id: organization_id, { $addToSet: user_ids: {user_id: new_user_id, permission: permission}})
  Meteor.users.findOne(_id: new_user_id)



# Simple invitational email linking to the organization site
sendInvitationEmail = (user, organization) ->
  options =
    from: 'SA Units <steadypathapp@gmail.com>'
    to: user.emails[0].address
    subject: 'Invited to new SA Unit Organization'
    html: SSR.render('invite', {user: user, organization: organization, url: 'www.sa-units.com/login' })
  Email.send options

# Same as Meteor Accounts.sendEnrollmentEmail but with organization
sendInvitationEmailWithPasswordLink = (userId, email, organization) ->
  #  XXX refactor! This is basically identical to sendResetPasswordEmail.

  #  Make sure the user exists, and email is in their addresses.
  user = Meteor.users.findOne(userId)
  if (!user)
    throw new Error("Can't find user")
  #  pick the first email if we weren't passed an email.
  if (!email && user.emails && user.emails[0])
    email = user.emails[0].address
  #  make sure we have a valid email
  if (!email || !_.contains(_.pluck(user.emails || [], 'address'), email))
    throw new Error("No such email for user.")

  token = Random.secret()
  whenn = new Date()
  tokenRecord =
    token: token
    email: email
    when: whenn

  Meteor.users.update userId, $set: "services.password.reset": tokenRecord

  #  before passing to template, update user object with new token
  Meteor._ensure(user, 'services', 'password').reset = tokenRecord

  enrollAccountUrl = Accounts.urls.enrollAccount(token);

  options =
    to: email
    from: if Accounts.emailTemplates.enrollAccount.from? then Accounts.emailTemplates.enrollAccount.from(user) else Accounts.emailTemplates.from
    subject: Accounts.emailTemplates.enrollAccount.subject(user)


  if (typeof Accounts.emailTemplates.enrollAccount.text is 'function')
    options.text = Accounts.emailTemplates.enrollAccount.text(user, enrollAccountUrl, organization)

  if (typeof Accounts.emailTemplates.enrollAccount.html is 'function')
    options.html = Accounts.emailTemplates.enrollAccount.html(user, enrollAccountUrl, organization)

  if (typeof Accounts.emailTemplates.headers is 'object')
    options.headers = Accounts.emailTemplates.headers

  Email.send(options)



# Invite User to organization
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: (args) ->
    Meteor.users.simpleSchema().validate(args.user_doc)
    unless args.organization_id?
      throw new Meteor.Error 'invalidArgs', 'invalid arguments'

    unless args.permission?
      throw new Meteor.Error 'invalidArgs', 'invalid arguments'

  run: (args) ->
    @unblock()
    invited_user_doc = args.user_doc
    organization_id = args.organization_id
    permission = args.permission
    isLoggedIn(@userId)

    unless @isSimulation
      organization = userOwnsOrganization(Meteor.users.findOne(_id: @userId), organization_id)
      invited_user = Accounts.findUserByEmail invited_user_doc.emails[0].address
      if invited_user?
        Organizations.update(_id: organization._id, {$addToSet: user_ids: {user_id: invited_user._id, permission: permission}})
        sendInvitationEmail(invited_user, organization)
      else
        new_user = createInvitedUser(invited_user_doc, organization_id, permission)
        sendInvitationEmailWithPasswordLink(new_user, new_user.emails[0].address, organization)


# Update Profile

# Update Organization Permissons

# Remove Organization
