{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

OrganizationModule = require './organizations.coffee'

###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###

isLoggedIn = (userId) ->
  unless userId?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


# Insert
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: OrganizationModule.Organizations.simpleSchema().validator()
  run: (organization_doc) ->
    isLoggedIn(@userId)

    organization_id = OrganizationModule.Organizations.insert organization_doc

    # Refactor this code
    user = Meteor.user()
    for user_organ in user.organizations
      user_organ.selected = false

    organschema_doc =
      organization_id: organization_id
      permission:
          owner: true
          editor: true
          expanses_manager: true
          sells_manager: true
          units_manager: true
          inventories_manager: true
          users_manager: true
      selected: true

    user.organizations.push organschema_doc
    Meteor.users.update @userId, $set: organizations: user.organizations


# Select Organization
module.exports.select = new ValidatedMethod
  name: 'organization.select'
  validate: new SimpleSchema(
              organization_id:
                type: String
            ).validator()
  run: (selected_doc) ->
    isLoggedIn(@userId)
    user = Meteor.user()
    belongs
    for user_organ in user.organizations
      user_organ.selected = false
      if user_organ.organization_id == selected_doc.organization_id
        user_organ.selected = true
        belongs = true

    unless belongs?
      throw new Meteor.Error 'notAuthorized', 'User does not belong to this organization'

    Meteor.users.update @userId, $set: organizations: user.organizations
