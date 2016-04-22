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

  return true

selectOrganization = (user, organization_id) ->

  for user_organ in user.organizations
    user_organ.selected = false
    if user_organ.organization_id == organization_id
      user_organ.selected = true
      belongs = true

  if belongs?
    return user
  else
    throw new Meteor.Error 'notAuthorized', 'User does not belong to this organization'

addNewOrganization = (user, organization_id) ->

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
    selected: false

  user.organizations.push organschema_doc
  user


# Insert
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: OrganizationModule.Organizations.simpleSchema().validator()
  run: (organization_doc) ->
    isLoggedIn(@userId)
    organization_id = OrganizationModule.Organizations.insert organization_doc
    user = addNewOrganization Meteor.users.findOne(_id: @userId), organization_id
    Meteor.users.update @userId, $set: organizations: user.organizations # Move this line inside addNewOrganization


# Select Organization ( Move to User methods )
module.exports.select = new ValidatedMethod
  name: 'organization.select'
  validate: new SimpleSchema(
              organization_id:
                type: String
                max: 128
            ).validator()
  run: (selected_doc) ->
    isLoggedIn(@userId)
    user = selectOrganization Meteor.users.findOne(_id: @userId), selected_doc.organization_id
    Meteor.users.update @userId, $set: organizations: user.organizations
