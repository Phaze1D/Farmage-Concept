{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

OrganizationModule = require './organizations.coffee'
ContactModule = require '../../shared/contact_info.coffee'

{ loggedIn, ownsOrganization } = require '../../mixins/mixins.coffee'



###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###


# Insert (For unique names it will pass on the client side but fail on the server)
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: (organization_doc) ->
    OrganizationModule.Organizations.simpleSchema().clean(organization_doc)
    OrganizationModule.Organizations.simpleSchema().validate(organization_doc)

  mixins: [loggedIn]

  run: (organization_doc) ->
    OrganizationModule.Organizations.insert organization_doc



# Update Name and/ or Email
module.exports.update = new ValidatedMethod
  name: 'organizations.update'
  validate: ({organization_id, updated_organization_doc}) ->
    OrganizationModule.Organizations.simpleSchema().clean(updated_organization_doc)
    OrganizationModule.Organizations.simpleSchema().validate(updated_organization_doc)
    new SimpleSchema(
      organization_id:
        type: String
    ).validate({organization_id})

  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, updated_organization_doc}) ->

    OrganizationModule.Organizations.update _id: organization_id,
                                            $set:
                                              name: updated_organization_doc.name
                                              email: updated_organization_doc.email
                                              addresses: updated_organization_doc.addresses
                                              telephones: updated_organization_doc.telephones
