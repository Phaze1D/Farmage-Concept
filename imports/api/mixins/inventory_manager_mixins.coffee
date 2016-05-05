OrganizationModule = require '../collections/organizations/organizations.coffee'
ProductModule = require '../collections/customers/customers.coffee'
#
module.exports.hasInventoryManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)
      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      cuser = organization.hasUser(@userId)
      unless cuser?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      unless(cuser.permission.owner || cuser.permission.inventory_manager)
        throw new Meteor.Error 'notInventoryManager', 'only inventory managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions

module.exports.productBelongsToOrgan = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      product = ProductModule.Products.findOne(_id: arguments[0].product_id)

      unless (product? && product.organization_id is arguments[0].organization_id)
        throw new Meteor.Error 'notAuthorized', 'not authorized'

    RUN.call(@, arguments[0])

  return methodOptions
