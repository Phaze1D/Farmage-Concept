{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ SSR } = require 'meteor/meteorhacks:ssr'
{ Random } = require 'meteor/random'
{ Email } = require 'meteor/email'

OrganizationModule  = require '../../organizations/organizations.coffee'

# Secert Method Code
exports.SMC =

  createInvitedUser: (user_doc) ->
    new_user_id = Accounts.createUser(email: user_doc.emails[0].address, profile: user_doc.profile)
    Meteor.users.findOne(_id: new_user_id)

  # Simple invitational email linking to the organization site
  sendInvitationEmail: (user, organization) ->
    options =
      from: 'SA Units <steadypathapp@gmail.com>'
      to: user.emails[0].address
      subject: 'Invited to new SA Unit Organization'
      html: SSR.render('invite', {user: user, organization: organization, url: 'www.sa-units.com/login' })
    Email.send options

  # Same as Meteor Accounts.sendEnrollmentEmail but with organization
  sendInvitationEmailWithPasswordLink: (userId, email, organization) ->
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
