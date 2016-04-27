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


# ---------- User Only Mixins ------------ #
hasUserManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)

      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      user = organization.hasUser(@userId)
      unless( user? && (user.permission.owner || user.permission.users_manager) )
        throw new Meteor.Error 'notUserManager', 'only user managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions

updateUserBelongsToOrgan = (methodOptions) ->
    RUN = methodOptions.run
    methodOptions.run = () ->
      unless @isSimulation
        organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)
        unless( organization? && organization.hasUser(arguments.update_user_id)? )
          throw new Meteor.Error 'userNotInOrganization', 'not authorized'

        arguments[0].organization = organization
      RUN.call(@, arguments[0])

    return methodOptions


# ----------- Common Code ----------- #
addUserToOrganization = (user_id, organization, permission) ->
  unless organization.hasUser(user_id)?
    OrganizationModule.Organizations.update(_id: organization._id,
                                            $addToSet:
                                              ousers:
                                                user_id: user_id
                                                permission: permission)



# ----------- Methods ------------ #
# Invite User to organization
module.exports.inviteUser = new ValidatedMethod
  name: 'user.inviteUser'
  validate: ({invited_user_doc, organization_id, permission}) ->
    Meteor.users.simpleSchema().validate(invited_user_doc)
    OrganizationModule.PermissionSchema.validate(permission)

  mixins: [ownsOrganization, loggedIn]

  run: ({invited_user_doc, organization_id, permission}) ->
    @unblock()
    unless @isSimulation
      organization = arguments[0].organization
      invited_user = Accounts.findUserByEmail invited_user_doc.emails[0].address
      if invited_user?
        addUserToOrganization(invited_user._id, organization, permission)
        SMC.sendInvitationEmail(invited_user, organization)
      else
        new_user = SMC.createInvitedUser(invited_user_doc, organization_id, permission)
        addUserToOrganization(new_user._id, organization, permission)
        SMC.sendInvitationEmailWithPasswordLink(new_user, new_user.emails[0].address, organization)


# Update User Organization Permissons
module.exports.updatePermisson = new ValidatedMethod
  name: 'user.updatePermisson'
  validate: ({update_user_id, organization_id, permission}) ->
    OrganizationModule.PermissionSchema.validate(permission)

  mixins: [updateUserBelongsToOrgan, hasUserManagerPermission, loggedIn]

  run: ({update_user_id, organization_id, permission}) ->
    unless @isSimulation
      organization = arguments[0].organization
      ouser = organization.hasUser(update_user_id)
      ouser.permission = permission
      OrganizationModule.Organizations.update _id: organization_id,
                                              $set:
                                                ousers: organization.ousers


# Remove User from Organization

# Update Profile
