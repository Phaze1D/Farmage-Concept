
OrganizationModule = require '../collections/organizations/organizations.coffee'

# Checks if user is logged in
module.exports.loggedIn = (methodOptions) ->
  RUN = methodOptions.run

  methodOptions.run = () ->
    unless @userId?
      throw new Meteor.Error 'notLoggedIn', 'Must be logged in'
    RUN.call(@, arguments[0])

  return methodOptions

# Checks if current user owns organization
module.exports.ownsOrganization = (methodOptions) ->
  RUN = methodOptions.run

  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id, user_ids: $elemMatch: user_id: @userId)
      if organization?
        permission = ( user.permission for user in organization.user_ids when user.user_id is @userId)
        if permission[0].owner
          arguments[0].organization = organization
          RUN.call(@, arguments[0])
        else
          throw new Meteor.Error 'notOwner', 'only owners can access this'
      else
        throw new Meteor.Error 'notAuthorized', 'not Authorized'


  return methodOptions
