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
  validate: ({receipt_doc}) ->
    ReceiptsModule.Receipts.simpleSchema().validate(receipt_doc)

  run: ({receipt_doc}) ->

    loggedIn(@userId)
    unless @isSimulation
      hasPermission(@userId, receipt_doc.organization_id, "expenses_manager")

    ReceiptsModule.Receipts.insert receipt_doc



# Remove
