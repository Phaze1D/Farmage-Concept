{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'


YieldModule = require './yields.coffee'

{
  loggedIn
  hasPermission
  unitBelongsToOrgan
  yieldBelongsToOrgan
} = require '../../mixins/mixins.coffee'



# insert
module.exports.insert = new ValidatedMethod
  name: "yields.insert"
  validate: ({organization_id, yield_doc}) ->
    YieldModule.Yields.simpleSchema().clean(yield_doc)
    YieldModule.Yields.simpleSchema().validate(yield_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  run: ({organization_id, yield_doc}) ->
    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, "units_manager")
      unitBelongsToOrgan(yield_doc.unit_id, organization_id)

    delete yield_doc.amount
    yield_doc.organization_id = organization_id
    YieldModule.Yields.insert yield_doc

# update
module.exports.update = new ValidatedMethod
  name: "yields.update"
  validate: ({organization_id, yield_id, yield_doc}) ->
    YieldModule.Yields.simpleSchema().clean(yield_doc)
    YieldModule.Yields.simpleSchema().validate({$set: yield_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
      yield_id:
        type: String
    ).validate({organization_id, yield_id})

  run: ({organization_id, yield_id, yield_doc}) ->
    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "units_manager")
      yieldBelongsToOrgan(yield_id, organization_id)

    delete yield_doc.amount
    delete yield_doc.ingredient_name
    delete yield_doc.measurement_unit
    delete yield_doc.unit_id
    delete yield_doc.organization_id

    YieldModule.Yields.update yield_id,
                            $set: yield_doc



# user event
