
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'


UnitModule = require './units.coffee'

{
  loggedIn
  hasPermission
  unitBelongsToOrgan
} = require '../../mixins/mixins.coffee'


# insert
module.exports.insert = new ValidatedMethod
  name: 'units.insert'
  validate: ({unit_doc}) ->
    UnitModule.Units.simpleSchema().clean(unit_doc)
    UnitModule.Units.simpleSchema().validate(unit_doc)

  run: ({unit_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, unit_doc.organization_id, "units_manager")
      unitBelongsToOrgan(unit_doc.unit_id, unit_doc.organization_id) if unit_doc.unit_id?

    delete unit_doc.amount # User cannot insert unit amount via this method (defaults to 0)

    if UnitModule.Units.findOne( $and: [ { organization_id: unit_doc.organization_id }, {name: unit_doc.name} ] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

    UnitModule.Units.insert unit_doc


# update
module.exports.update = new ValidatedMethod
  name: 'units.update'
  validate: ({organization_id, unit_id, unit_doc}) ->
    unit_doc.unit_id = if unit_doc.unit_id? then unit_doc.unit_id else null
    UnitModule.Units.simpleSchema().validate({$set: unit_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      unit_id:
        type: String
    ).validate({organization_id, unit_id})

  run: ({organization_id, unit_id, unit_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "units_manager")
      unitBelongsToOrgan(unit_id, organization_id)
      unitBelongsToOrgan(unit_doc.unit_id, organization_id) if unit_doc.unit_id?
      loopProblem(unit_id, unit_doc.unit_id, organization_id)

    delete unit_doc.organization_id # Organization ID can't be update
    delete unit_doc.amount # User cannot update unit amount via this method

    if UnitModule.Units.findOne( $and: [{_id: {$ne: unit_id }}, { organization_id: organization_id }, {name: unit_doc.name}] )?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'


    UnitModule.Units.update unit_id,
                            $set: unit_doc


loopProblem = (child_id, parent_id, organization_id) ->
  current_id = parent_id
  while current_id?
    unit = unitBelongsToOrgan(current_id, organization_id)
    throw new Meteor.Error 'loopError', 'cannot be parent of itself' if child_id is current_id
    current_id = unit.unit_id
