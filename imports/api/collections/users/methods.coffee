{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'
{ Accounts } = require 'meteor/accounts-base'

OrganizationModule = require '../organizations/organizations.coffee'
ContactModule = require '../../shared/contact_info.coffee'
UsersModule = require './users.coffee'

{ loggedIn, ownsOrganization } = require '../../mixins/mixins.coffee'
{ hasUserManagerPermission, updateUserBelongsToOrgan } = require '../../mixins/users_manager_mixins.coffee'



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
  name: 'users.inviteUser'
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
module.exports.updatePermission = new ValidatedMethod
  name: 'users.updatePermisson'
  validate: ({update_user_id, organization_id, permission}) ->
    OrganizationModule.PermissionSchema.validate(permission)

  mixins: [updateUserBelongsToOrgan, hasUserManagerPermission, loggedIn]

  run: ({update_user_id, organization_id, permission}) ->
    unless @isSimulation
      organization = arguments[0].organization
      uuser = organization.hasUser(update_user_id)
      cuser = organization.hasUser(@userId)

      # Only owners can change the owner permission
      if !cuser.permission.owner && permission.owner isnt uuser.permission.owner
        throw new Meteor.Error 'notOwner', 'user managers cannot set the owner permission'

      # Pervents from there every not being an owner
      if update_user_id is @userId && permission.owner isnt uuser.permission.owner
        throw new Meteor.Error 'notAuthorized', 'an owner cannot set his/her own permission.owner'

      uuser.permission = permission
      OrganizationModule.Organizations.update _id: organization_id,
                                              $set:
                                                ousers: organization.ousers


# Remove User from Organization
module.exports.removeFromOrganization = new ValidatedMethod
  name: 'users.removeFromOrganization'
  validate: null
  mixins: [updateUserBelongsToOrgan, ownsOrganization, loggedIn]
  run: ({update_user_id, organization_id}) ->
    unless @isSimulation
      # Pervents owners from removing themselves
      if update_user_id is @userId
        throw new Meteor.Error 'notAuthorized', 'an owner cannot remove themselves'

      OrganizationModule.Organizations.update _id: organization_id,
                                              $pull:
                                                ousers:
                                                  user_id: update_user_id
                                                  

# Update Profile
module.exports.updateProfile = new ValidatedMethod
  name: 'users.updateProfile'
  validate: ({profile_doc}) ->
    UsersModule.UserProfileSchema.validate(profile_doc)

  mixins: [loggedIn]

  run: ({profile_doc}) ->
    profile_doc.user_avatar_url = "" # This needs to change cannot trust user
    Meteor.users.update @userId,
                        $set:
                          profile: profile_doc
