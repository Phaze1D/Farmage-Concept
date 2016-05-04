
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'


UnitModule = require './units.coffee'
{
  loggedIn
  ownsOrganization
} = require '../../mixins/mixins.coffee'

{
  hasUnitsManagerPermission
  unitBelongsToOrgan
  parentUnitBelongsToOrgan
} = require '../../mixins/units_manager_mixins.coffee'


# insert
module.exports.insert = new ValidatedMethod
  name: 'units.insert'
  validate: ({organization_id, unit_doc}) ->
    UnitModule.Units.simpleSchema().validate(unit_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  mixins: [parentUnitBelongsToOrgan, hasUnitsManagerPermission, loggedIn]

  run: ({organization_id, unit_doc}) ->
    if UnitModule.Units.findOne( $and: [ { organization_id: organization_id }, {name: unit_doc.name} ] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

    unit_doc.organization_id = organization_id
    UnitModule.Units.insert unit_doc


# update
module.exports.update = new ValidatedMethod
  name: 'units.update'
  validate: ({organization_id, unit_id, unit_doc}) ->

    UnitModule.Units.simpleSchema().validate({$set: unit_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      unit_id:
        type: String
    ).validate({organization_id, unit_id})

  mixins: [parentUnitBelongsToOrgan, unitBelongsToOrgan, hasUnitsManagerPermission, loggedIn]

  run: ({organization_id, unit_id, unit_doc}) ->
    delete unit_doc.organization_id
    if UnitModule.Units.findOne( $and: [{_id: {$ne: unit_id }}, { organization_id: organization_id }, {name: unit_doc.name}] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

    UnitModule.Units.update unit_id,
                            $set: unit_doc
