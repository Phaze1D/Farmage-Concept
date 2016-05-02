OrganizationModule = require '../collections/organizations/organizations.coffee'
ProviderModule = require '../collections/providers/providers.coffee'
#
module.exports.hasExpensesManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)
      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      cuser = organization.hasUser(@userId)
      unless cuser?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      unless(cuser.permission.owner || cuser.permission.expenses_manager)
        throw new Meteor.Error 'notExpensesManager', 'only expenses managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions


#
module.exports.providerBelongsToOrgan = (methodOptions) ->
    RUN = methodOptions.run
    methodOptions.run = () ->
      unless @isSimulation
        provider = ProviderModule.Providers.findOne(_id: arguments[0].provider_id)

        unless (provider? && provider.organization_id is arguments[0].organization_id)
          throw new Meteor.Error 'notAuthorized', 'not authorized'

      RUN.call(@, arguments[0])

    return methodOptions
