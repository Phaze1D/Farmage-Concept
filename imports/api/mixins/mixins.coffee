
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
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)

      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      user = organization.hasUser(@userId)
      unless( user? && user.permission.owner )
        throw new Meteor.Error 'notOwner', 'only owners can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions
