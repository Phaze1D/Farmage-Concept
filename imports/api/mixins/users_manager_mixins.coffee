OrganizationModule = require '../collections/organizations/organizations.coffee'


module.exports.hasUserManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)

      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      cuser = organization.hasUser(@userId)
      unless cuser?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      unless(cuser.permission.owner || cuser.permission.users_manager)
        throw new Meteor.Error 'notUserManager', 'only user managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions


module.exports.updateUserBelongsToOrgan = (methodOptions) ->
    RUN = methodOptions.run
    methodOptions.run = () ->
      unless @isSimulation
        organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)

        unless( organization? && organization.hasUser(arguments[0].update_user_id)? )
          throw new Meteor.Error 'userNotInOrganization', 'not authorized'

        arguments[0].organization = organization
      RUN.call(@, arguments[0])

    return methodOptions
