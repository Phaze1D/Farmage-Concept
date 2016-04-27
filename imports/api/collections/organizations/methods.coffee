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


# Insert
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: (organization_doc) ->
    OrganizationModule.Organizations.simpleSchema().validate(organization_doc)
    if OrganizationModule.Organizations.findOne(name: organization_doc.name)?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

  mixins: [loggedIn]

  run: (organization_doc) ->
    OrganizationModule.Organizations.insert organization_doc



# Update Name and/ or Email
module.exports.updateNameAndEmail = new ValidatedMethod
  name: 'organizations.updateNameAndEmail'
  validate: ({organization_id, updated_organization_doc}) ->
    OrganizationModule.Organizations.simpleSchema().validate(updated_organization_doc)
    if OrganizationModule.Organizations.findOne( {$and: [ { _id: {$ne: organization_id } }, {name: updated_organization_doc.name} ] })?
      throw new Meteor.Error 'nameNotUnique', 'name must be unqiue'

  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, updated_organization_doc}) ->
    OrganizationModule.Organizations.update _id: organization_id,
                                            $set:
                                              name: updated_organization_doc.name
                                              email: updated_organization_doc.email


# Add Address
module.exports.addAddress = new ValidatedMethod
  name: 'organizations.addAddress'
  validate: ({organization_id, address_doc}) ->
    ContactModule.AddressSchema.validate(address_doc)

  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, address_doc}) ->
    OrganizationModule.Organizations.update _id: organization_id,
                                                        $addToSet:
                                                          addresses: address_doc


# Delete Address
module.exports.deleteAddress = new ValidatedMethod
  name: 'organizations.deleteAddress'
  validate: ({organization_id, address_doc}) ->
    ContactModule.AddressSchema.validate(address_doc)

  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, address_doc}) ->
    OrganizationModule.Organizations.update _id: organization_id,
                                                        $pull:
                                                          addresses: address_doc

# Add Telephone
module.exports.addTelephone = new ValidatedMethod
  name: 'organizations.addTelephone'
  validate: ({organization_id, telephone_doc}) ->
    ContactModule.TelephoneSchema.validate(telephone_doc)
  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, telephone_doc}) ->
    OrganizationModule.Organizations.update _id: organization_id,
                                                        $addToSet:
                                                          telephones: telephone_doc


# Delete Telephone
module.exports.deleteTelephone = new ValidatedMethod
  name: 'organizations.deleteTelephone'
  validate: ({organization_id, telephone_doc}) ->
    ContactModule.TelephoneSchema.validate(telephone_doc)

  mixins: [ownsOrganization, loggedIn]

  run: ({organization_id, telephone_doc}) ->
    OrganizationModule.Organizations.update _id: organization_id,
                                                        $pull:
                                                          telephones: telephone_doc
