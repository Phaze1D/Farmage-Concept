OrganizationModule = require '../collections/organizations/organizations.coffee'
CustomerModule = require '../collections/customers/customers.coffee'
#
module.exports.hasSellsManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)
      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      cuser = organization.hasUser(@userId)
      unless cuser?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      unless(cuser.permission.owner || cuser.permission.sells_manager)
        throw new Meteor.Error 'notSellsManager', 'only sells managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions


#
module.exports.customerBelongsToOrgan = (methodOptions) ->
    RUN = methodOptions.run
    methodOptions.run = () ->
      unless @isSimulation
        customer = CustomerModule.Customers.findOne(_id: arguments[0].customer_id)

        unless customer.organization_id is arguments[0].organization_id
          throw new Meteor.Error 'notAuthorized', 'not authorized'

      RUN.call(@, arguments[0])

    return methodOptions
