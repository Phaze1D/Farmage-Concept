{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

ReceiptsModule = require './receipts.coffee'

{
  loggedIn
  hasPermission
} = require '../../mixins/mixins.coffee'


# Insert
module.exports.insert = new ValidatedMethod
  name: 'receipts.insert'
  validate: ({organization_id, receipt_doc}) ->
    ReceiptsModule.Receipts.simpleSchema().validate(receipt_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  run: ({organization_id, receipt_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, organization_id, "expenses_manager")

    receipt_doc.organization_id = organization_id
    ReceiptsModule.Receipts.insert receipt_doc



# Remove
