{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ SSR } = require 'meteor/meteorhacks:ssr'
{ Organizations } = require '../../organizations/organizations.coffee'

require '../users.coffee'


# User Accounts
Accounts.validateNewUser (user) ->
  Meteor.users.simpleSchema().validate(user)
  return true

Accounts.onCreateUser (options, user) ->
  user.organizations = []
  user.profile = options.profile
  return user


# Compiling User emails
SSR.compileTemplate('enrollmentInvite', Assets.getText('emails/enrollment_invite.html'))
SSR.compileTemplate('invite', Assets.getText('emails/invite.html'))

# User emails config
Accounts.emailTemplates.siteName = 'SA Units'
Accounts.emailTemplates.from = 'SA Units <steadypathapp@gmail.com>'
Accounts.emailTemplates.enrollAccount.subject = (user) ->
  'Invited to new SA Unit Organization'

Accounts.emailTemplates.enrollAccount.text = (user, url) ->
  ''

Accounts.emailTemplates.enrollAccount.html = (user, url) ->
  organ = Organizations.findOne(user.organizations[0].organization_id)
  SSR.render('enrollmentInvite', { user: user, organization: organ, url: url })
