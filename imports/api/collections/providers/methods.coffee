
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

ProviderModule  = require './providers.coffee'

{
  loggedIn
  hasPermission
  providerBelongsToOrgan
} = require '../../mixins/mixins.coffee'

###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###

# Insert Provider
module.exports.insert = new ValidatedMethod
  name: 'providers.insert'
  validate: ({provider_doc}) ->
    ProviderModule.Providers.simpleSchema().validate(provider_doc)
  run: ({provider_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, provider_doc.organization_id, "expenses_manager")

    ProviderModule.Providers.insert provider_doc


# Update
module.exports.update = new ValidatedMethod
  name: 'providers.update'
  validate: ({organization_id, provider_id, provider_doc}) ->
    ProviderModule.Providers.simpleSchema().clean({$set: provider_doc}, {isModifier: true})
    ProviderModule.Providers.simpleSchema().validate({$set: provider_doc}, modifier: true)

    new SimpleSchema(
      provider_id:
        type: String

      organization_id:
        type: String
    ).validate({provider_id, organization_id})

  run: ({organization_id, provider_id, provider_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "expenses_manager")
      providerBelongsToOrgan(provider_id, organization_id)

    delete provider_doc.organization_id
    ProviderModule.Providers.update provider_id,
                                    $set: provider_doc
