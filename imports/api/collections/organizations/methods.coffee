{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

OrganizationModule = require './organizations.coffee'
ContactModule = require '../../shared/contact_info.coffee'

{
  loggedIn
  hasPermission
} = require '../../mixins/mixins.coffee'



###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###


# Insert
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: ({organization_doc}) ->
    OrganizationModule.Organizations.simpleSchema().clean(organization_doc)
    OrganizationModule.Organizations.simpleSchema().validate(organization_doc)

  run: ({organization_doc}) ->
    loggedIn(@userId)
    OrganizationModule.Organizations.insert organization_doc



# Update
module.exports.update = new ValidatedMethod
  name: 'organizations.update'
  validate: ({organization_id, organization_doc}) ->
    OrganizationModule.Organizations.simpleSchema().validate({$set: organization_doc}, modifier: true)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  run: ({organization_id, organization_doc}) ->

    loggedIn(@userId)

    unless @isSimulation
      hasPermission(@userId, organization_id, 'owner')

    delete organization_doc.ousers
    OrganizationModule.Organizations.update _id: organization_id,
                                            $set: organization_doc
