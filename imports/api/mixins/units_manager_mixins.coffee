OrganizationModule = require '../collections/organizations/organizations.coffee'
UnitModule = require '../collections/units/units.coffee'
#
module.exports.hasUnitsManagerPermission = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      organization = OrganizationModule.Organizations.findOne(_id: arguments[0].organization_id)
      unless organization?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      cuser = organization.hasUser(@userId)
      unless cuser?
        throw new Meteor.Error 'notAuthorized', 'not authorized'

      unless(cuser.permission.owner || cuser.permission.units_manager)
        throw new Meteor.Error 'notUnitsManager', 'only units managers can access this'

      arguments[0].organization = organization
    RUN.call(@, arguments[0])

  return methodOptions


module.exports.unitBelongsToOrgan = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      unit = UnitModule.Units.findOne(_id: arguments[0].unit_id)

      unless (unit? && unit.organization_id is arguments[0].organization_id)
        throw new Meteor.Error 'notAuthorized', 'not authorized'

    RUN.call(@, arguments[0])

  return methodOptions


module.exports.parentUnitBelongsToOrgan = (methodOptions) ->
  RUN = methodOptions.run
  methodOptions.run = () ->
    unless @isSimulation
      unless arguments[0].unit_doc.unit_id?
        return RUN.call(@, arguments[0])

      parent_unit = UnitModule.Units.findOne(_id: arguments[0].unit_doc.unit_id)

      unless(parent_unit? && parent_unit.organization_id is arguments[0].organization_id)
        throw new Meteor.Error 'notAuthorized', 'not authorized'

    RUN.call(@, arguments[0])


  return methodOptions
