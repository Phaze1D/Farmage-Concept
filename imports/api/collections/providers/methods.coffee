
{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

ProviderModule  = require './providers.coffee'

{
  loggedIn
  ownsOrganization
} = require '../../mixins/mixins.coffee'
{
  hasExpensesManagerPermission
  providerBelongsToOrgan
} = require '../../mixins/expenses_manager_mixins.coffee'

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
  validate: ({organization_id, provider_doc}) ->
    ProviderModule.Providers.simpleSchema().validate(provider_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  mixins: [hasExpensesManagerPermission, loggedIn]

  run: ({organization_id, provider_doc}) ->
    provider_doc.organization_id = organization_id
    ProviderModule.Providers.insert provider_doc


# Update
module.exports.update = new ValidatedMethod
  name: 'providers.update'
  validate: ({organization_id, provider_id, provider_doc}) ->
    ProviderModule.Providers.simpleSchema().validate({$set: provider_doc}, modifier: true)

    new SimpleSchema(
      provider_id:
        type: String

      organization_id:
        type: String
    ).validate({provider_id, organization_id})

  mixins: [providerBelongsToOrgan, hasExpensesManagerPermission, loggedIn]

  run: ({organization_id, provider_id, provider_doc}) ->
    delete provider_doc.organization_id
    ProviderModule.Providers.update provider_id,
                                    $set: provider_doc
