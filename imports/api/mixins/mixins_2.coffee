OrganizationModule = require '../collections/organizations/organizations.coffee'

module.exports.loggedIn = (user_id) ->
  unless user_id?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


module.exports.hasPermission = (user_id, organization_id, type) ->
  unless @isSimulation
    organization = OrganizationModule.Organizations.findOne(_id: organization_id)
    unless organization?
      throw new Meteor.Error 'notAuthorized', 'not authorized'

    user = organization.hasUser(user_id)
    unless( user? && (user.permission[type] || user.permission["owner"]) )
      throw new Meteor.Error 'permissionDenied', 'permission denied'

    return organization


module.exports.userBelongsToOrgan = (user_id, organization_id) ->
  unless @isSimulation
    organization = OrganizationModule.Organizations.findOne(_id: organization_id)

    unless( organization? && organization.hasUser(user_id)? )
      throw new Meteor.Error 'notAuthorized', 'not authorized'



module.exports.unitBelongsToOrgan = (unit_id, organization_id) ->
  unless @isSimulation
    unit = UnitModule.Units.findOne(_id: unit_id)

    unless(unit? && unit.organization_id is organization_id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

    return unit


module.exports.customerBelongsToOrgan = (customer_id, organization_id) ->
  unless @isSimulation
    customer = CustomerModule.Customers.findOne(_id: customer_id)

    unless (customer? && customer.organization_id is organization_id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

    return customer



module.exports.productBelongsToOrgan = (product_id, organization_id) ->
  unless @isSimulation
    product = ProductModule.Products.findOne(_id: product_id)

    unless (product? && product.organization_id is organization_id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

    return product



module.exports.providerBelongsToOrgan = (provider_id, organization_id) ->
  unless @isSimulation
    provider = ProviderModule.Providers.findOne(_id: provider_id)

    unless (provider? && provider.organization_id is organization_id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'

    return provider
